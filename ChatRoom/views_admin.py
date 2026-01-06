from rest_framework import viewsets, permissions
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.shortcuts import get_object_or_404
from ChatRoom.models import ChatRoom
from ChatRoom.serializers import ChatRoomSerializer
from fields.models import Community
from accounts.permissions import IsAdminUser

class AdminChatRoomViewSet(viewsets.ModelViewSet):
    queryset = ChatRoom.objects.all()
    serializer_class = ChatRoomSerializer
    permission_classes = [IsAuthenticated, IsAdminUser]

    def create(self, request, *args, **kwargs):
        community_id = request.data.get('community')
        room_type = request.data.get('type', 'discussion_general')
        name = request.data.get('name')
        
        community = get_object_or_404(Community, id=community_id)

        # التأكد من عدم وجود غرفة من نفس النوع داخل المجتمع
        if ChatRoom.objects.filter(community=community, type=room_type).exists():
            return Response({"detail": "غرفة من هذا النوع موجودة بالفعل لهذا المجتمع."}, status=400)

        room = ChatRoom.objects.create(
            community=community,
            type=room_type,
            name=name,
            created_by=request.user
        )
        serializer = ChatRoomSerializer(room)
        return Response(serializer.data, status=201)
