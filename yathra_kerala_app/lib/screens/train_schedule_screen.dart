import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import 'train_live_map_screen.dart';

class TrainScheduleScreen extends StatefulWidget {
  final String? initialFrom;
  final String? initialTo;

  const TrainScheduleScreen({
    super.key,
    this.initialFrom,
    this.initialTo,
  });

  @override
  State<TrainScheduleScreen> createState() => _TrainScheduleScreenState();
}

class _TrainScheduleScreenState extends State<TrainScheduleScreen> {
  final List<Map<String, String>> _stations = [
    // Mangaluru & Kasaragod Region
    {'name': 'Mangaluru', 'code': 'MAQ', 'label': 'Mangaluru Central (MAQ)'},
    {'name': 'Manjeshwar', 'code': 'MJS', 'label': 'Manjeshwar (MJS)'},
    {'name': 'Kumbla', 'code': 'KMBL', 'label': 'Kumbla (KMBL)'},
    {'name': 'Kasaragod', 'code': 'KGQ', 'label': 'Kasaragod (KGQ)'},
    {'name': 'Kotikulam', 'code': 'KQK', 'label': 'Kotikulam (KQK)'},
    {'name': 'Bekal Fort', 'code': 'BFR', 'label': 'Bekal Fort (BFR)'},
    {'name': 'Kanhangad', 'code': 'KZE', 'label': 'Kanhangad (KZE)'},
    {'name': 'Nileshwar', 'code': 'NLE', 'label': 'Nileshwar (NLE)'},
    {'name': 'Cheruvathur', 'code': 'CHV', 'label': 'Cheruvathur (CHV)'},
    {'name': 'Payyanur', 'code': 'PAY', 'label': 'Payyanur (PAY)'},
    {'name': 'Pazhayangadi', 'code': 'PAZ', 'label': 'Pazhayangadi (PAZ)'},
    {'name': 'Cherukunnu', 'code': 'KPQ', 'label': 'Kannapuram / Cherukunnu (KPQ)'},
    {'name': 'Valapattanam', 'code': 'VAPM', 'label': 'Valapattanam (VAPM)'},

    // Kannur & Malabar Region
    {'name': 'Kannur', 'code': 'CAN', 'label': 'Kannur Main (CAN)'},
    {'name': 'Dharmadam', 'code': 'DMD', 'label': 'Dharmadam (DMD)'},
    {'name': 'Thalassery', 'code': 'TLY', 'label': 'Thalassery (TLY)'},
    {'name': 'Mahe', 'code': 'MAHE', 'label': 'Mahe (MAHE)'},
    {'name': 'Vadakara', 'code': 'BDJ', 'label': 'Vadakara (BDJ)'},
    {'name': 'Payyoli', 'code': 'PYOL', 'label': 'Payyoli (PYOL)'},
    {'name': 'Koyilandy', 'code': 'QLD', 'label': 'Koyilandy (QLD)'},

    // Kozhikode & Malappuram Region
    {'name': 'Kozhikode', 'code': 'CLT', 'label': 'Kozhikode Main (CLT)'},
    {'name': 'Ferok', 'code': 'FK', 'label': 'Ferok (FK)'},
    {'name': 'Parappanangadi', 'code': 'PGI', 'label': 'Parappanangadi (PGI)'},
    {'name': 'Tanur', 'code': 'TA', 'label': 'Tanur (TA)'},
    {'name': 'Tirur', 'code': 'TIR', 'label': 'Tirur (TIR)'},
    {'name': 'Kuttippuram', 'code': 'KTU', 'label': 'Kuttippuram (KTU)'},
    {'name': 'Pattambi', 'code': 'PTB', 'label': 'Pattambi (PTB)'},

    // Shoranur & Palakkad / Coimbatore Junctions
    {'name': 'Shoranur', 'code': 'SRR', 'label': 'Shoranur Jn (SRR)'},
    {'name': 'Ottappalam', 'code': 'OTP', 'label': 'Ottappalam (OTP)'},
    {'name': 'Palakkad', 'code': 'PGT', 'label': 'Palakkad Jn (PGT)'},
    {'name': 'Coimbatore', 'code': 'CBE', 'label': 'Coimbatore Jn (CBE)'},

    // Central Kerala (Thrissur & Ernakulam)
    {'name': 'Wadakanchery', 'code': 'WKI', 'label': 'Wadakanchery (WKI)'},
    {'name': 'Thrissur', 'code': 'TCR', 'label': 'Thrissur (TCR)'},
    {'name': 'Irinjalakuda', 'code': 'IJK', 'label': 'Irinjalakuda (IJK)'},
    {'name': 'Chalakudi', 'code': 'CKI', 'label': 'Chalakudi (CKI)'},
    {'name': 'Angamaly', 'code': 'AFK', 'label': 'Angamaly for Kalady (AFK)'},
    {'name': 'Aluva', 'code': 'AWY', 'label': 'Aluva (AWY)'},
    {'name': 'Ernakulam Town', 'code': 'ERN', 'label': 'Ernakulam Town / North (ERN)'},
    {'name': 'Ernakulam', 'code': 'ERS', 'label': 'Ernakulam Jn / South (ERS)'},
    {'name': 'Thrippunithura', 'code': 'TRTR', 'label': 'Thrippunithura (TRTR)'},
    {'name': 'Piravom Road', 'code': 'PVRD', 'label': 'Piravom Road (PVRD)'},

    // Alappuzha Coastal Route
    {'name': 'Cherthala', 'code': 'SRTL', 'label': 'Cherthala (SRTL)'},
    {'name': 'Alappuzha', 'code': 'ALLP', 'label': 'Alappuzha (ALLP)'},
    {'name': 'Ambalapuzha', 'code': 'AMPA', 'label': 'Ambalapuzha (AMPA)'},
    {'name': 'Haripad', 'code': 'HAD', 'label': 'Haripad (HAD)'},

    // Kottayam Inland Route
    {'name': 'Kottayam', 'code': 'KTYM', 'label': 'Kottayam (KTYM)'},
    {'name': 'Changanassery', 'code': 'CGY', 'label': 'Changanassery (CGY)'},
    {'name': 'Tiruvalla', 'code': 'TRVL', 'label': 'Tiruvalla (TRVL)'},
    {'name': 'Chengannur', 'code': 'CNGR', 'label': 'Chengannur (CNGR)'},
    {'name': 'Mavelikara', 'code': 'MVLK', 'label': 'Mavelikara (MVLK)'},

    // South Kerala (Kollam & Trivandrum)
    {'name': 'Kayamkulam', 'code': 'KYJ', 'label': 'Kayamkulam Jn (KYJ)'},
    {'name': 'Karunagappalli', 'code': 'KPY', 'label': 'Karunagappalli (KPY)'},
    {'name': 'Kollam', 'code': 'QLN', 'label': 'Kollam Jn (QLN)'},
    {'name': 'Paravur', 'code': 'PVU', 'label': 'Paravur (PVU)'},
    {'name': 'Varkala', 'code': 'VAK', 'label': 'Varkala Sivagiri (VAK)'},
    {'name': 'Chirayinkeezhu', 'code': 'CRY', 'label': 'Chirayinkeezhu (CRY)'},
    {'name': 'Kazhakkuttam', 'code': 'KZK', 'label': 'Kazhakkuttam / Technopark (KZK)'},
    {'name': 'Kochuveli', 'code': 'KCVL', 'label': 'Kochuveli (KCVL)'},
    {'name': 'Thiruvananthapuram', 'code': 'TVC', 'label': 'Thiruvananthapuram Central (TVC)'},
    {'name': 'Neyyattinkara', 'code': 'NYY', 'label': 'Neyyattinkara (NYY)'},
    {'name': 'Parassala', 'code': 'PASA', 'label': 'Parassala (PASA)'},
    {'name': 'Nagercoil', 'code': 'NCJ', 'label': 'Nagercoil Jn (NCJ)'},
  ];

