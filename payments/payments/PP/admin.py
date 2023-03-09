from django.contrib import admin
from .models import ongoing_payment, completed_payment

# Register your models here.
admin.site.register(ongoing_payment)
admin.site.register(completed_payment)