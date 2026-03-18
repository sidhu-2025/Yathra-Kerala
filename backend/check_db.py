import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'hostel_project.settings')
django.setup()

from django.db import connections
from smart_leaves.models import Attendance

db_conn = connections['leave_db']
with db_conn.cursor() as cursor:
    cursor.execute("DESCRIBE smart_leaves_attendance")
    columns = cursor.fetchall()
    for col in columns:
        print(col)
