from django.contrib import admin
from django.urls import path, include
from django.http import HttpResponse  # استيراد HttpResponse لإنشاء صفحة رئيسية مؤقتة

from django.conf import settings
from django.conf.urls.static import static

# دالة عرض بسيطة للصفحة الرئيسية
def home(request):
    return HttpResponse("<h1>Welcome to Circle Platform</h1>")
urlpatterns = [
    path("admin/", admin.site.urls),
    path("", include("accounts.urls")),  # جعل الحسابات هي الصفحة الرئيسية
    path('api/', include('fields.urls')),  # إضافة مسار API للمجالات
  # circle/urls.py (الرئيسي)
    path('api/jobs/', include('jobs.urls')),
    path('api/', include('organizations.urls')),



]


if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
