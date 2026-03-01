import json
from channels.generic.websocket import AsyncWebsocketConsumer

class LeaveConsumer(AsyncWebsocketConsumer):
    async def label(self):
        return "leave_updates"

    async def connect(self):
        # Join a global group for leave updates (or role-specific)
        await self.channel_layer.group_add(
            "leave_notifications",
            self.channel_name
        )
        await self.accept()

    async def disconnect(self, close_code):
        await self.channel_layer.group_discard(
            "leave_notifications",
            self.channel_name
        )

    # Receive message from room group
    async def send_leave_update(self, event):
        message = event['message']

        # Send message to WebSocket
        await self.send(text_data=json.dumps({
            'type': 'leave_update',
            'message': message
        }))
