import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/leave_model.dart';
import '../models/user_model.dart';
import '../constants.dart';

class LeaveProvider with ChangeNotifier {
  List<LeaveModel> _leaves = [];
  bool _isLoading = false;
  WebSocketChannel? _channel;

  List<LeaveModel> get leaves => _leaves;
  bool get isLoading => _isLoading;

  final String baseUrl = ApiConstants.baseUrl;
  final String wsUrl = ApiConstants.wsUrl;

  void initializeWebSocket(UserModel user) {
    if (_channel != null) return;

    _channel = IOWebSocketChannel.connect(Uri.parse(wsUrl));
    _channel!.stream.listen((message) {
      final data = json.decode(message);
      if (data['type'] == 'leave_update') {
        print('Real-time update received: ${data['message']}');
        fetchLeaves(user); // Refresh the list
      }
    }, onError: (error) {
      print('WebSocket Error: $error');
      _channel = null;
    }, onDone: () {
      print('WebSocket closed');
      _channel = null;
    });
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }

  Future<void> fetchLeaves(UserModel user) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/leaves/'),
        headers: {'Authorization': 'Token ${user.token}'},
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        _leaves = data.map((json) => LeaveModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('Fetch leaves error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> submitLeave(UserModel user, String reason, String destination, DateTime start, DateTime end) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/leaves/'),
        headers: {
          'Authorization': 'Token ${user.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'reason': reason,
          'destination': destination,
          'start_date': start.toIso8601String(),
          'end_date': end.toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        fetchLeaves(user);
        return true;
      }
    } catch (e) {
      print('Submit leave error: $e');
    }
    return false;
  }

  Future<bool> approveByParent(UserModel user, int leaveId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/leaves/$leaveId/approve_by_parent/'),
        headers: {'Authorization': 'Token ${user.token}'},
      );
      if (response.statusCode == 200) {
        fetchLeaves(user);
        return true;
      }
    } catch (e) {
      print('Approve by parent error: $e');
    }
    return false;
  }

  Future<bool> rejectByParent(UserModel user, int leaveId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/leaves/$leaveId/reject_by_parent/'),
        headers: {'Authorization': 'Token ${user.token}'},
      );
      if (response.statusCode == 200) {
        fetchLeaves(user);
        return true;
      }
    } catch (e) {
      print('Reject by parent error: $e');
    }
    return false;
  }

  Future<bool> approveByWarden(UserModel user, int leaveId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/leaves/$leaveId/approve_by_warden/'),
        headers: {'Authorization': 'Token ${user.token}'},
      );
      if (response.statusCode == 200) {
        fetchLeaves(user);
        return true;
      }
    } catch (e) {
      print('Approve by warden error: $e');
    }
    return false;
  }

  Future<bool> rejectByWarden(UserModel user, int leaveId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/leaves/$leaveId/reject_by_warden/'),
        headers: {'Authorization': 'Token ${user.token}'},
      );
      if (response.statusCode == 200) {
        fetchLeaves(user);
        return true;
      }
    } catch (e) {
      print('Reject by warden error: $e');
    }
    return false;
  }

  Future<Map<String, dynamic>?> verifyQR(UserModel user, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/leaves/verify/$token/'),
        headers: {'Authorization': 'Token ${user.token}'},
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Verify QR error: $e');
    }
    return null;
  }

  Future<bool> markEntryExit(UserModel user, int leaveId, String logType) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/leaves/$leaveId/mark_entry_exit/'),
        headers: {
          'Authorization': 'Token ${user.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode({'log_type': logType}),
      );
      if (response.statusCode == 200) {
        return true;
      }
      print('Mark entry/exit failed: ${response.statusCode} - ${response.body}');
    } catch (e) {
      print('Mark entry/exit error: $e');
    }
    return false;
  }

  Future<bool> registerComplaint(UserModel user, String description) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/complaints/'),
        headers: {
          'Authorization': 'Token ${user.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode({'description': description}),
      );
      if (response.statusCode == 201) return true;
    } catch (e) {
      print('Register complaint error: $e');
    }
    return false;
  }

  Future<bool> submitVacatingForm(UserModel user, String reason) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/vacating/'),
        headers: {
          'Authorization': 'Token ${user.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode({'reason': reason}),
      );
      if (response.statusCode == 201) return true;
    } catch (e) {
      print('Submit vacating form error: $e');
    }
    return false;
  }
}
