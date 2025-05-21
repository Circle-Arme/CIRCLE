from django.db import models
from django.contrib.auth import get_user_model

User = get_user_model()

class Alert(models.Model):
    recipient = models.ForeignKey(User, on_delete=models.CASCADE, related_name='alerts')  # المستخدم الذي يستقبل الإشعار
    message = models.TextField()  # نص الإشعار
    created_at = models.DateTimeField(auto_now_add=True)  # وقت إنشاء الإشعار
    is_read = models.BooleanField(default=False)  # لتحديد ما إذا تم قراءة الإشعار أم لا

    def __str__(self):
        return f"To {self.recipient.username}: {self.message[:20]}"
