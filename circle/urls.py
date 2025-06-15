from django.contrib import admin
from django.urls import path, include
from django.http import HttpResponse  # استيراد HttpResponse لإنشاء صفحة رئيسية مؤقتة

from django.conf import settings
from django.conf.urls.static import static

from django.urls import path, include

# دالة عرض بسيطة للصفحة الرئيسية
def home(request):
    return HttpResponse("<h1>Welcome to Circle Platform</h1>")
# urls.py في المشروع الأساسي CIRCLE/urls.py
urlpatterns = [
    path("admin/", admin.site.urls),
    path("", include("accounts.urls")),
    path("api/", include("fields.urls")),
    path("api/", include("ChatRoom.urls")),
    path("api/", include("CIRCLE.admin_urls")),
    path("api/", include("alerts.urls")),
]

# أضف دعم الميديا
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)

