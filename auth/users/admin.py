from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from users.models import CustomUser

class CustomUserAdmin(UserAdmin):
    model = CustomUser
    list_display = ['provider_id', 'provider',]
    search_fields = ['provider_id', 'provider',]
    readonly_fields = ['provider_id', 'provider',]
    ordering = ('id',)

admin.site.register(CustomUser, CustomUserAdmin)
