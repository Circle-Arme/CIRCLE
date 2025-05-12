from django.apps import AppConfig


class FieldsConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'fields'

<<<<<<< HEAD
    def ready(self):
        import fields.signals
=======

    def ready(self):
        import fields.signals
>>>>>>> 78439836091054e64c7c509bc55485550c515c0d
