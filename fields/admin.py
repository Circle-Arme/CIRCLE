from django.contrib import admin
from .models import Field, Community, UserCommunity

if not admin.site.is_registered(Field):
    @admin.register(Field)
    class FieldAdmin(admin.ModelAdmin):
        list_display = ('name', 'description', 'image')

if not admin.site.is_registered(Community):
    @admin.register(Community)
    class CommunityAdmin(admin.ModelAdmin):
        list_display = ('name', 'field', 'created_at', 'created_by', 'image')

if not admin.site.is_registered(UserCommunity):
    @admin.register(UserCommunity)
    class UserCommunityAdmin(admin.ModelAdmin):
        list_display = ('user', 'community')
