import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth_provider.dart';
import '../../constants.dart';

class AttendanceReportScreen extends StatefulWidget {
  const AttendanceReportScreen({super.key});

  @override
  State<AttendanceReportScreen> createState() => _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen> {
  DateTime _selectedMonth = DateTime.now();
  List<dynamic> _report = [];
  Map<String, dynamic>? _dailyStats;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    _fetchReport();
    _fetchDailyStats();
  }

  String get _monthString => '${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}';
  String get _displayMonth {
    const months = ['', 'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[_selectedMonth.month]} ${_selectedMonth.year}';
  }

  void _fetchDailyStats() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/attendance/daily_stats/'),
        headers: {'Authorization': 'Token ${auth.user?.token}'},
      );
      if (response.statusCode == 200) {
        setState(() {
          _dailyStats = json.decode(response.body);
        });
      }
    } catch (e) {
      debugPrint('Daily stats error: $e');
    }
  }

  void _fetchReport() async {
    setState(() { _isLoading = true; _error = null; });
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/attendance/monthly_report/?month=$_monthString'),
        headers: {'Authorization': 'Token ${auth.user?.token}'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() { _report = data['report'] ?? []; _isLoading = false; });
      } else {
        setState(() { _error = 'Failed to load report'; _isLoading = false; });
      }
    } catch (e) {
      setState(() { _error = 'Connection error'; _isLoading = false; });
    }
  }

  void _previousMonth() {
    setState(() => _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1));
    _fetchReport();
  }

  void _nextMonth() {
    if (_selectedMonth.year < DateTime.now().year || (_selectedMonth.year == DateTime.now().year && _selectedMonth.month < DateTime.now().month)) {
      setState(() => _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1));
      _fetchReport();
    }
  }

  void _downloadPDF() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/attendance/download_pdf/?month=$_monthString'),
        headers: {'Authorization': 'Token ${auth.user?.token}'},
      );
      
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final dir = await getDownloadDirectory();
        final file = File('${dir.path}/attendance_report_$_monthString.pdf');
        await file.writeAsBytes(bytes);
        
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('PDF Downloaded successfully'),
              action: SnackBarAction(
                label: 'Open',
                onPressed: () => OpenFilex.open(file.path),
              ),
            ),
          );
        }
      } else {
        setState(() { _error = 'Failed to download PDF'; _isLoading = false; });
      }
    } catch (e) {
      setState(() { _error = 'Download error'; _isLoading = false; });
    }
  }

  Future<Directory> getDownloadDirectory() async {
    if (Platform.isAndroid) {
      return Directory('/storage/emulated/0/Download');
    }
    return await getApplicationDocumentsDirectory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Attendance Statistics'),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _report.isNotEmpty ? _downloadPDF : null,
            tooltip: 'Download PDF',
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildDailyStatsSection(),
                Container(
                  color: Colors.indigo[900],
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: Colors.white),
                        onPressed: _previousMonth,
                      ),
                      Text(
                        _displayMonth,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, color: Colors.white),
                        onPressed: _nextMonth,
                      ),
                    ],
                  ),
                ),
                if (!_isLoading && _error == null && _report.isNotEmpty)
                  _buildMonthlySummaryHeader(),
              ],
            ),
          ),
          
          if (_isLoading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (_error != null)
            SliverFillRemaining(child: Center(child: Text(_error!, style: const TextStyle(color: Colors.red))))
          else if (_report.isEmpty)
            const SliverFillRemaining(child: Center(child: Text('No attendance data for this month')))
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final student = _report[index];
                    return _buildStudentCard(student);
                  },
                  childCount: _report.length,
                ),
              ),
            ),
          
          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  }

  Widget _buildDailyStatsSection() {
    if (_dailyStats == null) return const SizedBox.shrink();

    final present = (_dailyStats!['present'] as num).toDouble();
    final absent = (_dailyStats!['absent'] as num).toDouble();
    final total = (_dailyStats!['total'] as num).toDouble();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Attendance Overview',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              SizedBox(
                height: 150,
                width: 150,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 40,
                    sections: [
                      PieChartSectionData(
                        color: Colors.green,
                        value: present,
                        title: '${(present / total * 100).toStringAsFixed(0)}%',
                        radius: 50,
                        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      PieChartSectionData(
                        color: Colors.red,
                        value: absent,
                        title: '${(absent / total * 100).toStringAsFixed(0)}%',
                        radius: 50,
                        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Column(
                  children: [
                    _buildLegendItem('Present', present.toInt(), Colors.green),
                    const SizedBox(height: 12),
                    _buildLegendItem('Absent', absent.toInt(), Colors.red),
                    const Divider(height: 24),
                    _buildLegendItem('Total Students', total.toInt(), Colors.indigo),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, int value, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ),
        Text(
          value.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildMonthlySummaryHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly Summary',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _summaryChip('Total Students', '${_report.length}', Colors.indigo),
              _summaryChip('Avg Present', '${(_report.map((r) => r['present'] as int).fold(0, (a, b) => a + b) / _report.length).toStringAsFixed(1)}', Colors.green),
              _summaryChip('Avg Absent', '${(_report.map((r) => r['absent'] as int).fold(0, (a, b) => a + b) / _report.length).toStringAsFixed(1)}', Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(dynamic student) {
    final total = student['total'] as int;
    final present = student['present'] as int;
    final pct = total > 0 ? (present / total * 100).toStringAsFixed(0) : '0';
    final pctInt = total > 0 ? (present / total) : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student['full_name'] ?? student['username'],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(student['username'], style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: double.parse(pct) >= 75 ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$pct%',
                    style: TextStyle(
                      color: double.parse(pct) >= 75 ? Colors.green[700] : Colors.red[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pctInt.toDouble(),
                backgroundColor: Colors.grey[200],
                color: double.parse(pct) >= 75 ? Colors.green : Colors.red,
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statBadge('Present', '${student['present']}', Colors.green),
                _statBadge('Absent', '${student['absent']}', Colors.red),
                _statBadge('Late', '${student['late']}', Colors.orange),
                _statBadge('Total', '$total', Colors.indigo),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _statBadge(String label, String val, Color color) {
    return Column(
      children: [
        Text(val, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }
}
