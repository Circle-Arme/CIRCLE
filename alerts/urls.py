from django.urls import path
from .views import UserAlertsView

urlpatterns = [
    path('', UserAlertsView.as_view(), name='user-alerts'),
]
