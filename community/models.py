from django.db import models

class Community(models.Model):
    community_id = models.AutoField(primary_key=True)
    created_at = models.DateTimeField(auto_now_add=True)
    name = models.CharField(max_length=150, unique=True)
    description = models.TextField(blank=True, null=True)

    # field = models.ForeignKey('field.Field', on_delete=models.CASCADE, related_name='communities')
    # members = models.ManyToManyField('auth.User', related_name='communities')
    # discussion_room = models.TextField(blank=True, null=True)
    # jobs_room = models.TextField(blank=True, null=True)

    def __str__(self):
        return self.name
