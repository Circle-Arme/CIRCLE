"""
ChatRoom & friends
------------------
• حرصنا على ألّا نحذف أي حقل مستخدم حاليًا في الواجهة الأمامية.
• أضفنا قيودًا وفهارس لتحسين السلامة والأداء.
"""

from django.conf import settings
from django.contrib.auth import get_user_model
from django.db import models
from django.utils import timezone

User = get_user_model()


# ──────────────────────────── helpers ────────────────────────────
def thread_upload_path(instance: "Thread", filename: str) -> str:
    """رفع ملفات الـThread داخل مجلد فرعي لكل مجتمع لتسهيل الإدارة."""
    cid = instance.chat_room.community_id
    return f"thread_files/community_{cid}/{filename}"


def reply_upload_path(instance: "Reply", filename: str) -> str:
    tid = instance.thread_id
    return f"reply_files/thread_{tid}/{filename}"


# ───────────────────────────── models ─────────────────────────────
class ChatRoom(models.Model):
    ROOM_TYPE_CHOICES = [
        ("discussion_general", "General Discussion"),
        ("discussion_advanced", "Advanced Discussion"),
        ("job_opportunities", "Job Opportunities"),
    ]

    community   = models.ForeignKey(
        "fields.Community",
        on_delete=models.CASCADE,
        related_name="chat_rooms",
    )
    type        = models.CharField(max_length=30, choices=ROOM_TYPE_CHOICES, default="discussion_general")
    name        = models.CharField(max_length=255)
    created_at  = models.DateTimeField(auto_now_add=True)
    created_by  = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        null=True, blank=True,
        on_delete=models.SET_NULL,
        related_name="created_chat_rooms",
    )

    class Meta:
        unique_together = ("community", "type")          # ↔ لا يتغيّر على الـFrontend
        ordering = ["-created_at"]
        indexes  = [
            models.Index(fields=["community", "type"]),
        ]

    def __str__(self) -> str:        # pragma: no cover
        return f"{self.get_type_display()} room for {self.community.name}"


class Thread(models.Model):
    chat_room   = models.ForeignKey(ChatRoom, on_delete=models.CASCADE, related_name="threads")
    title       = models.CharField(max_length=255)
    details     = models.TextField()
    created_by  = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True)
    file_attachment = models.FileField(upload_to=thread_upload_path, null=True, blank=True)

    created_at  = models.DateTimeField(auto_now_add=True)

    # حقول فرص العمل (غير مؤثرة على الواجهة)
    is_job_opportunity = models.BooleanField(default=False)
    job_type     = models.CharField(max_length=100, null=True, blank=True)
    location     = models.CharField(max_length=255, null=True, blank=True)
    salary       = models.CharField(max_length=100, null=True, blank=True)

    classification = models.CharField(max_length=100, default="General")
    tags           = models.JSONField(default=list, blank=True)

    class Meta:
        ordering = ["-created_at"]
        indexes  = [
            models.Index(fields=["chat_room", "-created_at"]),
        ]

    def __str__(self) -> str:        # pragma: no cover
        return f"Thread: {self.title}"


class Reply(models.Model):
    thread       = models.ForeignKey(Thread, on_delete=models.CASCADE, related_name="replies")
    reply_text   = models.TextField()
    created_by   = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True)
    created_at   = models.DateTimeField(auto_now_add=True)

    parent_reply = models.ForeignKey(
        "self", on_delete=models.CASCADE,
        null=True, blank=True, related_name="nested_replies",
    )
    file         = models.FileField(upload_to=reply_upload_path, null=True, blank=True)

    is_promoted  = models.BooleanField(default=False)   # ← يُحدَّث بالسيجنال

    class Meta:
        verbose_name        = "Reply"
        verbose_name_plural = "Replies"
        ordering            = ["created_at"]
        indexes             = [
            models.Index(fields=["thread", "created_at"]),
        ]

    def __str__(self) -> str:        # pragma: no cover
        return f"Reply to {self.thread.title} by {self.created_by}"


class Like(models.Model):
    """
    يمكن للمستخدم أن يُعجب إمّا بثريد أو بردّ (واحد فقط).
    """
    user       = models.ForeignKey(User,   on_delete=models.CASCADE)
    thread     = models.ForeignKey(Thread, on_delete=models.CASCADE, null=True, blank=True, related_name="stars")
    reply      = models.ForeignKey(Reply,  on_delete=models.CASCADE, null=True, blank=True, related_name="stars")
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=['user', 'thread'],
                condition=models.Q(reply__isnull=True),
                name='uniq_user_thread_like',
            ),
            models.UniqueConstraint(
                fields=['user', 'reply'],
                condition=models.Q(thread__isnull=True),
                name='uniq_user_reply_like',
            ),
            models.CheckConstraint(          # موجود سابقًا
                name='like_target_xor',
                check=(
                    models.Q(thread__isnull=False, reply__isnull=True) |
                    models.Q(thread__isnull=True,  reply__isnull=False)
                ),
            ),
        ]
        indexes = [models.Index(fields=["user", "-created_at"])]

    # لا نحتاج clean() بعد الآن لأن القيد أعلاه يحمينا على مستوى DB
    def __str__(self) -> str:        # pragma: no cover
        target = self.thread or self.reply
        return f"{self.user} starred {target}"


# إبقاء إشارات الترقية كما هي
from . import signals  # noqa: E402  (يجب أن يبقى في آخر الملف)
