from django.db import models
from django.conf import settings

class Field(models.Model):
    name = models.CharField(max_length=255)
    description = models.TextField(blank=True, null=True)  # وصف المجال
    image = models.ImageField(upload_to='field_images/', blank=True, null=True)  # صورة المجال
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return self.name

    class Meta:
        verbose_name = "Field"
        verbose_name_plural = "Fields"


class Community(models.Model):
    field = models.ForeignKey(Field, on_delete=models.CASCADE, related_name="communities", default=1)  # كل مجتمع تابع لفيلد
    name = models.CharField(max_length=255, unique=True)
    created_at = models.DateTimeField(auto_now_add=True)
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL, null=True, blank=True, on_delete=models.SET_NULL, related_name="communities_created"
    )  # الأدمن الذي أنشأ المجتمع

    def __str__(self):
        return self.name

    class Meta:
        verbose_name = "Community"
        verbose_name_plural = "Communities"


class UserCommunity(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="user_communities")
    community = models.ForeignKey(Community, on_delete=models.CASCADE, related_name="memberships")

    class Meta:
        unique_together = ('user', 'community')  # منع الانضمام لنفس المجتمع أكثر من مرة
        verbose_name = "User Community"
        verbose_name_plural = "User Communities"

    def __str__(self):
        return f"{self.user.username} in {self.community.name}"


class ChatRoom(models.Model):
    community = models.ForeignKey(Community, on_delete=models.CASCADE, related_name="chat_rooms")  # إضافة العلاقة مع المجتمع
    name = models.CharField(max_length=255, unique=True)
    created_at = models.DateTimeField(auto_now_add=True)
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL, null=True, blank=True, on_delete=models.SET_NULL, related_name="chat_rooms_created"
    )  # الأدمن الذي أنشأ الغرفة

    def __str__(self):
        return self.name

    class Meta:
        verbose_name = "Chat Room"
        verbose_name_plural = "Chat Rooms"