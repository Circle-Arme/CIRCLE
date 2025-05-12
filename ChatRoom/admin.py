from django.contrib import admin
<<<<<<< HEAD

# Register your models here.
=======
from .models import ChatRoom, Thread, Reply, Like

admin.site.register(ChatRoom)
admin.site.register(Thread)
admin.site.register(Reply)
admin.site.register(Like)
>>>>>>> 78439836091054e64c7c509bc55485550c515c0d
