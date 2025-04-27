# accounts/views_extra.py  (ملف جديد صغير)
from rest_framework.decorators import api_view, permission_classes, parser_classes
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

@api_view(['POST'])
@permission_classes([IsAuthenticated])
@parser_classes([MultiPartParser, FormParser])
def upload_avatar(request):
    """
    POST /api/accounts/profile/upload-avatar/
    body:  multipart/form-data  { avatar: <file> }
    """
    profile = request.user.profile
    profile.avatar = request.data.get('avatar')
    profile.save(update_fields=['avatar'])
    return Response({'avatar': request.build_absolute_uri(profile.avatar.url)})
