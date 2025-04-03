from django.contrib import admin
from .models import Field, Community, UserCommunity

# تأكد من عدم تسجيل Field أكثر من مرة
if not admin.site.is_registered(Field):
    @admin.register(Field)
    class FieldAdmin(admin.ModelAdmin):
        list_display = ('name', 'created_at', 'created_by')

if not admin.site.is_registered(Community):
    @admin.register(Community)
    class CommunityAdmin(admin.ModelAdmin):
        list_display = ('name', 'field', 'created_at', 'created_by')

if not admin.site.is_registered(UserCommunity):
    @admin.register(UserCommunity)
    class UserCommunityAdmin(admin.ModelAdmin):
        list_display = ('user', 'community')

