import os, django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'hostel_project.settings')
django.setup()
from smart_leaves.models import LeaveRequest
leaves = LeaveRequest.objects.all().order_by('-created_at')[:10]
for l in leaves:
    student = l.student.user.username
    parent = l.student.parent.user.username if l.student.parent else 'None'
    phone = l.student.parent.phone_number if l.student.parent else 'N/A'
    msg_status = "READY" if (l.student.parent and l.student.parent.phone_number) else "MISSING LINK/PHONE"
    print(f"ID: {l.id:3} Student: {student:15} Parent: {parent:15} Phone: {phone:13} Created: {l.created_at.strftime('%Y-%m-%d %H:%M')}")
    print(f"    Status: {l.status:15} Msg Config: {msg_status}")
