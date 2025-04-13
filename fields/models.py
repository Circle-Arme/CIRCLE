from django.db import models
from django.conf import settings

class Field(models.Model):
    name = models.CharField(max_length=255)
    description = models.TextField(blank=True, null=True)
    image = models.ImageField(upload_to='field_images/', blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name

    class Meta:
        verbose_name = "Field"
        verbose_name_plural = "Fields"


class Community(models.Model):
    field = models.ForeignKey(Field, on_delete=models.CASCADE, related_name="communities")
    name = models.CharField(max_length=255, unique=True)
    image = models.ImageField(upload_to='community_images/', blank=True, null=True)  # 🔹 مضاف حديثاً
    created_at = models.DateTimeField(auto_now_add=True)
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL, null=True, blank=True, on_delete=models.SET_NULL, related_name="communities_created"
    )

    def __str__(self):
        return self.name

    class Meta:
        verbose_name = "Community"
        verbose_name_plural = "Communities"


class UserCommunity(models.Model):
    LEVEL_CHOICES = [
        ('beginner', 'Beginner'),
        ('advanced', 'Advanced'),
        ('both', 'Both'),
    ]

    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="user_communities")
    community = models.ForeignKey(Community, on_delete=models.CASCADE, related_name="memberships")
    level = models.CharField(max_length=20, choices=LEVEL_CHOICES, default='beginner')  # ✅ مضاف لتحديد مستوى المستخدم داخل المجتمع

    class Meta:
        unique_together = ('user', 'community')
        verbose_name = "User Community"
        verbose_name_plural = "User Communities"

    def __str__(self):
        return f"{self.user.username} in {self.community.name} ({self.level})"
