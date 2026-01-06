# ChatRoom/middleware.py
# ──────────────────────────────────────────────────────────────
from urllib.parse import parse_qs
from channels.db import database_sync_to_async
from channels.middleware import BaseMiddleware
from rest_framework_simplejwt.tokens import AccessToken
from django.contrib.auth import get_user_model
from django.contrib.auth.models import AnonymousUser
import logging

User = get_user_model()
logger = logging.getLogger("jwt_ws")


class JWTAuthMiddleware(BaseMiddleware):
    async def __call__(self, scope, receive, send):
        token = self._extract_token(scope)
        # ┌─────────────────────────────────────┐
        # │ هنا نستدعي get_user (وليس _get_user) │
        # └─────────────────────────────────────┘
        scope["user"] = await self.get_user(token)
        return await super().__call__(scope, receive, send)

    # ───────── helpers ─────────
    def _extract_token(self, scope):
        qs = parse_qs(scope["query_string"].decode())
        token = qs.get("token", [None])[0]
        if token:
            return token

        for header, value in scope.get("headers", []):
            if header == b"authorization":
                val = value.decode()
                return val.split()[1] if val.lower().startswith("bearer ") else val
        return None

    @database_sync_to_async
    def get_user(self, raw_token):           # ← الاسم الأصلى
        print("WS-AUTH ➜ token =", raw_token[:40], "…" if raw_token else None)

        if not raw_token:
            print("WS-AUTH ✗ no token!")
            return AnonymousUser()

        try:
            validated = AccessToken(raw_token)
            print("WS-AUTH ✓ uid =", validated["user_id"])
            return User.objects.get(id=validated["user_id"])

        except Exception as exc:
            print("WS-AUTH ✗ invalid:", exc)
            return AnonymousUser()