  late String _fromStation;
  late String _toStation;
  bool _isLoading = false;
  List<dynamic> _trains = [];
  Map<String, dynamic>? _apiConfig;
  final TextEditingController _trackTrainNoCtrl = TextEditingController(text: '16650');

  String _normalizeStation(String? input, String fallback) {
    if (input == null || input.trim().isEmpty) return fallback;
    final clean = input.trim().toLowerCase();
    for (final s in _stations) {
      final nameLower = s['name']!.toLowerCase();
      final codeLower = s['code']!.toLowerCase();
      if (nameLower == clean ||
          codeLower == clean ||
          clean.contains(nameLower) ||
          nameLower.contains(clean)) {
        return s['name']!;
      }
    }
    return fallback;
  }

  @override
  void initState() {
    super.initState();
    _fromStation = _normalizeStation(widget.initialFrom, 'Kannur');
    _toStation = _normalizeStation(widget.initialTo, 'Thalassery');
    if (_fromStation == _toStation) {
      _toStation = _fromStation == 'Kannur' ? 'Thalassery' : 'Kannur';
    }
    _loadApiConfig();
    _fetchTrains();
  }

  @override
  void dispose() {
    _trackTrainNoCtrl.dispose();
    super.dispose();
  }

  void _showLiveTrackingSheet(String trainNo, {String? trainName}) {
    final cleanNo = trainNo.replaceAll(RegExp(r'[^0-9]'), '').trim();
    if (cleanNo.length != 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 5-digit Indian Railways train number (e.g. 16308, 16650, 22610).'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TrainLiveMapScreen(
          trainNo: cleanNo,
          startWithTimeline: true,
        ),
      ),
    );
  }

  Widget _buildQuickTrainChip(String trainNo, String label) {
    return InkWell(
      onTap: () {
        _trackTrainNoCtrl.text = trainNo;
        _showLiveTrackingSheet(trainNo, trainName: label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white38),
        ),
        child: Text(
          '$trainNo $label',
          style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> _loadApiConfig() async {
    try {
      final res = await http.get(Uri.parse('${ApiService.baseUrl}/api/trains/config'));
      if (res.statusCode == 200) {
        setState(() {
          _apiConfig = jsonDecode(res.body);
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchTrains() async {
    setState(() => _isLoading = true);
    try {
      final uri = Uri.parse(
        '${ApiService.baseUrl}/api/trains?from_station=${Uri.encodeComponent(_fromStation)}&to_station=${Uri.encodeComponent(_toStation)}',
      );
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _trains = data['trains'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _openApiKeyDialog() {
    final keyController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.vpn_key, color: const Color(0xFF1565C0)),
            SizedBox(width: 8),
            Text('Train API Key Config', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'All official train timetables and schedules work completely free without any key.',
              style: TextStyle(fontSize: 12, color: Colors.black87),
            ),
            const SizedBox(height: 6),
            const Text(
              'An API Key is only needed if you registered for a RailRadar sandbox account to get live satellite GPS coordinates.',
              style: TextStyle(fontSize: 11, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Status: ${_apiConfig?['api_key_configured'] == true ? "Configured" : "Timetable Active (No Key Needed)"}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _apiConfig?['api_key_configured'] == true ? Colors.green.shade800 : const Color(0xFF1565C0))),
                  const SizedBox(height: 2),
                  Text('Host: ${_apiConfig?['railway_api_host'] ?? "api.railradar.in"}', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: keyController,
              decoration: InputDecoration(
                hintText: 'Paste RailRadar API Key (Optional)...',
                hintStyle: const TextStyle(fontSize: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0), foregroundColor: Colors.white),
            onPressed: () async {
              if (keyController.text.trim().isNotEmpty) {
                try {
                  await http.post(
                    Uri.parse('${ApiService.baseUrl}/api/trains/config'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({'api_key': keyController.text.trim()}),
                  );
                } catch (_) {}
              }
              Navigator.pop(ctx);
              _loadApiConfig();
              _fetchTrains();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Railway API Key updated and persisted!')),
              );
            },
            child: const Text('Save & Fetch'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Yathra Kerala – Train Schedule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('Malabar Rail Corridor • Live Schedules & Fares', style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.vpn_key_outlined),
            tooltip: 'Configure Train API Key',
            onPressed: _openApiKeyDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Schedules',
            onPressed: _fetchTrains,
          ),
        ],
      ),
      body: Column(
        children: [
          // Live Train Radar Quick Bar
          Container(
            margin: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1565C0).withValues(alpha: 0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.radar, color: Colors.amberAccent, size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Live Train Tracking (Rail Radar API)',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('REAL-TIME', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: _trackTrainNoCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(
                            hintText: 'Enter Train No (e.g. 16650)',
                            hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                            prefixIcon: Icon(Icons.search, size: 18, color: Color(0xFF1565C0)),
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amberAccent,
                        foregroundColor: const Color(0xFF0D47A1),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.my_location, size: 15),
                      label: const Text('Track', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                      onPressed: () {
                        final no = _trackTrainNoCtrl.text.trim();
                        if (no.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a 5-digit train number (e.g. 16308, 16649, 16650, 20631)')),
                          );
                          return;
                        }
                        if (!RegExp(r'^\d{5}$').hasMatch(no)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Train number must be exactly 5 digits (e.g. 16308, 16649, 16650, 20631, 20632)'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                          return;
                        }
                        _showLiveTrackingSheet(no);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const Text('Popular: ', style: TextStyle(color: Colors.white70, fontSize: 10)),
                      _buildQuickTrainChip('16308', 'Executive'),
                      const SizedBox(width: 4),
                      _buildQuickTrainChip('16649', 'Parasuram'),
                      const SizedBox(width: 4),
                      _buildQuickTrainChip('20631', 'Vande Bharat'),
                      const SizedBox(width: 4),
                      _buildQuickTrainChip('16650', 'Parasuram (Up)'),
                      const SizedBox(width: 4),
                      _buildQuickTrainChip('16605', 'Ernad'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Station Selector Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // From Station
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('FROM STATION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<String>(
                            value: _fromStation,
                            isExpanded: true,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            items: _stations.map((s) => DropdownMenuItem(value: s['name'], child: Text(s['label']!, style: const TextStyle(fontSize: 12)))).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _fromStation = val);
                                _fetchTrains();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Swap Button
                    Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: IconButton(
                        icon: const Icon(Icons.swap_horiz, color: const Color(0xFF1565C0)),
                        tooltip: 'Swap Stations',
                        onPressed: () {
                          setState(() {
                            final tmp = _fromStation;
                            _fromStation = _toStation;
                            _toStation = tmp;
                          });
                          _fetchTrains();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // To Station
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TO STATION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<String>(
                            value: _toStation,
                            isExpanded: true,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            items: _stations.map((s) => DropdownMenuItem(value: s['name'], child: Text(s['label']!, style: const TextStyle(fontSize: 12)))).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _toStation = val);
                                _fetchTrains();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Live Status Pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.green),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${_trains.length} Direct Trains Found',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                    Text(
                      _apiConfig?['api_key_configured'] == true ? 'Rail Radar API Active' : 'Railway Timetable',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Trains List View
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: const Color(0xFF1565C0)))
                : _trains.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.train_outlined, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text('No direct trains between $_fromStation and $_toStation', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            const Text('Try selecting Kannur, Thalassery, Cherukunnu or Kozhikode', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _trains.length,
                        itemBuilder: (ctx, idx) {
                          final tr = _trains[idx];
                          final trainNo = tr['train_no'] ?? '';
                          final trainName = tr['name'] ?? '';
                          final dep = tr['departure'] ?? '';
                          final arr = tr['arrival'] ?? '';
                          final dur = tr['duration_mins'] ?? 0;
                          final fare = tr['fare_general'] ?? 30;
                          final type = tr['type'] ?? 'Express';
                          final status = tr['status'] ?? 'ON TIME';
                          final source = tr['api_source'] ?? 'Indian Railways Timetable';

                          final isPremium = trainName.toLowerCase().contains('vande');

                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(color: isPremium ? Colors.amber.shade400 : Colors.grey.shade200),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Top Row: Train Number, Name, Type
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isPremium ? const Color(0xFF1565C0) : Colors.blue.shade900,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '#$trainNo',
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              trainName,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  type,
                                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                                                ),
                                                if (tr['days'] != null) ...[
                                                  Text(' • ', style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                                                  Text(
                                                    tr['days'],
                                                    style: TextStyle(color: Colors.teal.shade700, fontSize: 10, fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade50,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: Colors.green),
                                        ),
                                        child: Text(
                                          status,
                                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 10),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const Divider(height: 20),

                                  // Middle Row: Time flow (Departure -> Duration -> Arrival)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Departure
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            dep,
                                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black87),
                                          ),
                                          Text(
                                            _fromStation,
                                            style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                                          ),
                                          if (tr['departure_pf'] != null)
                                            Container(
                                              margin: const EdgeInsets.only(top: 2),
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: Colors.amber.shade100,
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(color: Colors.amber.shade700, width: 0.8),
                                              ),
                                              child: Text(
                                                tr['departure_pf'],
                                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                                              ),
                                            ),
                                        ],
                                      ),

                                      // Journey arrow & duration
                                      Column(
                                        children: [
                                          Text(
                                            '$dur mins',
                                            style: TextStyle(fontSize: 11, color: const Color(0xFF1565C0), fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Container(width: 30, height: 1.5, color: Colors.grey.shade400),
                                              const Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
                                              Container(width: 30, height: 1.5, color: Colors.grey.shade400),
                                            ],
                                          ),
                                          const Text('Direct', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                        ],
                                      ),

                                      // Arrival
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            arr,
                                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black87),
                                          ),
                                          Text(
                                            _toStation,
                                            style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                                          ),
                                          if (tr['arrival_pf'] != null)
                                            Container(
                                              margin: const EdgeInsets.only(top: 2),
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade200,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                tr['arrival_pf'],
                                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  // Bottom Row: Classes and Fares
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50.withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.blue.shade100),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.confirmation_number_outlined, size: 14, color: Color(0xFF1565C0)),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Ticket Fare: ₹$fare',
                                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.blue.shade900),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              isPremium ? '(CC)' : '(General / 2S)',
                                              style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                                            ),
                                          ],
                                        ),
                                        const Text(
                                          'IRCTC Verified',
                                          style: TextStyle(fontSize: 9.5, color: Colors.black54, fontStyle: FontStyle.italic),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Track Live (Rail Radar) Action Button
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF1565C0),
                                        foregroundColor: Colors.white,
                                        elevation: 1,
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      icon: const Icon(Icons.radar, size: 15, color: Colors.amberAccent),
                                      label: const Text('Track Live (Rail Radar)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                      onPressed: () => _showLiveTrackingSheet(trainNo, trainName: trainName),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _LiveTrainTrackingSheet extends StatefulWidget {
  final String trainNo;
  final String? trainName;
  final VoidCallback onConfigUpdated;

  const _LiveTrainTrackingSheet({
    required this.trainNo,
    this.trainName,
    required this.onConfigUpdated,
  });

  @override
  State<_LiveTrainTrackingSheet> createState() => _LiveTrainTrackingSheetState();
}

class _LiveTrainTrackingSheetState extends State<_LiveTrainTrackingSheet> {
  bool _loading = true;
  Map<String, dynamic>? _trackData;
  final TextEditingController _keyCtrl = TextEditingController();
  bool _savingKey = false;

  @override
  void initState() {
    super.initState();
    _fetchLiveTrack();
  }

  @override
  void dispose() {
    _keyCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchLiveTrack() async {
    setState(() => _loading = true);
    final res = await ApiService.trackTrainLive(widget.trainNo);
    if (mounted) {
      setState(() {
        _trackData = res;
        _loading = false;
      });
    }
  }

  void _showApiKeyDialog() {
    final keyController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('RailRadar API Key', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your RailRadar API Key to fetch live running status.', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 10),
            TextField(
              controller: keyController,
              decoration: const InputDecoration(hintText: 'Paste RailRadar API Key...', border: OutlineInputBorder(), isDense: true),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final k = keyController.text.trim();
              if (k.isNotEmpty) {
                await ApiService.updateTrainConfig(apiKey: k);
                widget.onConfigUpdated();
                _fetchLiveTrack();
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveKey() async {
    final k = _keyCtrl.text.trim();
    if (k.isEmpty) return;
    setState(() => _savingKey = true);
    final ok = await ApiService.updateTrainConfig(
      apiKey: k,
      apiHost: 'api.railradar.in',
      enableLiveApi: true,
      strictRailRadar: true,
    );
    if (mounted) {
      setState(() => _savingKey = false);
      if (ok) {
        widget.onConfigUpdated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rail Radar API Key updated! Refreshing live status...')),
        );
        _fetchLiveTrack();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1565C0);
    const deepBlue = Color(0xFF0D47A1);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        top: 14,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Sheet Title Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.radar, color: primaryBlue, size: 24),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Train #${widget.trainNo}',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: deepBlue),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.green),
                            ),
                            child: const Text('RAIL RADAR LIVE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.green)),
                          ),
                        ],
                      ),
                      Text(
                        widget.trainName ?? 'Indian Railways Express',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 24),

            if (_loading) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: primaryBlue),
                      SizedBox(height: 12),
                      Text('Connecting to Rail Radar API (api.railradar.in)...', style: TextStyle(fontSize: 12, color: primaryBlue, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ] else if (_trackData != null && _trackData!['success'] == true && _trackData!['data'] != null) ...[
              // Live Rail Radar Status Display
              Builder(
                builder: (_) {
                  final data = _trackData!['data'] as Map<String, dynamic>;
                  final currStn = data['current_station'] ?? 'Kannur Main (CAN)';
                  final nextStn = data['next_station'] ?? 'Thalassery (TLY)';
                  final delay = (data['delay_minutes'] ?? 0) as int;
                  final status = data['current_status'] ?? 'ON TIME';
                  final lastUpdated = data['last_updated_at'] ?? 'Just now';
                  final pf = data['platform'] ?? '--';
                  final schDep = data['scheduled_departure'];
                  final actDep = data['actual_departure'];
                  final rawLat = data['latitude'] as num?;
                  final rawLng = data['longitude'] as num?;
                  final bool hasGps = rawLat != null && rawLng != null && rawLat.isFinite && rawLng.isFinite;
                  final isDelayed = delay > 0;
                  final apiSource = _trackData!['api_source'] ?? 'RailRadar Live API';

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Banner
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDelayed ? Colors.orange.shade50 : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isDelayed ? Colors.orange : Colors.green),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isDelayed ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                                  color: isDelayed ? Colors.orange.shade800 : Colors.green.shade800,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isDelayed ? 'DELAYED BY $delay MINS' : status,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                    color: isDelayed ? Colors.orange.shade900 : Colors.green.shade900,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: hasGps ? Colors.green.shade100 : Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                hasGps ? '● GPS FIX' : 'TIMETABLE SYNC',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: hasGps ? Colors.green.shade900 : deepBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Station progression
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.train, color: primaryBlue, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('CURRENT STATION / POSITION', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                                      Text(currStn.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                                      Text('Platform: $pf', style: const TextStyle(fontSize: 11, color: deepBlue, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Divider(),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.arrow_downward, color: Colors.grey, size: 18),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('NEXT UPCOMING STATION', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                                      Text(nextStn.toString(), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Scheduled vs Actual Timings
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                const Text('SCHEDULED DEP', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 2),
                                Text(schDep != null ? schDep.toString() : '--', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                            Container(width: 1, height: 26, color: Colors.grey.shade300),
                            Column(
                              children: [
                                const Text('ACTUAL / EST DEP', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 2),
                                Text(
                                  actDep != null ? actDep.toString() : (schDep != null ? '$schDep (Est)' : '--'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: isDelayed ? Colors.orange.shade900 : Colors.green.shade900,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Coordinates & Attribution
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              hasGps ? 'GPS Fix: ($rawLat, $rawLng)' : 'GPS: Exact satellite coords unavailable',
                              style: const TextStyle(fontSize: 10, color: Colors.black54),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(apiSource.toString(), style: const TextStyle(fontSize: 10, color: primaryBlue, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // View on Live OpenStreetMap Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.map, size: 18),
                          label: const Text('Open on Live OpenStreetMap', style: TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TrainLiveMapScreen(trainNo: widget.trainNo, initialData: data),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ] else ...[
              // Error fallback / Not found
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _trackData?['error'] ?? _trackData?['detail'] ?? _trackData?['message'] ?? 'Could not fetch live train status from Rail Radar.',
                      style: TextStyle(color: Colors.red.shade900, fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, foregroundColor: Colors.white),
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Retry Track'),
                          onPressed: _fetchLiveTrack,
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () {
                            _showApiKeyDialog();
                          },
                          child: const Text('API Key Config'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
