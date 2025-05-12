from django.urls import path, include
from rest_framework.routers import DefaultRouter
<<<<<<< HEAD
from .views import ChatRoomViewSet, LikeViewSet, ThreadViewSet, ReplyViewSet

router = DefaultRouter()

router.register(r'chat-rooms', ChatRoomViewSet)
router.register(r'threads', ThreadViewSet)
router.register(r'replies', ReplyViewSet)
router.register(r'Likes', LikeViewSet, basename='Like')


urlpatterns = [
    path('', include(router.urls)),
]
=======
from .views import ChatRoomViewSet, ThreadViewSet, ReplyViewSet, LikeViewSet

router = DefaultRouter()
router.register(r'chat-rooms', ChatRoomViewSet, basename='chatroom')
router.register(r'threads', ThreadViewSet, basename='thread')
router.register(r'replies', ReplyViewSet, basename='reply')
router.register(r'likes', LikeViewSet, basename='like')

urlpatterns = [
    path('', include(router.urls)),
]
>>>>>>> 78439836091054e64c7c509bc55485550c515c0d
