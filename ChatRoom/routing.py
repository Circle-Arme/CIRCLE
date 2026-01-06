# routing.py
from django.urls import path
from . import consumers
websocket_urlpatterns = [
    path("ws/community/<int:community_id>/", consumers.CommunityConsumer.as_asgi()),
    path("ws/thread/<int:thread_id>/",      consumers.ThreadConsumer.as_asgi()),
]
