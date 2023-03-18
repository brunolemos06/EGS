from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from rest_framework.authtoken.models import Token

class CustomUserManager(BaseUserManager):
    def create_user(self, provider_id, provider, password=None, **extra_fields):
        if not provider_id:
            raise ValueError('The provider_id field must be set')
        if not provider:
            raise ValueError('The provider field must be set')
        
        user = self.model(
            provider_id=provider_id,
            provider=provider,
            name = str(provider_id) + provider,
            **extra_fields
        )
        user.set_password(password)
        user.save(using=self._db)

    def create_superuser(self, name, provider_id, provider, password=None):
        user = self.create_user(
            name='admin',
            provider_id='0',
            provider='Django',
            is_staff=True,
            is_superuser=True,
        )
        Token.objects.create(user=user)

        

class CustomUser(AbstractBaseUser, PermissionsMixin):
    id          = models.AutoField(verbose_name="id", primary_key=True)
    name        = models.CharField(max_length=255, unique=True)
    provider_id = models.CharField(editable=False, max_length=255)
    provider    = models.CharField(default='Django', editable=False, max_length=255)

    is_staff    = models.BooleanField(default=False)
    is_active   = models.BooleanField(default=True)
    is_superuser= models.BooleanField(default=False)

    objects = CustomUserManager()

    USERNAME_FIELD = 'name'
    REQUIRED_FIELDS = ['provider_id', 'provider']

    def __str__(self):
        return {
            'provider_id': self.provider_id,
            'provider': self.provider,
        }
    
    def get_info(self):
        return {
            'provider_id': self.provider_id,
            'provider': self.provider,
        }
    
    def get_provider_id(self):
        return self.provider_id
    
    def get_provider(self):
        return self.provider


