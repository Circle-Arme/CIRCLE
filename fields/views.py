from django.shortcuts import get_object_or_404
from rest_framework import viewsets, permissions
from rest_framework.response import Response
from .models import Field, Community, UserCommunity, ChatRoom
from .serializers import ChatRoomSerializer, FieldSerializer, CommunitySerializer, UserCommunitySerializer

class FieldViewSet(viewsets.ReadOnlyModelViewSet):  
    queryset = Field.objects.all()
    serializer_class = FieldSerializer

class CommunityViewSet(viewsets.ReadOnlyModelViewSet):  
    queryset = Community.objects.all()
    serializer_class = CommunitySerializer

class UserCommunityViewSet(viewsets.ModelViewSet):
    queryset = UserCommunity.objects.all()
    serializer_class = UserCommunitySerializer
    permission_classes = [permissions.IsAuthenticated]  # السماح فقط للمستخدمين المسجلين

    def create(self, request, *args, **kwargs):
        community = get_object_or_404(Community, id=request.data.get('community'))
        user = request.user
        if UserCommunity.objects.filter(user=user, community=community).exists():
            return Response({"detail": "أنت بالفعل عضو في هذا المجتمع!"}, status=400)
        UserCommunity.objects.create(user=user, community=community)
        return Response({"detail": "تم الانضمام بنجاح!"}, status=201)

class ChatRoomViewSet(viewsets.ModelViewSet):
    queryset = ChatRoom.objects.all()
    serializer_class = ChatRoomSerializer
    permission_classes = [permissions.IsAuthenticated]

    def create(self, request, *args, **kwargs):
        community = get_object_or_404(Community, id=request.data.get('community'))
        user = request.user
        
        if not UserCommunity.objects.filter(user=user, community=community).exists():
            return Response({"detail": "أنت لست عضوًا في هذا المجتمع!"}, status=400)
        
        room = ChatRoom.objects.create(
            community=community,
            name=request.data.get('name'),
            created_by=user
        )
        return Response(ChatRoomSerializer(room).data, status=201)

    def list(self, request, *args, **kwargs):
        community_id = request.query_params.get('community', None)
        if community_id:
            community = get_object_or_404(Community, id=community_id)
            rooms = community.chat_rooms.all()
        else:
            rooms = ChatRoom.objects.all()
        
        serializer = ChatRoomSerializer(rooms, many=True)
        return Response(serializer.data)