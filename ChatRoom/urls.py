from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ChatRoomViewSet, ThreadViewSet, ReplyViewSet, LikeViewSet

router = DefaultRouter()
router.register(r'chat-rooms', ChatRoomViewSet, basename='chatroom')
router.register(r'threads', ThreadViewSet, basename='thread')
router.register(r'replies', ReplyViewSet, basename='reply')
router.register(r'likes', LikeViewSet, basename='like')

urlpatterns = [
    path('', include(router.urls)),
]
