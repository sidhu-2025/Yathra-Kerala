import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../providers/auth_provider.dart';
import '../../providers/leave_provider.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  List _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      final response = await http.get(
        Uri.parse('${auth.baseUrl}/profiles/'),
        headers: {'Authorization': 'Token ${auth.user?.token}'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> allProfiles = json.decode(response.body);
        setState(() {
          _students = allProfiles.where((p) => p['role'] == 'STUDENT').toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _markAttendance(int studentId, bool present) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    final response = await http.post(
      Uri.parse('${auth.baseUrl}/attendance/'),
      headers: {
        'Authorization': 'Token ${auth.user!.token}',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'student': studentId,
        'is_present': present,
      }),
    );

    if (response.statusCode == 201) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance marked')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mark Attendance')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _students.length,
            itemBuilder: (context, index) {
              final student = _students[index];
              return ListTile(
                title: Text(
                  // Show full name; fall back to username if name is empty
                  (() {
                    final firstName = student['user']['first_name'] ?? '';
                    final lastName = student['user']['last_name'] ?? '';
                    final fullName = '$firstName $lastName'.trim();
                    return fullName.isNotEmpty ? fullName : student['user']['username'];
                  })(),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(student['user']['username'] ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                      onPressed: () => _markAttendance(student['id'], true),
                    ),
                    IconButton(
                      icon: const Icon(Icons.highlight_off, color: Colors.red),
                      onPressed: () => _markAttendance(student['id'], false),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }
}
