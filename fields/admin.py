from django.contrib import admin
from .models import Field, Community, UserCommunity
from django.contrib.admin.sites import AlreadyRegistered

try:
    @admin.register(Field)
    class FieldAdmin(admin.ModelAdmin):
        list_display = ('name', 'description', 'image')
        search_fields = ('name',)
except AlreadyRegistered:
    pass

try:
    @admin.register(Community)
    class CommunityAdmin(admin.ModelAdmin):
        list_display = ('name', 'field', 'created_at', 'created_by', 'image')
        list_filter = ('field',)
        search_fields = ('name',)
except AlreadyRegistered:
    pass

try:
    @admin.register(UserCommunity)
    class UserCommunityAdmin(admin.ModelAdmin):
        list_display = ('user', 'community', 'level')
        list_filter = ('level', 'community')
        search_fields = ('user__username', 'community__name')
        list_editable = ('level',)
except AlreadyRegistered:
    pass
