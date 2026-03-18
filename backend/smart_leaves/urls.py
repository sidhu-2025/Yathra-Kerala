from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    LeaveRequestViewSet, ComplaintViewSet, 
    AttendanceViewSet, CustomAuthToken,
    RegisterViewSet, VacatingFormViewSet, UserProfileViewSet, ChangePasswordView,
    PasswordResetView, StudentLocationViewSet
)
from django.contrib.auth import views as auth_views

router = DefaultRouter()
router.register(r'leaves', LeaveRequestViewSet)
router.register(r'complaints', ComplaintViewSet)
router.register(r'attendance', AttendanceViewSet)
router.register(r'register', RegisterViewSet, basename='register')
router.register(r'vacating', VacatingFormViewSet)
router.register(r'profiles', UserProfileViewSet)
router.register(r'change-password', ChangePasswordView, basename='change-password')
router.register(r'locations', StudentLocationViewSet)

urlpatterns = [
    path('', include(router.urls)),
    path('login/', CustomAuthToken.as_view(), name='api_login'),
    
    # Password Reset URLs
    path('password-reset/', PasswordResetView.as_view(), name='password_reset'),
    path('password-reset/done/', auth_views.PasswordResetDoneView.as_view(), name='password_reset_done'),
    path('password-reset-confirm/<uidb64>/<token>/', auth_views.PasswordResetConfirmView.as_view(), name='password_reset_confirm'),
    path('password-reset-complete/', auth_views.PasswordResetCompleteView.as_view(), name='password_reset_complete'),
]
