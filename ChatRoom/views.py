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
        room_type = request.data.get('type', 'discussion_general')
        name = request.data.get('name')
        
        community = get_object_or_404(Community, id=community_id)
        user = request.user

        if not UserCommunity.objects.filter(user=user, community=community).exists():
            return Response({"detail": "أنت لست عضوًا في هذا المجتمع!"}, status=400)

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
        community_id = request.query_params.get('community_id', None)
        room_type = request.query_params.get('type', None)
        user = request.user

        if community_id:
            community = get_object_or_404(Community, id=community_id)

            try:
                user_membership = UserCommunity.objects.get(user=user, community=community)
            except UserCommunity.DoesNotExist:
                return Response({"detail": "أنت لست عضوًا في هذا المجتمع!"}, status=403)

            # إذا كان المستخدم من نوع organization، يُعرض له فقط غرفة فرص العمل
            if user.user_type == 'organization':
                rooms = community.chat_rooms.filter(type='job_opportunities')
            else:
                allowed_types = ['job_opportunities']
                if user_membership.level == 'beginner':
                    allowed_types.append('discussion_general')
                elif user_membership.level == 'advanced':
                    allowed_types.append('discussion_advanced')
                elif user_membership.level == 'both':
                    allowed_types += ['discussion_general', 'discussion_advanced']

                rooms = community.chat_rooms.filter(type__in=allowed_types)
            
            if room_type:
                rooms = rooms.filter(type=room_type)

            if not rooms.exists():
                return Response({"detail": "لا توجد غرف مطابقة للمعايير المحددة"}, status=404)

            serializer = ChatRoomSerializer(rooms, many=True)
            return Response(serializer.data)
        else:
            return Response({"detail": "يجب تحديد community_id."}, status=400)

class ThreadViewSet(viewsets.ModelViewSet):
    queryset = Thread.objects.all()
    serializer_class = ThreadSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        queryset = Thread.objects.all()

        community_id = self.request.query_params.get('community_id')
        is_job_opportunity = self.request.query_params.get('is_job_opportunity')

        if community_id:
            community = get_object_or_404(Community, id=community_id)

            try:
                membership = UserCommunity.objects.get(user=user, community=community)
            except UserCommunity.DoesNotExist:
                return Thread.objects.none()

            allowed_types = ['job_opportunities']
            if membership.level == 'beginner':
                allowed_types.append('discussion_general')
            elif membership.level == 'advanced':
                allowed_types.append('discussion_advanced')
            elif membership.level == 'both':
                allowed_types += ['discussion_general', 'discussion_advanced']

            queryset = queryset.filter(chat_room__community=community, chat_room__type__in=allowed_types)

        if is_job_opportunity is not None:
            is_job_opportunity = is_job_opportunity.lower() == 'true'
            queryset = queryset.filter(is_job_opportunity=is_job_opportunity)

        return queryset
    def perform_create(self, serializer):
       # عند إنشاء ثريد جديد، احفظ created_by تلقائياً
        serializer.save(created_by=self.request.user)

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
