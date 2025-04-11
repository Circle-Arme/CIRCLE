# views.py
from rest_framework import viewsets
from .models import Organization
from .serializers import OrganizationSerializer
from .permissions import IsAdminUserOnly
from rest_framework.permissions import IsAuthenticatedOrReadOnly

class OrganizationViewSet(viewsets.ModelViewSet):
    queryset = Organization.objects.all()
    serializer_class = OrganizationSerializer

    def get_permissions(self):
        if self.action in ['create', 'update', 'partial_update', 'destroy']:
            return [IsAdminUserOnly()]
        return [IsAuthenticatedOrReadOnly()]
