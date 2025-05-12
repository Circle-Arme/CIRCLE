from rest_framework import serializers
from django.contrib.auth import get_user_model
from django.contrib.auth.hashers import make_password
<<<<<<< HEAD
=======
from .models import UserProfile
>>>>>>> 78439836091054e64c7c509bc55485550c515c0d

User = get_user_model()

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
<<<<<<< HEAD
        fields = ['id', 'username', 'email', 'phone', 'password']
=======
        fields = ['id', 'email', 'first_name', 'last_name', 'password', 'user_type']
>>>>>>> 78439836091054e64c7c509bc55485550c515c0d
        extra_kwargs = {'password': {'write_only': True}}

    def create(self, validated_data):
        validated_data['password'] = make_password(validated_data['password'])
        return super().create(validated_data)
<<<<<<< HEAD
=======


class UserProfileSerializer(serializers.ModelSerializer):
    id          = serializers.IntegerField(read_only=True)
    user        = serializers.PrimaryKeyRelatedField(read_only=True)
    communities = serializers.PrimaryKeyRelatedField(many=True, read_only=True)

    class Meta:
        model  = UserProfile
        fields = [
            'id',
            'user',
            'name',
            'work_education',
            'position',
            'description',
            'email',
            'communities',
            'website',               # ← ضُمَّ الحقل الجديد
            'avatar'
        ]


class OrgUserCreateSerializer(serializers.Serializer):
    """
    Serializer خاص بإنشاء مستخدم مؤسسة مع جميع حقول البروفايل.
    """
    email          = serializers.EmailField()
    password       = serializers.CharField(write_only=True)
    name           = serializers.CharField()
    work_education = serializers.CharField(allow_blank=True, required=False)
    position       = serializers.CharField(allow_blank=True, required=False)
    description    = serializers.CharField(allow_blank=True, required=False)
    website        = serializers.URLField(allow_blank=True, required=False)

    def create(self, validated_data):
        full_name = validated_data.pop('name').strip()
        parts     = full_name.split(' ', 1)
        first_name = parts[0]
        last_name  = parts[1] if len(parts) > 1 else ''

        user = User.objects.create_user(
            email      = validated_data['email'],
            password   = validated_data['password'],
            first_name = first_name,
            last_name  = last_name,
            user_type  = 'organization'
        )
        # حدّث البروفايل التلقائي
        profile = user.profile
        profile.name           = full_name
        profile.work_education = validated_data.get('work_education', '')
        profile.position       = validated_data.get('position', '')
        profile.description    = validated_data.get('description', '')
        profile.email          = user.email
        profile.website        = validated_data.get('website', '')
        profile.save()
        return user
>>>>>>> 78439836091054e64c7c509bc55485550c515c0d
