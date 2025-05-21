from django.shortcuts import render

from rest_framework.generics import ListAPIView
from rest_framework.permissions import IsAuthenticated
from .models import Alert
from .serializers import AlertSerializer

class UserAlertsView(ListAPIView):
    serializer_class = AlertSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return Alert.objects.filter(recipient=self.request.user).order_by('-created_at')
