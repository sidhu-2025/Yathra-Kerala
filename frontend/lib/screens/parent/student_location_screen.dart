import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/location_provider.dart';

class StudentLocationScreen extends StatefulWidget {
  final int? studentProfileId;
  const StudentLocationScreen({super.key, this.studentProfileId});

  @override
  State<StudentLocationScreen> createState() => _StudentLocationScreenState();
}

class _StudentLocationScreenState extends State<StudentLocationScreen> {
  final MapController _mapController = MapController();
  Map<String, dynamic>? _locationData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    
    final studentId = widget.studentProfileId ?? 0;
    final location = await locationProvider.getStudentLocation(auth.user!, studentId);

    if (mounted) {
      setState(() {
        _locationData = location;
        _isLoading = false;
      });

      if (location != null) {
        debugPrint('Location fetched: ${location['latitude']}, ${location['longitude']}');
      }
    }
  }

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return 'Never';
    try {
      final dateTime = DateTime.parse(dateTimeStr).toLocal();
      return DateFormat('dd MMM, hh:mm a').format(dateTime);
    } catch (e) {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Tracking'),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchLocation,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Fetching location details...'),
                ],
              ),
            )
          : _locationData == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_off, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'No location found!',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'The student has not shared their location yet, or their GPS is turned off.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _fetchLocation,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              : Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: LatLng(
                          double.tryParse(_locationData!['latitude'].toString()) ?? 0.0,
                          double.tryParse(_locationData!['longitude'].toString()) ?? 0.0,
                        ),
                        initialZoom: 16.0,
                      ),
                      children: [
                        TileLayer(
                        urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                        subdomains: const ['a', 'b', 'c', 'd'],
                        userAgentPackageName: 'com.example.hostel_smart_leave',
                        tileDisplay: const TileDisplay.instantaneous(),
                        retinaMode: RetinaMode.isHighDensity(context),
                        keepBuffer: 3,
                      ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(
                                double.tryParse(_locationData!['latitude'].toString()) ?? 0.0,
                                double.tryParse(_locationData!['longitude'].toString()) ?? 0.0,
                              ),
                              width: 60,
                              height: 60,
                              alignment: Alignment.topCenter,
                              child: const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Detail Card Overlay
                    Positioned(
                      bottom: 24,
                      left: 16,
                      right: 16,
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.indigo[50],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.person, color: Colors.indigo[900]),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _locationData!['student_name'] ?? 'Student',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Text(
                                          'Last known location',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.info_outline, color: Colors.grey, size: 20),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(Icons.access_time, size: 14, color: Colors.blue),
                                          SizedBox(width: 4),
                                          Text(
                                            'Updated',
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _formatDateTime(_locationData!['updated_at']),
                                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(Icons.my_location, size: 14, color: Colors.green),
                                          SizedBox(width: 4),
                                          Text(
                                            'Coordinates',
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${_locationData!['latitude'].toString().padRight(7).substring(0, 7)}, ${_locationData!['longitude'].toString().padRight(7).substring(0, 7)}',
                                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
        onPressed: () {
          final lat = double.tryParse(_locationData!['latitude'].toString()) ?? 0.0;
          final lng = double.tryParse(_locationData!['longitude'].toString()) ?? 0.0;
          _mapController.move(LatLng(lat, lng), 16.0);
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
