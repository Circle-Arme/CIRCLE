from django.apps import AppConfig


class ChatroomConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'ChatRoom'

def ready(self):
        # يضمن استيراد الإشارات فور بدء Django
        import ChatRoom.realtime_signals      # 