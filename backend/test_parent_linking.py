import os
import django
import uuid

# Setup Django environment BEFORE importing anything else
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'hostel_project.settings')
django.setup()

from django.conf import settings
settings.ALLOWED_HOSTS.append('testserver')

from rest_framework.test import APIClient
from django.contrib.auth.models import User
from smart_leaves.models import UserProfile, Role

def test_parent_linking():
    client = APIClient()
    
    # 1. Register a student first
    student_username = f"test_student_{uuid.uuid4().hex[:6]}"
    parent_username = f"test_parent_{uuid.uuid4().hex[:6]}"
    
    print(f"Registering student: {student_username} requesting parent: {parent_username}")
    resp = client.post('/api/register/', {
        'username': student_username,
        'password': 'password123',
        'email': f'{student_username}@example.com',
        'role': 'STUDENT',
        'parent_username': parent_username
    })
    
    if resp.status_code != 201:
        print(f"Student registration failed: {resp.data}")
        return

    student_profile = UserProfile.objects.get(user__username=student_username)
    print(f"Student registered. Parent link: {student_profile.parent}")
    print(f"Requested Parent: {student_profile.requested_parent_username}")

    # 2. Register the parent second
    print(f"Registering parent: {parent_username}")
    resp = client.post('/api/register/', {
        'username': parent_username,
        'password': 'password123',
        'email': f'{parent_username}@example.com',
        'role': 'PARENT'
    })
    
    if resp.status_code != 201:
        print(f"Parent registration failed: {resp.data}")
        return

    # 3. Verify the link
    student_profile.refresh_from_db()
    parent_profile = UserProfile.objects.get(user__username=parent_username)
    
    print(f"Parent registered. Student's parent link after: {student_profile.parent}")
    
    if student_profile.parent == parent_profile:
        print("SUCCESS: Bidirectional linking worked!")
    else:
        print("FAILURE: Bidirectional linking failed!")

if __name__ == "__main__":
    test_parent_linking()
