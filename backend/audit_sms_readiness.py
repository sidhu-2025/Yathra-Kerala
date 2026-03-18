import os
import django

# Setup Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'hostel_project.settings')
django.setup()

from smart_leaves.models import UserProfile, Role

def audit_sms_readiness():
    print("--- SMS Readiness Audit ---")
    students = UserProfile.objects.filter(role='STUDENT')
    print(f"Total Students found: {students.count()}")
    
    ready_count = 0
    missing_parent_count = 0
    missing_phone_count = 0
    
    for s in students:
        parent = s.parent
        if not parent:
            # Check if there's a requested parent username
            if s.requested_parent_username:
                parent = UserProfile.objects.filter(user__username__iexact=s.requested_parent_username, role='PARENT').first()
            
        if not parent:
            print(f"Student: {s.user.username: <15} | Parent: MISSING (Requested: '{s.requested_parent_username}')")
            missing_parent_count += 1
        elif not parent.phone_number:
            print(f"Student: {s.user.username: <15} | Parent: {parent.user.username: <15} | Phone: MISSING")
            missing_phone_count += 1
        else:
            print(f"Student: {s.user.username: <15} | Parent: {parent.user.username: <15} | Phone: {parent.phone_number}")
            ready_count += 1
            
    print("\n--- Summary ---")
    print(f"Ready for SMS: {ready_count}")
    print(f"Missing Parent Link: {missing_parent_count}")
    print(f"Missing Parent Phone: {missing_phone_count}")
    print(f"Total: {students.count()}")

if __name__ == "__main__":
    audit_sms_readiness()
