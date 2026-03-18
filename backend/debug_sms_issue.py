import os
import django

# Setup Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'hostel_project.settings')
django.setup()

from smart_leaves.models import UserProfile, Role

def debug_sms_issue():
    print("--- Debugging SMS Issue ---")
    
    # Check Appu
    appu = UserProfile.objects.filter(user__username='appu').first()
    if not appu:
        print("Student 'appu' not found!")
    else:
        print(f"Student: {appu.user.username}")
        print(f"Role: {appu.role}")
        print(f"Requested Parent Username: '{appu.requested_parent_username}'")
        if appu.parent:
            print(f"Linked Parent: {appu.parent.user.username}")
            print(f"Parent Phone: {appu.parent.phone_number}")
        else:
            print("Linked Parent: NONE")

    # Check Manoj
    manoj = UserProfile.objects.filter(user__username='manoj').first()
    if not manoj:
        print("Parent 'manoj' not found!")
    else:
        print(f"\nParent Profile: {manoj.user.username}")
        print(f"Role: {manoj.role}")
        print(f"Phone Number: {manoj.phone_number}")
        
        # Check students linking to manoj
        linked_students = UserProfile.objects.filter(parent=manoj)
        print(f"Students specifically linked to Manoj: {[s.user.username for s in linked_students]}")
        
        potential_students = UserProfile.objects.filter(requested_parent_username__iexact='manoj')
        print(f"Students requesting 'manoj': {[s.user.username for s in potential_students]}")

if __name__ == "__main__":
    debug_sms_issue()
