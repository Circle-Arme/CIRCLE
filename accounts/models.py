<<<<<<< HEAD
from django.contrib.auth.models import AbstractUser, BaseUserManager
from django.db import models
=======
from django.db import models
from django.conf import settings
from django.contrib.auth.models import AbstractUser, BaseUserManager
>>>>>>> 78439836091054e64c7c509bc55485550c515c0d

class CustomUserManager(BaseUserManager):
    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError("The Email field must be set")
<<<<<<< HEAD
        
        email = self.normalize_email(email)
        extra_fields.setdefault("is_active", True)  # تأكد من أن الحساب نشط عند إنشائه
=======
        email = self.normalize_email(email)
        extra_fields.setdefault("is_active", True)  # إعادة القيمة الأصلية
>>>>>>> 78439836091054e64c7c509bc55485550c515c0d
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)
<<<<<<< HEAD
        extra_fields.setdefault("is_active", True)  # تأكد من أن الحساب الفائق نشط
=======
        extra_fields.setdefault("is_active", True)
        extra_fields.setdefault("user_type", "admin")
>>>>>>> 78439836091054e64c7c509bc55485550c515c0d
        return self.create_user(email, password, **extra_fields)

class CustomUser(AbstractUser):
    email = models.EmailField(unique=True)
<<<<<<< HEAD
    username = None  # إزالة username تمامًا لجعل البريد الإلكتروني هو الحقل الأساسي
    first_name = models.CharField(max_length=30, blank=True, null=True)
    last_name = models.CharField(max_length=30, blank=True, null=True)

    objects = CustomUserManager()

    USERNAME_FIELD = "email"  # استخدام البريد الإلكتروني كمعرف رئيسي
    REQUIRED_FIELDS = ["first_name", "last_name"]  # الحقول المطلوبة عند إنشاء superuser
=======
    username = None
    first_name = models.CharField(max_length=30, blank=True, null=True)
    last_name = models.CharField(max_length=30, blank=True, null=True)

    USER_TYPE_CHOICES = [
        ('normal', 'Normal User'),
        ('organization', 'Organization User'),
        ('admin', 'Admin'),
    ]
    user_type = models.CharField(max_length=20, choices=USER_TYPE_CHOICES, default='normal')

    objects = CustomUserManager()

    USERNAME_FIELD = "email"
    REQUIRED_FIELDS = ["first_name", "last_name"]

class UserProfile(models.Model):
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='profile')
    name = models.CharField(max_length=100)
    work_education = models.TextField(blank=True)
    position = models.CharField(max_length=100, blank=True)
    description = models.TextField(blank=True)
    email = models.EmailField(blank=True)
    communities = models.ManyToManyField('fields.Community', blank=True)
    website     = models.URLField(blank=True, null=True)
    avatar      = models.ImageField(upload_to='avatars/', blank=True, null=True)

    def __str__(self):
        return self.name or self.user.email
>>>>>>> 78439836091054e64c7c509bc55485550c515c0d
