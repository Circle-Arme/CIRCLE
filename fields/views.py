from rest_framework import viewsets
from .models import Field
from .serializers import FieldSerializer

class FieldViewSet(viewsets.ModelViewSet):
    queryset = Field.objects.all()
    serializer_class = FieldSerializer
