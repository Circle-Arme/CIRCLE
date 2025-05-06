# ChatRoom/views.py
from django.shortcuts import get_object_or_404
from rest_framework import viewsets, permissions, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.db import transaction
from .models import ChatRoom, Thread, Reply, Like
from ChatRoom.serializers import (ChatRoomSerializer, ThreadSerializer,ReplySerializer, LikeSerializer)
from fields.models import Community, UserCommunity
from rest_framework.permissions import BasePermission
from utils.chat import allowed_types
from rest_framework.exceptions import PermissionDenied
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

        community  = get_object_or_404(Community, id=community_id)
        membership = get_object_or_404(UserCommunity,
                                       user=request.user,
                                       community=community)

        allowed = allowed_types(membership.level, request.user.user_type)

        rooms = community.chat_rooms.filter(type__in=allowed)

        if room_type := request.query_params.get("type"):
            rooms = rooms.filter(type=room_type)

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
              .select_related("chat_room__community", "created_by")
              .prefetch_related("stars"))
        #   السماح لعملية retrieve بدون community_id
        if self.action == "retrieve":
            return qs

        # إلزام community_id
        community_id = self.request.query_params.get("community_id")
        if not community_id:
            return qs.none()          # أو ارفع خطأ 400 إذا تفضّل

        community  = get_object_or_404(Community, id=community_id)
        membership = get_object_or_404(UserCommunity,
                                       user=self.request.user,
                                       community=community)

        allowed = allowed_types(membership.level, self.request.user.user_type)

        qs = qs.filter(chat_room__community=community,
                       chat_room__type__in=allowed)

        if flag := self.request.query_params.get("is_job_opportunity"):
            qs = qs.filter(is_job_opportunity=flag.lower() == "true")

        return qs.order_by("-created_at")

    # منع إنشاء ثريد في مجتمع غريب
    def perform_create(self, serializer):
        chat_room = serializer.validated_data["chat_room"]
        if not UserCommunity.objects.filter(user=self.request.user,
                                            community=chat_room.community).exists():
            raise PermissionDenied("لست عضوًا في هذا المجتمع.")
        serializer.save(created_by=self.request.user)

        serializer.save(created_by=self.request.user)


# ─────────────────────────── Reply ─────────────────────────────
class ReplyViewSet(viewsets.ModelViewSet):
    serializer_class   = ReplySerializer
    permission_classes = [IsAuthenticated, IsCommunityMember]

    def get_queryset(self):
        qs = (Reply.objects
          .select_related("thread__chat_room__community", "created_by")
          .prefetch_related("stars"))

        community_id = self.request.query_params.get("community_id")
        if not community_id:
             return qs.none()

        community  = get_object_or_404(Community, id=community_id)
        membership = get_object_or_404(UserCommunity,
                                   user=self.request.user,
                                   community=community)

        allowed = allowed_types(membership.level, self.request.user.user_type)

        return qs.filter(thread__chat_room__community=community,
                     thread__chat_room__type__in=allowed)


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


class IsCommunityMember(BasePermission):
    """
    يتحقق من أن المستخدم عضو في المجتمع الذي يُمرَّر
    عبر body (POST) أو query params (GET).
    """
    message = "أنت لست عضوًا في هذا المجتمع!"

    def has_object_permission(self, request, view, obj):
        """
        يُستدعى تلقائياً في retrieve / update / delete
        """
        community = getattr(obj, "community", None)
        # للـ Thread و Reply نصل للمجتمع عبر السلسلة
        if community is None and hasattr(obj, "chat_room"):
            community = obj.chat_room.community

        if community is None:
            return False

        from fields.models import UserCommunity
        return UserCommunity.objects.filter(user=request.user,
                                            community=community).exists()

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
