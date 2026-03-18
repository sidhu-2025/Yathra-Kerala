import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/leave_provider.dart';
import '../../providers/auth_provider.dart';
import 'qr_view_screen.dart';
import 'modify_leave_screen.dart';

class LeaveHistoryScreen extends StatelessWidget {
  const LeaveHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave History'),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
      ),
      body: Consumer<LeaveProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.leaves.isEmpty) {
            return const Center(child: Text('No leave requests found'));
          }
          return ListView.builder(
            itemCount: provider.leaves.length,
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemBuilder: (context, index) {
              final leave = provider.leaves[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey[200]!),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    leave.reason,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('${DateFormat('MMM d').format(leave.startDate)} - ${DateFormat('MMM d').format(leave.endDate)}'),
                      const SizedBox(height: 8),
                      _buildStatusBadge(leave.status),
                    ],
                  ),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      if (leave.status == 'APPROVED')
                        IconButton(
                          icon: const Icon(Icons.qr_code, color: Colors.blue),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => QRViewScreen(token: leave.qrToken!)),
                          ),
                        ),
                      if (leave.status != 'COMPLETED' && leave.status != 'REJECTED')
                        IconButton(
                          icon: const Icon(Icons.edit_calendar, color: Colors.indigo),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ModifyLeaveScreen(leave: leave)),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'APPROVED':
        color = Colors.green;
        break;
      case 'REJECTED':
        color = Colors.red;
        break;
      case 'PENDING_PARENT':
      case 'PENDING_WARDEN':
        color = Colors.orange;
        break;
      case 'COMPLETED':
        color = Colors.grey;
        break;
      default:
        color = Colors.blue;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
