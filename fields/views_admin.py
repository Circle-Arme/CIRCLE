from rest_framework import viewsets, permissions
from rest_framework.permissions import IsAuthenticated
from .models import Field, Community
from .serializers import FieldSerializer, CommunitySerializer
from accounts.permissions import IsAdminUser

class AdminFieldViewSet(viewsets.ModelViewSet):
    queryset = Field.objects.all()
    serializer_class = FieldSerializer
    permission_classes = [IsAuthenticated, IsAdminUser]

    def update(self, request, *args, **kwargs):
        instance = self.get_object()
        serializer = self.get_serializer(instance, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        
        # Handle clear_image flag
        if request.data.get('clear_image') == 'true':
            instance.image = None
        
        self.perform_update(serializer)
        return Response(serializer.data)

class AdminCommunityViewSet(viewsets.ModelViewSet):
    queryset = Community.objects.all()
    serializer_class = CommunitySerializer
    permission_classes = [IsAuthenticated, IsAdminUser]

    def update(self, request, *args, **kwargs):
        instance = self.get_object()
        serializer = self.get_serializer(instance, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        
        # Handle clear_image flag
        if request.data.get('clear_image') == 'true':
            instance.image = None
        
        self.perform_update(serializer)
        return Response(serializer.data)