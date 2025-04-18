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
    #path("admin/", admin.site.urls),
    path("", include("accounts.urls")),  # API الحسابات
    path('api/', include('fields.urls')),     # 🔁 غيرنا المسار هنا
    path('api/ChatRoom/', include('ChatRoom.urls')),     # 🔁 وغيرنا هنا أيضًا
]



if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)



urlpatterns = [
    path("admin/", admin.site.urls),
    path("", include("accounts.urls")),       # API الحسابات
    path("api/", include("fields.urls")),       # API المجالات والمجتمعات (للقراءة والعمليات الأخرى)
    path("api/", include("ChatRoom.urls")),     # API غرف الدردشة (للمستخدمين)
    path("api/", include("CIRCLE.admin_urls")),        # API الأدمن المخصصة للإدارة
]
