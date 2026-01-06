# alerts/routing.py
from django.urls import re_path
from .consumers import AlertConsumer          # ← يجب أن يكون موجودًا

websocket_urlpatterns = [
    re_path(r"ws/alerts/(?P<user_id>\d+)/?$", AlertConsumer.as_asgi()),
]
