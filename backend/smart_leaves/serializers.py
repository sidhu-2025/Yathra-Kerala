from rest_framework import serializers
from django.contrib.auth.models import User
from .models import UserProfile, LeaveRequest, Complaint, Attendance, AccessLog, VacatingForm

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'first_name', 'last_name', 'email']

class UserProfileSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    class Meta:
        model = UserProfile
        fields = ['id', 'user', 'role', 'phone_number', 'parent']

class LeaveRequestSerializer(serializers.ModelSerializer):
    student_name = serializers.CharField(source='student.user.username', read_only=True)
    class Meta:
        model = LeaveRequest
        fields = [
            'id', 'student', 'student_name', 'reason', 'destination',
            'start_date', 'end_date', 
            'parent_approved', 'warden_approved', 'status', 'qr_code_token', 
            'created_at', 'updated_at'
        ]
        read_only_fields = ['student', 'qr_code_token', 'status', 'parent_approved', 'warden_approved']

class ComplaintSerializer(serializers.ModelSerializer):
    student_name = serializers.CharField(source='student.user.username', read_only=True)
    class Meta:
        model = Complaint
        fields = ['id', 'student', 'student_name', 'description', 'status', 'created_at', 'resolved_at']
        read_only_fields = ['student', 'status', 'resolved_at']

class AttendanceSerializer(serializers.ModelSerializer):
    student_name = serializers.CharField(source='student.user.username', read_only=True)
    class Meta:
        model = Attendance
        fields = ['id', 'student', 'student_name', 'date', 'is_present', 'marked_by']

class AccessLogSerializer(serializers.ModelSerializer):
    class Meta:
        model = AccessLog
        fields = '__all__'

class VacatingFormSerializer(serializers.ModelSerializer):
    student_name = serializers.CharField(source='student.user.username', read_only=True)
    class Meta:
        model = VacatingForm
        fields = ['id', 'student', 'student_name', 'reason', 'status', 'submitted_at', 'approved_by', 'approved_at']
        read_only_fields = ['student', 'status', 'approved_by', 'approved_at']

class RegisterSerializer(serializers.Serializer):
    username = serializers.CharField()
    password = serializers.CharField(write_only=True)
    email = serializers.EmailField()
    role = serializers.ChoiceField(choices=[('STUDENT', 'Student'), ('PARENT', 'Parent'), ('WARDEN', 'Warden'), ('SECURITY', 'Security')])
    phone_number = serializers.CharField(required=False, allow_blank=True)
    parent_username = serializers.CharField(required=False, allow_blank=True)

    def validate_username(self, value):
        if User.objects.filter(username=value).exists():
            raise serializers.ValidationError("A user with this username already exists.")
        return value

    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data['email'],
            password=validated_data['password']
        )
        
        profile, created = UserProfile.objects.get_or_create(
            user=user,
            defaults={
                'role': validated_data['role'],
                'phone_number': validated_data.get('phone_number', ''),
            }
        )
        if not created:
            profile.role = validated_data['role']
            profile.phone_number = validated_data.get('phone_number', '')
            profile.save()
        
        parent_username = validated_data.get('parent_username', '').strip().lower()
        if validated_data['role'] == 'STUDENT' and parent_username:
            profile.requested_parent_username = parent_username
            profile.save()
            try:
                # Case-insensitive lookup for parent
                parent_user = User.objects.get(username__iexact=parent_username)
                profile.parent = parent_user.profile
                profile.save()
            except (User.DoesNotExist, UserProfile.DoesNotExist):
                pass
        
        if validated_data['role'] == 'PARENT':
            # Link existing students who requested this parent's username
            from smart_leaves.models import UserProfile as Profile
            students_to_link = Profile.objects.filter(
                role='STUDENT', 
                requested_parent_username__iexact=user.username
            )
            for student_profile in students_to_link:
                student_profile.parent = profile
                student_profile.save()

        return user
                

class ChangePasswordSerializer(serializers.Serializer):
    old_password = serializers.CharField(required=True)
    new_password = serializers.CharField(required=True)

    def validate_old_password(self, value):
        user = self.context.get('request').user
        if not user.check_password(value):
            raise serializers.ValidationError("Old password is incorrect.")
        return value

    def validate_new_password(self, value):
        # We could add more complex password validation here if needed
        if len(value) < 4:
            raise serializers.ValidationError("New password must be at least 4 characters long.")
        return value
