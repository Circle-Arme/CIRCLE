from django.db import models
from accounts.models import CustomUser
from fields.models import Community
from organizations.models import Organization  # تأكد من اسم التطبيق الصحيح

class JobOpportunity(models.Model):
    title = models.CharField(max_length=255)
    description = models.TextField()
    organization = models.ForeignKey(Organization, on_delete=models.SET_NULL, null=True, blank=True)
    user = models.ForeignKey(CustomUser, on_delete=models.SET_NULL, null=True, blank=True)
    community = models.ForeignKey(Community, on_delete=models.CASCADE)
    posted_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title


class JobReply(models.Model):
    job = models.ForeignKey(JobOpportunity, on_delete=models.CASCADE, related_name='replies')
    user = models.ForeignKey('accounts.CustomUser', on_delete=models.CASCADE)
    content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"رد من {self.user.username} على {self.job.title}"
