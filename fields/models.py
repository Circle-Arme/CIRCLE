from django.db import models
from django.conf import settings
<<<<<<< HEAD
from ChatRoom.models import ChatRoom

class Field(models.Model):
    name = models.CharField(max_length=255)
    description = models.TextField(blank=True, null=True)  # وصف المجال
    image = models.ImageField(upload_to='field_images/', blank=True, null=True)  # صورة المجال
    created_at = models.DateTimeField(auto_now_add=True)
    
=======

class Field(models.Model):
    name = models.CharField(max_length=255)
    description = models.TextField(blank=True, null=True)
    image = models.ImageField(upload_to='field_images/', blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)

>>>>>>> 78439836091054e64c7c509bc55485550c515c0d
    def __str__(self):
        return self.name

    class Meta:
        verbose_name = "Field"
        verbose_name_plural = "Fields"


class Community(models.Model):
<<<<<<< HEAD
    field = models.ForeignKey(Field, on_delete=models.CASCADE, related_name="communities", default=1)  # كل مجتمع تابع لفيلد
    name = models.CharField(max_length=255, unique=True)
    created_at = models.DateTimeField(auto_now_add=True)
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL, null=True, blank=True, on_delete=models.SET_NULL, related_name="communities_created"
    )  # الأدمن الذي أنشأ المجتمع
    # chat_room = models.OneToOneField('ChatRoom.ChatRoom', on_delete=models.CASCADE, related_name='community', null=True, blank=True)

=======
    field = models.ForeignKey(Field, on_delete=models.CASCADE, related_name="communities")
    name = models.CharField(max_length=255, unique=True)
    image = models.ImageField(upload_to='community_images/', blank=True, null=True)  # 🔹 مضاف حديثاً
    created_at = models.DateTimeField(auto_now_add=True)
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL, null=True, blank=True, on_delete=models.SET_NULL, related_name="communities_created"
    )
>>>>>>> 78439836091054e64c7c509bc55485550c515c0d

    def __str__(self):
        return self.name

    class Meta:
        verbose_name = "Community"
        verbose_name_plural = "Communities"


class UserCommunity(models.Model):
<<<<<<< HEAD
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="user_communities")
    community = models.ForeignKey(Community, on_delete=models.CASCADE, related_name="memberships")

    class Meta:
        unique_together = ('user', 'community')  # منع الانضمام لنفس المجتمع أكثر من مرة
=======
    LEVEL_CHOICES = [
        ('beginner', 'Beginner'),
        ('advanced', 'Advanced'),
        ('both', 'Both'),
        ('job_only','Job Only'),
    ]

    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="user_communities")
    community = models.ForeignKey(Community, on_delete=models.CASCADE, related_name="memberships")
    level = models.CharField(max_length=20, choices=LEVEL_CHOICES, default='beginner')  # ✅ مضاف لتحديد مستوى المستخدم داخل المجتمع

    class Meta:
        unique_together = ('user', 'community')
>>>>>>> 78439836091054e64c7c509bc55485550c515c0d
        verbose_name = "User Community"
        verbose_name_plural = "User Communities"

    def __str__(self):
<<<<<<< HEAD
        return f"{self.user.username} in {self.community.name}"
=======
        return f"{self.user.username} in {self.community.name} ({self.level})"
>>>>>>> 78439836091054e64c7c509bc55485550c515c0d
