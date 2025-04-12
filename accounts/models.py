from django.db import models
from django.conf import settings
from django.contrib.auth.models import AbstractUser, BaseUserManager

class CustomUserManager(BaseUserManager):
    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError("The Email field must be set")
        email = self.normalize_email(email)
        extra_fields.setdefault("is_active", True)  # إعادة القيمة الأصلية
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)
        extra_fields.setdefault("is_active", True)
        extra_fields.setdefault("user_type", "admin")
        return self.create_user(email, password, **extra_fields)

class CustomUser(AbstractUser):
    email = models.EmailField(unique=True)
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

    def __str__(self):
        return self.name or self.user.email