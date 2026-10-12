import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/api_service.dart';

class LiveTrackingScreen extends StatefulWidget {
  final String? initialVehicleId;

  const LiveTrackingScreen({super.key, this.initialVehicleId});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  final MapController _mapController = MapController();
  List<dynamic> _vehicles = [];
  bool _isLoading = true;
  dynamic _selectedVehicle;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() => _isLoading = true);
    final vehicles = await ApiService.fetchLiveVehicles();
    setState(() {
      _vehicles = vehicles;
      _isLoading = false;
      if (widget.initialVehicleId != null) {
        _selectedVehicle = _vehicles.firstWhere(
          (v) => v['vehicle_id'] == widget.initialVehicleId,
          orElse: () => _vehicles.isNotEmpty ? _vehicles.first : null,
        );
      } else if (_vehicles.isNotEmpty) {
        _selectedVehicle = _vehicles.first;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Default center at Kannur/Taliparamba area
    final LatLng center = _selectedVehicle != null
        ? LatLng(_selectedVehicle['lat'] ?? 11.8745, _selectedVehicle['lng'] ?? 75.3704)
        : const LatLng(11.8745, 75.3704);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Multi-Modal Tracking'),
        backgroundColor: Colors.teal.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVehicles,
            tooltip: 'Refresh GPS',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: 12.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.yathrakerala.app',
                    ),
                    MarkerLayer(
                      markers: _vehicles.map<Marker>((v) {
                        final lat = (v['lat'] as num?)?.toDouble() ?? 11.8745;
                        final lng = (v['lng'] as num?)?.toDouble() ?? 75.3704;
                        final isTrain = v['type'] == 'Train';

                        return Marker(
                          point: LatLng(lat, lng),
                          width: 60,
                          height: 60,
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _selectedVehicle = v);
                            },
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: isTrain ? Colors.orange.shade800 : Colors.teal.shade700,
                                    shape: BoxShape.circle,
                                    boxShadow: const [
                                      BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                                    ],
                                  ),
                                  child: Icon(
                                    isTrain ? Icons.train : Icons.directions_bus,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.black87,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    v['vehicle_id'] ?? '',
                                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                if (_selectedVehicle != null)
                  Positioned(
                    bottom: 20,
                    left: 16,
                    right: 16,
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    _selectedVehicle['name'] ?? 'Vehicle Details',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.speed, size: 14, color: Colors.green),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${_selectedVehicle['speed_kmh']} km/h',
                                        style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Route: ${_selectedVehicle['route'] ?? 'Live Corridor'}',
                              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                            ),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Current Stop', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                    Text(
                                      _selectedVehicle['current_stop'] ?? 'In transit',
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                    ),
                                  ],
                                ),
                                const Icon(Icons.arrow_forward, color: Colors.grey, size: 18),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text('Next Stop', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                    Text(
                                      _selectedVehicle['next_stop'] ?? 'Approaching',
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
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
    );
  }
}
