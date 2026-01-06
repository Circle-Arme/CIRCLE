from django.contrib import admin
from .models import CustomUser
from fields.models import Field

admin.site.register(CustomUser)
admin.site.register(Field)
