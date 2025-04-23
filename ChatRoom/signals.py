# ChatRoom/signals.py

from django.db.models.signals import post_save, post_delete
from django.dispatch import receiver
from .models import Like, Reply

# الحد الأدنى من اللايكات لترقية الرد
PROMOTE_THRESHOLD = 10

@receiver([post_save, post_delete], sender=Like)
def update_promotion(sender, instance, **kwargs):
    """
    عند إضافة أو حذف لايك، نتحقق من عدد اللايكات على الرد
    فإذا وصل أو تجاوز الـ PROMOTE_THRESHOLD نجعله مروجًا، وإلا نرفعه.
    """
    reply = instance.reply
    if reply:
        count = reply.stars.count()
        promoted = count >= PROMOTE_THRESHOLD
        if reply.is_promoted != promoted:
            reply.is_promoted = promoted
            reply.save(update_fields=['is_promoted'])
