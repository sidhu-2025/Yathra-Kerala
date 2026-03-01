-- Run these commands in your MySQL client (e.g., MySQL Workbench or Command Line)

-- 1. Create the 'student' database (for Users, Profiles, etc.)
CREATE DATABASE IF NOT EXISTS student;

-- 3. Create a user if you haven't already
-- CREATE USER 'root'@'localhost' IDENTIFIED BY '2004';
-- GRANT ALL PRIVILEGES ON student.* TO 'root'@'localhost';
-- GRANT ALL PRIVILEGES ON leave_database.* TO 'root'@'localhost';
-- FLUSH PRIVILEGES;

-- 2. Create the 'leave_database' database (for Leaves, Complaints, Attendance, etc.)
CREATE DATABASE IF NOT EXISTS leave_database;

-- After running these, you will need to run the following Django commands to migrate:
-- CD into the backend folder first:
-- 1. venv\Scripts\python.exe manage.py migrate
-- 2. venv\Scripts\python.exe manage.py migrate --database=leave_db
