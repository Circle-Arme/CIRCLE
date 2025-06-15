# accounts/views.py
from rest_framework import status
from rest_framework.response import Response
from rest_framework.decorators import (
    api_view,
    permission_classes,
    parser_classes,      # ⬅️ لاستعمال MultiPartParser / FormParser
)
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework import generics, permissions
from rest_framework.parsers import MultiPartParser, FormParser, JSONParser

from django.contrib.auth import get_user_model

from .serializers import UserSerializer, UserProfileSerializer
from .models import UserProfile

User = get_user_model()

# ------------------------------------------------------------------
# 1) المصادقة والتسجيل
# ------------------------------------------------------------------
@api_view(['POST'])
@permission_classes([AllowAny])
def login_api(request):
    email = request.data.get('email')
    password = request.data.get('password')

    try:
        user = User.objects.get(email=email)
    except User.DoesNotExist:
        return Response({'error': 'البريد الإلكتروني أو كلمة المرور غير صحيحة'}, status=400)

    if not user.check_password(password):
        return Response({'error': 'البريد الإلكتروني أو كلمة المرور غير صحيحة'}, status=400)

    refresh = RefreshToken.for_user(user)
    profile  = UserProfileSerializer(user.profile).data
    return Response({
        'refresh': str(refresh),
        'access': str(refresh.access_token),
        'user': UserSerializer(user).data,
        "profile": profile,   
    })


@api_view(['POST'])
@permission_classes([AllowAny])
def register_api(request):
    email = request.data.get('email')
    password = request.data.get('password')
    full_name = request.data.get('full_name', '')

    first_name, last_name = '', ''
    if full_name:
        parts = full_name.strip().split(' ', 1)
        first_name = parts[0]
        if len(parts) > 1:
            last_name = parts[1]

    if User.objects.filter(email=email).exists():
        return Response({'error': 'البريد الإلكتروني مأخوذ بالفعل'}, status=400)

    user = User.objects.create_user(
        email=email,
        password=password,
        first_name=first_name,
        last_name=last_name,
        user_type='normal',
    )
    return Response({'message': 'تم إنشاء الحساب بنجاح!'}, status=201)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def protected_view(request):
    return Response({'message': f'مرحبًا {request.user.email}, هذه صفحة محمية!'})


# ------------------------------------------------------------------
# 2) بروفايل المستخدم الحالي
# ------------------------------------------------------------------
class UserProfileDetailView(generics.RetrieveUpdateAPIView):
    """
    GET /api/accounts/profile/   → جلب بيانات البروفايل
    PATCH /api/accounts/profile/ → تحديث جزئي (نصوص + صورة معاً)
    """
    serializer_class = UserProfileSerializer
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser, JSONParser]  # يدعم JSON + ملفات

    def get_object(self):
        return self.request.user.profile

    # نجعل كل التحديثات جزئية حتى مع PATCH/PUT
    def get_serializer(self, *args, **kwargs):
        kwargs['partial'] = True
        return super().get_serializer(*args, **kwargs)

# ------------------------------------------------------------------
# 3) بروفايل عام لأي مستخدم بالـ ID
# ------------------------------------------------------------------
class PublicUserProfileView(generics.RetrieveAPIView):
    """
    GET /api/accounts/profile/<user_id>/ لجلب ملف البروفايل لأي مستخدم.
    """
    queryset = UserProfile.objects.select_related('user')
    serializer_class = UserProfileSerializer
    permission_classes = [permissions.IsAuthenticated]   # بدّل إلى AllowAny إن أردت
    lookup_field = 'user__id'
    lookup_url_kwarg = 'user_id'

# ------------------------------------------------------------------
# 4) رفع الصورة فقط (بدون النصوص) – أبقِه إن أردت Endpoint منفصل
# ------------------------------------------------------------------
@api_view(['POST'])
@permission_classes([IsAuthenticated])
@parser_classes([MultiPartParser, FormParser])
def upload_avatar(request):
    """
    POST /api/accounts/profile/upload-avatar/
    body: multipart/form-data { avatar: <file> }
    """
    image = request.data.get('avatar')
    if not image:
        return Response({'error': 'الملف avatar مفقود'}, status=400)

    profile = request.user.profile
    profile.avatar = image
    profile.save(update_fields=['avatar'])

    return Response({
        'avatar': request.build_absolute_uri(profile.avatar.url)
    })

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def change_password(request):
    """
    POST /api/accounts/change-password/
    Body: { old_password, new_password }
    """
    user = request.user
    old = request.data.get('old_password')
    new = request.data.get('new_password')

    if not old or not new:
        return Response(
            {'error': 'يجب إرسال old_password و new_password'},
            status=status.HTTP_400_BAD_REQUEST
        )

    if not user.check_password(old):
        return Response(
            {'error': 'كلمة المرور القديمة غير صحيحة'},
            status=status.HTTP_400_BAD_REQUEST
        )

    user.set_password(new)
    user.save()
    return Response({'message': 'تم تغيير كلمة المرور بنجاح'})