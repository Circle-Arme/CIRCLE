# jobs/serializers.py
from rest_framework import serializers
from .models import JobOpportunity, JobReply

class JobReplySerializer(serializers.ModelSerializer):
    user = serializers.StringRelatedField(read_only=True)

    class Meta:
        model = JobReply
        fields = ['id', 'job', 'user', 'content', 'created_at']

class JobOpportunitySerializer(serializers.ModelSerializer):
    replies = JobReplySerializer(many=True, read_only=True)
    user = serializers.StringRelatedField(read_only=True)
    organization = serializers.StringRelatedField(read_only=True)

    class Meta:
        model = JobOpportunity
        fields = ['id', 'title', 'description', 'organization', 'user', 'community', 'posted_at', 'replies']
