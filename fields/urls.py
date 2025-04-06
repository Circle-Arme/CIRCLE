from django.urls import path, include
from rest_framework.routers import DefaultRouter
# from ChatRoom.views import ChatRoomViewSet
from .views import FieldViewSet, CommunityViewSet, UserCommunityViewSet

router = DefaultRouter()
router.register(r'fields', FieldViewSet)
router.register(r'communities', CommunityViewSet)
router.register(r'user-communities', UserCommunityViewSet)
# router.register(r'chat-rooms', ChatRoomViewSet)


urlpatterns = [
    path('', include(router.urls)),
]