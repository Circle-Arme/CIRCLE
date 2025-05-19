# ChatRoom/realtime_signals.py
import json
from asgiref.sync import async_to_sync
from channels.layers import get_channel_layer
from django.db import transaction
from django.db.models.signals import post_save, post_delete
from django.dispatch import receiver

from .models import Thread, Reply, Like
from .serializers import ThreadSerializer, ReplySerializer


layer = get_channel_layer()

# ─────────────────── Helper ───────────────────
def _send(group: str, payload: dict):
    """
    نرسل دائماً بعد اكتمال الـcommit كي نتأكد من أن
    البيانات أصبحت في قاعدة البيانات فعلاً.
    """
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
    data  = ThreadSerializer(instance, context={"request": None}).data
    _send(group, {"type": event, "thread": data})

@receiver(post_delete, sender=Thread, dispatch_uid="thread_delete_broadcast")
def thread_deleted(sender, instance, **kwargs):
    group = f"community_{instance.chat_room.community_id}"
    _send(group, {"type": "thread_deleted", "id": instance.id})

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
    }
    _send(f"thread_{instance.thread_id}", payload)
    _send(f"community_{instance.thread.chat_room.community_id}", payload)


@receiver(post_delete, sender=Reply, dispatch_uid="reply_delete_broadcast")
def reply_deleted(sender, instance, **kwargs):
    thread_group    = f"thread_{instance.thread_id}"
    community_group = f"community_{instance.thread.chat_room.community_id}"   # ★

    replies = instance.thread.replies.count()  # بعد الحذف

    payload = {"type": "reply_deleted",
               "thread_id": instance.thread_id,
               "id": instance.id,
               "replies": replies}             # ★

    _send(thread_group,    payload)
    _send(community_group, payload)            # ★


# ─────────────────── Likes ───────────────────
@receiver([post_save, post_delete], sender=Like, dispatch_uid="like_toggle_broadcast")
def like_toggled(sender, instance, **kwargs):
    """
    نرسل حدثًا واحدًا سواء أُضيف أو حُذف اللايك.
    نحسب العدد الجديد بعد التغيير.
    """
    if instance.thread_id:
        target = instance.thread
        thread_group    = f"thread_{target.id}"
        community_group = f"community_{target.chat_room.community_id}"   # ★ جديد
        event  = "thread_like_toggled"
        likes  = target.stars.filter(reply__isnull=True).count()
        pk     = target.id

        payload = {"type": event, "id": pk, "likes": likes}

        _send(thread_group,    payload)      # كان موجودًا
        _send(community_group, payload)      # ★ أرسِل للغرفة أيضًا

    else:
        target = instance.reply
        thread_group = f"thread_{target.thread_id}"
        event  = "reply_like_toggled"
        likes  = target.stars.count()
        pk     = target.id
        _send(thread_group, {"type": event, "id": pk, "likes": likes})
