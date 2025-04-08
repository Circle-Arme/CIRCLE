from django.db.models.signals import post_save
from django.dispatch import receiver
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