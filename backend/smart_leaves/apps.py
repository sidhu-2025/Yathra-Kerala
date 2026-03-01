from django.apps import AppConfig


class SmartLeavesConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'smart_leaves'

    def ready(self):
        import smart_leaves.signals
