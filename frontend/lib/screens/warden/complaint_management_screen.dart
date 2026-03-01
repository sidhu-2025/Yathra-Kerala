import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ComplaintManagementScreen extends StatefulWidget {
  const ComplaintManagementScreen({super.key});

  @override
  State<ComplaintManagementScreen> createState() => _ComplaintManagementScreenState();
}

class _ComplaintManagementScreenState extends State<ComplaintManagementScreen> {
  List<dynamic> _complaints = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchComplaints();
  }

  void _fetchComplaints() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      final response = await http.get(
        Uri.parse('${auth.baseUrl}/complaints/'),
        headers: {'Authorization': 'Token ${auth.user?.token}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _complaints = json.decode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _resolveComplaint(int id) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      final response = await http.post(
        Uri.parse('${auth.baseUrl}/complaints/$id/resolve/'),
        headers: {'Authorization': 'Token ${auth.user?.token}'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complaint marked as resolved')),
        );
        _fetchComplaints();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error resolving complaint')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complaint Management')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _complaints.isEmpty
              ? const Center(child: Text('No complaints found'))
              : ListView.builder(
                  itemCount: _complaints.length,
                  itemBuilder: (context, index) {
                    final complaint = _complaints[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text('Student: ${complaint['student_name']}'),
                        subtitle: Text('Description: ${complaint['description']}\nStatus: ${complaint['status']}'),
                        trailing: complaint['status'] == 'PENDING'
                            ? ElevatedButton(
                                onPressed: () => _resolveComplaint(complaint['id']),
                                child: const Text('Resolve'),
                              )
                            : const Icon(Icons.check_circle, color: Colors.green),
                      ),
                    );
                  },
                ),
    );
  }
}
