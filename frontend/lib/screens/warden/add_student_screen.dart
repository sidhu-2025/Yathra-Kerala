import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/ui_utils.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _deptController = TextEditingController();
  final _roomController = TextEditingController();
  final _admissionController = TextEditingController();
  String _gender = 'MALE';

  bool _isLoading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    bool success = await auth.register(
      username: _usernameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      role: 'STUDENT',
      phoneNumber: _phoneController.text,
      department: _deptController.text,
      roomNumber: _roomController.text,
      admissionNumber: _admissionController.text,
      gender: _gender,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        await showSuccessDialog(context, message: 'Student added successfully!');
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(auth.lastError ?? 'Failed to add student')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Add New Student'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Login Credentials'),
              const SizedBox(height: 16),
              _buildTextField(_usernameController, 'Student ID / Username', Icons.badge, required: true),
              const SizedBox(height: 16),
              _buildTextField(_passwordController, 'Initial Password', Icons.lock, isPassword: true, required: true),
              const SizedBox(height: 24),
              _buildSectionTitle('Profile Information'),
              const SizedBox(height: 16),
              _buildTextField(_emailController, 'Email Address', Icons.email, required: true),
              const SizedBox(height: 16),
              _buildTextField(_phoneController, 'Phone Number', Icons.phone),
              const SizedBox(height: 16),
              _buildTextField(_deptController, 'Department', Icons.school),
              const SizedBox(height: 16),
              _buildTextField(_roomController, 'Room Number', Icons.room),
              const SizedBox(height: 16),
              _buildTextField(_admissionController, 'Admission Number', Icons.numbers),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: InputDecoration(
                  labelText: 'Gender',
                  prefixIcon: const Icon(Icons.people),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: ['MALE', 'FEMALE', 'OTHER'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (val) => setState(() => _gender = val!),
              ),
              const SizedBox(height: 40),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo[900],
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Register Student', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo[900]),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {bool isPassword = false, bool required = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (val) {
        if (required && (val == null || val.isEmpty)) return 'This field is required';
        return null;
      },
    );
  }
}
