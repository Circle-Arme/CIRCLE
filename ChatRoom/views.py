from django.shortcuts import get_object_or_404
from rest_framework import viewsets, permissions
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from .models import ChatRoom, Thread, Reply, Like
from ChatRoom.serializers import ChatRoomSerializer, ThreadSerializer, ReplySerializer, LikeSerializer
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
            # التعديل: الوصول إلى chat_room ككائن واحد
            room = community.chat_room  # لا حاجة لـ .all()
            if room is None:
                return Response({"detail": "لا توجد غرفة دردشة لهذا المجتمع"}, status=404)
            serializer = ChatRoomSerializer(room)  # تسلسل كائن واحد
            return Response(serializer.data)
        else:
            rooms = ChatRoom.objects.all()
            serializer = ChatRoomSerializer(rooms, many=True)
            return Response(serializer.data)

class ThreadViewSet(viewsets.ModelViewSet):
    queryset = Thread.objects.all()
    serializer_class = ThreadSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        queryset = Thread.objects.all()
        community_id = self.request.query_params.get('community_id')
        is_job_opportunity = self.request.query_params.get('is_job_opportunity')

        if community_id:
            queryset = queryset.filter(chat_room__community__id=community_id)

        if is_job_opportunity is not None:
            is_job_opportunity = is_job_opportunity.lower() == 'true'
            queryset = queryset.filter(is_job_opportunity=is_job_opportunity)

        return queryset

class ReplyViewSet(viewsets.ModelViewSet):
    queryset = Reply.objects.all()
    serializer_class = ReplySerializer
    permission_classes = [IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(created_by=self.request.user)

class LikeViewSet(viewsets.ModelViewSet):
    queryset = Like.objects.all()
    serializer_class = LikeSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Like.objects.filter(user=self.request.user)