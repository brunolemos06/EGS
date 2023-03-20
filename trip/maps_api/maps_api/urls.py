"""maps_api URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/4.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include, re_path

from rest_framework import permissions
# from drf_yasg.views import get_schema_view
# from drf_yasg import openapi

from rest_framework.views import APIView
from rest_framework.schemas import get_schema_view
from django.views.generic import TemplateView

from django.views.decorators.csrf import csrf_exempt

urlpatterns = [
    path('admin/', admin.site.urls),
    path('directions/', include('directions.urls')),
    # path('user/', csrf_exempt(views.UserView.as_view()), name='user'),
    # path('trip/', csrf_exempt(views.TripView.as_view()), name='trip'),
    # path('user/', views.user, name='user'),
    # path('trip/', views.trip, name='trip'),
    # path('api/', get_schema_view(
    #     title="Trip API",
    #     description="API for all things …",
    #     version="1.0.0",
    # ), name='api-schema'),
    path('docs/', TemplateView.as_view(
        template_name='swagger-ui.html',
        extra_context={'schema_url':'api-schema'}
    ), name='swagger-ui'),

]
