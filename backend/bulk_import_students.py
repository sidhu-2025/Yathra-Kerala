import os
import csv
import django

# Setup Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'hostel_project.settings')
django.setup()

from django.contrib.auth.models import User
from smart_leaves.models import UserProfile, Role

def update_passwords_and_import(file_path):
    if not os.path.exists(file_path):
        print(f"Error: File {file_path} not found.")
        return

    with open(file_path, mode='r', encoding='utf-8') as f:
        reader = csv.reader(f)
        headers = next(reader)
        print(f"Detected {len(headers)} columns.")

        # Column indexes:
        # 1: Full Name
        # 2: Student ID (Username)
        # 7: Admission No (For Password)
        # 11: Email
        # 12: Guardian Name
        # 13: Guardian Phone

        count = 0
        for row in reader:
            if not any(row): continue
            
            try:
                full_name = row[1].strip()
                student_id = row[2].strip()
                admission_no = row[7].strip()
                email = row[11].strip() if len(row) > 11 else ""
                guardian_name = row[12].strip() if len(row) > 12 else ""
                guardian_phone = row[13].strip() if len(row) > 13 else ""

                if not student_id or student_id.lower() == 'student id(vml)':
                    continue
                
                username = student_id.lower().replace(" ", "")
                # NEW PASSWORD: vjec + Admission Number
                new_password = f"vjec{admission_no}"
                
                user_exists = User.objects.filter(username=username).exists()
                
                if user_exists:
                    user = User.objects.get(username=username)
                    user.set_password(new_password)
                    user.save()
                    print(f"Updated password for: {username} -> {new_password}")
                else:
                    # Create User if not exists
                    name_parts = full_name.split(' ', 1)
                    first_name = name_parts[0]
                    last_name = name_parts[1] if len(name_parts) > 1 else ""

                    user = User.objects.create_user(
                        username=username,
                        email=email or f"{username}@vjec.ac.in",
                        password=new_password,
                        first_name=first_name,
                        last_name=last_name
                    )
                    print(f"Created user: {username} with password {new_password}")

                # Sync/Create Profile
                profile, created = UserProfile.objects.get_or_create(
                    user=user,
                    defaults={'role': Role.STUDENT, 'phone_number': row[10].strip() if len(row) > 10 else ""}
                )
                
                # Update Parent Password too
                parent_username = f"parent_{username}"
                if User.objects.filter(username=parent_username).exists():
                    parent_user = User.objects.get(username=parent_username)
                    parent_user.set_password(new_password)
                    parent_user.save()
                    print(f"  - Updated parent password: {parent_username} -> {new_password}")

                count += 1
            except Exception as e:
                print(f"Error processing row: {e}")

    print(f"\nSuccessfully processed {count} students.")
    print("Passwords updated to: vjec + Admission Number")

if __name__ == "__main__":
    update_passwords_and_import('students.csv')
