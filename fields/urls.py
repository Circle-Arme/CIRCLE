from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import FieldViewSet

router = DefaultRouter()
router.register(r'fields', FieldViewSet)

urlpatterns = [
    path('', include(router.urls)),
]
