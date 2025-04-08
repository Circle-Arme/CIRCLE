from django.db import models
from fields.models import Community

class Organization(models.Model):
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    website = models.URLField(blank=True, null=True)
    communities = models.ManyToManyField(Community, related_name='organizations')  # المجتمعات التي تنتمي لها المؤسسة

    def __str__(self):
        return self.name
