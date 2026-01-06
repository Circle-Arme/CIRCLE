from django.contrib import admin
from .models import ChatRoom, Thread, Reply, Like

admin.site.register(ChatRoom)
admin.site.register(Thread)
admin.site.register(Reply)
admin.site.register(Like)
