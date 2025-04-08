from rest_framework import viewsets, permissions
from .models import Organization
from .serializers import OrganizationSerializer

# الصلاحيات للمشرف فقط
class IsAdminOnly(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user and request.user.is_staff

class OrganizationViewSet(viewsets.ModelViewSet):
    queryset = Organization.objects.all()
    serializer_class = OrganizationSerializer
    permission_classes = [IsAdminOnly]
