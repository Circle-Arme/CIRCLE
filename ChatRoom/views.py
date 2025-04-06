from django.shortcuts import get_object_or_404
from rest_framework import viewsets, permissions
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from .models import ChatRoom, Thread, Reply
from ChatRoom.serializers import ChatRoomSerializer, ThreadSerializer, ReplySerializer
from fields.models import Community, UserCommunity


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



class ThreadViewSet(viewsets.ModelViewSet):
    queryset = Thread.objects.all()
    serializer_class = ThreadSerializer
    permission_classes = [IsAuthenticated]


class ReplyViewSet(viewsets.ModelViewSet):
    queryset = Reply.objects.all()
    serializer_class = ReplySerializer
    permission_classes = [IsAuthenticated]