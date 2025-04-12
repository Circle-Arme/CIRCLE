from rest_framework import serializers
from .models import ChatRoom, Thread, Reply, Like

class ChatRoomSerializer(serializers.ModelSerializer):
    class Meta:
        model = ChatRoom
        fields = ['id', 'community', 'name', 'created_at', 'created_by']

class ReplySerializer(serializers.ModelSerializer):
    likes_count = serializers.SerializerMethodField()

    class Meta:
        model = Reply
        fields = ['id','thread', 'reply_text', 'created_by', 'created_at', 'parent_reply', 'likes_count']

    def get_likes_count(self, obj):
        return obj.stars.count()  # تعديل: استخدام related_name='stars'

class ThreadSerializer(serializers.ModelSerializer):
    replies = ReplySerializer(many=True, read_only=True)
    replies_count = serializers.SerializerMethodField()
    likes_count = serializers.SerializerMethodField()

    class Meta:
        model = Thread
        fields = [
            'id', 'chat_room', 'title', 'details', 'created_by', 
            'file_attachment', 'created_at', 'replies', 
            'replies_count', 'likes_count', 'is_job_opportunity',
            'job_type', 'location', 'salary'
        ]

    def get_replies_count(self, obj):
        return obj.replies.count()

    def get_likes_count(self, obj):
        return obj.stars.filter(reply__isnull=True).count()  # تعديل: استخدام related_name='stars'

class LikeSerializer(serializers.ModelSerializer):
    class Meta:
        model = Like
        fields = ['id', 'user', 'thread', 'reply', 'created_at']
        read_only_fields = ['user', 'created_at']

    def validate(self, data):
        thread = data.get('thread')
        reply = data.get('reply')
        if not thread and not reply:
            raise serializers.ValidationError("يجب تحديد Thread أو Reply")
        if thread and reply:
            raise serializers.ValidationError("لا يمكن تحديد الاثنين معًا")
        return data

    def create(self, validated_data):
        validated_data['user'] = self.context['request'].user
        return super().create(validated_data)