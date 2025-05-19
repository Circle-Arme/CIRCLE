# consumers.py
import json
from channels.generic.websocket import AsyncWebsocketConsumer

class ThreadConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.thread_id = self.scope["url_route"]["kwargs"]["thread_id"]
        self.group_name = f"thread_{self.thread_id}"

        # تحقّق أن المستخدم عضو في المجتمع (اختياري)
        if not self.scope["user"].is_authenticated:
            return await self.close()

        await self.channel_layer.group_add(self.group_name, self.channel_name)
        await self.accept()

    async def disconnect(self, code):
        await self.channel_layer.group_discard(self.group_name, self.channel_name)

    # لا نستقبل أي رسائل من العميل الآن
    async def receive(self, text_data):
        pass

    # مستقبل كل الأحداث
    async def broadcast(self, event):
        await self.send(text_data=json.dumps(event["payload"]))

class CommunityConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.community_id = self.scope["url_route"]["kwargs"]["community_id"]
        self.group_name   = f"community_{self.community_id}"

        if not self.scope["user"].is_authenticated:
            return await self.close()

        await self.channel_layer.group_add(self.group_name, self.channel_name)
        await self.accept()

    async def disconnect(self, code):
        await self.channel_layer.group_discard(self.group_name, self.channel_name)

    # كل الرسائل من signals تُمرَّر إلى send()
    async def broadcast(self, event):
        await self.send(text_data=json.dumps(event["payload"]))
