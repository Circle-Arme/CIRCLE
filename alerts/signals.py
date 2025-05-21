from django.db.models.signals import post_save
from django.dispatch import receiver
from ChatRoom.models import Reply, Thread
from alerts.models import Alert
from django.contrib.auth import get_user_model

User = get_user_model()


@receiver(post_save, sender=Reply)
def handle_reply_notifications(sender, instance, created, **kwargs):
    if not created:
        return

    thread = instance.thread
    replier = instance.created_by
    thread_owner = thread.created_by

    #  1. إشعار لصاحب الثريد عند وجود رد جديد (إذا لم يكن هو المجيب)
    if thread_owner != replier:
        Alert.objects.create(
            recipient=thread_owner,
            message=f"{replier.username} قام بالرد على الثريد الخاص بك: {thread.title}"
        )

    #  2. إذا كانت الثريد عبارة عن فرصة عمل، إشعار لصاحب الفرصة
    if thread.is_job_opportunity and thread.created_by != replier:
        Alert.objects.create(
            recipient=thread.created_by,
            message=f"{replier.username} قام بالرد على فرصة العمل الخاصة بك: {thread.title}"
        )


@receiver(post_save, sender=Thread)
def handle_job_post_notifications(sender, instance, created, **kwargs):
    if not created:
        return

    if instance.is_job_opportunity:
        job_poster = instance.created_by
        community = instance.chat_room.community

        # استبعاد ناشر الفرصة من الإشعارات
        members_to_notify = community.members.exclude(id=job_poster.id)

        for user in members_to_notify:
            Alert.objects.create(
                recipient=user,
                message=f"{job_poster.username} قام بنشر فرصة عمل جديدة في مجتمعك: {instance.title}"
            )
