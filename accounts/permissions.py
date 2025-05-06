# accounts/permissions.py
from rest_framework.permissions import BasePermission


class IsAdminUser(BasePermission):
    """
    يسمح فقط للمستخدمين الذين يحملون user_type == 'admin'
    (هذا هو السلوك الحالى ولا يتغيّر).
    """
    message = "يجب أن تكون مشرفًا (Admin) لتنفيذ هذا الإجراء."

    def has_permission(self, request, view):
        return (
            request.user.is_authenticated
            and getattr(request.user, "user_type", None) == "admin"
        )


class IsCommunityMember(BasePermission):
    """
    يتحقّق من أن المستخدم عضو في المجتمع المطلوب، سواء أُرسل رقم المجتمع
    صراحةً (community / community_id) أو ضِمن كيان آخر (chat_room, thread, reply).
    يعمل الفحص في:
      • has_permission   → القوائم / الإنشاء
      • has_object_perm → retrieve, update, delete
    """
    message = "أنت لست عضوًا في هذا المجتمع!"

    # ---------- أداة مساعدة خاصة ----------
    def _extract_community(self, request):
        """
        نحاول استنتاج كائن Community من البيانات الواردة.
        يقبل: community, chat_room, thread, reply
        يرجع: كائن Community أو None
        """
        from fields.models  import Community           # import هنا لتجنب الدوران
        from ChatRoom.models import ChatRoom, Thread, Reply

        # 1) id صريح للمجتمع
        cid = request.data.get("community") or request.query_params.get("community_id")
        # لو جاب لنا قائمة، خلنا نأخذ العنصر الأول
        if isinstance(cid, (list, tuple)):
            cid = cid[0]
        if cid:
            return Community.objects.filter(id=cid).first()

        # 2) غرفة دردشة
        room_id = request.data.get("chat_room")
        if room_id:
            room = ChatRoom.objects.select_related("community").filter(id=room_id).first()
            return room.community if room else None

        # 3) ثريد
        thread_id = request.data.get("thread")
        if thread_id:
            th = Thread.objects.select_related("chat_room__community").filter(id=thread_id).first()
            return th.chat_room.community if th else None


        # 4) ردّ
        reply_id = request.data.get("reply")
        if reply_id:
            rp = Reply.objects.select_related("thread__chat_room__community").filter(id=reply_id).first()
            return rp.thread.chat_room.community if rp else None

        return None
    # ---------------------------------------

    # ---- استدعاء عام (list / create) ----
    def has_permission(self, request, view):
        community = self._extract_community(request)
        if community is None:
            return True
        from fields.models import UserCommunity
        return UserCommunity.objects.filter(user=request.user,
                                            community=community).exists()


    # ---- استدعاء على الكائن نفسه ----
    def has_object_permission(self, request, view, obj):
        """
        بالنسبة لـ retrieve / update / destroy على كائن معيّن (ChatRoom, Thread, Reply)
        نستخلص المجتمع مباشرةً من الكائن ثم نعيد استخدام نفس منطق العضوية.
        """
        # محاولة للوصول إلى خاصية community في الكائن أو في السلاسل المرتبطة
        community = getattr(obj, "community", None)
        if community is None and hasattr(obj, "chat_room"):
            community = obj.chat_room.community
        if community is None and hasattr(obj, "thread"):
            community = obj.thread.chat_room.community

        if community is None:
            return False

        from fields.models import UserCommunity
        return UserCommunity.objects.filter(user=request.user,
                                            community=community).exists()
