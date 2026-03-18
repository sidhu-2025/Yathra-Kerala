import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/leave_provider.dart';

class WardenPendingLeavesScreen extends StatelessWidget {
  const WardenPendingLeavesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Approvals'),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
      ),
      body: Consumer<LeaveProvider>(
        builder: (context, provider, child) {
          final pending = provider.leaves.where((l) => l.status == 'PENDING_WARDEN').toList();
          
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (pending.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No pending leave requests', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pending.length,
            itemBuilder: (context, index) {
              final leave = pending[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${leave.studentName} (${leave.vmlId})', 
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)
                            ),
                          ),
                          _buildStatusBadge(leave.status),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('Reason: ${leave.reason}', style: const TextStyle(fontSize: 16)),
                      if (leave.destination.isNotEmpty) Text('Destination: ${leave.destination}'),
                      const SizedBox(height: 4),
                      Text('Dates: ${DateFormat('MMM d').format(leave.startDate)} - ${DateFormat('MMM d').format(leave.endDate)}'),
                      Text('Parent Approved: ${leave.parentApproved ? "Yes" : "No"}', style: TextStyle(color: leave.parentApproved ? Colors.green : Colors.red, fontWeight: FontWeight.w500)),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => _handleReject(context, leave.id),
                            icon: const Icon(Icons.close, color: Colors.red),
                            label: const Text('Reject', style: TextStyle(color: Colors.red)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () => _handleApprove(context, leave.id),
                            icon: const Icon(Icons.check),
                            label: const Text('Approve'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
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

  void _handleApprove(BuildContext context, int id) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final provider = Provider.of<LeaveProvider>(context, listen: false);
    final success = await provider.approveByWarden(auth.user!, id);
    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Leave Approved!')));
        provider.fetchLeaves(auth.user!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Action failed')));
      }
    }
  }

  void _handleReject(BuildContext context, int id) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final provider = Provider.of<LeaveProvider>(context, listen: false);
    final success = await provider.rejectByWarden(auth.user!, id);
    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Leave Rejected!')));
        provider.fetchLeaves(auth.user!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Action failed')));
      }
    }
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status, style: const TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
