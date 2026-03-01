from rest_framework import viewsets, status, permissions
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.authtoken.views import ObtainAuthToken
from rest_framework.authtoken.models import Token
from django.utils import timezone
from .models import UserProfile, LeaveRequest, Complaint, Attendance, AccessLog, Role, VacatingForm
from .serializers import (
    UserProfileSerializer, LeaveRequestSerializer, 
    ComplaintSerializer, AttendanceSerializer, AccessLogSerializer,
    RegisterSerializer, VacatingFormSerializer, ChangePasswordSerializer
)

class CustomAuthToken(ObtainAuthToken):
    def post(self, request, *args, **kwargs):
        # Make username lookup case-insensitive
        data = request.data.copy()
        if 'username' in data:
            data['username'] = data['username'].strip().lower()
        
        serializer = self.serializer_class(data=data, context={'request': request})
        serializer.is_valid(raise_exception=True)
        user = serializer.validated_data['user']
        token, created = Token.objects.get_or_create(user=user)
        profile = user.profile
        return Response({
            'token': token.key,
            'user_id': user.pk,
            'username': user.username,
            'role': profile.role,
            'profile_id': profile.id
        })

class LeaveRequestViewSet(viewsets.ModelViewSet):
    queryset = LeaveRequest.objects.all()
    serializer_class = LeaveRequestSerializer

    def get_queryset(self):
        user_profile = self.request.user.profile
        if user_profile.role == Role.STUDENT:
            return LeaveRequest.objects.filter(student=user_profile)
        elif user_profile.role == Role.PARENT:
            # Cannot do cross-db JOIN. Explicitly query UserProfile from
            # 'default' db, then filter LeaveRequests in 'leave_db'.
            student_ids = list(
                UserProfile.objects.using('default')
                .filter(parent=user_profile)
                .values_list('id', flat=True)
            )
            return LeaveRequest.objects.filter(student_id__in=student_ids)
        elif user_profile.role == Role.WARDEN or user_profile.role == Role.SECURITY:
            return LeaveRequest.objects.all()
        return LeaveRequest.objects.none()

    def perform_create(self, serializer):
        serializer.save(student=self.request.user.profile, status='PENDING_PARENT')

    @action(detail=True, methods=['post'], permission_classes=[permissions.IsAuthenticated])
    def approve_by_parent(self, request, pk=None):
        leave = self.get_object()
        parent_profile = request.user.profile
        if parent_profile.role != Role.PARENT:
            return Response({'error': 'Unauthorized'}, status=status.HTTP_403_FORBIDDEN)
        # Explicitly query UserProfile from 'default' db using ID for cross-db safety
        is_linked = UserProfile.objects.using('default').filter(
            id=leave.student_id, parent_id=parent_profile.id
        ).exists()
        if not is_linked:
            return Response({'error': 'Unauthorized'}, status=status.HTTP_403_FORBIDDEN)
        
        leave.parent_approved = True
        leave.status = 'PENDING_WARDEN'
        leave.save()
        return Response({'status': 'Parent approved'})

    @action(detail=True, methods=['post'], permission_classes=[permissions.IsAuthenticated])
    def reject_by_parent(self, request, pk=None):
        leave = self.get_object()
        parent_profile = request.user.profile
        if parent_profile.role != Role.PARENT:
            return Response({'error': 'Unauthorized'}, status=status.HTTP_403_FORBIDDEN)
        # Check that this parent is linked to the student (cross-db safe)
        is_linked = UserProfile.objects.using('default').filter(
            id=leave.student_id, parent_id=parent_profile.id
        ).exists()
        if not is_linked:
            return Response({'error': 'Unauthorized'}, status=status.HTTP_403_FORBIDDEN)
        leave.status = 'REJECTED'
        leave.save()
        return Response({'status': 'Rejected by parent'})

    @action(detail=True, methods=['post'], permission_classes=[permissions.IsAuthenticated])
    def approve_by_warden(self, request, pk=None):
        leave = self.get_object()
        if request.user.profile.role != Role.WARDEN:
            return Response({'error': 'Unauthorized'}, status=status.HTTP_403_FORBIDDEN)
        
        if not leave.parent_approved:
            return Response({'error': 'Parent approval required first'}, status=status.HTTP_400_BAD_REQUEST)
        
        leave.warden_approved = True
        leave.status = 'APPROVED'
        leave.save()
        return Response({'status': 'Warden approved', 'qr_token': leave.qr_code_token})

    @action(detail=True, methods=['post'], permission_classes=[permissions.IsAuthenticated])
    def reject_by_warden(self, request, pk=None):
        leave = self.get_object()
        if request.user.profile.role != Role.WARDEN:
            return Response({'error': 'Unauthorized'}, status=status.HTTP_403_FORBIDDEN)
        leave.status = 'REJECTED'
        leave.save()
        return Response({'status': 'Rejected by warden'})

    @action(detail=False, methods=['get'], url_path='verify/(?P<token>[^/.]+)')
    def verify_qr(self, request, token=None):
        if request.user.profile.role != Role.SECURITY:
            return Response({'error': 'Unauthorized'}, status=status.HTTP_403_FORBIDDEN)
        
        try:
            leave = LeaveRequest.objects.get(qr_code_token=token, status='APPROVED')
            # Check if QR has expired (past return date)
            if leave.end_date < timezone.now():
                return Response({'error': 'QR code has expired (leave return date passed)', 'expired': True}, status=status.HTTP_400_BAD_REQUEST)
            data = LeaveRequestSerializer(leave).data
            data['valid'] = True
            return Response(data)
        except LeaveRequest.DoesNotExist:
            return Response({'error': 'Invalid or expired QR code'}, status=status.HTTP_404_NOT_FOUND)

    @action(detail=True, methods=['post'], permission_classes=[permissions.IsAuthenticated])
    def mark_entry_exit(self, request, pk=None):
        if request.user.profile.role != Role.SECURITY:
            return Response({'error': 'Unauthorized'}, status=status.HTTP_403_FORBIDDEN)
        leave = self.get_object()
        log_type = request.data.get('log_type', 'EXIT')
        access_log = AccessLog.objects.create(
            leave_request=leave,
            security_personnel=request.user.profile,
            log_type=log_type
        )
        if log_type == 'ENTRY':
            leave.status = 'COMPLETED'
            leave.save()
        return Response({'status': f'{log_type} logged', 'timestamp': access_log.timestamp})

