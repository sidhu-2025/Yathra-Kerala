import os
import django
from django.contrib.auth.models import User

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'hostel_project.settings')
django.setup()

def test_password_change():
    username = 'vml23cs094' # Chris George
    new_pass = 'vjec8777_new'
    old_pass = 'vjec8777' # From our previous import
    
    try:
        user = User.objects.get(username=username)
        print(f"Testing password change for {username}...")
        
        # Verify old password
        if not user.check_password(old_pass):
            print("FAILED: Old password check failed.")
            return

        # Set new password
        user.set_password(new_pass)
        user.save()
        
        # Verify new password
        user = User.objects.get(username=username)
        if user.check_password(new_pass):
            print("SUCCESS: Password updated and verified.")
            # Reset back to original for user
            user.set_password(old_pass)
            user.save()
            print("SUCCESS: Reset back to original password.")
        else:
            print("FAILED: New password verification failed.")
            
    except Exception as e:
        print(f"ERROR: {e}")

if __name__ == "__main__":
    test_password_change()
