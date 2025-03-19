from django.urls import path
from .views import login_api, register_api, protected_view
from rest_framework_simplejwt.views import TokenRefreshView

urlpatterns = [
    path('api/accounts/login/', login_api, name='login_api'),
    path('api/accounts/register/', register_api, name='register_api'),
    path('api/accounts/protected/', protected_view, name='protected_view'),  # لاختبار المصادقة
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
]
