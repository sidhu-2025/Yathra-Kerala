import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../providers/auth_provider.dart';
import '../../providers/leave_provider.dart';
import '../../models/leave_model.dart';

class ModifyLeaveScreen extends StatefulWidget {
  final LeaveModel leave;

  const ModifyLeaveScreen({super.key, required this.leave});

  @override
  State<ModifyLeaveScreen> createState() => _ModifyLeaveScreenState();
}

class _ModifyLeaveScreenState extends State<ModifyLeaveScreen> {
  late DateTime _newEndDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _newEndDate = widget.leave.endDate;
  }

  void _updateLeave() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final baseUrl = Provider.of<LeaveProvider>(context, listen: false).baseUrl;

    setState(() => _isLoading = true);

    try {
      // Assuming a PATCH endpoint exists for partial updates and QR regeneration
      final response = await http.patch(
        Uri.parse('$baseUrl/leaves/${widget.leave.id}/'),
        headers: {
          'Authorization': 'Token ${auth.user!.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'end_date': _newEndDate.toIso8601String(),
          // Trigger QR regeneration on backend if end_date changes
        }),
      );

      if (response.statusCode == 200) {
        Provider.of<LeaveProvider>(context, listen: false).fetchLeaves(auth.user!);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Leave details updated and new QR generated')),
        );
      }
    } catch (e) {
      print('Update error: $e');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modify Leave Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Current Start Date: ${widget.leave.startDate.toString().split(' ')[0]}'),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('New End Date (Late Return)'),
              subtitle: Text(_newEndDate.toString().split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _newEndDate,
                  firstDate: widget.leave.startDate,
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (d != null) setState(() => _newEndDate = d);
              },
            ),
            const SizedBox(height: 24),
            _isLoading 
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _updateLeave,
                  child: const Text('Update & Regenerate QR'),
                ),
          ],
        ),
      ),
    );
  }
}
