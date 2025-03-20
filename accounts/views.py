from rest_framework import generics
from .models import CustomUser
from .serializers import UserSerializer

class UserListCreateAPIView(generics.ListCreateAPIView):
    queryset = CustomUser.objects.all() 
    serializer_class = UserSerializer
