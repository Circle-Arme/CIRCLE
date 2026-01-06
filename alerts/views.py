from django.shortcuts import render

from rest_framework.generics import ListAPIView
from rest_framework.permissions import IsAuthenticated
from .models import Alert

from rest_framework import mixins, viewsets, permissions, status   # ← أضف mixins و status
from rest_framework.decorators import action                      # ← أضف action
from rest_framework.response import Response                      # ← أضف Response

from .models import Alert
from .serializers import AlertSerializer


class UserAlertsView(ListAPIView):
    serializer_class = AlertSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return Alert.objects.filter(recipient=self.request.user).order_by('-created_at')

class AlertViewSet(mixins.ListModelMixin,
                   viewsets.GenericViewSet):
    permission_classes = [permissions.IsAuthenticated]
    serializer_class   = AlertSerializer

    def get_queryset(self):
        qs = Alert.objects.filter(recipient=self.request.user)
        if self.request.query_params.get("unread") == "true":
            qs = qs.filter(is_read=False)
        return qs

    @action(methods=["patch"], detail=True)
    def mark_read(self, request, pk=None):
        alert = self.get_object()
        alert.is_read = True
        alert.save(update_fields=["is_read"])
        return Response(status=status.HTTP_204_NO_CONTENT)

    @action(methods=["patch"], detail=False)
    def mark_all_read(self, request):
        updated = (Alert.objects
                        .filter(recipient=request.user, is_read=False)
                        .update(is_read=True))
        return Response({"updated": updated})