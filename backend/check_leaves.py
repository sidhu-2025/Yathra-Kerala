import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'hostel_project.settings')
django.setup()

from smart_leaves.models import LeaveRequest

print(f"{'ID':<4} | {'Student ID':<10} | {'Status':<20} | {'Parent Appr':<12}")
print("-" * 55)
for leave in LeaveRequest.objects.all():
    print(f"{leave.id:<4} | {leave.student_id:<10} | {leave.status:<20} | {leave.parent_approved:<12}")
