from django.conf import settings
from django.contrib.auth import get_user_model
from django.db import models

class ChatRoom(models.Model):
    ROOM_TYPE_CHOICES = [
        ('discussion_general', 'General Discussion'),
        ('discussion_advanced', 'Advanced Discussion'),
        ('job_opportunities', 'Job Opportunities'),
    ]

    community = models.ForeignKey("fields.Community", on_delete=models.CASCADE, related_name="chat_rooms")
    type = models.CharField(max_length=30, choices=ROOM_TYPE_CHOICES, default='discussion_general')
    name = models.CharField(max_length=255)
    created_at = models.DateTimeField(auto_now_add=True)
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL, null=True, blank=True, on_delete=models.SET_NULL, related_name="created_chat_rooms"
    )

    class Meta:
        unique_together = ('community', 'type')

    def __str__(self):
        return f"{self.get_type_display()} room for {self.community.name}"


class Thread(models.Model):
    chat_room = models.ForeignKey(ChatRoom, on_delete=models.CASCADE, related_name="threads")
    title = models.CharField(max_length=255)
    details = models.TextField()
    created_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True)
    file_attachment = models.FileField(upload_to='thread_files/', null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    is_job_opportunity = models.BooleanField(default=False)
    job_type = models.CharField(max_length=100, null=True, blank=True)
    location = models.CharField(max_length=255, null=True, blank=True)
    salary = models.CharField(max_length=100, null=True, blank=True)

    def __str__(self):
        return f"Thread: {self.title}"


class Reply(models.Model):
    thread = models.ForeignKey(Thread, on_delete=models.CASCADE, related_name="replies")
    reply_text = models.TextField()
    created_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    parent_reply = models.ForeignKey('self', on_delete=models.CASCADE, null=True, blank=True, related_name="nested_replies")

    def __str__(self):
        return f"Reply to {self.thread.title} by {self.created_by}"

    class Meta:
        verbose_name = "Reply"
        verbose_name_plural = "Replies"


User = get_user_model()

class Like(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    thread = models.ForeignKey(Thread, null=True, blank=True, on_delete=models.CASCADE, related_name='stars')
    reply = models.ForeignKey(Reply, null=True, blank=True, on_delete=models.CASCADE, related_name='stars')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('user', 'thread', 'reply')

    def clean(self):
        from django.core.exceptions import ValidationError
        if not self.thread and not self.reply:
            raise ValidationError("يجب اختيار Thread أو Reply")
        if self.thread and self.reply:
            raise ValidationError("لا يمكن عمل Star على Thread وReply في نفس الوقت")

    def __str__(self):
        target = self.thread or self.reply
        return f"{self.user} starred {target}"
