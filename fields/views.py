# fields/views.py

from django.contrib.auth import get_user_model
from django.shortcuts import get_object_or_404
from rest_framework import viewsets, permissions, status
from rest_framework.response import Response
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated

from .models import Field, Community, UserCommunity
from .serializers import FieldSerializer, CommunitySerializer, UserCommunitySerializer

User = get_user_model()

class FieldViewSet(viewsets.ReadOnlyModelViewSet):
    """
    Read-only endpoints for Field.
    GET /api/fields/
    GET /api/fields/{id}/
    GET /api/fields/{id}/communities/
    """
    queryset = Field.objects.all()
    serializer_class = FieldSerializer
    permission_classes = [permissions.AllowAny]

    @action(detail=True, methods=['get'], url_path='communities')
    def get_communities(self, request, pk=None):
        field = self.get_object()
        communities = field.communities.all()
        serializer = CommunitySerializer(communities, many=True, context={'request': request})
        return Response(serializer.data)


class CommunityViewSet(viewsets.ReadOnlyModelViewSet):
    """
    Read-only endpoints for Community.
    GET /api/communities/
    GET /api/communities/{id}/
    """
    queryset = Community.objects.all()
    serializer_class = CommunitySerializer
    permission_classes = [permissions.AllowAny]


class UserCommunityViewSet(viewsets.ModelViewSet):
    """
    Endpoints to manage a user's memberships:
    - POST   /api/user-communities/         → join a community
    - GET    /api/user-communities/my/      → list this user's communities
    - GET    /api/user-communities/for-user/{user_id}/  → list *any* user's communities
    - DELETE /api/user-communities/leave/?community_id={id} → leave a community
    """
    queryset = UserCommunity.objects.all()
    serializer_class = UserCommunitySerializer
    permission_classes = [IsAuthenticated]

    def create(self, request, *args, **kwargs):
        community = get_object_or_404(Community, id=request.data.get('community'))
        user = request.user

        if UserCommunity.objects.filter(user=user, community=community).exists():
            return Response(
                {"detail": "أنت بالفعل عضو في هذا المجتمع!"},
                status=status.HTTP_400_BAD_REQUEST
            )

        # 1) أنشئ الاشتراك
        membership = UserCommunity.objects.create(user=user, community=community)

        # 2) مزامنة مع حقل M2M في بروفايل المستخدم
        request.user.profile.communities.add(community)

        return Response({"detail": "تم الانضمام بنجاح!"}, status=status.HTTP_201_CREATED)


    @action(detail=False, methods=['get'], permission_classes=[IsAuthenticated], url_path='my')
    def my(self, request):
        """
        GET /api/user-communities/my/
        يعيد قائمة مجتمعات المستخدم الحالي
        """
        user_communities = UserCommunity.objects.filter(user=request.user).select_related('community')
        communities = [uc.community for uc in user_communities]
        serializer = CommunitySerializer(communities, many=True, context={'request': request})
        return Response(serializer.data)


    @action(
        detail=False,
        methods=['get'],
        permission_classes=[permissions.AllowAny],
        url_path=r'for-user/(?P<user_id>\d+)'
    )
    def for_user(self, request, user_id=None):
        """
        GET /api/user-communities/for-user/{user_id}/
        يعيد قائمة مجتمعات أي مستخدم حسب الـuser_id
        """
        user = get_object_or_404(User, id=user_id)
        user_communities = UserCommunity.objects.filter(user=user).select_related('community')
        communities = [uc.community for uc in user_communities]
        serializer = CommunitySerializer(communities, many=True, context={'request': request})
        return Response(serializer.data)


    @action(
        detail=False,
        methods=['delete'],
        permission_classes=[IsAuthenticated],
        url_path='leave'
    )
    def leave(self, request):
        """
        DELETE /api/user-communities/leave/?community_id={id}
        يحذف اشتراك المستخدم في مجتمع ويُحدّث M2M في بروفايله
        """
        community_id = request.query_params.get('community_id')
        if not community_id:
            return Response(
                {"detail": "community_id is required."},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            uc = UserCommunity.objects.get(user=request.user, community__id=community_id)
            uc.delete()
            # إزالة من M2M في بروفايل المستخدم
            request.user.profile.communities.remove(community_id)
            return Response(
                {"detail": "تمت المغادرة بنجاح."},
                status=status.HTTP_204_NO_CONTENT
            )
        except UserCommunity.DoesNotExist:
            return Response(
                {"detail": "أنت لست عضوًا في هذا المجتمع."},
                status=status.HTTP_404_NOT_FOUND
            )
