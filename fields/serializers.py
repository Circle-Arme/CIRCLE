from rest_framework import serializers
from ChatRoom.serializers import ChatRoomSerializer
from .models import Field, Community, UserCommunity , ChatRoom

class FieldSerializer(serializers.ModelSerializer):
    class Meta:
        model = Field
        fields = '__all__'

class CommunitySerializer(serializers.ModelSerializer):
    chat_room = ChatRoomSerializer(read_only=True)  # تضمين الغرفة الحوارية في السيريالايزر
    class Meta:
        model = Community
        fields = '__all__'

class UserCommunitySerializer(serializers.ModelSerializer):
    class Meta:
        model = UserCommunity
        fields = '__all__'