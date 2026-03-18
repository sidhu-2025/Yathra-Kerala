import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/leave_provider.dart';
import '../attendance_history_screen.dart';
import 'attendance_screen.dart';
import 'vacating_approval_screen.dart';
import 'student_management_screen.dart';
import 'complaint_management_screen.dart';
import '../change_password_screen.dart';
import 'attendance_report_screen.dart';
import 'warden_pending_leaves_screen.dart';
import 'warden_leave_history_screen.dart';

class WardenDashboard extends StatefulWidget {
  const WardenDashboard({super.key});

  @override
  State<WardenDashboard> createState() => _WardenDashboardState();
}

class _WardenDashboardState extends State<WardenDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final leaveProvider = Provider.of<LeaveProvider>(context, listen: false);
      if (auth.user != null) {
        leaveProvider.fetchLeaves(auth.user!);
        leaveProvider.initializeWebSocket(auth.user!);
      }
    });
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
                        const CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 32),
                        ),
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Warden Portal,',
                              style: TextStyle(color: Colors.white70, fontSize: 16),
                            ),
                            Text(
                              user?.fullName ?? 'Warden',
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
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Management Actions',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.5,
                      children: [
                        _buildActionCard(
                          'Pending Leaves',
                          Icons.pending_actions,
                          Colors.orange,
                          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WardenPendingLeavesScreen())),
                        ),
                         _buildActionCard(
                          'Leave History',
                          Icons.history,
                          Colors.indigo,
                          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WardenLeaveHistoryScreen())),
                        ),
                        _buildActionCard('Attendance', Icons.assignment_ind, Colors.blue, 
                          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceScreen()))),
                        _buildActionCard('Attendance Hist', Icons.history_toggle_off, Colors.indigo, 
                          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceHistoryScreen()))),
                        _buildActionCard('Vacating', Icons.exit_to_app, Colors.orange, 
                          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VacatingApprovalScreen()))),
                        _buildActionCard('Students', Icons.people, Colors.teal, 
                          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentManagementScreen()))),
                        _buildActionCard('Complaints', Icons.report_problem, Colors.red, 
                          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ComplaintManagementScreen()))),
                        _buildActionCard('Password', Icons.password, Colors.green, 
                          () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChangePasswordScreen()))),
                        _buildActionCard('Report', Icons.bar_chart, Colors.purple, 
                          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceReportScreen()))),
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

  Future<void> _onRefresh() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.user != null) {
      await Provider.of<LeaveProvider>(context, listen: false).fetchLeaves(auth.user!);
    }
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
