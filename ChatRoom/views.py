# ChatRoom/views.py
from django.shortcuts import get_object_or_404
from rest_framework import viewsets, permissions, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.db import transaction
from .models import ChatRoom, Thread, Reply, Like
from ChatRoom.serializers import (ChatRoomSerializer, ThreadSerializer,ReplySerializer, LikeSerializer)
from fields.models import Community, UserCommunity
from accounts.permissions import IsCommunityMember      # جديد


# ─────────────────────────── ChatRoom ───────────────────────────
class ChatRoomViewSet(viewsets.ReadOnlyModelViewSet,     # لا نحتاج update/delete
                      viewsets.GenericViewSet):
    """
    - list: يعرض الغرف المسموح بها للمستخدم داخل مجتمع محدّد.
    - create: يتيح إنشاء غرفة جديدة (إن أردت السماح بذلك).
    """
    serializer_class   = ChatRoomSerializer
    permission_classes = [permissions.IsAuthenticated, IsCommunityMember]

    def get_queryset(self):
        return (ChatRoom.objects
                .select_related("community", "created_by")
                .order_by("-created_at"))

    # -------- list ----------
    def list(self, request, *args, **kwargs):
        community_id = request.query_params.get("community_id")
        if not community_id:
            return Response({"detail": "يجب تحديد community_id."},
                            status=status.HTTP_400_BAD_REQUEST)

        community = get_object_or_404(Community, id=community_id)
        user      = request.user
        membership = get_object_or_404(UserCommunity, user=user, community=community)

        allowed = {"job_opportunities"}
        match membership.level:
            case "beginner": allowed.add("discussion_general")
            case "advanced": allowed.add("discussion_advanced")
            case "both":     allowed.update(("discussion_general", "discussion_advanced"))

        if user.user_type == "organization":
            allowed = {"job_opportunities"}

        rooms = community.chat_rooms.filter(type__in=allowed)

        room_type = request.query_params.get("type")
        if room_type:
            rooms = rooms.filter(type=room_type)

        # لا 404؛ نعيد [] إن لم توجد نتائج
        serializer = self.get_serializer(rooms, many=True)
        return Response(serializer.data)

    # -------- create --------
    def create(self, request, *args, **kwargs):
        community = get_object_or_404(Community, id=request.data.get("community"))
        room_type = request.data.get("type", "discussion_general")

        if ChatRoom.objects.filter(community=community, type=room_type).exists():
            return Response({"detail": "غرفة من هذا النوع موجودة بالفعل لهذا المجتمع."},
                            status=status.HTTP_400_BAD_REQUEST)

        room = ChatRoom.objects.create(
            community  = community,
            type       = room_type,
            name       = request.data.get("name"),
            created_by = request.user,
        )
        return Response(ChatRoomSerializer(room).data,
                        status=status.HTTP_201_CREATED)


# ─────────────────────────── Thread ────────────────────────────
class ThreadViewSet(viewsets.ModelViewSet):
    serializer_class   = ThreadSerializer
    permission_classes = [IsAuthenticated, IsCommunityMember]

    def get_queryset(self):
        qs = (Thread.objects
                    .select_related("chat_room", "chat_room__community", "created_by")
                    .prefetch_related("stars"))

        community_id = self.request.query_params.get("community_id")
        if community_id:
            community   = get_object_or_404(Community, id=community_id)
            membership  = get_object_or_404(UserCommunity,
                                            user=self.request.user,
                                            community=community)

            allowed = {"job_opportunities"}
            match membership.level:
                case "beginner": allowed.add("discussion_general")
                case "advanced": allowed.add("discussion_advanced")
                case "both":     allowed.update(("discussion_general", "discussion_advanced"))

            qs = qs.filter(chat_room__community=community,
                           chat_room__type__in=allowed)

        flag = self.request.query_params.get("is_job_opportunity")
        if flag is not None:
            qs = qs.filter(is_job_opportunity=flag.lower() == "true")

        return qs.order_by("-created_at")

    def perform_create(self, serializer):
        serializer.save(created_by=self.request.user)


# ─────────────────────────── Reply ─────────────────────────────
class ReplyViewSet(viewsets.ModelViewSet):
    serializer_class   = ReplySerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return (Reply.objects
                .select_related("thread", "created_by")
                .prefetch_related("stars"))

    def perform_create(self, serializer):
        serializer.save(created_by=self.request.user)


# ─────────────────────────── Like (toggle) ─────────────────────

class LikeViewSet(viewsets.GenericViewSet):
    """
    POST /api/likes/
        body = {"thread": <id>}  أو  {"reply": <id>}
    يقوم بالـ toggle: إضافة إذا لم تُوجد، أو حذف إذا وُجدت.
    """
    serializer_class   = LikeSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Like.objects.filter(user=self.request.user)

    @transaction.atomic
    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data,
                                         context={"request": request})
        serializer.is_valid(raise_exception=True)

        thread = serializer.validated_data.get("thread")
        reply  = serializer.validated_data.get("reply")

        # نحجز الصفوف المحتملة لتفادى سباق الكتابة
        qs = Like.objects.select_for_update().filter(
            user=request.user,
            thread=thread,
            reply=reply,
        )

        if qs.exists():                     # كان مُعجبًا → إلغاء
            qs.delete()
            return Response(status=status.HTTP_204_NO_CONTENT)

        # لم يكن مُعجبًا → إضافة
        like = Like.objects.create(
            user=request.user,
            thread=thread,
            reply=reply,
        )
        return Response(LikeSerializer(like).data,
                        status=status.HTTP_201_CREATED)

# ─────────────────────────── Permission helper ─────────────────
# accounts/permissions.py  (أضِفه إن لم يكن موجوداً)
from rest_framework.permissions import BasePermission

class IsCommunityMember(BasePermission):
    """
    يتحقق من أن المستخدم عضو في المجتمع الذي يُمرَّر
    عبر body (POST) أو query params (GET).
    """
    message = "أنت لست عضوًا في هذا المجتمع!"

    def has_permission(self, request, view):
        community_id = (request.data.get("community") or
                        request.query_params.get("community_id"))
        if not community_id:
            return True   # إذا لم يُحدد المجتمع، لا يمنع الطلب
        from fields.models import Community, UserCommunity
        try:
            community = Community.objects.get(id=community_id)
        except Community.DoesNotExist:
            return False
        return UserCommunity.objects.filter(user=request.user,
                                            community=community).exists()
