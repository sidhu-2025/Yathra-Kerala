import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'hostel_project.settings')
django.setup()

from django.contrib.auth.models import User
from smart_leaves.models import UserProfile, LeaveRequest, Complaint, Attendance, AccessLog, VacatingForm
from rest_framework.authtoken.models import Token

def clear_data():
    print("Clearing all data...")
    # Deleting Users will cascade to UserProfiles and most related data
    count, deleted = User.objects.all().delete()
    print(f"Deleted {count} objects: {deleted}")
    
    # Just in case, clear orphan profiles or other tables if needed
    UserProfile.objects.all().delete()
    print("Cleanup complete. Database is now empty for testing.")

if __name__ == "__main__":
    clear_data()
