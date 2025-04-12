from rest_framework import serializers
from .models import Field, Community, UserCommunity

class FieldSerializer(serializers.ModelSerializer):
    class Meta:
        model = Field
        fields = '__all__'

class CommunitySerializer(serializers.ModelSerializer):
    image = serializers.ImageField(read_only=True)  # 🔹 لإرجاع رابط الصورة
    level = serializers.CharField(read_only=True)

    class Meta:
        model = Community
        fields = '__all__'

class UserCommunitySerializer(serializers.ModelSerializer):
    community = CommunitySerializer(read_only=True)
    
    class Meta:
        model = UserCommunity
        fields = '__all__'
