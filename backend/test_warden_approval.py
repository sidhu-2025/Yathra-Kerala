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

def test_warden_approval():
    # Find a leave request in PENDING_WARDEN status (approved by parent)
    leave = LeaveRequest.objects.filter(status='PENDING_WARDEN').first()
    if not leave:
        print("No pending warden leave requests found. Try running test_approval.py first.")
        return

    print(f"Testing warden approval for Leave ID {leave.id}, Student {leave.student.user.username}")
    
    # Find a warden
    warden_profile = UserProfile.objects.filter(role=Role.WARDEN).first()
    if not warden_profile:
        print("No warden found in the database!")
        return
        
    print(f"Warden: {warden_profile.user.username} (ID {warden_profile.id})")
    
    # Get warden's token
    token, _ = Token.objects.using('default').get_or_create(user=warden_profile.user)
    
    # Setup API client
    client = APIClient()
    client.credentials(HTTP_AUTHORIZATION='Token ' + token.key)
    
    # Call approve_by_warden
    url = f'/api/leaves/{leave.id}/approve_by_warden/'
    print(f"POST to {url}")
    response = client.post(url)
    
    print(f"Response Status: {response.status_code}")
    if response.status_code == 200:
        print(f"Response Data: {response.data}")
    else:
        print(f"Error: {response.data if hasattr(response, 'data') else response.content}")
    
    # Refresh leave object
    leave.refresh_from_db()
    print(f"Status after: {leave.status}")
    print(f"Warden Approved after: {leave.warden_approved}")
    print(f"QR Code Token: {leave.qr_code_token}")
    
    if leave.qr_code_token:
        print("SUCCESS: QR Code generated!")
    else:
        print("FAILURE: QR Code NOT generated!")

if __name__ == "__main__":
    test_warden_approval()
