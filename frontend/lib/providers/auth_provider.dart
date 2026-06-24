import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../constants.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;

  String? _lastError;
  String? get lastError => _lastError;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      _user = UserModel.fromJson(json.decode(userData));
      notifyListeners();
    }
  }

  Future<void> _saveUser(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode(userData));
  }

  Future<void> _clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }

  final String baseUrl = ApiConstants.baseUrl;

  Future<bool> login(String username, String password, String role) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login/'),
        body: {
          'username': username,
          'password': password,
          'role': role,
        },
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        _user = UserModel.fromJson(userData);
        await _saveUser(_user!.toJson());
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final errorData = json.decode(response.body);
        _lastError = _parseError(errorData);
        print('Login failed: $_lastError');
      }
    } catch (e) {
      _lastError = 'Connection error: $e';
      print('Login Exception: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String role,
    String? phoneNumber,
    String? parentUsername,
    String? department,
    String? roomNumber,
    String? gender,
    String? admissionNumber,
    int? semester,
    String? parentName,
    String? parentEmail,
    String? studentUsername,
    String? fullName,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
          'role': role,
          'phone_number': phoneNumber ?? '',
          'parent_username': parentUsername ?? '',
          'student_username': studentUsername ?? '',
          'department': department ?? '',
          'room_number': roomNumber ?? '',
          'gender': gender ?? '',
          'admission_number': admissionNumber ?? '',
          'semester': semester,
          'parent_name': parentName ?? '',
          'parent_email': parentEmail ?? '',
          'full_name': fullName ?? '',
        }),
      );

      print('Registration response status: ${response.statusCode}');
      print('Registration response body: ${response.body}');

      if (response.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final errorData = json.decode(response.body);
        _lastError = _parseError(errorData);
        print('Registration failed: $_lastError');
      }
    } catch (e, stackTrace) {
      _lastError = 'Connection error: $e';
      print('Registration Exception: $e');
      print('Stack trace: $stackTrace');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  String _parseError(dynamic errorData) {
    if (errorData is Map) {
      // Return the first error message found
      for (var value in errorData.values) {
        if (value is List && value.isNotEmpty) return value[0].toString();
        if (value is String) return value;
      }
    }
    return errorData.toString();
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/password-reset/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200 || response.statusCode == 302) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Django's PasswordResetView might return HTML or a redirect
        // In a real API setup, we'd use a dedicated API view, but for now
        // we'll assume success if it doesn't 500 or 400.
        // Actually, let's just check for non-error codes.
        if (response.statusCode < 400) {
           _isLoading = false;
           notifyListeners();
           return true;
        }
        _lastError = 'Failed to send reset email. Status: ${response.statusCode}';
      }
    } catch (e) {
      _lastError = 'Connection error: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/change-password/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token ${user!.token}',
        },
        body: json.encode({
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final errorData = json.decode(response.body);
        _lastError = _parseError(errorData);
        print('Password change failed: $_lastError');
      }
    } catch (e) {
      _lastError = 'Connection error: $e';
      print('Password Change Exception: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void logout() async {
    _user = null;
    await _clearUser();
    notifyListeners();
  }
}
