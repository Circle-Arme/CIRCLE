from django.contrib import admin
from .models import Field

class FieldAdmin(admin.ModelAdmin):
    list_display = ('name', 'created_at', 'created_by')
    search_fields = ('name',)
    list_filter = ('created_at',)
    ordering = ('-created_at',)

    def has_add_permission(self, request):
        return request.user.is_superuser  # السماح فقط للأدمن بالإضافة

    def has_change_permission(self, request, obj=None):
        return request.user.is_superuser  # السماح فقط للأدمن بالتعديل

    def has_delete_permission(self, request, obj=None):
        return request.user.is_superuser  # السماح فقط للأدمن بالحذف

# حل مشكلة التكرار في التسجيل
if not admin.site.is_registered(Field):
    admin.site.register(Field, FieldAdmin)
