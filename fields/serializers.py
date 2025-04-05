from rest_framework import serializers
from .models import Field, Community, UserCommunity, ChatRoom

class FieldSerializer(serializers.ModelSerializer):
    class Meta:
        model = Field
        fields = '__all__'

class CommunitySerializer(serializers.ModelSerializer):
    class Meta:
        model = Community
        fields = '__all__'

class UserCommunitySerializer(serializers.ModelSerializer):
    class Meta:
        model = UserCommunity
        fields = '__all__'

class ChatRoomSerializer(serializers.ModelSerializer):
    class Meta:
        model = ChatRoom
        fields = ['id', 'community', 'name', 'created_at', 'created_by']