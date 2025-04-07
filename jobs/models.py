from django.db import models

class Organization(models.Model):
    name = models.CharField(max_length=255)

    def __str__(self):
        return self.name

class JobOpportunity(models.Model):
    title = models.CharField(max_length=255)
    description = models.TextField()
    organization = models.ForeignKey(Organization, on_delete=models.CASCADE, null=True, blank=True)
    posted_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title
