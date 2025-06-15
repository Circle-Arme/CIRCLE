from django.db import models
from django.contrib.auth import get_user_model

User = get_user_model()

class Alert(models.Model):
    INFO  = "info"
    WARN  = "warn"
    JOB   = "job"
    REPLY = "reply"
    TYPES = [(INFO, "Info"), (WARN, "Warning"), (JOB, "Job post"), (REPLY, "Reply")]

    recipient   = models.ForeignKey(User, on_delete=models.CASCADE, related_name="alerts")
    type        = models.CharField(max_length=10, choices=TYPES, default=INFO)
    # optional payload id (thread id, reply id …)
    object_id   = models.PositiveIntegerField(null=True, blank=True)
    message     = models.TextField()
    created_at  = models.DateTimeField(auto_now_add=True)
    is_read     = models.BooleanField(default=False)

    class Meta:
        indexes = [
            models.Index(fields=["recipient", "is_read", "-created_at"]),
        ]
        ordering = ["-created_at"]
