from django.apps import AppConfig

<<<<<<< HEAD

class AccountsConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'accounts'
=======
class AccountsConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'accounts'

    def ready(self):
        import accounts.signals  # ⬅️ هذا يفعل الـ signals عند بدء المشروع
>>>>>>> 78439836091054e64c7c509bc55485550c515c0d
