from rest_framework import serializers
from .models import Community
# from field.models import Field
from django.contrib.auth.models import User

class CommunitySerializer(serializers.ModelSerializer):
    field = serializers.SlugRelatedField(
        # queryset=Field.objects.all(), slug_field='name'
    )
    members = serializers.SlugRelatedField(
        queryset=User.objects.all(), slug_field='username', many=True
    )
    
    class Meta:
        model = Community
        fields = ['community_id', 'field', 'name', 'description', 'members', 'discussion_room', 'jobs_room', 'created_at']
