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
        community_id = request.data.get('community')
        room_type = request.data.get('type', 'discussion_general')  # النوع الافتراضي
        name = request.data.get('name')  # الاسم يمكن إرساله أو توليده تلقائيًا

        community = get_object_or_404(Community, id=community_id)
        user = request.user

        # تحقق من أن المستخدم عضو في هذا المجتمع
        if not UserCommunity.objects.filter(user=user, community=community).exists():
            return Response({"detail": "أنت لست عضوًا في هذا المجتمع!"}, status=400)

        # تحقق من عدم وجود غرفة من نفس النوع مسبقًا
        if ChatRoom.objects.filter(community=community, type=room_type).exists():
            return Response({"detail": "غرفة من هذا النوع موجودة بالفعل لهذا المجتمع."}, status=400)

        room = ChatRoom.objects.create(
            community=community,
            type=room_type,
            name=name,
            created_by=user
        )
        serializer = ChatRoomSerializer(room)
        return Response(serializer.data, status=201)

    def list(self, request, *args, **kwargs):
        community_id = request.query_params.get('community', None)
        room_type = request.query_params.get('type', None)

        if community_id:
            community = get_object_or_404(Community, id=community_id)
            rooms = community.chat_rooms.all()

            if room_type:
                rooms = rooms.filter(type=room_type)

            if not rooms.exists():
                return Response({"detail": "لا توجد غرف مطابقة للمعايير المحددة"}, status=404)

            serializer = ChatRoomSerializer(rooms, many=True)
            return Response(serializer.data)

        else:
            serializer = ChatRoomSerializer(self.queryset, many=True)
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
