import os
import django

# Setup Django environment BEFORE importing anything else
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'hostel_project.settings')
django.setup()

from django.conf import settings
settings.ALLOWED_HOSTS.append('testserver')

from rest_framework.test import APIClient
from rest_framework.authtoken.models import Token

from smart_leaves.models import LeaveRequest, UserProfile, Role

def test_view():
    # Target parent_vml23ad017 (ID 7)
    parent_profile = UserProfile.objects.using('default').get(id=7)
    print(f"Testing view for Parent: {parent_profile.user.username} (ID {parent_profile.id})")
    
    # Get parent's token
    token, _ = Token.objects.using('default').get_or_create(user=parent_profile.user)
    
    # Setup API client
    client = APIClient()
    client.credentials(HTTP_AUTHORIZATION='Token ' + token.key)
    
    # Call GET /api/leaves/
    url = '/api/leaves/'
    print(f"GET {url}")
    response = client.get(url)
    
    print(f"Response Status: {response.status_code}")
    if response.status_code == 200:
        print(f"Found {len(response.data)} leaves.")
        for l in response.data:
            print(f"  - Leave ID {l['id']}, Student {l['student_name']}, Status {l['status']}")
    else:
        print(f"Error: {response.data}")

if __name__ == "__main__":
    test_view()
