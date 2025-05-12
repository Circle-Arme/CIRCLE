# admin_urls.py

from django.urls import path, include
from rest_framework.routers import DefaultRouter
from fields.views_admin import AdminFieldViewSet, AdminCommunityViewSet
from ChatRoom.views_admin import AdminChatRoomViewSet
from accounts.views_admin import update_organization_user
from dashboard.views import admin_summary

router = DefaultRouter()
router.register(r'admin/fields', AdminFieldViewSet, basename='admin-field')
router.register(r'admin/communities', AdminCommunityViewSet, basename='admin-community')
router.register(r'admin/chat-rooms', AdminChatRoomViewSet, basename='admin-chatroom')

urlpatterns = [
    path('', include(router.urls)),
    path('admin/summary/', admin_summary, name='admin-summary'),
    path('admin/update-org-user/<int:user_id>/', update_organization_user, name='admin-update-org-user'),
]