class ComplaintViewSet(viewsets.ModelViewSet):
    queryset = Complaint.objects.all()
    serializer_class = ComplaintSerializer

    def get_queryset(self):
        user_profile = self.request.user.profile
        if user_profile.role == Role.STUDENT:
            return Complaint.objects.filter(student=user_profile)
        return Complaint.objects.all()

    def perform_create(self, serializer):
        serializer.save(student=self.request.user.profile)

    @action(detail=True, methods=['post'])
    def resolve(self, request, pk=None):
        if request.user.profile.role != Role.WARDEN:
            return Response({'error': 'Unauthorized'}, status=status.HTTP_403_FORBIDDEN)
        complaint = self.get_object()
        complaint.status = 'RESOLVED'
        complaint.resolved_at = timezone.now()
        complaint.save()
        return Response({'status': 'Complaint resolved'})

class RegisterViewSet(viewsets.GenericViewSet):
    serializer_class = RegisterSerializer
    permission_classes = [permissions.AllowAny]

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        token, created = Token.objects.get_or_create(user=user)
        return Response({
            'token': token.key,
            'user_id': user.pk,
            'role': user.profile.role
        }, status=status.HTTP_201_CREATED)

class AttendanceViewSet(viewsets.ModelViewSet):
    queryset = Attendance.objects.all()
    serializer_class = AttendanceSerializer

    def get_queryset(self):
        user_profile = self.request.user.profile
        if user_profile.role == Role.STUDENT:
            return Attendance.objects.filter(student=user_profile)
        elif user_profile.role == Role.PARENT:
            # Fetch student IDs from 'default' db first, using ID for matching
            student_ids = list(
                UserProfile.objects.using('default')
                .filter(parent_id=user_profile.id)
                .values_list('id', flat=True)
            )
            return Attendance.objects.filter(student_id__in=student_ids)
        return Attendance.objects.all()

    def perform_create(self, serializer):
        if self.request.user.profile.role != Role.WARDEN:
            raise permissions.PermissionDenied("Only wardens can mark attendance")
        serializer.save(marked_by=self.request.user.profile)

class VacatingFormViewSet(viewsets.ModelViewSet):
    queryset = VacatingForm.objects.all()
    serializer_class = VacatingFormSerializer

    def get_queryset(self):
        user_profile = self.request.user.profile
        if user_profile.role == Role.STUDENT:
            return VacatingForm.objects.filter(student=user_profile)
        return VacatingForm.objects.all()

    def perform_create(self, serializer):
        serializer.save(student=self.request.user.profile)

    @action(detail=True, methods=['post'])
    def approve(self, request, pk=None):
        if request.user.profile.role != Role.WARDEN:
            return Response({'error': 'Unauthorized'}, status=status.HTTP_403_FORBIDDEN)
        form = self.get_object()
        form.status = 'APPROVED'
        form.approved_by = request.user.profile
        form.approved_at = timezone.now()
        form.save()
        
        # Logic to "remove" student
        student_profile = form.student
        student_profile.user.is_active = False
        student_profile.user.save()
        
        return Response({'status': 'Vacating form approved and student deactivated'})

class UserProfileViewSet(viewsets.ModelViewSet):
    queryset = UserProfile.objects.all()
    serializer_class = UserProfileSerializer

    def get_queryset(self):
        if self.request.user.profile.role == Role.WARDEN:
            return UserProfile.objects.all()
        return UserProfile.objects.filter(user=self.request.user)

    @action(detail=True, methods=['post'])
    def remove_student(self, request, pk=None):
        if request.user.profile.role != Role.WARDEN:
            return Response({'error': 'Unauthorized'}, status=status.HTTP_403_FORBIDDEN)
        profile = self.get_object()
        profile.user.is_active = False
        profile.user.save()

class ChangePasswordView(viewsets.GenericViewSet):
    serializer_class = ChangePasswordSerializer
    permission_classes = [permissions.IsAuthenticated]

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        user = request.user
        user.set_password(serializer.validated_data['new_password'])
        user.save()
        
        return Response({"status": "Password changed successfully"}, status=status.HTTP_200_OK)
