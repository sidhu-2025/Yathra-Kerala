class DatabaseRouter:
    """
    A router to control all database operations on models in the
    smart_leaves application.
    """
    def db_for_read(self, model, **hints):
        if model._meta.app_label == 'smart_leaves':
            if model._meta.model_name == 'userprofile':
                return 'default'  # 'default' is mapped to 'student' DB
            return 'leave_db'     # mapped to 'leave_database'
        return 'default'

    def db_for_write(self, model, **hints):
        if model._meta.app_label == 'smart_leaves':
            if model._meta.model_name == 'userprofile':
                return 'default'
            return 'leave_db'
        return 'default'

    def allow_relation(self, obj1, obj2, **hints):
        # Allow relations if both models are in the same app
        if obj1._meta.app_label == 'smart_leaves' or \
           obj2._meta.app_label == 'smart_leaves':
            return True
        return None

    def allow_migrate(self, db, app_label, model_name=None, **hints):
        if app_label == 'smart_leaves':
            if model_name == 'userprofile':
                return db == 'default'
            if model_name is None:
                # If model_name is None, it's a general check. 
                # We allow it on both to be safe, or specify. 
                # Django expects a boolean.
                return True 
            return db == 'leave_db'
        
        # Other apps (admin, auth, etc.) only go to default
        return db == 'default'
