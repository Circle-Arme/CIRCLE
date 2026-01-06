import json
from asgiref.sync import async_to_sync
from channels.layers import get_channel_layer
from django.db import transaction
from django.db.models.signals import post_save, post_delete
from django.dispatch import receiver
from django.contrib.auth import get_user_model

from .models import Thread, Reply, Like
from .serializers import ThreadSerializer, ReplySerializer

User = get_user_model()
layer = get_channel_layer()

# ─────────────────── Helper ───────────────────
def _send(group: str, payload: dict):
    transaction.on_commit(
        lambda: async_to_sync(layer.group_send)(
            group,
            {"type": "broadcast", "payload": payload},
        )
    )

# ─────────────────── Threads ───────────────────
@receiver(post_save, sender=Thread, dispatch_uid="thread_save_broadcast")
def thread_saved(sender, instance, created, **kwargs):
    group = f"community_{instance.chat_room.community_id}"
    event = "thread_created" if created else "thread_updated"
    data = ThreadSerializer(instance, context={"request": None}).data
    _send(group, {"type": event, "thread": data, "room_type": instance.chat_room.type})  # ★ إضافة room_type

@receiver(post_delete, sender=Thread, dispatch_uid="thread_delete_broadcast")
def thread_deleted(sender, instance, **kwargs):
    group = f"community_{instance.chat_room.community_id}"
    _send(group, {
        "type": "thread_deleted",
        "id": instance.id,
        "room_type": instance.chat_room.type  # ★ إضافة room_type
    })

# ─────────────────── Replies ───────────────────
@receiver(post_save, sender=Reply, dispatch_uid="reply_save_broadcast")
def reply_saved(sender, instance, created, **kwargs):
    if not created:
        return 
    print("### SIGNAL: reply_saved fired ###")
    replies = instance.thread.replies.count()
    payload = {
        "type": "reply_added",
        "thread_id": instance.thread_id,
        "replies": replies,
        "reply": ReplySerializer(instance, context={"request": None}).data,
        "room_type": instance.thread.chat_room.type  # ★ إضافة room_type
    }
    _send(f"thread_{instance.thread_id}", payload)
    _send(f"community_{instance.thread.chat_room.community_id}", payload)

@receiver(post_delete, sender=Reply, dispatch_uid="reply_delete_broadcast")
def reply_deleted(sender, instance, **kwargs):
    thread_group = f"thread_{instance.thread_id}"
    community_group = f"community_{instance.thread.chat_room.community_id}"
    replies = instance.thread.replies.count()
    payload = {
        "type": "reply_deleted",
        "thread_id": instance.thread_id,
        "id": instance.id,
        "replies": replies,
        "room_type": instance.thread.chat_room.type  # ★ إضافة room_type
    }
    _send(thread_group, payload)
    _send(community_group, payload)

# ─────────────────── Likes ───────────────────
@receiver([post_save, post_delete], sender=Like, dispatch_uid="like_toggle_broadcast")
def like_toggled(sender, instance, **kwargs):
    # تجاهل الإشارة إذا لم يعد هناك هدف
    if instance.thread_id is None and instance.reply_id is None:
        return

    user = instance.user

    # فرع الـ Thread
    if instance.thread_id is not None:
        try:
            t = instance.thread
            room_type    = t.chat_room.type
            community_id = t.chat_room.community_id
            likes        = t.stars.filter(reply__isnull=True).count()
            liked_by_me  = t.stars.filter(user=user, reply__isnull=True).exists()
        except Thread.DoesNotExist:
            return

        payload = {
            "type":         "thread_like_toggled",
            "id":           t.id,
            "likes":        likes,
            "liked_by_me":  liked_by_me,
            "room_type":    room_type,
        }
        _send(f"thread_{t.id}",        payload)
        _send(f"community_{community_id}", payload)
        return

    # فرع الـ Reply
    if instance.reply_id is not None:
        try:
            r = instance.reply
            t = r.thread
            room_type   = t.chat_room.type
            likes       = r.stars.count()
            liked_by_me = r.stars.filter(user=user).exists()
        except (Reply.DoesNotExist, Thread.DoesNotExist):
            return

        payload = {
            "type":        "reply_like_toggled",
            "id":          r.id,
            "likes":       likes,
            "liked_by_me": liked_by_me,
            "room_type":   room_type,
        }
        _send(f"thread_{r.thread_id}", payload)
