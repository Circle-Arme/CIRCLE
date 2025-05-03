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
    يُتحقَّق من أن المستخدم عضو فى المجتمع المُشار إليه
    فى الـ body أو الـ query-params.
    إذا لم يُرسل المجتمع أصلًا، لا تمنع الصلاحية الطلب.
    """
    message = "أنت لست عضوًا في هذا المجتمع!"

    def has_permission(self, request, view):
        community_id = (
            request.data.get("community") or
            request.query_params.get("community_id")
        )
        if not community_id:
            return True     # لا يوجد مجتمع محدَّد → السماح
        from fields.models import Community, UserCommunity
        try:
            community = Community.objects.get(id=community_id)
        except Community.DoesNotExist:
            return False
        return UserCommunity.objects.filter(user=request.user,
                                            community=community).exists()
