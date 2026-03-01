import os
import django

# Setup Django environment BEFORE importing anything else
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'hostel_project.settings')
django.setup()

from django.conf import settings
settings.ALLOWED_HOSTS.append('testserver')

from rest_framework.test import APIClient
from rest_framework.authtoken.models import Token
from smart_leaves.models import UserProfile, Attendance, Role

def test_attendance_visibility():
    # Target parent_vml23ad017 (ID 7)
    parent_profile = UserProfile.objects.using('default').get(id=7)
    print(f"Testing attendance view for Parent: {parent_profile.user.username} (ID {parent_profile.id})")
    
    # Get parent's token
    token, _ = Token.objects.using('default').get_or_create(user=parent_profile.user)
    
    # Setup API client
    client = APIClient()
    client.credentials(HTTP_AUTHORIZATION='Token ' + token.key)
    
    # Call GET /api/attendance/
    url = '/api/attendance/'
    print(f"GET {url}")
    try:
        response = client.get(url)
        print(f"Response Status: {response.status_code}")
        if response.status_code == 200:
            print(f"Found {len(response.data)} attendance records.")
            for a in response.data:
                print(f"  - Record ID {a['id']}, Student {a['student_name']}, Date {a['date']}, Present {a['is_present']}")
        else:
            print(f"Error: {response.data}")
    except Exception as e:
        print(f"Exception during request: {e}")

if __name__ == "__main__":
    test_attendance_visibility()
