from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ChatRoomViewSet, StarViewSet, ThreadViewSet, ReplyViewSet

router = DefaultRouter()

router.register(r'chat-rooms', ChatRoomViewSet)
router.register(r'threads', ThreadViewSet)
router.register(r'replies', ReplyViewSet)
router.register(r'stars', StarViewSet, basename='star')


urlpatterns = [
    path('', include(router.urls)),
]