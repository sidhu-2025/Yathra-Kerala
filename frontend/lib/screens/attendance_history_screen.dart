import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  Map<DateTime, bool> _attendanceMap = {};
  bool _isLoading = true;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Search & Warden specifics
  final _searchController = TextEditingController();
  List<dynamic> _allAttendanceData = [];
  List<Map<String, dynamic>> _studentSummaries = [];
  List<Map<String, dynamic>> _filteredSummaries = [];
  String? _selectedStudentName;
  bool _isWarden = false;

  @override
  void initState() {
    super.initState();
    _fetchAttendance();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAttendance() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _isWarden = auth.user?.role == 'WARDEN';
    
    try {
      final response = await http.get(
        Uri.parse('${auth.baseUrl}/attendance/'),
        headers: {'Authorization': 'Token ${auth.user?.token}'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _allAttendanceData = data;

        if (_isWarden) {
          _processWardenData(data);
        } else {
          _processStudentData(data);
        }

        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _processStudentData(List<dynamic> data) {
    Map<DateTime, bool> tempMap = {};
    for (var item in data) {
      DateTime date = DateFormat('yyyy-MM-dd').parse(item['date']);
      DateTime normalizedDate = DateTime(date.year, date.month, date.day);
      tempMap[normalizedDate] = item['is_present'];
    }
    _attendanceMap = tempMap;
  }

  void _processWardenData(List<dynamic> data) {
    // Group records by student
    Map<String, List<dynamic>> grouped = {};
    for (var item in data) {
      String name = item['student_name'] ?? 'Unknown';
      grouped.putIfAbsent(name, () => []).add(item);
    }

    _studentSummaries = grouped.entries.map((e) {
      int present = e.value.where((v) => v['is_present']).length;
      int total = e.value.length;
      return {
        'name': e.key,
        'present': present,
        'total': total,
        'records': e.value,
      };
    }).toList();
    
    _filteredSummaries = List.from(_studentSummaries);
  }

  void _filterSearch(String query) {
    setState(() {
      _filteredSummaries = _studentSummaries
          .where((s) => s['name'].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _selectStudent(Map<String, dynamic> summary) {
    setState(() {
      _selectedStudentName = summary['name'];
      _processStudentData(summary['records']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(_isWarden && _selectedStudentName == null ? 'Search Attendance' : 'Attendance History'),
        elevation: 0,
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
        leading: _selectedStudentName != null 
          ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _selectedStudentName = null))
          : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isWarden && _selectedStudentName == null
              ? _buildWardenSearch()
              : _buildHistoryView(),
    );
  }

  Widget _buildWardenSearch() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.indigo[900],
          child: TextField(
            controller: _searchController,
            onChanged: _filterSearch,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search by VML or Name...',
              hintStyle: const TextStyle(color: Colors.white70),
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
        Expanded(
          child: _filteredSummaries.isEmpty
              ? const Center(child: Text('No students found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredSummaries.length,
                  itemBuilder: (context, index) {
                    final student = _filteredSummaries[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigo[50],
                          child: Text(student['name'].substring(0, 1).toUpperCase()),
                        ),
                        title: Text(student['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Present: ${student['present']} / ${student['total']}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _selectStudent(student),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHistoryView() {
    int presentCount = _attendanceMap.values.where((v) => v).length;
    int absentCount = _attendanceMap.values.where((v) => !v).length;
    double total = (presentCount + absentCount).toDouble();

    return SingleChildScrollView(
      child: Column(
        children: [
          if (_selectedStudentName != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Viewing: $_selectedStudentName',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
            ),
          _buildCalendar(),
          const SizedBox(height: 24),
          if (total > 0) _buildSummaryChart(presentCount, absentCount, total),
          if (total == 0)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('No attendance records to display'),
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: TableCalendar(
        firstDay: DateTime.now().subtract(const Duration(days: 365)),
        lastDay: DateTime.now().add(const Duration(days: 30)),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) => setState(() => _calendarFormat = format),
        onPageChanged: (focusedDay) => _focusedDay = focusedDay,
        eventLoader: (day) {
          final normalizedDay = DateTime(day.year, day.month, day.day);
          if (_attendanceMap.containsKey(normalizedDay)) {
            return [_attendanceMap[normalizedDay]];
          }
          return [];
        },
        calendarStyle: const CalendarStyle(
          todayDecoration: BoxDecoration(color: Colors.indigo, shape: BoxShape.circle),
          selectedDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
          markerDecoration: BoxDecoration(color: Colors.transparent),
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (events.isEmpty) return null;
            bool isPresent = events.first as bool;
            return Positioned(
              bottom: 1,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPresent ? Colors.green : Colors.red,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryChart(int present, int absent, double total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Visual Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                height: 150,
                width: 150,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: [
                      PieChartSectionData(
                        color: Colors.green,
                        value: present.toDouble(),
                        title: '${((present / total) * 100).toStringAsFixed(0)}%',
                        radius: 50,
                        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      PieChartSectionData(
                        color: Colors.red,
                        value: absent.toDouble(),
                        title: '${((absent / total) * 100).toStringAsFixed(0)}%',
                        radius: 50,
                        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _chartLegend('Present', Colors.green, present),
                  const SizedBox(height: 8),
                  _chartLegend('Absent', Colors.red, absent),
                  const Divider(height: 24),
                  Text(
                    'Total Days: ${total.toInt()}',
                    style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chartLegend(String label, Color color, int count) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
        Text('$count', style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
