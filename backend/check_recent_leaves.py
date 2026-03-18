import os
import django

# Setup Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'hostel_project.settings')
django.setup()

from smart_leaves.models import LeaveRequest

def check_recent_leaves():
    print("--- Recent Leave Requests (Last 5) ---")
    leaves = LeaveRequest.objects.using('leave_db').all().order_by('-created_at')[:5]
    for l in leaves:
        student_name = "Unknown"
        # Try to get student name from default DB
        from smart_leaves.models import UserProfile
        try:
            student = UserProfile.objects.using('default').get(id=l.student_id)
            student_name = student.user.username
        except:
            pass
            
        print(f"ID: {l.id} | Student: {student_name: <10} | Status: {l.status: <15} | W-Apprv: {l.warden_approved} | P-Apprv: {l.parent_approved} | Created: {l.created_at} | Updated: {l.updated_at}")

if __name__ == "__main__":
    check_recent_leaves()
