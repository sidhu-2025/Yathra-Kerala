import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/api_service.dart';

class OsmLocationPickerScreen extends StatefulWidget {
  final String title;
  final String initialSelectedStop;
  final bool isSource;

  const OsmLocationPickerScreen({
    super.key,
    required this.title,
    required this.initialSelectedStop,
    required this.isSource,
  });

  @override
  State<OsmLocationPickerScreen> createState() => _OsmLocationPickerScreenState();
}

class _OsmLocationPickerScreenState extends State<OsmLocationPickerScreen> {
  final MapController _mapController = MapController();
  List<Map<String, dynamic>> _stops = [];
  bool _isLoading = true;
  String? _selectedStopName;
  LatLng? _selectedPoint;

  @override
  void initState() {
    super.initState();
    _selectedStopName = widget.initialSelectedStop;
    _loadStops();
  }

  Future<void> _loadStops() async {
    final stops = await ApiService.fetchStopsWithCoords();
    setState(() {
      _stops = stops;
      _isLoading = false;

      // Find initial coordinate
      final match = _stops.firstWhere(
        (s) => s['name'] == _selectedStopName,
        orElse: () => _stops.isNotEmpty ? _stops.first : {'name': 'Chemperi', 'lat': 12.0469, 'lng': 75.5451},
      );
      _selectedPoint = LatLng(
        (match['lat'] as num).toDouble(),
        (match['lng'] as num).toDouble(),
      );
    });
  }

  void _onStopSelected(String name, double lat, double lng) {
    setState(() {
      _selectedStopName = name;
      _selectedPoint = LatLng(lat, lng);
    });
    _mapController.move(_selectedPoint!, 14.0);
  }

  @override
  Widget build(BuildContext context) {
    final LatLng center = _selectedPoint ?? const LatLng(11.95, 75.45);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: widget.isSource ? Colors.green.shade800 : Colors.red.shade800,
        foregroundColor: Colors.white,
        actions: [
          if (_selectedStopName != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context, _selectedStopName);
              },
              child: const Text(
                'CONFIRM',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
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
                    onTap: (tapPosition, point) {
                      // Find closest stop to tapped position
                      double minDistance = double.infinity;
                      Map<String, dynamic>? closest;
                      const Distance distance = Distance();

                      for (final s in _stops) {
                        final stopPoint = LatLng((s['lat'] as num).toDouble(), (s['lng'] as num).toDouble());
                        final d = distance.as(LengthUnit.Meter, point, stopPoint);
                        if (d < minDistance) {
                          minDistance = d;
                          closest = s;
                        }
                      }

                      if (closest != null) {
                        _onStopSelected(
                          closest['name'],
                          (closest['lat'] as num).toDouble(),
                          (closest['lng'] as num).toDouble(),
                        );
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.yathrakerala.app',
                    ),
                    MarkerLayer(
                      markers: _stops.map<Marker>((s) {
                        final lat = (s['lat'] as num).toDouble();
                        final lng = (s['lng'] as num).toDouble();
                        final isCurrentSelected = s['name'] == _selectedStopName;

                        return Marker(
                          point: LatLng(lat, lng),
                          width: isCurrentSelected ? 65 : 40,
                          height: isCurrentSelected ? 65 : 40,
                          child: GestureDetector(
                            onTap: () => _onStopSelected(s['name'], lat, lng),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: isCurrentSelected
                                      ? (widget.isSource ? Colors.green.shade700 : Colors.red.shade700)
                                      : Colors.blueGrey.shade700,
                                  size: isCurrentSelected ? 36 : 24,
                                ),
                                if (isCurrentSelected)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: Colors.black87,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      s['name'],
                                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
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

                // Top Floating Search / Guidance Banner
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          Icon(
                            widget.isSource ? Icons.trip_origin : Icons.location_on,
                            color: widget.isSource ? Colors.green : Colors.red,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.isSource ? 'Select Source / Origin' : 'Select Destination',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  _selectedStopName ?? 'Tap on any stop pin on map',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.isSource ? Colors.green.shade700 : Colors.red.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            onPressed: _selectedStopName != null
                                ? () => Navigator.pop(context, _selectedStopName)
                                : null,
                            child: const Text('SELECT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Quick List Sheet at bottom
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: SizedBox(
                    height: 48,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _stops.length,
                      itemBuilder: (context, index) {
                        final s = _stops[index];
                        final isSel = s['name'] == _selectedStopName;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ActionChip(
                            avatar: Icon(
                              Icons.location_pin,
                              size: 16,
                              color: isSel ? Colors.white : Colors.teal.shade800,
                            ),
                            label: Text(s['name']),
                            backgroundColor: isSel
                                ? (widget.isSource ? Colors.green.shade800 : Colors.red.shade800)
                                : Colors.white,
                            labelStyle: TextStyle(
                              color: isSel ? Colors.white : Colors.black87,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                            onPressed: () {
                              _onStopSelected(
                                s['name'],
                                (s['lat'] as num).toDouble(),
                                (s['lng'] as num).toDouble(),
                              );
                            },
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
