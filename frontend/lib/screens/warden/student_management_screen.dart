import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'add_student_screen.dart';
import '../../utils/ui_utils.dart';

class StudentManagementScreen extends StatefulWidget {
  const StudentManagementScreen({super.key});

  @override
  State<StudentManagementScreen> createState() => _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen> {
  List<dynamic> _students = [];
  List<dynamic> _filteredStudents = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          _students = allProfiles.where((p) => 
            p['role'] == 'STUDENT' && 
            (p['user']['is_active'] ?? true)
          ).toList();
          _filteredStudents = List.from(_students);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterSearch(String query) {
    setState(() {
      _filteredStudents = _students.where((student) {
        final username = student['user']['username']?.toString().toLowerCase() ?? '';
        final firstName = student['user']['first_name']?.toString().toLowerCase() ?? '';
        final lastName = student['user']['last_name']?.toString().toLowerCase() ?? '';
        final fullName = '$firstName $lastName'.trim();
        return username.contains(query.toLowerCase()) || fullName.contains(query.toLowerCase());
      }).toList();
    });
  }

  void _deactivateStudent(int profileId) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      final response = await http.post(
        Uri.parse('${auth.baseUrl}/profiles/$profileId/remove_student/'),
        headers: {'Authorization': 'Token ${auth.user?.token}'},
      );

      if (response.statusCode == 200) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student deactivated successfully')));
           _fetchStudents();
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error deactivating student')));
    }
  }

  void _editStudentName(int profileId, String currentName) async {
    final controller = TextEditingController(text: currentName);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Student Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Full Name', hintText: 'Enter student\'s full name'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result.trim().isNotEmpty) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      try {
        final response = await http.post(
          Uri.parse('${auth.baseUrl}/profiles/$profileId/update_student_name/'),
          headers: {
            'Authorization': 'Token ${auth.user?.token}',
            'Content-Type': 'application/json',
          },
          body: json.encode({'full_name': result.trim()}),
        );

        if (response.statusCode == 200) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name updated successfully')));
            _fetchStudents();
          }
        } else {
           if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update name')));
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connection error')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Student Management'),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddStudentScreen()),
          );
          if (result == true) _fetchStudents();
        },
        backgroundColor: Colors.indigo[900],
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.indigo[900],
            child: TextField(
              controller: _searchController,
              onChanged: _filterSearch,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search by ID or Name...',
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredStudents.isEmpty
                    ? const Center(child: Text('No students found'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredStudents.length,
                        itemBuilder: (context, index) {
                          final student = _filteredStudents[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: Colors.grey[200]!),
                            ),
                            elevation: 0,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.indigo[50],
                                child: Text(
                                  student['user']['username']?.substring(0, 1).toUpperCase() ?? 'S',
                                  style: TextStyle(color: Colors.indigo[900], fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(
                                (() {
                                  final firstName = student['user']['first_name'] ?? '';
                                  final lastName = student['user']['last_name'] ?? '';
                                  final fullName = '$firstName $lastName'.trim();
                                  return fullName.isNotEmpty ? fullName : (student['user']['username'] ?? 'No Username');
                                })(),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(student['user']['username'] ?? 'No ID'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.indigo),
                                    onPressed: () {
                                      final firstName = student['user']['first_name'] ?? '';
                                      final lastName = student['user']['last_name'] ?? '';
                                      final fullName = '$firstName $lastName'.trim();
                                      _editStudentName(student['id'], fullName);
                                    },
                                    tooltip: 'Edit Name',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.person_remove, color: Colors.red),
                                    onPressed: () => _showDeactivateDialog(student['id'], student['user']['username']),
                                    tooltip: 'Deactivate',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
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
