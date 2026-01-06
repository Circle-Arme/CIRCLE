# accounts/urls.py

from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView

from .views import (
    change_password,
    login_api,
    register_api,
    protected_view,
    UserProfileDetailView,
    PublicUserProfileView,
    upload_avatar,                  # ← استوردنا هنا upload_avatar من views
)
from .views_admin import (
    list_organization_users,
    create_organization_user,
    update_organization_user,
    delete_organization_user,
)

urlpatterns = [
    path('api/accounts/login/', login_api, name='login_api'),
    path('api/accounts/register/', register_api, name='register_api'),
    path('api/accounts/protected/', protected_view, name='protected_view'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),

    # بروفايل المستخدم الحالي (GET و PATCH/PUT جزئي)
    path('api/accounts/profile/', UserProfileDetailView.as_view(), name='user-profile'),
    # بروفايل أي مستخدم عام حسب الـ ID
    path(
        'api/accounts/profile/<int:user_id>/',
        PublicUserProfileView.as_view(),
        name='public-user-profile'
    ),
    # رفع / تحديث صورة الحساب
    path(
        'api/accounts/profile/upload-avatar/',
        upload_avatar,
        name='upload-avatar'
    ),
    path(
      'api/accounts/change-password/',
      change_password,
      name='change-password'
    ),

    # إدارة مستخدمي المؤسسات (Admin only)
    path('api/accounts/admin/org-users/', list_organization_users, name='list_org_users'),
    path('api/accounts/admin/create-org-user/', create_organization_user, name='create_org_user'),
    path('api/accounts/admin/update-org-user/<int:user_id>/', update_organization_user, name='update_org_user'),
    path('api/accounts/admin/delete-org-user/<int:user_id>/', delete_organization_user, name='delete_org_user'),
]
