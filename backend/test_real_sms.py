import os
import django
from dotenv import load_dotenv

# Setup Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'hostel_project.settings')
load_dotenv()
django.setup()

from smart_leaves.models import LeaveRequest
from smart_leaves.sms_utils import send_leave_sms

def test_real_sms():
    print(f"FAST2SMS_API_KEY: {os.getenv('FAST2SMS_API_KEY')[:10]}...")
    
    leave = LeaveRequest.objects.first()
    if not leave:
        print("No leave requests found.")
        return

    print(f"Testing REAL SMS for Leave ID: {leave.id}")
    print(f"Student: {leave.student.user.username}")
    
    parent = leave.student.parent
    if parent:
        print(f"Parent: {parent.user.username}, Phone: {parent.phone_number}")
    else:
        print(f"No parent linked for student {leave.student.user.username}")
        if leave.student.requested_parent_username:
             print(f"Requested Parent Username: {leave.student.requested_parent_username}")

    # Try sending for real
    success = send_leave_sms(leave, template_type='SUBMISSION')
    print(f"Real Sending Result: {success}")

if __name__ == "__main__":
    test_real_sms()
