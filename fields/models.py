from django.db import models

class Field(models.Model):
    field_id = models.AutoField(primary_key=True)  # معرف المجال
    name = models.CharField(max_length=100, unique=True)  # اسم المجال، يجب أن يكون فريدًا
    description = models.TextField(blank=True, null=True)  # وصف المجال (اختياري)
    created_at = models.DateTimeField(auto_now_add=True)  # تاريخ الإنشاء
    #created_by = models.ForeignKey("Admin", on_delete=models.CASCADE)  # العلاقة مع الـ Admin

    def __str__(self):
        return self.name
