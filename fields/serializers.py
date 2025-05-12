from rest_framework import serializers
<<<<<<< HEAD
from ChatRoom.serializers import ChatRoomSerializer
from .models import Field, Community, UserCommunity , ChatRoom
=======
from .models import Field, Community, UserCommunity
>>>>>>> 78439836091054e64c7c509bc55485550c515c0d

class FieldSerializer(serializers.ModelSerializer):
    class Meta:
        model = Field
        fields = '__all__'

class CommunitySerializer(serializers.ModelSerializer):
<<<<<<< HEAD
    chat_room = ChatRoomSerializer(read_only=True)  # تضمين الغرفة الحوارية في السيريالايزر
    class Meta:
        model = Community
        fields = '__all__'

class UserCommunitySerializer(serializers.ModelSerializer):
    class Meta:
        model = UserCommunity
        fields = '__all__'
=======
    image = serializers.ImageField(required=False, allow_null=True)
    level = serializers.SerializerMethodField()

    class Meta:
        model = Community
        fields = '__all__'
    
    def validate_name(self, value):
        if Community.objects.filter(name=value).exists():
            raise serializers.ValidationError("اسم المجتمع موجود بالفعل.")
        return value
    
    def validate_field(self, value):
        if not Field.objects.filter(id=value.id).exists():
            raise serializers.ValidationError("المجال غير موجود.")
        return value

    def get_level(self, obj):
        user = self.context['request'].user
        if not user.is_authenticated:
            return None
        uc = obj.memberships.filter(user=user).first()
        return uc.level if uc else None

class UserCommunitySerializer(serializers.ModelSerializer):
    community = CommunitySerializer(read_only=True)
    
    class Meta:
        model = UserCommunity
        fields = '__all__'
>>>>>>> 78439836091054e64c7c509bc55485550c515c0d
