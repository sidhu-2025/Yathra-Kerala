import os, django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'hostel_project.settings')
django.setup()
from smart_leaves.models import UserProfile
from django.contrib.auth.models import User

print("--- All User Profiles ---")
profiles = UserProfile.objects.all()
for p in profiles:
    print(f"Username: {p.user.username:20} Role: {p.role:10} Phone: {p.phone_number or 'N/A'}")

print("\n--- Summary by Role ---")
for role_choice in ['STUDENT', 'PARENT', 'WARDEN', 'ADMIN']:
    count = UserProfile.objects.filter(role=role_choice).count()
    print(f"{role_choice:10}: {count}")
