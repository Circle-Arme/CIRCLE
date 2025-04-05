from django.shortcuts import get_object_or_404
from rest_framework import viewsets, permissions
from rest_framework.response import Response
from rest_framework.decorators import action
from .models import Field, Community, UserCommunity
from .serializers import FieldSerializer, CommunitySerializer, UserCommunitySerializer

class FieldViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Field.objects.all()
    serializer_class = FieldSerializer

    @action(detail=True, methods=['get'], url_path='communities')
    def get_communities(self, request, pk=None):
        field = self.get_object()
        communities = field.communities.all()
        serializer = CommunitySerializer(communities, many=True, context={'request': request})
        return Response(serializer.data)

class CommunityViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Community.objects.all()
    serializer_class = CommunitySerializer

class UserCommunityViewSet(viewsets.ModelViewSet):
    queryset = UserCommunity.objects.all()
    serializer_class = UserCommunitySerializer
    permission_classes = [permissions.IsAuthenticated]

    def create(self, request, *args, **kwargs):
        community = get_object_or_404(Community, id=request.data.get('community'))
        user = request.user
        if UserCommunity.objects.filter(user=user, community=community).exists():
            return Response({"detail": "أنت بالفعل عضو في هذا المجتمع!"}, status=400)
        UserCommunity.objects.create(user=user, community=community)
        return Response({"detail": "تم الانضمام بنجاح!"}, status=201)
