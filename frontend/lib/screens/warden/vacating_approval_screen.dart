import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VacatingApprovalScreen extends StatefulWidget {
  const VacatingApprovalScreen({super.key});

  @override
  State<VacatingApprovalScreen> createState() => _VacatingApprovalScreenState();
}

class _VacatingApprovalScreenState extends State<VacatingApprovalScreen> {
  List<dynamic> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  void _fetchRequests() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      final response = await http.get(
        Uri.parse('${auth.baseUrl}/vacating/'),
        headers: {'Authorization': 'Token ${auth.user?.token}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _requests = json.decode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _approveRequest(int id) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      final response = await http.post(
        Uri.parse('${auth.baseUrl}/vacating/$id/approve/'),
        headers: {'Authorization': 'Token ${auth.user?.token}'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request approved. Student account deactivated.')),
        );
        _fetchRequests();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error approving request')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vacating Requests')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.where((r) => r['status'] == 'PENDING').isEmpty
              ? const Center(child: Text('No pending requests'))
              : ListView.builder(
                  itemCount: _requests.length,
                  itemBuilder: (context, index) {
                    final req = _requests[index];
                    if (req['status'] != 'PENDING') return const SizedBox.shrink();
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text('Student: ${req['student_name']}'),
                        subtitle: Text('Reason: ${req['reason']}\nSubmitted: ${req['created_at'].split('T')[0]}'),
                        trailing: ElevatedButton(
                          onPressed: () => _approveRequest(req['id']),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                          child: const Text('Approve'),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
