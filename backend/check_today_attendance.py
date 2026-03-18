import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'hostel_project.settings')
django.setup()

from django.utils import timezone
from smart_leaves.models import Attendance

today = timezone.now().date()
existing = Attendance.objects.filter(date=today)
print(f"Total records for {today}: {existing.count()}")
for r in existing:
    print(f"Student ID: {r.student_id}, Status: {r.is_present}")
