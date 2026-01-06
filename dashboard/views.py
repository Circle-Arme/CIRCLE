from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.db.models import Count
from datetime import datetime

from accounts.permissions import IsAdminUser
from accounts.models import CustomUser
from fields.models import Field, Community
from ChatRoom.models import Thread, Reply

# عدد العناصر المطلوبة فى قسم Recent
RECENT_LIMIT = 10

@api_view(['GET'])
@permission_classes([IsAuthenticated, IsAdminUser])
def admin_summary(request):
    """
    GET /api/admin/summary/

    يعيد:
      • إحصاءات سريعة  (stats)
      • أحدث العمليات  (recent)
    """
    # ──────────────── الإحصاءات ────────────────
    stats = {
        "total_users"        : CustomUser.objects.filter(user_type='normal').count(),
        "total_organizations": CustomUser.objects.filter(user_type='organization').count(),
        "total_admins"       : CustomUser.objects.filter(user_type='admin').count(),
        "total_fields"       : Field.objects.count(),
        "total_communities"  : Community.objects.count(),
        "total_threads"      : Thread.objects.count(),
        "total_replies"      : Reply.objects.count(),
    }

    # ──────────────── آخر العمليات ────────────────
    recent = []

    # أحدث مستخدمين
    for u in CustomUser.objects.order_by('-date_joined')[:RECENT_LIMIT]:
        recent.append({
            "type" : "user",
            "id"   : u.id,
            "email": u.email,
            "when" : u.date_joined,
        })

    # أحدث مجتمعات
    for c in Community.objects.order_by('-created_at')[:RECENT_LIMIT]:
        recent.append({
            "type" : "community",
            "id"   : c.id,
            "name" : c.name,
            "when" : c.created_at,
        })

    # أحدث مواضيع (Threads)
    for t in Thread.objects.order_by('-created_at')[:RECENT_LIMIT]:
        recent.append({
            "type"   : "thread",
            "id"     : t.id,
            "title"  : t.title,
            "when"   : t.created_at,
            "room_id": t.chat_room_id,
        })

    # دمج القوائم ثم ترتيبها بحسب الحقل when desc وأخذ أول RECENT_LIMIT عنصر
    recent_sorted = sorted(recent, key=lambda x: x["when"], reverse=True)[:RECENT_LIMIT]

    return Response({"stats": stats, "recent": recent_sorted})
