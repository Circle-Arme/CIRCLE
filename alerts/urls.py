# alerts/urls.py
from rest_framework.routers import DefaultRouter
from .views import AlertViewSet

router = DefaultRouter()
router.register(r"alerts", AlertViewSet, basename="alerts")

urlpatterns = router.urls          # ← يُعيد  /alerts/   و  /alerts/<id>/mark_read/
