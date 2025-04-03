from rest_framework import viewsets, permissions
from .models import Field
from .serializers import FieldSerializer

class FieldViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Field.objects.all()
    serializer_class = FieldSerializer
    permission_classes = [permissions.AllowAny]  # السماح للجميع بالوصول
