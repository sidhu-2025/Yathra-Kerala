import requests
import os
from django.conf import settings

def send_leave_sms(leave_request, template_type='SUBMISSION'):
    """
    Sends an SMS notification to the parent using Fast2SMS.
    template_type: 'SUBMISSION' or 'APPROVAL'
    """
    api_key = os.getenv('FAST2SMS_API_KEY')
    if not api_key:
        print("Fast2SMS API Key not found in environment.")
        return False

    from .models import UserProfile
    
    # Explicitly fetch student profile from default DB using student_id
    try:
        student_profile = UserProfile.objects.using('default').get(id=leave_request.student_id)
    except UserProfile.DoesNotExist:
        print(f"SMS Error: Student profile {leave_request.student_id} not found.")
        return False

    parent_profile = student_profile.parent
    if not parent_profile:
        # Try to find parent by requested_parent_username if not directly linked
        if student_profile.requested_parent_username:
            parent_profile = UserProfile.objects.using('default').filter(
                user__username__iexact=student_profile.requested_parent_username,
                role='PARENT'
            ).first()

    if not parent_profile or not parent_profile.phone_number:
        print(f"SMS Error: Parent or phone number not found for student {student_profile.user.username}")
        return False

    # Clean phone number (remove non-digits, ensure 10 digits for India)
    phone = "".join(filter(str.isdigit, str(parent_profile.phone_number)))
    if len(phone) < 10:
        print(f"SMS Error: Invalid phone number '{parent_profile.phone_number}' for parent {parent_profile.user.username}")
        return False
    
    if len(phone) > 10:
        phone = phone[-10:]
    
    vml_id = student_profile.user.username
    student_name = student_profile.user.get_full_name() or vml_id
    start_date = leave_request.start_date.strftime('%d-%m-%Y %H:%M')
    end_date = leave_request.end_date.strftime('%d-%m-%Y %H:%M')
    reason = leave_request.reason

    if template_type == 'SUBMISSION':
        message = f"SmartLeave: {student_name} ({vml_id}) has submitted a leave request. From: {start_date} To: {end_date}. Reason: {reason}"
    elif template_type == 'APPROVAL':
        message = f"SmartLeave: {student_name} ({vml_id})'s leave request has been APPROVED by the Warden. Reason: {reason}. Dates: {start_date} to {end_date}."
    elif template_type == 'EXIT':
        message = f"SmartLeave Notification: Student {student_name} ({vml_id}) has EXITED the hostel after scanning their QR code for the approved leave."
    elif template_type == 'ENTRY':
        message = f"SmartLeave Notification: Student {student_name} ({vml_id}) has ENTERED the hostel/returned from their leave successfully."
    else:
        message = f"SmartLeave: Update on leave request for {student_name} ({vml_id}): {leave_request.status}"

    url = "https://www.fast2sms.com/dev/bulkV2"
    
    print(f"SMS Debug: Sending {template_type} to {phone} for {student_name}")

    # Fast2SMS Quick SMS Payload
    payload = {
        "message": message,
        "language": "english",
        "route": "q", # 'q' for Quick SMS
        "numbers": phone,
    }
    
    headers = {
        'authorization': api_key,
        'Content-Type': "application/x-www-form-urlencoded",
        'Cache-Control': "no-cache",
    }

    try:
        response = requests.post(url, data=payload, headers=headers)
        result = response.json()
        if result.get('return'):
            print(f"SMS SUCCESS: Sent to {phone}. Response: {result}")
            return True
        else:
            print(f"SMS FAILURE: Fast2SMS Error for {phone}: {result}")
            return False
    except Exception as e:
        print(f"SMS EXCEPTION: {str(e)}")
        return False
