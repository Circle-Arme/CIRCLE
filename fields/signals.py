from django.db.models.signals import post_save
from django.dispatch import receiver
<<<<<<< HEAD
from .models import Community
from ChatRoom.models import ChatRoom

@receiver(post_save, sender=Community)
def create_chatroom_for_community(sender, instance, created, **kwargs):
    if created:
        ChatRoom.objects.create(
            community=instance,
            name=f"Discussion Room",
            created_by=instance.created_by
        )
=======
from fields.models import Community
from ChatRoom.models import ChatRoom

@receiver(post_save, sender=Community)
def create_default_chat_rooms(sender, instance, created, **kwargs):
    if created:
        room_types = [
            ('discussion_general', 'النقاش العام'),
            ('discussion_advanced', 'النقاش المتقدم'),
            ('job_opportunities', 'فرص العمل'),
        ]
        for room_type, name in room_types:
            ChatRoom.objects.get_or_create(
                community=instance,
                type=room_type,
                defaults={
                    'name': name,
                    'created_by': instance.created_by  # لو كانت متوفرة
                }
            )
>>>>>>> 78439836091054e64c7c509bc55485550c515c0d
