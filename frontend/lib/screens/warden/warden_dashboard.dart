import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/leave_provider.dart';
import '../attendance_history_screen.dart';
import 'attendance_screen.dart';
import 'vacating_approval_screen.dart';
import 'student_management_screen.dart';
import 'complaint_management_screen.dart';
import '../change_password_screen.dart';

class WardenDashboard extends StatefulWidget {
  const WardenDashboard({super.key});

  @override
  State<WardenDashboard> createState() => _WardenDashboardState();
}

class _WardenDashboardState extends State<WardenDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _approveLeave(int id) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final provider = Provider.of<LeaveProvider>(context, listen: false);
    final success = await provider.approveByWarden(auth.user!, id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Leave approved — QR code generated')),
      );
    }
  }

  void _rejectLeave(int id) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final provider = Provider.of<LeaveProvider>(context, listen: false);
    final success = await provider.rejectByWarden(auth.user!, id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Leave rejected')),
      );
    }
  }

  Widget _buildLeaveList(List leaves, {bool showActions = false}) {
    if (leaves.isEmpty) {
      return const Center(child: Text('No leave requests'));
    }
    return ListView.builder(
      itemCount: leaves.length,
      itemBuilder: (context, index) {
        final leave = leaves[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(leave.studentName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Chip(
                      label: Text(leave.status, style: const TextStyle(fontSize: 12)),
                      backgroundColor: leave.status == 'APPROVED'
                          ? Colors.green[100]
                          : leave.status == 'REJECTED'
                              ? Colors.red[100]
                              : Colors.orange[100],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Reason: ${leave.reason}'),
                if (leave.destination.isNotEmpty) Text('Destination: ${leave.destination}'),
                Text('${DateFormat('MMM d').format(leave.startDate)} - ${DateFormat('MMM d').format(leave.endDate)}'),
                Text('Parent Approved: ${leave.parentApproved ? "Yes" : "No"}'),
                if (showActions && leave.status == 'PENDING_WARDEN')
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _approveLeave(leave.id),
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Approve'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => _rejectLeave(leave.id),
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text('Reject'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Warden Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'All Leaves'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final user = Provider.of<AuthProvider>(context, listen: false).user;
              if (user != null) {
                Provider.of<LeaveProvider>(context, listen: false).fetchLeaves(user);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Provider.of<AuthProvider>(context, listen: false).logout(),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.indigo),
              child: Text('Warden Panel',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.assignment_ind),
              title: const Text('Mark Attendance'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AttendanceScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Attendance History'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AttendanceHistoryScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Vacating Requests'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const VacatingApprovalScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Student Management'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const StudentManagementScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.report_problem),
              title: const Text('Complaint Management'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ComplaintManagementScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.password),
              title: const Text('Change Password'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ChangePasswordScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Consumer<LeaveProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final pending = provider.leaves.where((l) => l.status == 'PENDING_WARDEN').toList();
          return TabBarView(
            controller: _tabController,
            children: [
              _buildLeaveList(pending, showActions: true),
              _buildLeaveList(provider.leaves),
            ],
          );
        },
      ),
    );
  }
}
