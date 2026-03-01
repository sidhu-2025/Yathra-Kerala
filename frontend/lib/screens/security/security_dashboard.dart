import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/leave_provider.dart';
import 'qr_scanner_screen.dart';
import '../change_password_screen.dart';

class SecurityDashboard extends StatefulWidget {
  const SecurityDashboard({super.key});

  @override
  State<SecurityDashboard> createState() => _SecurityDashboardState();
}

class _SecurityDashboardState extends State<SecurityDashboard> {
  final _tokenController = TextEditingController();
  Map<String, dynamic>? _verificationResult;
  bool _isVerifying = false;
  String? _errorMessage;

  void _verifyToken([String? manualToken]) async {
    final token = manualToken ?? _tokenController.text.trim();
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter or scan a QR token')),
      );
      return;
    }

    if (manualToken != null) {
      _tokenController.text = manualToken;
    }

    setState(() {
      _isVerifying = true;
      _verificationResult = null;
      _errorMessage = null;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final provider = Provider.of<LeaveProvider>(context, listen: false);
    final result = await provider.verifyQR(auth.user!, token);

    setState(() {
      _isVerifying = false;
      if (result != null && result['valid'] == true) {
        _verificationResult = result;
        _errorMessage = null;
      } else {
        _verificationResult = null;
        _errorMessage = result?['error'] ?? 'Invalid or expired QR code';
      }
    });
  }

  void _scanQR() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    );

    if (result != null && mounted) {
      _verifyToken(result);
    }
  }

  void _markEntryExit(String logType) async {
    if (_verificationResult == null) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final provider = Provider.of<LeaveProvider>(context, listen: false);
    final leaveId = _verificationResult!['id'];

    final success = await provider.markEntryExit(auth.user!, leaveId, logType);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$logType logged successfully')),
      );
      setState(() {
        _verificationResult = null;
        _tokenController.clear();
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to mark $logType. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security — QR Verification'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Provider.of<AuthProvider>(context, listen: false).logout(),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.indigo),
              child: Text('Security Panel',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.password),
              title: const Text('Change Password'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ChangePasswordScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // QR Scan Button
            ElevatedButton.icon(
              onPressed: _scanQR,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan QR Code Camera'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('OR', style: TextStyle(color: Colors.grey)),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 24),

            // Manual token input
            const Text('Manual Token Entry',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _tokenController,
              decoration: InputDecoration(
                hintText: 'Enter QR token manually',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _tokenController.clear();
                    setState(() {
                      _verificationResult = null;
                      _errorMessage = null;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isVerifying ? null : () => _verifyToken(),
              icon: _isVerifying
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.verified_user),
              label: Text(_isVerifying ? 'Verifying...' : 'Verify Token'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),

            // Verification result
            if (_errorMessage != null)
              Card(
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (_verificationResult != null) ...[
              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 32),
                          const SizedBox(width: 12),
                          const Text('VALID LEAVE',
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(),
                      _infoRow('Student', _verificationResult!['student_name'] ?? ''),
                      _infoRow('Reason', _verificationResult!['reason'] ?? ''),
                      if ((_verificationResult!['destination'] ?? '').isNotEmpty)
                        _infoRow('Destination', _verificationResult!['destination']),
                      _infoRow('Start', _verificationResult!['start_date']?.toString().split('T')[0] ?? ''),
                      _infoRow('End', _verificationResult!['end_date']?.toString().split('T')[0] ?? ''),
                      _infoRow('Status', _verificationResult!['status'] ?? ''),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _markEntryExit('EXIT'),
                      icon: const Icon(Icons.exit_to_app),
                      label: const Text('Mark EXIT'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _markEntryExit('ENTRY'),
                      icon: const Icon(Icons.login),
                      label: const Text('Mark ENTRY'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
