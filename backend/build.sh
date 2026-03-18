#!/usr/bin/env bash
# exit on error
set -o errexit

# Install dependencies
pip install -r requirements.txt

# Collect static files
python manage.py collectstatic --no-input

# Run migrations for the default database (student models)
python manage.py migrate

# Run migrations for the leave database
python manage.py migrate --database=leave_db
