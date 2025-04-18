# accounts/views_admin.py

from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from django.contrib.auth import get_user_model
from .serializers import UserProfileSerializer
from accounts.permissions import IsAdminUser
from rest_framework.permissions import IsAuthenticated

User = get_user_model()

@api_view(['PATCH'])
@permission_classes([IsAuthenticated, IsAdminUser])
def update_organization_user(request, user_id):
    try:
        user = User.objects.get(id=user_id, user_type='organization')
        profile = user.profile  # نفترض وجود علاقة OneToOne مع UserProfile
    except User.DoesNotExist:
        return Response({'error': 'المستخدم غير موجود'}, status=404)

    serializer = UserProfileSerializer(profile, data=request.data, partial=True)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data)
    return Response(serializer.errors, status=400)
