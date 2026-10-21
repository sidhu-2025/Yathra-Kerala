import 'package:flutter/material.dart';
import '../services/api_service.dart';

class KsrtcBusScheduleScreen extends StatefulWidget {
  final String? initialDestination;
  const KsrtcBusScheduleScreen({super.key, this.initialDestination});

  @override
  State<KsrtcBusScheduleScreen> createState() => _KsrtcBusScheduleScreenState();
}

class _KsrtcBusScheduleScreenState extends State<KsrtcBusScheduleScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _schedules = [];
  List<dynamic> _filteredSchedules = [];
  List<String> _categories = [];
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  static const Color ksrtcRed = Color(0xFFB71C1C);
  static const Color ksrtcGold = Color(0xFFFFC107);

  @override
  void initState() {
    super.initState();
    if (widget.initialDestination != null && widget.initialDestination!.isNotEmpty) {
      _searchController.text = widget.initialDestination!;
    }
    _fetchSchedules();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchSchedules() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final data = await ApiService.fetchKsrtcKannurSchedules();
    if (data != null && data['status'] == 'success') {
      final list = data['schedules'] as List? ?? [];
      final cats = (data['categories'] as List? ?? []).map((e) => e.toString()).toList();
      setState(() {
        _schedules = list;
        _categories = ['All', ...cats];
        _isLoading = false;
      });
      _applyFilter();
    } else {
      setState(() {
        _errorMessage = 'Failed to load KSRTC Kannur schedules. Ensure backend is running.';
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _filteredSchedules = _schedules.where((item) {
        final dest = (item['destination'] ?? '').toString().toLowerCase();
        final name = (item['bus_name'] ?? '').toString().toLowerCase();
        final cat = (item['category'] ?? '').toString().toLowerCase();
        final vias = (item['via_stops'] as List? ?? []).map((v) => v.toString().toLowerCase()).join(' ');

        final matchesCategory = _selectedCategory == 'All' || cat.contains(_selectedCategory.toLowerCase());
        final matchesQuery = query.isEmpty || dest.contains(query) || name.contains(query) || vias.contains(query) || cat.contains(query);

        return matchesCategory && matchesQuery;
      }).toList();
    });
  }

  Color _getCategoryColor(String category) {
    final c = category.toLowerCase();
    if (c.contains('interstate')) return Colors.purple.shade700;
    if (c.contains('super fast') || c.contains('super deluxe')) return Colors.red.shade700;
    if (c.contains('feeder')) return Colors.teal.shade700;
    if (c.contains('hill') || c.contains('wayanad')) return Colors.green.shade800;
    if (c.contains('southbound')) return Colors.indigo.shade700;
    return Colors.amber.shade900;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ksrtcRed,
        foregroundColor: Colors.white,
        elevation: 2,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'KSRTC Kannur Timetable',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            Text(
              'Kannur Central Depot • 96 Scheduled Services',
              style: TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Schedules',
            onPressed: _fetchSchedules,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Box
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search destination or stop (e.g. Iritty, Kasaragod, Kudiyanmala)...',
                    hintStyle: TextStyle(fontSize: 12.5, color: Colors.grey.shade500),
                    prefixIcon: const Icon(Icons.search, size: 20, color: ksrtcRed),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _applyFilter();
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: ksrtcRed, width: 1.5),
                    ),
                  ),
                  onChanged: (_) => _applyFilter(),
                ),

                const SizedBox(height: 8),

                // Category Chips (Horizontal Scroll)
                if (_categories.isNotEmpty)
                  SizedBox(
                    height: 32,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 6),
                      itemBuilder: (ctx, i) {
                        final cat = _categories[i];
                        final isSelected = _selectedCategory == cat;
                        return ChoiceChip(
                          label: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: ksrtcRed,
                          backgroundColor: Colors.grey.shade200,
                          showCheckmark: false,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          onSelected: (val) {
                            setState(() => _selectedCategory = cat);
                            _applyFilter();
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Header summary count
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredSchedules.length} bus services found',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified, size: 12, color: Colors.green),
                      SizedBox(width: 4),
                      Text('OFFICIAL KSRTC DATA', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Schedule List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: ksrtcRed))
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 42, color: Colors.grey),
                            const SizedBox(height: 10),
                            Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: ksrtcRed, foregroundColor: Colors.white),
                              onPressed: _fetchSchedules,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _filteredSchedules.isEmpty
                        ? const Center(
                            child: Text(
                              'No KSRTC buses found for your search.\nTry another destination or clear filters.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          )
                        : RefreshIndicator(
                            color: ksrtcRed,
                            onRefresh: _fetchSchedules,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(14, 6, 14, 16),
                              itemCount: _filteredSchedules.length,
                              itemBuilder: (ctx, idx) {
                                final s = _filteredSchedules[idx];
                                final depTime = s['departure_time'] ?? '00:00';
                                final dest = s['destination'] ?? 'Unknown';
                                final cat = s['category'] ?? 'Regional';
                                final dur = s['duration'] ?? '';
                                final arr = s['arrival_time'] ?? '';
                                final fare = s['fare'] ?? 30;
                                final vias = s['via_stops'] as List? ?? [];
                                final statusLabel = s['status_label'] ?? '';
                                final busNo = s['bus_number'] ?? '';
                                final catColor = _getCategoryColor(cat);

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(color: Colors.grey.shade200),
                                  ),
                                  elevation: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Top Row: Departure Time & Category Badge
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: ksrtcRed,
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      const Icon(Icons.access_time, size: 12, color: Colors.white),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        depTime,
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  statusLabel,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: statusLabel.contains('In ') ? Colors.green.shade800 : Colors.grey.shade600,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: catColor.withOpacity(0.12),
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(color: catColor.withOpacity(0.3)),
                                              ),
                                              child: Text(
                                                cat.toUpperCase(),
                                                style: TextStyle(
                                                  color: catColor,
                                                  fontSize: 9.5,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 8),

                                        // Route: Kannur -> Destination
                                        Row(
                                          children: [
                                            const Icon(Icons.trip_origin, size: 14, color: Colors.blue),
                                            const SizedBox(width: 6),
                                            const Text('Kannur', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                            const SizedBox(width: 8),
                                            Icon(Icons.arrow_forward, size: 14, color: Colors.grey.shade400),
                                            const SizedBox(width: 8),
                                            const Icon(Icons.location_on, size: 15, color: Colors.red),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                dest,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: ksrtcRed),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),

                                        // Via Stops
                                        if (vias.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade50,
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: Colors.grey.shade200),
                                            ),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Icon(Icons.route, size: 13, color: Colors.grey),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    'Via: ${vias.join(' • ')}',
                                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade800),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],

                                        const SizedBox(height: 8),
                                        const Divider(height: 1),
                                        const SizedBox(height: 8),

                                        // Bottom Stats: Arrival | Duration | Est Fare | Fleet No
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(Icons.timelapse, size: 13, color: Colors.grey),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '~${dur.isEmpty ? "Direct" : dur}',
                                                  style: const TextStyle(fontSize: 11, color: Colors.black87),
                                                ),
                                                if (arr.isNotEmpty) ...[
                                                  const SizedBox(width: 8),
                                                  Text('• Arr: $arr', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                                                ],
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  'Fare: ₹$fare',
                                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  busNo,
                                                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
