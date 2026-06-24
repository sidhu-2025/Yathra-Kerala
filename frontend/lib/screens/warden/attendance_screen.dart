import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../providers/auth_provider.dart';
import '../../utils/ui_utils.dart';
import '../../constants.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  List _students = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  final Map<int, bool> _attendanceStates = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/profiles/'),
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
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading students: $e')));
      }
    }
  }

  void _toggleAttendance(int studentId, bool present) {
    setState(() {
      _attendanceStates[studentId] = present;
    });
  }

  Future<void> _submitBatchAttendance() async {
    if (_attendanceStates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please mark at least one student')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    int successCount = 0;
    int failCount = 0;

    for (var entry in _attendanceStates.entries) {
      try {
        final response = await http.post(
          Uri.parse('${ApiConstants.baseUrl}/attendance/'),
          headers: {
            'Authorization': 'Token ${auth.user!.token}',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'student': entry.key,
            'is_present': entry.value,
          }),
        );
        if (response.statusCode == 201 || response.statusCode == 200) {
          successCount++;
        } else {
          failCount++;
        }
      } catch (e) {
        failCount++;
      }
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (failCount == 0) {
        await showSuccessDialog(context);
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Processed: $successCount successful, $failCount failed'),
            backgroundColor: failCount > 0 ? Colors.orange : Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Mark Attendance'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Students: ${_students.length}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        'Marked: ${_attendanceStates.length}',
                        style: TextStyle(color: Colors.indigo[900], fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                _buildSearchSection(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _students.where((student) {
                      final firstName = (student['user']['first_name'] ?? '').toString().toLowerCase();
                      final lastName = (student['user']['last_name'] ?? '').toString().toLowerCase();
                      final fullName = '$firstName $lastName'.trim();
                      final vml = (student['user']['username'] ?? '').toString().toLowerCase();
                      final query = _searchQuery.toLowerCase();
                      return fullName.contains(query) || vml.contains(query);
                    }).length,
                    itemBuilder: (context, index) {
                      final filteredStudents = _students.where((student) {
                        final firstName = (student['user']['first_name'] ?? '').toString().toLowerCase();
                        final lastName = (student['user']['last_name'] ?? '').toString().toLowerCase();
                        final fullName = '$firstName $lastName'.trim();
                        final vml = (student['user']['username'] ?? '').toString().toLowerCase();
                        final query = _searchQuery.toLowerCase();
                        return fullName.contains(query) || vml.contains(query);
                      }).toList();
                      
                      final student = filteredStudents[index];
                      final studentId = student['id'];
                      final isSelected = _attendanceStates.containsKey(studentId);
                      final isPresent = _attendanceStates[studentId] ?? false;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isSelected 
                              ? (isPresent ? Colors.green : Colors.red).withOpacity(0.5)
                              : Colors.grey[200]!,
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: isSelected 
                                  ? (isPresent ? Colors.green[50] : Colors.red[50])
                                  : Colors.indigo[50],
                                child: Text(
                                  student['user']['username']?.substring(0, 1).toUpperCase() ?? 'S',
                                  style: TextStyle(
                                    color: isSelected 
                                      ? (isPresent ? Colors.green : Colors.red)
                                      : Colors.indigo[900],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (() {
                                        final firstName = student['user']['first_name'] ?? '';
                                        final lastName = student['user']['last_name'] ?? '';
                                        final fullName = '$firstName $lastName'.trim();
                                        return fullName.isNotEmpty ? fullName : student['user']['username'];
                                      })(),
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    Text(
                                      student['user']['username'] ?? '',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  _buildAttendanceButton(
                                    icon: Icons.check,
                                    color: Colors.green,
                                    isSelected: isSelected && isPresent,
                                    onTap: () => _toggleAttendance(studentId, true),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildAttendanceButton(
                                    icon: Icons.close,
                                    color: Colors.red,
                                    isSelected: isSelected && !isPresent,
                                    onTap: () => _toggleAttendance(studentId, false),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitBatchAttendance,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo[900],
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                        shadowColor: Colors.indigo.withOpacity(0.5),
                      ),
                      child: _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Save and Submit',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by Name or VML...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty 
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _searchQuery = '';
                  });
                },
              )
            : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildAttendanceButton({
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? Colors.white : Colors.grey[400],
        ),
      ),
    );
  }
}
