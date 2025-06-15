# CIRCLE/asgi.py
# ────────────────────────────────────────────────────────────────────────
import os
import django

from django.core.asgi import get_asgi_application
from channels.routing import ProtocolTypeRouter, URLRouter
from channels.auth import AuthMiddlewareStack

# 1) تهيئة Django
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "CIRCLE.settings")
django.setup()
django_http_app = get_asgi_application()

# 2) استيراد الـ middleware و مسارات الـ WS
from ChatRoom.middleware import JWTAuthMiddleware
from ChatRoom.routing  import websocket_urlpatterns as chat_ws
from alerts.routing    import websocket_urlpatterns as alert_ws

websocket_urlpatterns = chat_ws + alert_ws

# 3) تكوين البروتوكولات
application = ProtocolTypeRouter({
    "http": django_http_app,

    # **احذف** AllowedHostsOriginValidator و OriginValidator
    "websocket": JWTAuthMiddleware(
        AuthMiddlewareStack(
            URLRouter(websocket_urlpatterns)
        )
    ),
})
