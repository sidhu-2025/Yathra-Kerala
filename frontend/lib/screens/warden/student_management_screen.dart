import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StudentManagementScreen extends StatefulWidget {
  const StudentManagementScreen({super.key});

  @override
  State<StudentManagementScreen> createState() => _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen> {
  List<dynamic> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  void _fetchStudents() async {
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

  void _deactivateStudent(int profileId) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      final response = await http.post(
        Uri.parse('${auth.baseUrl}/profiles/$profileId/remove_student/'),
        headers: {'Authorization': 'Token ${auth.user?.token}'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student deactivated successfully')),
        );
        _fetchStudents();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error deactivating student')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Management')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _students.length,
              itemBuilder: (context, index) {
                final student = _students[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(student['user']['username'] ?? 'No Username'),
                    subtitle: Text('Phone: ${student['phone_number'] ?? 'N/A'}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.person_remove, color: Colors.red),
                      onPressed: () => _showDeactivateDialog(student['id'], student['user']['username']),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showDeactivateDialog(int id, String? name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Student'),
        content: Text('Are you sure you want to deactivate $name? This will prevent them from logging in.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deactivateStudent(id);
            },
            child: const Text('Deactivate', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
