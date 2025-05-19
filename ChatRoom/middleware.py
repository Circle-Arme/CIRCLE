# middleware.py
from django.contrib.auth.models import AnonymousUser 
from urllib.parse import parse_qs
from channels.db import database_sync_to_async
from channels.middleware import BaseMiddleware
from rest_framework_simplejwt.tokens import AccessToken
from django.contrib.auth import get_user_model

User = get_user_model()

class JWTAuthMiddleware(BaseMiddleware):
    async def __call__(self, scope, receive, send):
        query_string = parse_qs(scope["query_string"].decode())
        token = query_string.get("token", [None])[0]
        scope["user"] = await self.get_user(token)
        return await super().__call__(scope, receive, send)

    @database_sync_to_async
    def get_user(self, raw_token):
        if not raw_token:
            return AnonymousUser()
        try:
            validated = AccessToken(raw_token)
            return User.objects.get(id=validated["user_id"])
        except Exception:
            return AnonymousUser()
