from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.contrib.auth import get_user_model

from accounts.permissions import IsAdminUser
from .models import UserProfile
from .serializers import (
    OrgUserCreateSerializer,
    UserProfileSerializer,
)

User = get_user_model()

@api_view(['GET'])
@permission_classes([IsAuthenticated, IsAdminUser])
def list_organization_users(request):
    """
    GET /api/accounts/admin/org-users/
    يرجع جميع بروفايلات المستخدمين من نوع 'organization'
    """
    profiles  = UserProfile.objects.filter(
                    user__user_type='organization'
                ).select_related('user')
    serializer = UserProfileSerializer(profiles, many=True)
    return Response(serializer.data)


@api_view(['POST'])
@permission_classes([IsAuthenticated, IsAdminUser])
def create_organization_user(request):
    """
    POST /api/accounts/admin/create-org-user/
    ينشئ مستخدم مؤسسة + بروفايله بكل الحقول (name, work_education, position, description, website).
    """
    serializer = OrgUserCreateSerializer(data=request.data)
    if serializer.is_valid():
        user    = serializer.save()
        profile = user.profile
        output  = UserProfileSerializer(profile)
        return Response(output.data, status=201)
    return Response(serializer.errors, status=400)


@api_view(['PATCH'])
@permission_classes([IsAuthenticated, IsAdminUser])
def update_organization_user(request, user_id):
    """
    PATCH /api/accounts/admin/update-org-user/<user_id>/
    تحديث جزئي لبروفايل مؤسسة.
    """
    try:
        user    = User.objects.get(id=user_id, user_type='organization')
        profile = user.profile
    except User.DoesNotExist:
        return Response({'error': 'المستخدم غير موجود'}, status=404)

    data = request.data.copy()
    data.pop('user_type', None)

    serializer = UserProfileSerializer(profile, data=data, partial=True)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data)
    return Response(serializer.errors, status=400)


@api_view(['DELETE'])
@permission_classes([IsAuthenticated, IsAdminUser])
def delete_organization_user(request, user_id):
    """
    DELETE /api/accounts/admin/delete-org-user/<user_id>/
    حذف مستخدم مؤسسة.
    """
    try:
        user = User.objects.get(id=user_id, user_type='organization')
        user.delete()
        return Response({'message': 'تم حذف المستخدم بنجاح!'})
    except User.DoesNotExist:
        return Response({'error': 'المستخدم غير موجود'}, status=404)
