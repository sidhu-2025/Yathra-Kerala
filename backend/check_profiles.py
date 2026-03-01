import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'hostel_project.settings')
django.setup()

from django.contrib.auth.models import User
from smart_leaves.models import UserProfile

print(f"{'ID':<4} | {'Username':<20} | {'Role':<10} | {'Parent ID':<10} | {'Parent Name':<20}")
print("-" * 75)
for profile in UserProfile.objects.all():
    parent_id = profile.parent.id if profile.parent else "None"
    parent_name = profile.parent.user.username if profile.parent else "None"
    print(f"{profile.id:<4} | {profile.user.username:<20} | {profile.role:<10} | {parent_id:<10} | {parent_name:<20}")
