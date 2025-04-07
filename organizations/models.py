from django.db import models

class Organization(models.Model):
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    website = models.URLField(blank=True, null=True)

    def __str__(self):
        return self.name
