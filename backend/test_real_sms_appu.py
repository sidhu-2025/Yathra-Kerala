import os
import django

# Setup Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'hostel_project.settings')
django.setup()

from smart_leaves.models import LeaveRequest, UserProfile
from smart_leaves.sms_utils import send_leave_sms

def test_real_sms_for_appu():
    print("--- Testing Real SMS for Appu ---")
    
    # Get Appu's profile first (default DB)
    appu_profile = UserProfile.objects.using('default').filter(user__username='appu').first()
    if not appu_profile:
        print("Profile for Appu not found!")
        return

    # Get latest leave for this student ID (leave_db DB)
    leave = LeaveRequest.objects.using('leave_db').filter(student_id=appu_profile.id).order_by('-created_at').first()
    if not leave:
        print("No leave requests found for Appu!")
        return

    print(f"Latest Leave ID: {leave.id}, Status: {leave.status}")
    print(f"Student: {leave.student.user.username}")
    if leave.student.parent:
        print(f"Parent: {leave.student.parent.user.username}, Phone: {leave.student.parent.phone_number}")
    else:
        print("Parent: NONE")

    # Send real SMS (Submission)
    print("\nAttempting to send real SUBMISSION SMS via Fast2SMS...")
    success_sub = send_leave_sms(leave, template_type='SUBMISSION')
    print(f"Submission Result: {'SUCCESS' if success_sub else 'FAILURE'}")

    # Send real SMS (Approval)
    print("\nAttempting to send real APPROVAL SMS via Fast2SMS...")
    success_app = send_leave_sms(leave, template_type='APPROVAL')
    print(f"Approval Result: {'SUCCESS' if success_app else 'FAILURE'}")
    
    print(f"\nFinal Result: {'BOTH SUCCESS' if success_sub and success_app else 'ONE OR MORE FAILED'}")

if __name__ == "__main__":
    test_real_sms_for_appu()
