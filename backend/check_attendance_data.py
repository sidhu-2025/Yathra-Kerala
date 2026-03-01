import os
import django

# Setup Django environment BEFORE importing anything else
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'hostel_project.settings')
django.setup()

from smart_leaves.models import UserProfile, Attendance

def check_attendance_data():
    parents = UserProfile.objects.using('default').filter(role='PARENT')
    for p in parents:
        students = UserProfile.objects.using('default').filter(parent=p)
        print(f"Parent: {p.user.username} (ID {p.id}) has {students.count()} students.")
        for s in students:
            atts = Attendance.objects.filter(student_id=s.id)
            print(f"  - Student: {s.user.username} (ID {s.id}) has {atts.count()} attendance records.")
            for a in atts:
                print(f"    - Attendance: ID {a.id}, Date {a.date}, Present {a.is_present}")

if __name__ == "__main__":
    check_attendance_data()
