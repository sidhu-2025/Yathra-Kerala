from django.contrib import admin
from .models import UserProfile, LeaveRequest, Complaint, Attendance, AccessLog

@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    list_display = ('user', 'role', 'phone_number', 'parent')
    list_filter = ('role',)
    search_fields = ('user__username', 'phone_number')

@admin.register(LeaveRequest)
class LeaveRequestAdmin(admin.ModelAdmin):
    list_display = ('student', 'start_date', 'end_date', 'status', 'parent_approved', 'warden_approved')
    list_filter = ('status', 'parent_approved', 'warden_approved')
    search_fields = ('student__user__username',)

@admin.register(Complaint)
class ComplaintAdmin(admin.ModelAdmin):
    list_display = ('student', 'status', 'created_at')
    list_filter = ('status',)
    search_fields = ('student__user__username', 'description')

@admin.register(Attendance)
class AttendanceAdmin(admin.ModelAdmin):
    list_display = ('student', 'date', 'is_present', 'marked_by')
    list_filter = ('date', 'is_present')
    search_fields = ('student__user__username',)

@admin.register(AccessLog)
class AccessLogAdmin(admin.ModelAdmin):
    list_display = ('leave_request', 'log_type', 'timestamp', 'security_personnel')
    list_filter = ('log_type', 'timestamp')
