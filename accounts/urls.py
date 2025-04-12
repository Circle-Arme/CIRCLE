from django.urls import path
from .views import (
    login_api, register_api,
    protected_view, UserProfileDetailView,
    list_organization_users, create_organization_user, delete_organization_user
)
from rest_framework_simplejwt.views import TokenRefreshView

urlpatterns = [
    path('api/accounts/login/', login_api, name='login_api'),
    path('api/accounts/register/', register_api, name='register_api'),
    path('api/accounts/protected/', protected_view, name='protected_view'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('api/accounts/profile/', UserProfileDetailView.as_view(), name='user-profile'),
    path('api/accounts/admin/org-users/', list_organization_users, name='list_org_users'),
    path('api/accounts/admin/create-org-user/', create_organization_user, name='create_org_user'),
    path('api/accounts/admin/delete-org-user/<int:user_id>/', delete_organization_user, name='delete_org_user'),
]