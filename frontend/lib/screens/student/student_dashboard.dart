import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/leave_provider.dart';
import '../../providers/location_provider.dart';
import 'request_leave_screen.dart';
import 'qr_view_screen.dart';
import 'vacating_screen.dart';
import '../attendance_history_screen.dart';
import 'student_profile_screen.dart';
import 'complaint_screen.dart';
import 'modify_leave_screen.dart';
import 'leave_history_screen.dart';
import '../../models/leave_model.dart';
import '../../models/user_model.dart';
import '../change_password_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user != null) {
        Provider.of<LeaveProvider>(context, listen: false).fetchLeaves(user);
        Provider.of<LeaveProvider>(context, listen: false).initializeWebSocket(user);
        
        final result = await Provider.of<LocationProvider>(context, listen: false).startTracking(user);
        _handleTrackingResult(result);
      }
    });
  }

  void _handleTrackingResult(String result) {
    if (!mounted) return;
    
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    String message = '';
    Color color = Colors.green;
    SnackBarAction? action;
    
    switch (result) {
      case 'success':
        message = 'Location tracking active.';
        break;
      case 'service_disabled':
        message = 'Please turn ON your phone GPS (Location).';
        color = Colors.orange;
        action = SnackBarAction(
          label: 'Turn ON',
          textColor: Colors.white,
          onPressed: () => locationProvider.openSettings(),
        );
        break;
      case 'permission_denied':
        message = 'Location permission is required for safety tracking.';
        color = Colors.red;
        action = SnackBarAction(
          label: 'Allow',
          textColor: Colors.white,
          onPressed: () => locationProvider.openAppSettings(),
        );
        break;
      case 'permission_permanently_denied':
        message = 'Permission permanently denied. Please enable in App Settings.';
        color = Colors.red;
        action = SnackBarAction(
          label: 'Settings',
          textColor: Colors.white,
          onPressed: () => locationProvider.openAppSettings(),
        );
        break;
      case 'already_tracking':
        return; // No massage needed
    }
    
    if (message.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 5),
          action: action,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.indigo[900],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.indigo[900]!, Colors.blue[800]!],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60, left: 24, right: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const StudentProfileScreen()),
                          ),
                          child: const CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white24,
                            child: Icon(Icons.person, color: Colors.white, size: 32),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome,',
                              style: TextStyle(color: Colors.white70, fontSize: 16),
                            ),
                            Text(
                              user?.fullName ?? 'Student',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (user != null)
                              Text(
                                user.email.isNotEmpty ? user.email : user.username,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () => auth.logout(),
                )
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.5,
                      children: [
                        _buildActionCard(
                          'Request Leave',
                          Icons.add_circle_outline,
                          Colors.indigo,
                          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RequestLeaveScreen())),
                          isProminent: true,
                        ),
                        _buildActionCard(
                          'Recent Leaves',
                          Icons.history,
                          Colors.indigo,
                          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaveHistoryScreen())),
                        ),
                        _buildActionCard(
                          'Attendance',
                          Icons.calendar_month,
                          Colors.blue,
                          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceHistoryScreen())),
                        ),
                        _buildActionCard(
                          'Complaints',
                          Icons.report_problem,
                          Colors.red,
                          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ComplaintScreen())),
                        ),
                        _buildActionCard(
                          'Vacate',
                          Icons.exit_to_app,
                          Colors.orange,
                          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VacatingScreen())),
                        ),
                        _buildLocationCard(context, auth.user!),
                        _buildActionCard(
                          'Password',
                          Icons.password,
                          Colors.green,
                          () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChangePasswordScreen())),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context, UserModel user) {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        final isTracking = locationProvider.isTracking;
        return Container(
          decoration: BoxDecoration(
            color: isTracking ? Colors.blue.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isTracking ? Colors.blue.withOpacity(0.5) : Colors.grey.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: InkWell(
            onTap: () async {
              if (isTracking) {
                locationProvider.stopTracking();
              } else {
                final result = await locationProvider.startTracking(user);
                _handleTrackingResult(result);
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        isTracking ? Icons.location_on : Icons.location_off,
                        color: isTracking ? Colors.blue : Colors.grey,
                        size: 28,
                      ),
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value: isTracking,
                          onChanged: (value) async {
                            if (value) {
                              final result = await locationProvider.startTracking(user);
                              _handleTrackingResult(result);
                            } else {
                              locationProvider.stopTracking();
                            }
                          },
                          activeColor: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Location Sharing',
                    style: TextStyle(
                      color: isTracking ? Colors.blue[900] : Colors.grey[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    isTracking ? 'Active' : 'Off',
                    style: TextStyle(
                      color: isTracking ? Colors.green : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _onRefresh() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.user != null) {
      await Provider.of<LeaveProvider>(context, listen: false).fetchLeaves(auth.user!);
    }
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap, {bool isProminent = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: isProminent ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: isProminent ? [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isProminent ? Colors.white : color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isProminent ? Colors.white : color.darken(0.2),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension ColorExtension on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsv = HSVColor.fromColor(this);
    final darkenedHsv = hsv.withValue((hsv.value - amount).clamp(0.0, 1.0));
    return darkenedHsv.toColor();
  }
}
