"""
ASGI config for CIRCLE project
--------------------------------
يشغِّل HTTP + WebSocket مع Django Channels.
"""

import os

# 1) عرِّف متغيّر الإعدادات قبل أى استيراد لدجانجو
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "circle.settings")

# 2) دع Django يحمِّل الـ INSTALLED_APPS الآن
from django.core.asgi import get_asgi_application

django_http_app = get_asgi_application()      # ← هذا يستدعى django.setup()

# 3) بعد أن أصبحت الـ apps جاهزة، يمكنك استيراد أى شىء يعتمد على النماذج
from channels.routing import ProtocolTypeRouter, URLRouter
from ChatRoom.middleware import JWTAuthMiddleware
from ChatRoom.routing import websocket_urlpatterns

# 4) جمِّع البروتوكولات
application = ProtocolTypeRouter(
    {
        "http": django_http_app,
        "websocket": JWTAuthMiddleware(
            URLRouter(websocket_urlpatterns)
        ),
    }
)
