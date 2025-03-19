from django.contrib import admin
from django.urls import path, include
from django.http import HttpResponse  # استيراد HttpResponse لإنشاء صفحة رئيسية مؤقتة

# دالة عرض بسيطة للصفحة الرئيسية
def home(request):
    return HttpResponse("<h1>Welcome to Circle Platform</h1>")
urlpatterns = [
    path("admin/", admin.site.urls),
    path("", include("accounts.urls")),  # جعل الحسابات هي الصفحة الرئيسية
]

