from rest_framework import serializers
from .models import ChatRoom, Thread, Reply


class ChatRoomSerializer(serializers.ModelSerializer):
    class Meta:
        model = ChatRoom
        fields = ['id', 'community', 'name', 'created_at', 'created_by']

class ReplySerializer(serializers.ModelSerializer):
    class Meta:
        model = Reply
        fields = ['id', 'reply_text', 'created_by', 'created_at', 'parent_reply']

class ThreadSerializer(serializers.ModelSerializer):
    replies = ReplySerializer(many=True, read_only=True)

    class Meta:
        model = Thread
        fields = ['id', 'chat_room', 'title', 'details', 'created_by', 'file_attachment', 'created_at', 'replies']