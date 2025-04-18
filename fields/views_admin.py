# fields/views_admin.py

from rest_framework import viewsets, permissions
from rest_framework.permissions import IsAuthenticated
from .models import Field
from .serializers import FieldSerializer
from accounts.permissions import IsAdminUser
from .models import Community
from .serializers import CommunitySerializer

class AdminFieldViewSet(viewsets.ModelViewSet):
    queryset = Field.objects.all()
    serializer_class = FieldSerializer
    permission_classes = [IsAuthenticated, IsAdminUser]


class AdminCommunityViewSet(viewsets.ModelViewSet):
    queryset = Community.objects.all()
    serializer_class = CommunitySerializer
    permission_classes = [IsAuthenticated, IsAdminUser]