import 'package:flutter/material.dart';
import 'dart:ui' show ImageFilter;
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _deptController = TextEditingController();
  final _roomController = TextEditingController();
  final _admissionController = TextEditingController();
  final _parentNameController = TextEditingController();
  final _parentEmailController = TextEditingController();
  final _semesterController = TextEditingController();
  String _selectedRole = 'STUDENT';
  String _selectedGender = 'MALE';
  bool _isLoading = false;

  final List<String> _roles = ['STUDENT', 'PARENT', 'WARDEN', 'SECURITY'];

  InputDecoration _glassInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white70),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white),
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
    );
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final auth = Provider.of<AuthProvider>(context, listen: false);
      final success = await auth.register(
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        role: _selectedRole,
        phoneNumber: _phoneController.text,
        department: _selectedRole == 'STUDENT' ? _deptController.text : null,
        roomNumber: _selectedRole == 'STUDENT' ? _roomController.text : null,
        gender: _selectedRole == 'STUDENT' ? _selectedGender : null,
        admissionNumber: _selectedRole == 'STUDENT' ? _admissionController.text : null,
        semester: _selectedRole == 'STUDENT' ? int.tryParse(_semesterController.text) : null,
        parentName: _selectedRole == 'STUDENT' ? _parentNameController.text : null,
        parentEmail: _selectedRole == 'STUDENT' ? _parentEmailController.text : null,
        studentUsername: _selectedRole == 'PARENT' ? _admissionController.text : null,
      );

      setState(() => _isLoading = false);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful! Please login.')),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(auth.lastError ?? 'Registration failed')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.indigo[900]!, Colors.blue[800]!],
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        padding: const EdgeInsets.all(32.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Create Account',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Join our hostel community',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.white70,
                                    ),
                              ),
                              const SizedBox(height: 32),
                              DropdownButtonFormField<String>(
                                value: _selectedRole,
                                dropdownColor: Colors.grey[800],
                                style: const TextStyle(color: Colors.white),
                                decoration: _glassInputDecoration('Select Role', Icons.badge_outlined),
                                items: _roles.map((role) {
                                  return DropdownMenuItem(
                                    value: role,
                                    child: Text(role[0] + role.substring(1).toLowerCase()),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedRole = value!;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _usernameController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _glassInputDecoration('Username', Icons.person_outline),
                                validator: (value) => value!.isEmpty ? 'Enter username' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _emailController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _glassInputDecoration('Email', Icons.email_outlined),
                                validator: (value) => value!.isEmpty ? 'Enter email' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _glassInputDecoration('Password', Icons.lock_outline),
                                obscureText: true,
                                validator: (value) => value!.length < 6 ? 'Password too short' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _phoneController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _glassInputDecoration('Phone Number', Icons.phone_outlined),
                              ),
                              if (_selectedRole == 'STUDENT') ...[
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _admissionController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: _glassInputDecoration('Admission Number', Icons.numbers_outlined),
                                  validator: (value) => value!.isEmpty ? 'Admission number required' : null,
                                ),
                                const SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  value: _selectedGender,
                                  dropdownColor: Colors.grey[800],
                                  style: const TextStyle(color: Colors.white),
                                  decoration: _glassInputDecoration('Gender', Icons.wc_outlined),
                                  items: ['MALE', 'FEMALE', 'OTHER'].map((gender) {
                                    return DropdownMenuItem(
                                      value: gender,
                                      child: Text(gender[0] + gender.substring(1).toLowerCase()),
                                    );
                                  }).toList(),
                                  onChanged: (value) => setState(() => _selectedGender = value!),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _deptController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: _glassInputDecoration('Department', Icons.school_outlined),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _semesterController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: _glassInputDecoration('Semester', Icons.calendar_view_day_outlined),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _roomController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: _glassInputDecoration('Room Number', Icons.room_outlined),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _parentNameController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: _glassInputDecoration('Parent Name', Icons.person_outline),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _parentEmailController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: _glassInputDecoration('Parent Email', Icons.email_outlined),
                                ),
                              ],
                              if (_selectedRole == 'PARENT') ...[
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _admissionController, // Reusing admissionController for Student ID
                                  style: const TextStyle(color: Colors.white),
                                  decoration: _glassInputDecoration('Student ID (VML Number)', Icons.school_outlined),
                                  validator: (value) => value!.isEmpty ? 'Student ID required for linking' : null,
                                ),
                              ],
                              const SizedBox(height: 32),
                              _isLoading
                                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                                  : ElevatedButton(
                                      onPressed: _register,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.blueAccent,
                                        padding: const EdgeInsets.symmetric(vertical: 18),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 2,
                                      ),
                                      child: const Text(
                                        'Register',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'Already have an account? Login',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
