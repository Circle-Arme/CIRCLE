# alerts/signals.py
from django.db import transaction
from django.db.models.signals import post_save
from django.dispatch import receiver

from asgiref.sync import async_to_sync
from channels.layers import get_channel_layer

from ChatRoom.models import Thread, Reply
from alerts.models import Alert
from alerts.serializers import AlertSerializer
from fields.models import UserCommunity          # ⭐️ استيراد جديد
layer = get_channel_layer()

# ──────────────────────────── helpers ──────────────────────────────
def _display_name(user) -> str:
    """
    Return a human-friendly name for notifications:
    1) full name  2) profile.name  3) e-mail
    """
    full = user.get_full_name()
    if full:
        return full.strip()
    if hasattr(user, "profile") and user.profile.name:
        return user.profile.name
    return user.email


def _push(alert: Alert) -> None:
    """
    Send alert to WebSocket group user_<id>.
    Executed after the DB commit is finished.
    """
    payload = AlertSerializer(alert).data
    async_to_sync(layer.group_send)(
        f"user_{alert.recipient_id}",
        {"type": "alert", "payload": payload},
    )


def _create_and_push(**kwargs) -> None:
    alert = Alert.objects.create(**kwargs)
    transaction.on_commit(lambda: _push(alert))


# ─────────────────────────── Reply signal ──────────────────────────
@receiver(post_save, sender=Reply)
def handle_reply_notifications(sender, instance: Reply, created, **kwargs):
    if not created:
        return

    thread       = instance.thread
    replier      = instance.created_by
    thread_owner = thread.created_by

    replier_name = _display_name(replier)

    # 1. Notify the thread owner (unless he is the replier)
    if thread_owner and thread_owner != replier:
        _create_and_push(
            recipient=thread_owner,
            type=Alert.REPLY,
            object_id=thread.id,
            message=f"{replier_name} replied to your thread: {thread.title}",
        )

    # 2. Extra notice for job-opportunity threads
    if thread.is_job_opportunity and thread_owner and thread_owner != replier:
        _create_and_push(
            recipient=thread_owner,
            type=Alert.REPLY,
            object_id=thread.id,
            message=f"{replier_name} commented on your job post: {thread.title}",
        )


# ────────────────────────── Thread signal ──────────────────────────


@receiver(post_save, sender=Thread)
def handle_thread_notifications(sender, instance: Thread, created, **kwargs):
    if not created:
        return

    poster      = instance.created_by
    poster_name = _display_name(poster) if poster else "Someone"

    community   = instance.chat_room.community

    # ­----------------------------------------------
    # **هنا كان سبب الخطأ**
    # members = community.members.exclude(id=getattr(poster, "id", None))
    # ­----------------------------------------------
    member_qs = (
        community.memberships        # <QuerySet في UserCommunity>
        .exclude(user_id=getattr(poster, "id", None))
        .select_related("user")      # لتجنب استعلام لكل مستخدم
    )
    recipients = [uc.user for uc in member_qs]
    # ­----------------------------------------------

    for user in recipients:
        _create_and_push(
            recipient=user,
            type=Alert.JOB if instance.is_job_opportunity else Alert.INFO,
            object_id=instance.id,
            message=(
                f"{poster_name} posted a new job opportunity: {instance.title}"
                if instance.is_job_opportunity
                else f"{poster_name} started a new thread: {instance.title}"
            ),
        )

