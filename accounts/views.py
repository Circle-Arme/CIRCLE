from rest_framework import generics
from .models import Book
from .serializers import BookSerializer, UserSerializer
from rest_framework.generics import CreateAPIView
from .models import CustomUser

class UserListCreateAPIView(generics.ListCreateAPIView):
    queryset = CustomUser.objects.all()
    serializer_class = UserSerializer
