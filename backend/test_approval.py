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

def test_approval():
    # Find a leave request in PENDING_PARENT status
    leave = LeaveRequest.objects.filter(status='PENDING_PARENT').first()
    if not leave:
        print("No pending leave requests found.")
        return

    print(f"Testing approval for Leave ID {leave.id}, Student ID {leave.student_id}")
    
    # Find the student's parent
    student_profile = UserProfile.objects.using('default').get(id=leave.student_id)
    parent_profile = student_profile.parent
    
    if not parent_profile:
        print(f"Student {student_profile.user.username} has no parent linked!")
        return
        
    print(f"Parent: {parent_profile.user.username} (ID {parent_profile.id})")
    
    # Get parent's token
    token, _ = Token.objects.using('default').get_or_create(user=parent_profile.user)
    
    # Setup API client
    client = APIClient()
    client.credentials(HTTP_AUTHORIZATION='Token ' + token.key)
    
    # Call approve_by_parent
    url = f'/api/leaves/{leave.id}/approve_by_parent/'
    print(f"POST to {url}")
    response = client.post(url)
    
    print(f"Response Status: {response.status_code}")
    print(f"Response Data: {response.data}")
    
    # Refresh leave object
    leave.refresh_from_db()
    print(f"Status after: {leave.status}")
    print(f"Parent Approved after: {leave.parent_approved}")

if __name__ == "__main__":
    test_approval()
