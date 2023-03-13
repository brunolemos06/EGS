from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.utils import timezone
from django.db.models.signals import post_save
from django.dispatch import receiver
from rest_framework.authtoken.models import Token
from django.conf import settings

class CustomUserManager(BaseUserManager):
    def create_user(self, uuid, email, first_name, last_name, password=None, **extra_fields):
        if not email:
            raise ValueError('The Email field must be set')
        if not uuid:
            raise ValueError('The UUID field must be set')
        
        user = self.model(
            email=self.normalize_email(email),
            uuid=uuid,
            first_name=first_name,
            last_name=last_name,
            **extra_fields
        )
        user.set_password(password)
        user.save(using=self._db)

    def create_superuser(self, email, password=None):
        user = self.create_user(
            email=self.normalize_email(email),
            uuid='5aa479e4-2027-4e20-99ef-395dc21829c0',
            first_name='admin',
            last_name='admin',
            password=password,
            is_staff=True,
            is_superuser=True
        )
        Token.objects.create(user=user)

        

class CustomUser(AbstractBaseUser, PermissionsMixin):
    uuid = models.CharField(default='000000000000000000000', editable=False, max_length=255)
    email = models.EmailField(unique=True, primary_key=True)
    first_name = models.CharField(max_length=30, blank=True)
    last_name = models.CharField(max_length=30, blank=True)
    provider = models.CharField(max_length=30, blank=True, default='Django')
    date_joined = models.DateTimeField(default=timezone.now)
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    is_superuser = models.BooleanField(default=False)

    objects = CustomUserManager()

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = []

    def __str__(self):
        return {
            'uuid': self.uuid,
            'email': self.email,
            'first_name': self.first_name,
            'last_name': self.last_name,
        }
    
    def get_info(self):
        return {
            'uuid': self.uuid,
            'email': self.email,
            'first_name': self.first_name,
            'last_name': self.last_name,
        }

    def get_full_name(self):
        return f'{self.first_name} {self.last_name}'

    def get_short_name(self):
        return self.first_name
    
    def get_uuid(self):
        return self.uuid
    
    def get_email(self):
        return self.email
    
    def get_provider(self):
        return self.provider


