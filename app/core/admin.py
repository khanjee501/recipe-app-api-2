"""
Django admin customization
"""

from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin

from core import models


class userAdmin(BaseUserAdmin):
    """
    Define admin pages for users.
    """

    ordering = ["id"]
    list_display = ["email", "name"]


admin.site.register(models.User, userAdmin)
