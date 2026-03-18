import os
import django
from unittest.mock import MagicMock, patch

# Setup Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'hostel_project.settings')
django.setup()

from smart_leaves.models import LeaveRequest
from smart_leaves.sms_utils import send_leave_sms

def test_sms_logic():
    # Find a leave request
    leave = LeaveRequest.objects.first()
    if not leave:
        print("No leave requests found for testing.")
        return

    print(f"Testing SMS for Leave ID: {leave.id}")
    
    # Mock the API Key
    with patch.dict(os.environ, {"FAST2SMS_API_KEY": "MOCK_KEY"}):
        # Mock requests.post to avoid actual network call
        with patch('requests.post') as mock_post:
            mock_post.return_value.json.return_value = {"return": True, "message": "Success"}
            
            # Test Submission SMS
            print("Sending Submission SMS...")
            success = send_leave_sms(leave, template_type='SUBMISSION')
            print(f"Submission Success: {success}")
            
            # Test Approval SMS
            print("Sending Approval SMS...")
            success = send_leave_sms(leave, template_type='APPROVAL')
            print(f"Approval Success: {success}")

if __name__ == "__main__":
    test_sms_logic()
