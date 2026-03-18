from rest_framework import viewsets, status, permissions
from rest_framework.views import APIView
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.authtoken.views import ObtainAuthToken
from rest_framework.authtoken.models import Token
from django.utils import timezone
from django.contrib.auth.forms import PasswordResetForm
from .models import UserProfile, LeaveRequest, Complaint, Attendance, AccessLog, Role, VacatingForm, StudentLocation
from .serializers import (
    UserProfileSerializer, LeaveRequestSerializer, 
    ComplaintSerializer, AttendanceSerializer, AccessLogSerializer,
    RegisterSerializer, VacatingFormSerializer, ChangePasswordSerializer,
    PasswordResetSerializer, StudentLocationSerializer
)
from .sms_utils import send_leave_sms

class CustomAuthToken(ObtainAuthToken):
    def post(self, request, *args, **kwargs):
        from django.contrib.auth.models import User as DjangoUser
        # Make username lookup flexible but case-accurate for authentication
        data = request.data.copy()
        if 'username' in data:
            login_input = data['username'].strip()
            
            # 1. Try exact username match first (case-sensitive)
            if not DjangoUser.objects.filter(username=login_input).exists():
                # 2. Try email lookup (case-insensitive)
                if '@' in login_input:
                    try:
                        matched_user = DjangoUser.objects.get(email__iexact=login_input)
                        login_input = matched_user.username
                    except (DjangoUser.DoesNotExist, DjangoUser.MultipleObjectsReturned):
                        pass
                else:
                    # 3. Try case-insensitive username lookup to get the correct casing
                    try:
                        matched_user = DjangoUser.objects.get(username__iexact=login_input)
                        login_input = matched_user.username
                    except (DjangoUser.DoesNotExist, DjangoUser.MultipleObjectsReturned):
                        pass
            
            data['username'] = login_input

        # Role validation
        selected_role = data.get('role')
        if not selected_role:
            return Response({'error': 'Please select a role'}, status=status.HTTP_400_BAD_REQUEST)

        serializer = self.serializer_class(data=data, context={'request': request})
        serializer.is_valid(raise_exception=True)
        user = serializer.validated_data['user']
        token, created = Token.objects.get_or_create(user=user)
        
        try:
            profile = user.profile
        except UserProfile.DoesNotExist:
            return Response({
                'error': 'User profile not found. Please contact support.',
            }, status=status.HTTP_400_BAD_REQUEST)

        if profile.role != selected_role:
            return Response({
                'error': f'Incorrect role selected. Your account is registered as {profile.role}.',
            }, status=status.HTTP_403_FORBIDDEN)

        full_name = user.get_full_name().strip()
        display_name = full_name if full_name else user.username

        return Response({
            'token': token.key,
            'user_id': user.pk,
            'username': user.username,
            'email': user.email,
            'full_name': display_name,
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
        leave = serializer.save(student=self.request.user.profile, status='PENDING_PARENT')
        # Send SMS to parent about the new leave request
        send_leave_sms(leave, template_type='SUBMISSION')

    def perform_update(self, serializer):
        user_profile = self.request.user.profile
        if user_profile.role == Role.STUDENT:
            # Students can only update the end_date (return date/time)
            # and only if the leave is not already COMPLETED or REJECTED
            instance = self.get_object()
            if instance.status in ['COMPLETED', 'REJECTED']:
                raise permissions.PermissionDenied("Cannot edit completed or rejected leave requests.")
            
            # Use serializer to save only allowed fields if needed, 
            # but for now we'll just let the standard update happen 
            # and rely on the frontend to only send end_date.
            # To be extra safe, we can inspect validated_data:
            allowed_fields = ['end_date', 'reason', 'destination'] # Allow some basic editing
            for field in list(serializer.validated_data.keys()):
                if field not in allowed_fields:
                    serializer.validated_data.pop(field)
                    
        serializer.save()

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
        # Send SMS to parent about the warden's approval
        send_leave_sms(leave, template_type='APPROVAL')
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
        
        # Send SMS notification to parent
        try:
            send_leave_sms(leave, template_type=log_type)
        except Exception as e:
            print(f"Failed to send {log_type} SMS: {e}")

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

    @action(detail=False, methods=['get'], url_path='daily_stats')
    def daily_stats(self, request):
        if request.user.profile.role != Role.WARDEN:
            return Response({'error': 'Unauthorized'}, status=status.HTTP_403_FORBIDDEN)

        date_str = request.query_params.get('date')
        if not date_str:
            from django.utils import timezone
            target_date = timezone.now().date()
        else:
            try:
                from datetime import datetime
                target_date = datetime.strptime(date_str, '%Y-%m-%d').date()
            except ValueError:
                return Response({'error': 'Invalid date format. Use YYYY-MM-DD'}, status=status.HTTP_400_BAD_REQUEST)

        records = Attendance.objects.filter(date=target_date)
        
        # We need total students to determine how many are absent (even if no record exists yet)
        total_students = UserProfile.objects.using('default').filter(role=Role.STUDENT, user__is_active=True).count()
        present = records.filter(is_present=True).count()
        absent = records.filter(is_present=False).count()
        
        # If total_students > (present + absent), the rest are implicitly absent/unmarked
        unmarked = max(0, total_students - (present + absent))

        return Response({
            'date': target_date.strftime('%Y-%m-%d'),
            'present': present,
            'absent': absent + unmarked,
            'total': total_students
        })

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

    def create(self, request, *args, **kwargs):
        if request.user.profile.role != Role.WARDEN:
            return Response({'error': 'Only wardens can mark attendance'}, status=status.HTTP_403_FORBIDDEN)
        
        serializer = self.get_serializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        student = serializer.validated_data['student']
        is_present = serializer.validated_data.get('is_present', False)
        
        # Use update_or_create for idempotency on (student, date)
        from django.utils import timezone
        today = timezone.now().date()
        
        attendance, created = Attendance.objects.update_or_create(
            student=student,
            date=today,
            defaults={
                'is_present': is_present,
                'marked_by': request.user.profile
            }
        )
        
        # Return serializable data
        return Response(self.get_serializer(attendance).data, 
                        status=status.HTTP_201_CREATED if created else status.HTTP_200_OK)

    def perform_create(self, serializer):
        # This is now handled by our custom create method
        pass

    @action(detail=False, methods=['get'], url_path='monthly_report')
    def monthly_report(self, request):
        if request.user.profile.role != Role.WARDEN:
            return Response({'error': 'Unauthorized'}, status=status.HTTP_403_FORBIDDEN)

        month = request.query_params.get('month')  # e.g. "2026-03"
        if not month:
            from django.utils import timezone as tz
            month = tz.now().strftime('%Y-%m')

        try:
            year, mon = int(month.split('-')[0]), int(month.split('-')[1])
        except Exception:
            return Response({'error': 'Invalid month format. Use YYYY-MM'}, status=status.HTTP_400_BAD_REQUEST)

        records = Attendance.objects.filter(
            date__year=year,
            date__month=mon
        )

        # Get unique student IDs from attendance records
        student_ids = list(records.values_list('student_id', flat=True).distinct())
        
        # Fetch student profile and user info from 'default' database
        profiles = {
            p.id: p for p in UserProfile.objects.using('default')
            .filter(id__in=student_ids)
            .select_related('user')
        }

        report = {}
        for r in records:
            student_id = r.student_id
            profile = profiles.get(student_id)
            
            if not profile:
                continue

            username = profile.user.username
            full_name = profile.user.get_full_name().strip() or username
            
            if student_id not in report:
                report[student_id] = {
                    'student_id': student_id,
                    'username': username,
                    'full_name': full_name,
                    'present': 0,
                    'absent': 0,
                    'late': 0,
                    'total': 0
                }
            report[student_id]['total'] += 1
            if r.is_present:
                report[student_id]['present'] += 1
            else:
                report[student_id]['absent'] += 1

        return Response({
            'month': month,
            'report': list(report.values())
        })

    @action(detail=False, methods=['get'], url_path='download_pdf')
    def download_pdf(self, request):
        import io
        from reportlab.lib import colors
        from reportlab.lib.pagesizes import letter
        from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Spacer
        from reportlab.lib.styles import getSampleStyleSheet
        from django.http import HttpResponse
        from django.utils import timezone

        month = request.query_params.get('month')
        if not month:
            month = timezone.now().strftime('%Y-%m')

        # Get the report data (reusing monthly_report logic)
        year, month_val = map(int, month.split('-'))
        user_profile = request.user.profile
        
        # Base query
        queryset = Attendance.objects.filter(date__year=year, date__month=month_val)
        
        if user_profile.role == Role.STUDENT:
            queryset = queryset.filter(student=user_profile)
        elif user_profile.role == Role.PARENT:
            student_ids = list(UserProfile.objects.using('default').filter(parent_id=user_profile.id).values_list('id', flat=True))
            queryset = queryset.filter(student_id__in=student_ids)

        records = list(queryset)
        student_ids = list(set(r.student_id for r in records))
        profiles = {p.id: p for p in UserProfile.objects.using('default').filter(id__in=student_ids).select_related('user')}

        report_data = {}
        for r in records:
            sid = r.student_id
            profile = profiles.get(sid)
            if not profile: continue
            
            if sid not in report_data:
                username = profile.user.username
                full_name = profile.user.get_full_name().strip() or username
                report_data[sid] = {'Name': full_name, 'ID': username, 'Present': 0, 'Absent': 0, 'Total': 0}
            
            report_data[sid]['Total'] += 1
            if r.is_present: report_data[sid]['Present'] += 1
            else: report_data[sid]['Absent'] += 1

        # Create PDF
        buffer = io.BytesIO()
        doc = SimpleDocTemplate(buffer, pagesize=letter)
        styles = getSampleStyleSheet()
        elements = []

        # Title
        title = f"Attendance Report - {month}"
        elements.append(Paragraph(title, styles['Title']))
        elements.append(Spacer(1, 12))

        # Table Data
        data = [['Student Name', 'Student ID', 'Present', 'Absent', 'Total']]
        for item in report_data.values():
            data.append([item['Name'], item['ID'], str(item['Present']), str(item['Absent']), str(item['Total'])])

        t = Table(data)
        t.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), colors.grey),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
            ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
            ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
            ('GRID', (0, 0), (-1, -1), 1, colors.black)
        ]))
        elements.append(t)
        doc.build(elements)

        buffer.seek(0)
        response = HttpResponse(buffer, content_type='application/pdf')
        response['Content-Disposition'] = f'attachment; filename="attendance_report_{month}.pdf"'
        return response

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
        return Response({'status': 'Student deactivated successfully'})

