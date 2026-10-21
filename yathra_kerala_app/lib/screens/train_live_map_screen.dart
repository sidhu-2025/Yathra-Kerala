import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/train_live_status.dart';
import '../services/api_service.dart';

class TrainLiveMapScreen extends StatefulWidget {
  final String? trainNo;
  final Map<String, dynamic>? initialData;
  final bool startWithTimeline;

  const TrainLiveMapScreen({
    super.key,
    this.trainNo,
    this.initialData,
    this.startWithTimeline = true,
  });

  @override
  State<TrainLiveMapScreen> createState() => _TrainLiveMapScreenState();
}

class _TrainLiveMapScreenState extends State<TrainLiveMapScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  TrainLiveStatus? _liveStatus;
  bool _isLoading = false;
  String? _errorMessage;
  String _activeTrainNo = '12081'; // Default popular train: Kannur Jan Shatabdi

  Timer? _pollingTimer;
  DateTime? _lastFetchTime;
  bool _autoRefreshEnabled = true;
  late bool _showStationTimeline;

  // Animation controller for pulsing train radar marker
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Preset quick-access trains in Kerala
  final List<Map<String, String>> _popularTrains = [
    {'no': '12081', 'name': 'Jan Shatabdi (CAN-TVC)'},
    {'no': '20631', 'name': 'Vande Bharat (KGQ-TVC)'},
    {'no': '16308', 'name': 'Executive (CAN-ALLP)'},
    {'no': '16649', 'name': 'Parasuram (MAQ-NCJ)'},
    {'no': '12617', 'name': 'Mangala Express'},
  ];

  @override
  void initState() {
    super.initState();
    _showStationTimeline = widget.startWithTimeline;
    WidgetsBinding.instance.addObserver(this);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    final inputTrain = widget.trainNo?.replaceAll(RegExp(r'[^0-9]'), '').trim();
    if (inputTrain != null && inputTrain.isNotEmpty) {
      _activeTrainNo = inputTrain;
      _searchController.text = inputTrain;
    } else {
      _searchController.text = _activeTrainNo;
    }

    if (widget.initialData != null) {
      _liveStatus = TrainLiveStatus.fromJson(widget.initialData!);
      _lastFetchTime = DateTime.now();
      _startPolling();
    } else {
      _fetchStatus(_activeTrainNo);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopPolling();
    _pulseController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _stopPolling();
    } else if (state == AppLifecycleState.resumed) {
      if (_autoRefreshEnabled && _activeTrainNo.isNotEmpty) {
        _startPolling();
        _fetchStatus(_activeTrainNo, isAutoPoll: true);
      }
    }
  }

  void _startPolling() {
    _stopPolling();
    if (!_autoRefreshEnabled) return;
    // Conservative 5-minute polling interval to strictly respect API rate limits and conserve quota
    _pollingTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (mounted && _activeTrainNo.isNotEmpty) {
        _fetchStatus(_activeTrainNo, isAutoPoll: true);
      }
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _fetchStatus(String trainNumber, {bool isAutoPoll = false}) async {
    final cleanNo = trainNumber.replaceAll(RegExp(r'[^0-9]'), '').trim();
    if (cleanNo.length != 5) {
      setState(() {
        _errorMessage = 'Please enter a valid 5-digit Indian Railways train number (e.g. 12081).';
        _isLoading = false;
      });
      return;
    }

    // Rate-limit throttle for manual click (minimum 3 seconds between requests)
    if (!isAutoPoll && _lastFetchTime != null) {
      final elapsed = DateTime.now().difference(_lastFetchTime!).inSeconds;
      if (elapsed < 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please wait 3 seconds before requesting a fresh update.'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _activeTrainNo = cleanNo;
    });

    try {
      final status = await ApiService.getTrainLiveStatusModel(cleanNo);
      if (!mounted) return;

      if (status != null) {
        setState(() {
          _liveStatus = status;
          _isLoading = false;
          _lastFetchTime = DateTime.now();
        });

        _startPolling();

        // Adjust map camera: center on train location or route polyline
        if (status.hasValidCoordinates && status.position != null) {
          try {
            _mapController.move(status.position!, 13.5);
          } catch (_) {}
        } else if (status.routePolyline.isNotEmpty) {
          try {
            _mapController.move(status.routePolyline.first, 11.5);
          } catch (_) {}
        }
      } else {
        // Fallback check error message from raw response
        final raw = await ApiService.getTrainLiveStatus(cleanNo);
        setState(() {
          _isLoading = false;
          _errorMessage = raw?['error'] ??
              raw?['message'] ??
              raw?['detail'] ??
              'Unable to fetch live status for train #$cleanNo. Verify connection.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Connection error: $e';
        });
      }
    }
  }

  void _openSettingsDialog() {
    final workerController = TextEditingController(text: ApiService.cloudflareWorkerUrl);
    final keyController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.settings, color: Color(0xFF1565C0)),
            SizedBox(width: 8),
            Text('Tracking Backend & API', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cloudflare Worker URL (Free Tier Backend):',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Deploy the included Cloudflare Worker to proxy RailRadar securely with 100% key protection.',
                style: TextStyle(fontSize: 11, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: workerController,
                decoration: const InputDecoration(
                  hintText: 'https://railradar-proxy.<subdomain>.workers.dev',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Server-side RailRadar API Key (Optional):',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Update backend server secret directly if running local backend_yathra.',
                style: TextStyle(fontSize: 11, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: keyController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Paste RAILRADAR_API_KEY...',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final workerUrl = workerController.text.trim();
              ApiService.setCloudflareWorkerUrl(workerUrl);

              final key = keyController.text.trim();
              if (key.isNotEmpty) {
                await ApiService.updateTrainConfig(apiKey: key);
              }
              if (ctx.mounted) {
                Navigator.pop(ctx);
              }
              if (mounted) {
                _fetchStatus(_activeTrainNo);
              }
            },
            child: const Text('Save & Apply'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1565C0);
    const deepBlue = Color(0xFF0D47A1);

    final status = _liveStatus;
    final bool hasValidCoordinates = status != null && status.hasValidCoordinates;
    final LatLng centerPoint = hasValidCoordinates
        ? status.position!
        : (status != null && status.routePolyline.isNotEmpty
            ? status.routePolyline.first
            : const LatLng(11.8745, 75.3704)); // Kannur corridor default

    final bool isDelayed = status?.isDelayed ?? false;
    final int delayMinutes = status?.delayMinutes ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.train, size: 18, color: Colors.white),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    status != null ? '#${status.trainNumber} ${status.trainName}' : 'Train Live Tracker',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: hasValidCoordinates ? Colors.greenAccent : Colors.amberAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    hasValidCoordinates
                        ? 'Live Satellite GPS Fix'
                        : (status != null ? 'Station Progress (Transponder GPS Inactive)' : 'Indian Railways Real-Time'),
                    style: TextStyle(
                      fontSize: 10.5,
                      color: hasValidCoordinates ? Colors.greenAccent : Colors.white70,
                      fontWeight: hasValidCoordinates ? FontWeight.bold : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        actions: [

          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Configure Cloudflare Worker / RailRadar API',
            onPressed: _openSettingsDialog,
          ),
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            tooltip: 'Manual Refresh (Quota-safe)',
            onPressed: _isLoading ? null : () => _fetchStatus(_activeTrainNo),
          ),
        ],
      ),
      body: _showStationTimeline && status != null
          ? _buildStationTimelineView(status)
          : Stack(
              children: [
                // ── OpenStreetMap Layer ──────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: centerPoint,
              initialZoom: hasValidCoordinates ? 13.5 : 11.0,
              minZoom: 5.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.yathrakerala.app',
              ),

              // Railway Route Polyline Overlay (if provided by RailRadar geometry)
              if (status != null && status.routePolyline.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: status.routePolyline,
                      strokeWidth: 4.5,
                      color: const Color(0xFF0288D1),
                      borderStrokeWidth: 1.5,
                      borderColor: Colors.white,
                    ),
                  ],
                ),

              // Moving Train Marker: Render ONLY when genuine coordinates are present
              if (hasValidCoordinates)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: status.position!,
                      width: 80,
                      height: 80,
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (ctx, child) {
                          return Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Radar pulse ripple ring
                                Container(
                                  width: 50 * _pulseAnimation.value,
                                  height: 50 * _pulseAnimation.value,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: (isDelayed ? Colors.orange : Colors.green)
                                        .withValues(alpha: 0.35 / _pulseAnimation.value),
                                  ),
                                ),
                                // Inner solid train badge
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isDelayed ? Colors.orange.shade800 : const Color(0xFF2E7D32),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2.5),
                                        boxShadow: [
                                          BoxShadow(
                                            color: (isDelayed ? Colors.orange : Colors.green).withValues(alpha: 0.5),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(Icons.train, color: Colors.white, size: 20),
                                    ),
                                    const SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: Colors.black87,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '#${status.trainNumber}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // ── Top Floating Search & Quick Train Chips Card ─────────────
          Positioned(
            top: 10,
            left: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Five-digit Search Input Card
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: primaryBlue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            keyboardType: TextInputType.number,
                            maxLength: 5,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(
                              hintText: 'Enter 5-digit Train No (e.g. 12081)',
                              hintStyle: TextStyle(fontSize: 13, color: Colors.black45),
                              border: InputBorder.none,
                              counterText: '',
                              isDense: true,
                            ),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            onSubmitted: (val) => _fetchStatus(val),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: _isLoading ? null : () => _fetchStatus(_searchController.text),
                          child: const Text('Track Train', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ),

                // Quick Popular Train Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _popularTrains.map((tr) {
                      final isSelected = _activeTrainNo == tr['no'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 6, top: 4),
                        child: ActionChip(
                          avatar: Icon(
                            Icons.train_outlined,
                            size: 14,
                            color: isSelected ? Colors.white : primaryBlue,
                          ),
                          label: Text(
                            '${tr['no']} ${tr['name']}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                          backgroundColor: isSelected ? deepBlue : Colors.white.withValues(alpha: 0.92),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isSelected ? primaryBlue : Colors.grey.shade300,
                            ),
                          ),
                          onPressed: () {
                            _searchController.text = tr['no']!;
                            _fetchStatus(tr['no']!);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Segmented View Toggle: Live Map vs Station Route Track
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => setState(() => _showStationTimeline = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: !_showStationTimeline ? primaryBlue : Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: primaryBlue),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.map, size: 14, color: !_showStationTimeline ? Colors.white : primaryBlue),
                                const SizedBox(width: 4),
                                Text(
                                  'Live Map',
                                  style: TextStyle(
                                    color: !_showStationTimeline ? Colors.white : primaryBlue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => setState(() => _showStationTimeline = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: _showStationTimeline ? primaryBlue : Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: primaryBlue),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.linear_scale, size: 14, color: _showStationTimeline ? Colors.white : primaryBlue),
                                const SizedBox(width: 4),
                                Text(
                                  'Station Track',
                                  style: TextStyle(
                                    color: _showStationTimeline ? Colors.white : primaryBlue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Error Notice Banner if any
                if (_errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red.shade900, fontSize: 11.5),
                          ),
                        ),
                      ],
                    ),
                  ),

                // No-GPS / Transponder Notice Banner (Authenticity & Transparency)
                if (status != null && !hasValidCoordinates)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber.shade900, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Satellite GPS coordinates are not currently broadcast by this train. Current station progression is shown below; no false coordinates are plotted.',
                            style: TextStyle(color: Colors.amber.shade900, fontSize: 10.5),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // ── OpenStreetMap Attribution (Required) ─────────────────────
          Positioned(
            bottom: 255,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Text(
                '© OpenStreetMap contributors',
                style: TextStyle(fontSize: 9, color: Colors.black87),
              ),
            ),
          ),

          // ── Recenter Camera Button ────────────────────────────────────
          Positioned(
            bottom: 255,
            left: 12,
            child: FloatingActionButton.small(
              heroTag: 'recenter_train_map',
              backgroundColor: Colors.white,
              foregroundColor: primaryBlue,
              tooltip: 'Center on Train',
              onPressed: () {
                _mapController.move(centerPoint, hasValidCoordinates ? 14.0 : 11.5);
              },
              child: const Icon(Icons.my_location, size: 20),
            ),
          ),

          // ── Bottom Train Status Details Card (Where Is My Train Style) ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 14,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: status == null
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 10),
                        const CircularProgressIndicator(),
                        const SizedBox(height: 12),
                        Text(
                          'Fetching live running status for Train #$_activeTrainNo…',
                          style: const TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                        const SizedBox(height: 10),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Pill, Delay, and Last Updated
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                              decoration: BoxDecoration(
                                color: isDelayed ? Colors.orange.shade50 : Colors.green.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isDelayed ? Colors.orange : Colors.green,
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isDelayed ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                                    size: 14,
                                    color: isDelayed ? Colors.orange.shade800 : Colors.green.shade800,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isDelayed ? 'DELAYED $delayMinutes MINS' : status.currentStatus,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: isDelayed ? Colors.orange.shade900 : Colors.green.shade900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                if (status.isStale) ...[
                                  const Icon(Icons.history, size: 14, color: Colors.deepOrange),
                                  const SizedBox(width: 3),
                                  const Text('Stale: ', style: TextStyle(fontSize: 10.5, color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                                ],
                                Text(
                                  'Updated: ${status.timeAgoDescription}',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: status.isStale ? Colors.deepOrange : Colors.grey.shade600,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Current Station & Next Station Row
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F4F8),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.blue.shade100),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'CURRENT STATION',
                                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      status.currentStation,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'Platform: ${status.platform}',
                                      style: const TextStyle(fontSize: 10.5, color: deepBlue, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'NEXT STOP',
                                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      status.nextStation,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      isDelayed ? 'Delayed: +$delayMinutes mins' : 'Expected: On Time',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        color: isDelayed ? Colors.orange.shade800 : Colors.green.shade800,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Scheduled vs Actual Timings Box
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
                                  Text(
                                    status.scheduledDeparture ?? '--',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ],
                              ),
                              Container(width: 1, height: 26, color: Colors.grey.shade300),
                              Column(
                                children: [
                                  const Text('ACTUAL / EST DEP', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 2),
                                  Text(
                                    status.actualDeparture ?? (status.scheduledDeparture != null ? '${status.scheduledDeparture} (Est)' : '--'),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: isDelayed ? Colors.orange.shade900 : Colors.green.shade900,
                                    ),
                                  ),
                                ],
                              ),
                              Container(width: 1, height: 26, color: Colors.grey.shade300),
                              Column(
                                children: [
                                  const Text('PREVIOUS STOP', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 2),
                                  Text(
                                    status.previousStation ?? 'Origin Terminus',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black87),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Switch to Where Is My Train Station Timeline Button
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.linear_scale, size: 16, color: primaryBlue),
                            label: const Text(
                              'OPEN STATION TRACK TIMELINE (WHERE IS MY TRAIN)',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: primaryBlue),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: primaryBlue),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            onPressed: () => setState(() => _showStationTimeline = true),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _resolveStationName(String code, String rawName) {
    if (rawName.isNotEmpty && rawName.trim().toUpperCase() != code.trim().toUpperCase()) {
      return rawName;
    }
    const map = {
      'CAN': 'Kannur Main',
      'TLY': 'Thalassery',
      'MAHE': 'Mahe',
      'BDJ': 'Vadakara',
      'QLD': 'Koyilandy',
      'CLT': 'Kozhikode Main',
      'FK': 'Ferok',
      'PGI': 'Parappanangadi',
      'TA': 'Tanur',
      'TIR': 'Tirur',
      'KTU': 'Kuttippuram',
      'PTB': 'Pattambi',
      'SRR': 'Shoranur Jn',
      'OTP': 'Ottappalam',
      'PGT': 'Palakkad Jn',
      'CBE': 'Coimbatore Jn',
      'WKI': 'Wadakanchery',
      'TCR': 'Thrissur',
      'IJK': 'Irinjalakuda',
      'CKI': 'Chalakudi',
      'AFK': 'Angamaly for Kalady',
      'AWY': 'Aluva',
      'ERN': 'Ernakulam North (Town)',
      'ERS': 'Ernakulam South (Jn)',
      'TRTR': 'Thrippunithura',
      'PVRD': 'Piravom Road',
      'SRTL': 'Cherthala',
      'ALLP': 'Alappuzha',
      'AMPA': 'Ambalapuzha',
      'HAD': 'Haripad',
      'KTYM': 'Kottayam',
      'CGY': 'Changanassery',
      'TRVL': 'Tiruvalla',
      'CNGR': 'Chengannur',
      'MVLK': 'Mavelikara',
      'KYJ': 'Kayamkulam Jn',
      'KPY': 'Karunagappalli',
      'QLN': 'Kollam Jn',
      'PVU': 'Paravur',
      'VAK': 'Varkala Sivagiri',
      'CRY': 'Chirayinkeezhu',
      'KZK': 'Kazhakkuttam / Technopark',
      'KCVL': 'Kochuveli',
      'TVC': 'Thiruvananthapuram Central',
      'NYY': 'Neyyattinkara',
      'PASA': 'Parassala',
      'NCJ': 'Nagercoil Jn',
      'CAPE': 'Kanyakumari',
      'KPQ': 'Cherukunnu / Kannapuram',
      'PAY': 'Payyanur',
      'PAZ': 'Pazhayangadi',
      'CHV': 'Cheruvathur',
      'NLE': 'Nileshwar',
      'KZE': 'Kanhangad',
      'BFR': 'Bekal Fort',
      'KQK': 'Kotikulam',
      'KGQ': 'Kasaragod',
      'KMBL': 'Kumbla',
      'UAA': 'Uppala',
      'MJS': 'Manjeshwar',
      'MAQ': 'Mangaluru Central',
      'MAJN': 'Mangaluru Jn',
      'DMD': 'Dharmadam',
      'VAPM': 'Valapattanam',
      'PYOL': 'Payyoli',
    };
    return map[code.toUpperCase()] ?? (rawName.isNotEmpty ? rawName : code);
  }

  /// Authentic "Where Is My Train" Station Progression Track Timeline
  Widget _buildStationTimelineView(TrainLiveStatus status) {
    const primaryBlue = Color(0xFF1565C0);
    final isDelayed = status.isDelayed;
    final delayMinutes = status.delayMinutes;

    final stops = status.routeStations;
    final currCode = status.currentStationCode.toUpperCase();
    final currName = status.currentStation.toUpperCase();

    int currentIndex = -1;
    if (stops.isNotEmpty) {
      for (int i = 0; i < stops.length; i++) {
        final code = stops[i].stationCode.toUpperCase();
        final name = stops[i].stationName.toUpperCase();
        if ((currCode.isNotEmpty && (code == currCode || currName.contains(code))) ||
            currName.contains(name) || name.contains(currName)) {
          currentIndex = i;
          break;
        }
      }
      if (currentIndex == -1) {
        currentIndex = 0;
      }
    }

    return Column(
      children: [
        // Top Sticky Train Status Bar (Where Is My Train style)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0D47A1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDelayed ? Colors.orange.shade700 : Colors.green.shade700,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          isDelayed ? 'DELAYED $delayMinutes MINS' : status.currentStatus,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        status.timeAgoDescription,
                        style: const TextStyle(color: Colors.white70, fontSize: 11, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),

                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.amberAccent, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'At: ${status.currentStation} • Platform ${status.platform}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
              if (status.nextStation.isNotEmpty && status.nextStation != 'Upcoming Station') ...[
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Text(
                    'Next Stop: ${status.nextStation}',
                    style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Vertical Railway Track Station List
        Expanded(
          child: stops.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.alt_route, size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        const Text(
                          'Station progression data is being fetched from RailRadar...',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, foregroundColor: Colors.white),
                          icon: const Icon(Icons.map),
                          label: const Text('View on Live Map'),
                          onPressed: () => setState(() => _showStationTimeline = false),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  itemCount: stops.length,
                  itemBuilder: (ctx, index) {
                    final stn = stops[index];
                    final isPast = currentIndex != -1 && index < currentIndex;
                    final isCurrent = currentIndex != -1 && index == currentIndex;

                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Left: Timings (Scheduled & Actual)
                          SizedBox(
                            width: 75,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  stn.actualDeparture ?? stn.scheduledDeparture ?? stn.scheduledArrival ?? '--:--',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: isPast
                                        ? Colors.grey.shade700
                                        : (isCurrent
                                            ? (isDelayed ? Colors.orange.shade900 : Colors.green.shade900)
                                            : Colors.black87),
                                  ),
                                ),
                                if (stn.scheduledDeparture != null && stn.actualDeparture != null && isDelayed)
                                  Text(
                                    stn.scheduledDeparture!,
                                    style: const TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey,
                                      fontSize: 10,
                                    ),
                                  ),
                                if (stn.distanceKm != null)
                                  Text(
                                    '${stn.distanceKm!.toInt()} km',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 9.5),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Center: Railway Track Line & Station Node / Train Icon
                          SizedBox(
                            width: 32,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Vertical track line
                                Positioned(
                                  top: index == 0 ? 12 : 0,
                                  bottom: index == stops.length - 1 ? 12 : 0,
                                  child: Container(
                                    width: 4,
                                    decoration: BoxDecoration(
                                      color: isPast
                                          ? const Color(0xFF2E7D32)
                                          : (isCurrent ? Colors.orange : Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                                // Node / Moving Train Icon
                                if (isCurrent)
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: isDelayed ? Colors.orange.shade800 : const Color(0xFF2E7D32),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (isDelayed ? Colors.orange : Colors.green).withValues(alpha: 0.5),
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.train, color: Colors.white, size: 16),
                                  )
                                else if (isPast)
                                  Container(
                                    width: 14,
                                    height: 14,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF2E7D32),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.check, color: Colors.white, size: 10),
                                  )
                                else
                                  Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: primaryBlue, width: 2.5),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Right: Station Name, Code, Platform badge
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 22),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _resolveStationName(stn.stationCode, stn.stationName),
                                          style: TextStyle(
                                            fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w600,
                                            fontSize: isCurrent ? 13.5 : 12.5,
                                            color: isCurrent
                                                ? (isDelayed ? Colors.orange.shade900 : const Color(0xFF1565C0))
                                                : (isPast ? Colors.grey.shade700 : Colors.black87),
                                          ),
                                        ),
                                      ),
                                      if (stn.platform != null && stn.platform!.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE3F2FD),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: Colors.blue.shade200),
                                          ),
                                          child: Text(
                                            stn.platform!.startsWith('PF') ? stn.platform! : 'PF ${stn.platform}',
                                            style: const TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0D47A1),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Text(
                                        stn.stationCode,
                                        style: TextStyle(
                                          color: isCurrent ? Colors.blue.shade900 : Colors.grey.shade600,
                                          fontSize: 10.5,
                                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                      if (isCurrent) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: (isDelayed ? Colors.orange : Colors.green).withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'CURRENT LOCATION',
                                            style: TextStyle(
                                              color: isDelayed ? Colors.orange.shade900 : Colors.green.shade900,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
