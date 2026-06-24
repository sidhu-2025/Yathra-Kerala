import os, django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'hostel_project.settings')
django.setup()
from django.contrib.auth.models import User
from smart_leaves.models import UserProfile

def create_test_user(username, password, role):
    user, created = User.objects.get_or_create(username=username)
    user.set_password(password)
    user.save()
    
    profile, p_created = UserProfile.objects.get_or_create(user=user)
    profile.role = role
    profile.save()
    print(f"User {username} created/updated with role {role} and password {password}")

if __name__ == "__main__":
    create_test_user("valid_student", "testpass123", "STUDENT")
    create_test_user("valid_warden", "testpass123", "WARDEN")
    create_test_user("valid_parent", "testpass123", "PARENT")
