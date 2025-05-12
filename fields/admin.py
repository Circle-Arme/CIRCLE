from django.contrib import admin
from .models import Field, Community, UserCommunity
<<<<<<< HEAD

# تأكد من عدم تسجيل Field أكثر من مرة
if not admin.site.is_registered(Field):
    @admin.register(Field)
    class FieldAdmin(admin.ModelAdmin):
        list_display = ('name', 'description', 'image')

if not admin.site.is_registered(Community):
    @admin.register(Community)
    class CommunityAdmin(admin.ModelAdmin):
        list_display = ('name', 'field', 'created_at', 'created_by')

if not admin.site.is_registered(UserCommunity):
    @admin.register(UserCommunity)
    class UserCommunityAdmin(admin.ModelAdmin):
        list_display = ('user', 'community')
=======
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
>>>>>>> 78439836091054e64c7c509bc55485550c515c0d
