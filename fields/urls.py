from django.urls import path, include
from rest_framework.routers import DefaultRouter
<<<<<<< HEAD
# from ChatRoom.views import ChatRoomViewSet
=======
>>>>>>> 78439836091054e64c7c509bc55485550c515c0d
from .views import FieldViewSet, CommunityViewSet, UserCommunityViewSet

router = DefaultRouter()
router.register(r'fields', FieldViewSet)
router.register(r'communities', CommunityViewSet)
router.register(r'user-communities', UserCommunityViewSet)
<<<<<<< HEAD
# router.register(r'chat-rooms', ChatRoomViewSet)


urlpatterns = [
    path('', include(router.urls)),
]
=======

urlpatterns = [
    path('', include(router.urls)),
]
>>>>>>> 78439836091054e64c7c509bc55485550c515c0d
