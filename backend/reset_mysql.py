import os
import django
from django.db import connections

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'hostel_project.settings')
django.setup()

def reset_database(db_alias):
    print(f"Resetting database: {db_alias}")
    with connections[db_alias].cursor() as cursor:
        # Get all tables
        cursor.execute("SHOW TABLES")
        tables = cursor.fetchall()
        
        # Disable foreign key checks
        cursor.execute("SET FOREIGN_KEY_CHECKS = 0")
        
        for table in tables:
            table_name = table[0]
            print(f"  Dropping table: {table_name}")
            cursor.execute(f"DROP TABLE IF EXISTS `{table_name}`")
            
        # Re-enable foreign key checks
        cursor.execute("SET FOREIGN_KEY_CHECKS = 1")
    print(f"Finished resetting {db_alias}\n")

if __name__ == "__main__":
    try:
        reset_database('default')
        reset_database('leave_db')
        print("All databases cleared successfully!")
    except Exception as e:
        print(f"Error: {e}")