class PasswordResetView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = PasswordResetSerializer(data=request.data)
        if serializer.is_valid():
            email = serializer.validated_data['email']
            form = PasswordResetForm({'email': email})
            if form.is_valid():
                form.save(
                    request=request,
                    use_https=request.is_secure(),
                    email_template_name='registration/password_reset_email.html',
                    subject_template_name='registration/password_reset_subject.txt',
                )
                return Response({'status': 'Password reset email sent if account exists.'})
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=True, methods=['post'])
    def upload_photo(self, request, pk=None):
        profile = self.get_object()
        if 'photo' not in request.FILES:
            return Response({'error': 'No photo provided'}, status=status.HTTP_400_BAD_REQUEST)
        
        profile.photo = request.FILES['photo']
        profile.save()
        return Response({'status': 'Photo uploaded successfully', 'photo_url': request.build_absolute_uri(profile.photo.url)})

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

class StudentLocationViewSet(viewsets.ModelViewSet):
    queryset = StudentLocation.objects.all()
    serializer_class = StudentLocationSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user_profile = self.request.user.profile
        if user_profile.role == Role.STUDENT:
            return StudentLocation.objects.using('leave_db').filter(student_id=user_profile.id)
        elif user_profile.role == Role.PARENT:
            student_ids = list(
                UserProfile.objects.using('default')
                .filter(parent=user_profile)
                .values_list('id', flat=True)
            )
            return StudentLocation.objects.using('leave_db').filter(student_id__in=student_ids)
        return StudentLocation.objects.using('leave_db').none()

    def perform_create(self, serializer):
        # Use update_or_create to ensure one record per student
        StudentLocation.objects.update_or_create(
            student=self.request.user.profile,
            defaults={
                'latitude': serializer.validated_data['latitude'],
                'longitude': serializer.validated_data['longitude']
            }
        )

    @action(detail=False, methods=['post'])
    def update_location(self, request):
        if request.user.profile.role != Role.STUDENT:
            return Response({'error': 'Only students can update their location'}, status=status.HTTP_403_FORBIDDEN)
        
        latitude = request.data.get('latitude')
        longitude = request.data.get('longitude')
        
        if latitude is None or longitude is None:
            return Response({'error': 'Latitude and Longitude are required'}, status=status.HTTP_400_BAD_REQUEST)
        
        location, created = StudentLocation.objects.using('leave_db').update_or_create(
            student_id=request.user.profile.id, # Use _id to avoid join/cross-db issues
            defaults={'latitude': latitude, 'longitude': longitude}
        )
        
        return Response(StudentLocationSerializer(location).data)
