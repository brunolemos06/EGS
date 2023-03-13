from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from users.models import CustomUser

class CustomUserAdmin(UserAdmin):
    model = CustomUser
    list_display = ['email', 'uuid', 'first_name', 'last_name', 'provider',]
    search_fields = ['email', 'uuid', 'provider',]
    readonly_fields = ['uuid', 'provider',]
    ordering = ('email',)

admin.site.register(CustomUser, CustomUserAdmin)
