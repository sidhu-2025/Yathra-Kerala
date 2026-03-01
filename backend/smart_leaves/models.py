from django.db import models
from django.contrib.auth.models import User
import uuid

class Role(models.TextChoices):
    STUDENT = 'STUDENT', 'Student'
    PARENT = 'PARENT', 'Parent'
    WARDEN = 'WARDEN', 'Warden'
    SECURITY = 'SECURITY', 'Security'

class UserProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    role = models.CharField(max_length=20, choices=Role.choices, default=Role.STUDENT)
    phone_number = models.CharField(max_length=15, blank=True, null=True)
    # For students, link to their parent
    parent = models.ForeignKey('self', on_delete=models.SET_NULL, null=True, blank=True, limit_choices_to={'role': Role.PARENT})
    requested_parent_username = models.CharField(max_length=150, blank=True, null=True)

    def __str__(self):
        return f"{self.user.username} - {self.role}"

class LeaveRequest(models.Model):
    STATUS_CHOICES = [
        ('PENDING_PARENT', 'Pending Parent Approval'),
        ('PENDING_WARDEN', 'Pending Warden Approval'),
        ('APPROVED', 'Approved'),
        ('REJECTED', 'Rejected'),
        ('COMPLETED', 'Completed (Returned)'),
    ]
    
    student = models.ForeignKey(UserProfile, on_delete=models.CASCADE, limit_choices_to={'role': Role.STUDENT}, db_constraint=False)
    reason = models.TextField()
    destination = models.CharField(max_length=255, blank=True, default='')
    start_date = models.DateTimeField()
    end_date = models.DateTimeField()
    
    parent_approved = models.BooleanField(default=False)
    warden_approved = models.BooleanField(default=False)
    
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='PENDING_PARENT')
    
    qr_code_token = models.CharField(max_length=100, unique=True, blank=True, null=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def save(self, *args, **kwargs):
        if not self.qr_code_token and self.status == 'APPROVED':
            self.qr_code_token = str(uuid.uuid4())
        super().save(*args, **kwargs)

    def __str__(self):
        return f"Leave {self.id} - {self.student.user.username}"

class Complaint(models.Model):
    STATUS_CHOICES = [
        ('PENDING', 'Pending'),
        ('RESOLVED', 'Resolved'),
    ]
    student = models.ForeignKey(UserProfile, on_delete=models.CASCADE, limit_choices_to={'role': Role.STUDENT}, db_constraint=False)
    description = models.TextField()
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='PENDING')
    created_at = models.DateTimeField(auto_now_add=True)
    resolved_at = models.DateTimeField(null=True, blank=True)

    def __str__(self):
        return f"Complaint {self.id} by {self.student.user.username}"

class Attendance(models.Model):
    student = models.ForeignKey(UserProfile, on_delete=models.CASCADE, limit_choices_to={'role': Role.STUDENT}, db_constraint=False)
    date = models.DateField(auto_now_add=True)
    is_present = models.BooleanField(default=False)
    marked_by = models.ForeignKey(UserProfile, on_delete=models.SET_NULL, null=True, related_name='attendances_marked', limit_choices_to={'role': Role.WARDEN}, db_constraint=False)

    class Meta:
        unique_together = ('student', 'date')

    def __str__(self):
        return f"{self.student.user.username} - {self.date} - {'Present' if self.is_present else 'Absent'}"

class AccessLog(models.Model):
    LOG_TYPE = [
        ('ENTRY', 'Entry'),
        ('EXIT', 'Exit'),
    ]
    leave_request = models.ForeignKey(LeaveRequest, on_delete=models.CASCADE)
    security_personnel = models.ForeignKey(UserProfile, on_delete=models.SET_NULL, null=True, limit_choices_to={'role': Role.SECURITY}, db_constraint=False)
    log_type = models.CharField(max_length=10, choices=LOG_TYPE)
    timestamp = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.log_type} - {self.leave_request.student.user.username} at {self.timestamp}"

class VacatingForm(models.Model):
    STATUS_CHOICES = [
        ('PENDING', 'Pending'),
        ('APPROVED', 'Approved'),
        ('REJECTED', 'Rejected'),
    ]
    student = models.ForeignKey(UserProfile, on_delete=models.CASCADE, limit_choices_to={'role': Role.STUDENT}, db_constraint=False)
    reason = models.TextField()
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='PENDING')
    submitted_at = models.DateTimeField(auto_now_add=True)
    approved_by = models.ForeignKey(UserProfile, on_delete=models.SET_NULL, null=True, blank=True, related_name='vacating_approvals', limit_choices_to={'role': Role.WARDEN}, db_constraint=False)
    approved_at = models.DateTimeField(null=True, blank=True)

    def __str__(self):
        return f"Vacating Form {self.id} - {self.student.user.username}"
