"""
Serializers with minor fixes:
• إزالة تمرير context فارغ يمنع liked_by_me من العمل.
• تحسين الأداء عبر select/prefetch داخل get_replies_tree.
"""

from rest_framework import serializers
from django.db.models import Prefetch, Count

from .models import ChatRoom, Thread, Reply, Like


# ─────────────────────────── ChatRoom ───────────────────────────
class ChatRoomSerializer(serializers.ModelSerializer):
    type_display = serializers.CharField(source="get_type_display", read_only=True)

    class Meta:
        model  = ChatRoom
        fields = ["id", "community", "type", "type_display", "name", "created_at", "created_by"]


# ─────────────────────────── Reply ──────────────────────────────
class ReplySerializer(serializers.ModelSerializer):
    likes_count  = serializers.SerializerMethodField()
    liked_by_me  = serializers.SerializerMethodField()
    creator_name = serializers.SerializerMethodField()
    children     = serializers.SerializerMethodField()
    file         = serializers.FileField(required=False, use_url=True)
    is_promoted  = serializers.BooleanField(read_only=True)

    class Meta:
        model  = Reply
        fields = [
            "id", "thread", "reply_text", "created_by", "creator_name",
            "created_at", "parent_reply", "likes_count", "liked_by_me",
            "file", "children", "is_promoted",
        ]

    # ----- helpers
    def _user(self):
        return self.context.get("request").user if self.context.get("request") else None

    def get_likes_count(self, obj):
        return obj.stars.count()

    def get_liked_by_me(self, obj):
        user = self._user()
        return bool(user and not user.is_anonymous and obj.stars.filter(user=user).exists())

    def get_creator_name(self, obj):
        user = obj.created_by
        if not user:
            return "مستخدم غير معروف"
        return user.get_full_name() or user.username or "مستخدم غير معروف"

    def get_children(self, obj):
        qs = (
            obj.nested_replies
              .annotate(likes_count=Count("stars"))
              .order_by("-likes_count", "created_at")
              .select_related("created_by")
        )
        return ReplySerializer(qs, many=True, context=self.context).data


# ─────────────────────────── Thread ─────────────────────────────
class ThreadSerializer(serializers.ModelSerializer):
    replies        = ReplySerializer(many=True, read_only=True)   # ← لم نعد نمرّر context فارغ
    replies_tree   = serializers.SerializerMethodField()
    replies_count  = serializers.SerializerMethodField()
    likes_count    = serializers.SerializerMethodField()
    liked_by_me    = serializers.SerializerMethodField()
    creator_name   = serializers.SerializerMethodField()

    class Meta:
        model  = Thread
        fields = [
            "id", "chat_room", "title", "details", "created_by", "creator_name",
            "file_attachment", "created_at",
            "replies", "replies_tree",
            "replies_count", "likes_count", "liked_by_me",
            "is_job_opportunity", "job_type", "location", "salary",
            "classification", "tags",
        ]

    # ----- tree helper
    def get_replies_tree(self, obj):
        replies_qs = (
            Reply.objects.filter(thread=obj, parent_reply__isnull=True)
            .annotate(likes_count=Count("stars"))
            .select_related("created_by")
            .prefetch_related(
                Prefetch(
                    "nested_replies",
                    queryset=Reply.objects.annotate(likes_count=Count("stars"))
                                            .select_related("created_by")
                                            .order_by("-likes_count", "created_at"),
                )
            )
            .order_by("-likes_count", "created_at")
        )

        def build_node(reply):
            data = ReplySerializer(reply, context=self.context).data
            data["children"] = [build_node(child) for child in reply.nested_replies.all()]
            return data

        return [build_node(r) for r in replies_qs]

    # ----- meta info
    def _user(self):
        return self.context.get("request").user if self.context.get("request") else None

    def get_replies_count(self, obj):
        return obj.replies.count()

    def get_likes_count(self, obj):
        return obj.stars.filter(reply__isnull=True).count()

    def get_liked_by_me(self, obj):
        user = self._user()
        return bool(user and not user.is_anonymous and obj.stars.filter(user=user, reply__isnull=True).exists())

    def get_creator_name(self, obj):
        user = obj.created_by
        if not user:
            return "مستخدم غير معروف"
        return user.get_full_name() or user.username or "مستخدم غير معروف"


# ─────────────────────────── Like ───────────────────────────────
class LikeSerializer(serializers.ModelSerializer):
    thread = serializers.PrimaryKeyRelatedField(queryset=Thread.objects.all(), required=False, allow_null=True)
    reply  = serializers.PrimaryKeyRelatedField(queryset=Reply.objects.all(),  required=False, allow_null=True)

    class Meta:
        model  = Like
        fields = ["id", "user", "thread", "reply", "created_at"]
        read_only_fields = ["user", "created_at"]

    # التحقق المنطقي… القيد DB يكفي، لكن نبقيه لرسالة أوضح
    def validate(self, data):
        thread = data.get("thread")
        reply  = data.get("reply")
        if not thread and not reply:
            raise serializers.ValidationError("يجب تحديد Thread أو Reply.")
        if thread and reply:
            raise serializers.ValidationError("لا يمكن تحديد الاثنين معًا.")
        return data

    def create(self, validated_data):
        validated_data["user"] = self.context["request"].user
        return super().create(validated_data)
