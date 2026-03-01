import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  List<dynamic> _attendance = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAttendance();
  }

  void _fetchAttendance() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      final response = await http.get(
        Uri.parse('${auth.baseUrl}/attendance/'),
        headers: {'Authorization': 'Token ${auth.user?.token}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _attendance = json.decode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance History')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _attendance.isEmpty
              ? const Center(child: Text('No records found'))
              : ListView.builder(
                  itemCount: _attendance.length,
                  itemBuilder: (context, index) {
                    final item = _attendance[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: item['is_present'] ? Colors.green : Colors.red,
                          child: Icon(
                            item['is_present'] ? Icons.check : Icons.close,
                            color: Colors.white,
                          ),
                        ),
                        title: Text('Date: ${item['date']}'),
                        subtitle: Text('Student: ${item['student_name']}'),
                        trailing: Text(
                          item['is_present'] ? 'PRESENT' : 'ABSENT',
                          style: TextStyle(
                            color: item['is_present'] ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
