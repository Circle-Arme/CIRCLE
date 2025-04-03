from django.conf import settings
from django.db import models

class Field(models.Model):
    field_id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=100, unique=True)
    description = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,  # ربط مع جدول المستخدمين
        on_delete=models.CASCADE,
        default=1  # ضع ID لمستخدم أدمن موجود في قاعدة البيانات
    )

    def __str__(self):
        return self.name
