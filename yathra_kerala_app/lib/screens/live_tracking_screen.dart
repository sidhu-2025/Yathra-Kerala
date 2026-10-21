import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import 'osm_location_picker_screen.dart';

class LiveTrackingScreen extends StatefulWidget {
  final String? initialVehicleId;
  final String? initialSource;
  final String? initialDestination;
  final LatLng? exactBusLocation;
  final Map<String, dynamic>? selectedVehicleData;
  final String? initialMode;
  final dynamic initialRoute;
  final bool isTrackBusMode;

  const LiveTrackingScreen({
    super.key,
    this.initialVehicleId,
    this.initialSource,
    this.initialDestination,
    this.exactBusLocation,
    this.selectedVehicleData,
    this.initialMode,
    this.initialRoute,
    this.isTrackBusMode = false,
  });

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  final MapController _mapController = MapController();

  // User Current Location
  double? _userLat;
  double? _userLng;
  String _userLocationLabel = 'Locating...';
  bool _hasUserLocation = false;

  // Stops and Coords
  List<String> _stops = [];
  final Map<String, LatLng> _stopsCoords = {};

  // Source & Destination Input
  String _source = 'Kannur';
  String _destination = 'Thalassery';
  late TextEditingController _sourceCtrl;
  late TextEditingController _destCtrl;

  // Journey Planning & Suggestions
  Map<String, dynamic>? _journeyPlan;
  bool _isLoadingRoutes = false;
  String _preference = 'timings';
  dynamic _selectedRoute;
  List<LatLng> _routePolylinePoints = [];

  // UI Panels State
  bool _isSearchExpanded = true;
  bool _isSuggestionsVisible = true;

  // Live Vehicle Telemetry (Fleet Tracking)
  List<dynamic> _vehicles = [];
  dynamic _selectedVehicle;
  Timer? _pollTimer;
  bool _autoFollowVehicle = false;
  LatLng? _lastCenteredPoint;

  @override
  void initState() {
    super.initState();
    _source = widget.initialSource?.trim().isNotEmpty == true ? widget.initialSource!.trim() : 'Kannur';
    _destination = widget.initialDestination?.trim().isNotEmpty == true ? widget.initialDestination!.trim() : 'Thalassery';

    _sourceCtrl = TextEditingController(text: _source);
    _destCtrl = TextEditingController(text: _destination);

    if (widget.isTrackBusMode == true && widget.exactBusLocation != null) {
      _autoFollowVehicle = true;
      _selectedVehicle = widget.selectedVehicleData;
      _isSearchExpanded = false;
      _isSuggestionsVisible = false;
    } else if (widget.initialMode == 'CAR' || widget.initialMode == 'TWO_WHEELER') {
      _selectedRoute = widget.initialRoute;
      _isSearchExpanded = false;
      _isSuggestionsVisible = false;
    }

    _initScreenData();

    // Poll live vehicles every 3 seconds
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) _pollVehicles();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _sourceCtrl.dispose();
    _destCtrl.dispose();
    super.dispose();
  }

  Future<void> _initScreenData() async {
    if (widget.isTrackBusMode == true && widget.exactBusLocation != null) {
      _autoFollowVehicle = true;
      _selectedVehicle = widget.selectedVehicleData;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(widget.exactBusLocation!, 16.0);
      });
    } else if (widget.initialRoute != null && (widget.initialMode == 'CAR' || widget.initialMode == 'TWO_WHEELER')) {
      _selectedRoute = widget.initialRoute;
      _updateRoutePolyline(_selectedRoute);
      await _detectUserLocation();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fitMapToRoute();
      });
    } else {
      // 1. Detect physical user GPS location
      await _detectUserLocation();
      // 3. Load initial journey routes
      await _planJourney();
    }

    // 2. Fetch stops list and stop coordinates
    final stops = await ApiService.fetchStops();
    final stopsWithCoords = await ApiService.fetchStopsWithCoords();

    if (mounted) {
      setState(() {
        _stops = stops;
        for (var sc in stopsWithCoords) {
          final name = sc['name']?.toString() ?? '';
          final lat = (sc['lat'] as num?)?.toDouble();
          final lng = (sc['lng'] as num?)?.toDouble();
          if (name.isNotEmpty && lat != null && lng != null) {
            _stopsCoords[name.toLowerCase()] = LatLng(lat, lng);
          }
        }
      });
    }

    // 4. Load live vehicles
    await _pollVehicles();
  }

  Future<void> _detectUserLocation() async {
    try {
      final pos = await getDeviceLocation();
      if (pos != null && pos['lat'] != null && pos['lng'] != null) {
        final lat = (pos['lat'] as num).toDouble();
        final lng = (pos['lng'] as num).toDouble();
        if (mounted) {
          setState(() {
            _userLat = lat;
            _userLng = lng;
            _userLocationLabel = 'Your Current Location';
            _hasUserLocation = true;
          });
          // Center camera to user's location
          _mapController.move(LatLng(lat, lng), 13.5);
        }
        return;
      }
    } catch (_) {}

    // Fallback coordinates (Chalingal / Kasaragod / Kannur hub)
    if (mounted) {
      setState(() {
        _userLat = 11.8745;
        _userLng = 75.3704;
        _userLocationLabel = _source.isNotEmpty ? _source : 'Kannur';
        _hasUserLocation = true;
      });
    }
  }

  Future<void> _planJourney() async {
    if (_source.trim().isEmpty || _destination.trim().isEmpty) return;

    setState(() => _isLoadingRoutes = true);
    final plan = await ApiService.planJourney(
      source: _source.trim(),
      destination: _destination.trim(),
      preference: _preference,
    );

    if (!mounted) return;

    setState(() {
      _journeyPlan = plan;
      _isLoadingRoutes = false;
      _isSuggestionsVisible = true;

      final routes = plan?['routes'] as List? ?? [];
      if (routes.isNotEmpty) {
        _selectedRoute = routes.first;
        _updateRoutePolyline(_selectedRoute);
      } else {
        _selectedRoute = null;
        _routePolylinePoints = [];
      }
    });

    _fitMapToRoute();
  }

  void _updateRoutePolyline(dynamic route) {
    if (route == null) {
      _routePolylinePoints = [];
      return;
    }

    // High-resolution OSRM road coordinates (Google Maps style highway curves)
    if (route['route_coordinates'] != null && (route['route_coordinates'] as List).isNotEmpty) {
      final rawCoords = route['route_coordinates'] as List;
      final points = rawCoords.map((c) => LatLng((c[0] as num).toDouble(), (c[1] as num).toDouble())).toList();
      setState(() {
        _routePolylinePoints = points;
      });
      return;
    }

    final points = <LatLng>[];

    // Source coordinate
    final srcCoord = _resolveStopCoord(_source);
    if (srcCoord != null) points.add(srcCoord);

    // Intermediate stops if available
    final intermediate = route['intermediate_stops'] as List? ?? [];
    for (var st in intermediate) {
      final coord = _resolveStopCoord(st.toString());
      if (coord != null) points.add(coord);
    }

    // Destination coordinate
    final dstCoord = _resolveStopCoord(_destination);
    if (dstCoord != null) points.add(dstCoord);

    setState(() {
      _routePolylinePoints = points;
    });
  }

  LatLng? _resolveStopCoord(String stopName) {
    final lower = stopName.toLowerCase().trim();
    if (_stopsCoords.containsKey(lower)) {
      return _stopsCoords[lower];
    }
    for (var key in _stopsCoords.keys) {
      if (lower.contains(key) || key.contains(lower)) {
        return _stopsCoords[key];
      }
    }
    // Check known landmarks
    if (lower.contains('kannur')) return const LatLng(11.8745, 75.3704);
    if (lower.contains('thalassery')) return const LatLng(11.7491, 75.4890);
    if (lower.contains('kozhikode') || lower.contains('calicut')) return const LatLng(11.2588, 75.7804);
    if (lower.contains('chemperi')) return const LatLng(12.0469, 75.5451);
    if (lower.contains('taliparamba')) return const LatLng(12.0436, 75.3562);
    if (lower.contains('payyambalam')) return const LatLng(11.8685, 75.3480);
    if (lower.contains('cherukunnu')) return const LatLng(11.9860, 75.3210);
    if (lower.contains('chalingal')) return const LatLng(12.3816, 75.1038);
    return null;
  }

  void _fitMapToRoute() {
    final pointsToFit = <LatLng>[];
    if (_hasUserLocation && _userLat != null && _userLng != null) {
      pointsToFit.add(LatLng(_userLat!, _userLng!));
    }
    final sCoord = _resolveStopCoord(_source);
    if (sCoord != null) pointsToFit.add(sCoord);
    final dCoord = _resolveStopCoord(_destination);
    if (dCoord != null) pointsToFit.add(dCoord);
    pointsToFit.addAll(_routePolylinePoints);

    if (pointsToFit.length >= 2) {
      try {
        final bounds = LatLngBounds.fromPoints(pointsToFit);
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: bounds,
            padding: const EdgeInsets.only(top: 140, bottom: 260, left: 30, right: 30),
          ),
        );
      } catch (_) {}
    } else if (pointsToFit.isNotEmpty) {
      _mapController.move(pointsToFit.first, 13.0);
    }
  }

  Future<void> _pollVehicles() async {
    // Only poll live vehicle telemetry when explicitly tracking a bus!
    if (widget.isTrackBusMode != true) {
      return;
    }
    final vehicles = await ApiService.fetchLiveVehicles();
    if (!mounted) return;

    setState(() {
      _vehicles = vehicles;

      if (widget.initialVehicleId != null) {
        final match = _vehicles.firstWhere(
          (v) => (v['vehicle_id'] ?? '').toString().toUpperCase() == widget.initialVehicleId!.toUpperCase() && v['is_active'] == true,
          orElse: () => null,
        );
        if (match != null) {
          _selectedVehicle = match;
        } else if (widget.selectedVehicleData != null && _selectedVehicle == null) {
          _selectedVehicle = widget.selectedVehicleData;
        }
      }

      if (_selectedVehicle != null) {
        final updated = _vehicles.firstWhere(
          (v) => v['vehicle_id'] == _selectedVehicle['vehicle_id'],
          orElse: () => null,
        );
        if (updated != null) {
          _selectedVehicle = updated;
        }
      }
    });

    if (_autoFollowVehicle && _selectedVehicle != null && _selectedVehicle['lat'] != null) {
      final double lat = (_selectedVehicle['lat'] as num).toDouble();
      final double lng = (_selectedVehicle['lng'] as num).toDouble();
      final newPoint = LatLng(lat, lng);
      if (_lastCenteredPoint == null ||
          (_lastCenteredPoint!.latitude - lat).abs() > 0.0001 ||
          (_lastCenteredPoint!.longitude - lng).abs() > 0.0001) {
        _lastCenteredPoint = newPoint;
        _mapController.move(newPoint, _mapController.camera.zoom);
      }
    }
  }

  void _useCurrentLocationAsSource() {
    if (_hasUserLocation && _userLat != null && _userLng != null) {
      // Find nearest stop or use label
      String bestStop = 'Chalingal';
      double bestDist = double.infinity;
      for (var entry in _stopsCoords.entries) {
        final d = (entry.value.latitude - _userLat!).abs() + (entry.value.longitude - _userLng!).abs();
        if (d < bestDist) {
          bestDist = d;
          bestStop = _stops.firstWhere((s) => s.toLowerCase() == entry.key, orElse: () => entry.key);
        }
      }

      setState(() {
        _source = bestStop;
        _sourceCtrl.text = bestStop;
      });
      _planJourney();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userPoint = (_hasUserLocation && _userLat != null && _userLng != null)
        ? LatLng(_userLat!, _userLng!)
        : const LatLng(12.3816, 75.1038);

    final sCoord = _resolveStopCoord(_source);
    final dCoord = _resolveStopCoord(_destination);

    final routes = (_journeyPlan != null && _journeyPlan!['routes'] is List)
        ? (_journeyPlan!['routes'] as List)
        : [];

    final isTrainRoute = _selectedRoute != null && _selectedRoute['mode_type'] == 'TRAIN';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Yathra Kerala • Map View',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              '$_source ➔ $_destination • Live Radar & Route Timing',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isSearchExpanded ? Icons.tune : Icons.search),
            tooltip: _isSearchExpanded ? 'Collapse Search' : 'Open Search',
            onPressed: () => setState(() => _isSearchExpanded = !_isSearchExpanded),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Routes & Radar',
            onPressed: () {
              _planJourney();
              _pollVehicles();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── FlutterMap Layer ──────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: userPoint,
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.yathrakerala.app',
              ),

              // Route Polyline (Google Maps Driving Navigation Blue or Bike Teal)
              if (_routePolylinePoints.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePolylinePoints,
                      strokeWidth: (_selectedRoute?['mode_type'] == 'CAR' || _selectedRoute?['mode_type'] == 'TWO_WHEELER') ? 6.5 : 5.0,
                      color: _selectedRoute?['mode_type'] == 'CAR'
                          ? const Color(0xFF1A73E8) // Google Maps Navigation Blue
                          : (_selectedRoute?['mode_type'] == 'TWO_WHEELER'
                              ? const Color(0xFF00897B) // Google Maps Bike Teal
                              : (isTrainRoute ? Colors.deepOrange : const Color(0xFF1565C0))),
                    ),
                  ],
                ),

              // Markers Layer: User Location + Source + Destination + Vehicles
              MarkerLayer(
                markers: [
                  // Driving Navigation Vehicle Icon (Car or Two Wheeler)
                  if ((_selectedRoute?['mode_type'] == 'CAR' || _selectedRoute?['mode_type'] == 'TWO_WHEELER') && _routePolylinePoints.isNotEmpty)
                    Marker(
                      point: _hasUserLocation && _userLat != null && _userLng != null ? LatLng(_userLat!, _userLng!) : _routePolylinePoints.first,
                      width: 44,
                      height: 44,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _selectedRoute['mode_type'] == 'CAR' ? const Color(0xFF1A73E8) : const Color(0xFF00897B),
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: const [
                            BoxShadow(color: Colors.black38, blurRadius: 6),
                          ],
                        ),
                        child: Icon(
                          _selectedRoute['mode_type'] == 'CAR' ? Icons.directions_car : Icons.two_wheeler,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),

                  // 1. User Physical Location Marker (Pulsing Blue)
                  if (_hasUserLocation && _userLat != null && _userLng != null)
                    Marker(
                      point: userPoint,
                      width: 60,
                      height: 60,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF1565C0).withValues(alpha: 0.25),
                            ),
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF1565C0),
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: const [
                                  BoxShadow(color: Colors.black38, blurRadius: 6),
                                ],
                              ),
                              child: const Icon(Icons.person, color: Colors.white, size: 12),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1565C0),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'You Are Here',
                              style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // 2. Source Marker (Green Pin)
                  if (sCoord != null)
                    Marker(
                      point: sCoord,
                      width: 70,
                      height: 55,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green,
                              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                            ),
                            child: const Icon(Icons.trip_origin, color: Colors.white, size: 14),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: Colors.green.shade900,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _source,
                              style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // 3. Destination Marker (Red Flag)
                  if (dCoord != null)
                    Marker(
                      point: dCoord,
                      width: 70,
                      height: 55,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                            ),
                            child: const Icon(Icons.flag, color: Colors.white, size: 14),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: Colors.red.shade900,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _destination,
                              style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // 4. Live Bus Location Marker - ONLY rendered when the user explicitly clicks 'Track Bus'!
                  if (widget.isTrackBusMode == true && _selectedVehicle != null && _selectedVehicle['lat'] != null && _selectedVehicle['lng'] != null)
                    Marker(
                      point: LatLng((_selectedVehicle['lat'] as num).toDouble(), (_selectedVehicle['lng'] as num).toDouble()),
                      width: 75,
                      height: 75,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: const Color(0xFF137333),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.amberAccent, width: 3),
                              boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 6, spreadRadius: 1)],
                            ),
                            child: const Icon(
                              Icons.directions_bus,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: Colors.green.shade900,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '📍 EXACT ${_selectedVehicle['vehicle_id'] ?? _selectedVehicle['bus_number'] ?? ''}',
                              style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),

          // ── Top Source & Destination Selection Card ────────────────────────
          Positioned(
            top: 10,
            left: 12,
            right: 12,
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Row with Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.route, color: Color(0xFF1565C0), size: 18),
                            SizedBox(width: 6),
                            Text('Select Route on Map', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                        InkWell(
                          onTap: () => setState(() => _isSearchExpanded = !_isSearchExpanded),
                          child: Row(
                            children: [
                              Text(
                                _isSearchExpanded ? 'Hide' : 'Expand',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF1565C0), fontWeight: FontWeight.bold),
                              ),
                              Icon(_isSearchExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 18, color: const Color(0xFF1565C0)),
                            ],
                          ),
                        ),
                      ],
                    ),

                    if (_isSearchExpanded) ...[
                      const SizedBox(height: 8),

                      // Origin Row
                      Row(
                        children: [
                          Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Autocomplete<String>(
                              initialValue: TextEditingValue(text: _source),
                              optionsBuilder: (TextEditingValue val) {
                                if (val.text.isEmpty) return _stops;
                                return _stops.where((s) => s.toLowerCase().contains(val.text.toLowerCase()));
                              },
                              fieldViewBuilder: (ctx, ctrl, focus, onSubmit) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (ctrl.text != _sourceCtrl.text) {
                                    ctrl.text = _sourceCtrl.text;
                                  }
                                });
                                return TextField(
                                  controller: ctrl,
                                  focusNode: focus,
                                  decoration: const InputDecoration(
                                    labelText: 'Starting From (Origin)',
                                    border: UnderlineInputBorder(),
                                    isDense: true,
                                    labelStyle: TextStyle(fontSize: 12),
                                    contentPadding: EdgeInsets.symmetric(vertical: 4),
                                  ),
                                  style: const TextStyle(fontSize: 12),
                                  onChanged: (v) {
                                    _sourceCtrl.text = v;
                                    setState(() => _source = v);
                                  },
                                  onSubmitted: (v) {
                                    setState(() => _source = v.trim());
                                    _planJourney();
                                  },
                                );
                              },
                              onSelected: (val) {
                                setState(() => _source = val);
                                _sourceCtrl.text = val;
                                _planJourney();
                              },
                            ),
                          ),
                          // Pick on OSM button
                          IconButton(
                            icon: const Icon(Icons.pin_drop, color: Colors.green, size: 20),
                            tooltip: 'Pick Origin on Map',
                            onPressed: () async {
                              final picked = await Navigator.push<String>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OsmLocationPickerScreen(
                                    title: 'Pick Origin on OpenStreetMap',
                                    initialSelectedStop: _source,
                                    isSource: true,
                                  ),
                                ),
                              );
                              if (picked != null) {
                                setState(() {
                                  _source = picked;
                                  _sourceCtrl.text = picked;
                                });
                                _planJourney();
                              }
                            },
                          ),
                        ],
                      ),

                      // Quick "Use My Current Location" + Swap Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_hasUserLocation)
                            InkWell(
                              onTap: _useCurrentLocationAsSource,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 3),
                                child: Row(
                                  children: [
                                    const Icon(Icons.my_location, size: 12, color: Color(0xFF1565C0)),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Use My Location (${_userLocationLabel.split(',').first})',
                                      style: const TextStyle(fontSize: 10, color: Color(0xFF1565C0), fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            const SizedBox.shrink(),

                          // Swap Button
                          InkWell(
                            onTap: () {
                              setState(() {
                                final temp = _source;
                                _source = _destination;
                                _destination = temp;
                                _sourceCtrl.text = _source;
                                _destCtrl.text = _destination;
                              });
                              _planJourney();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.swap_vert, size: 12, color: Color(0xFF1565C0)),
                                  SizedBox(width: 2),
                                  Text('Swap', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Destination Row
                      Row(
                        children: [
                          Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Autocomplete<String>(
                              initialValue: TextEditingValue(text: _destination),
                              optionsBuilder: (TextEditingValue val) {
                                if (val.text.isEmpty) return _stops;
                                return _stops.where((s) => s.toLowerCase().contains(val.text.toLowerCase()));
                              },
                              fieldViewBuilder: (ctx, ctrl, focus, onSubmit) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (ctrl.text != _destCtrl.text) {
                                    ctrl.text = _destCtrl.text;
                                  }
                                });
                                return TextField(
                                  controller: ctrl,
                                  focusNode: focus,
                                  decoration: const InputDecoration(
                                    labelText: 'Heading To (Destination)',
                                    border: UnderlineInputBorder(),
                                    isDense: true,
                                    labelStyle: TextStyle(fontSize: 12),
                                    contentPadding: EdgeInsets.symmetric(vertical: 4),
                                  ),
                                  style: const TextStyle(fontSize: 12),
                                  onChanged: (v) {
                                    _destCtrl.text = v;
                                    setState(() => _destination = v);
                                  },
                                  onSubmitted: (v) {
                                    setState(() => _destination = v.trim());
                                    _planJourney();
                                  },
                                );
                              },
                              onSelected: (val) {
                                setState(() => _destination = val);
                                _destCtrl.text = val;
                                _planJourney();
                              },
                            ),
                          ),
                          // Pick on OSM button
                          IconButton(
                            icon: const Icon(Icons.pin_drop, color: Colors.red, size: 20),
                            tooltip: 'Pick Destination on Map',
                            onPressed: () async {
                              final picked = await Navigator.push<String>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OsmLocationPickerScreen(
                                    title: 'Pick Destination on OpenStreetMap',
                                    initialSelectedStop: _destination,
                                    isSource: false,
                                  ),
                                ),
                              );
                              if (picked != null) {
                                setState(() {
                                  _destination = picked;
                                  _destCtrl.text = picked;
                                });
                                _planJourney();
                              }
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Search Button & Mode Filter Chips
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1565C0),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: _isLoadingRoutes
                                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Icon(Icons.search, size: 16),
                              label: const Text('Find Routes & Fares', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              onPressed: _isLoadingRoutes ? null : _planJourney,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // ── Floating Action Buttons (Recenter & User GPS) ──────────────────
          Positioned(
            right: 14,
            bottom: _isSuggestionsVisible && routes.isNotEmpty ? 290 : 20,
            child: Column(
              children: [
                // Fly to User GPS location
                FloatingActionButton.small(
                  heroTag: 'map_user_location',
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  tooltip: 'Center on My Current Location',
                  elevation: 4,
                  onPressed: () {
                    if (_hasUserLocation && _userLat != null && _userLng != null) {
                      _mapController.move(LatLng(_userLat!, _userLng!), 14.5);
                    } else {
                      _detectUserLocation();
                    }
                  },
                  child: const Icon(Icons.my_location),
                ),
                const SizedBox(height: 8),

                // Fit Route bounds
                if (routes.isNotEmpty)
                  FloatingActionButton.small(
                    heroTag: 'map_fit_route',
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1565C0),
                    tooltip: 'Fit Route to Screen',
                    elevation: 4,
                    onPressed: _fitMapToRoute,
                    child: const Icon(Icons.fit_screen),
                  ),
              ],
            ),
          ),

          // ── Google Maps Style Driving / Bike Navigation Card ───────────────
          if (_selectedRoute != null && (_selectedRoute['mode_type'] == 'CAR' || _selectedRoute['mode_type'] == 'TWO_WHEELER'))
            Positioned(
              bottom: 16,
              left: 12,
              right: 12,
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _selectedRoute['mode_type'] == 'CAR' ? const Color(0xFFE8F0FE) : const Color(0xFFE0F2F1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _selectedRoute['mode_type'] == 'CAR' ? Icons.directions_car : Icons.two_wheeler,
                              color: _selectedRoute['mode_type'] == 'CAR' ? const Color(0xFF1A73E8) : const Color(0xFF00897B),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '${_selectedRoute['trip_duration_mins'] ?? 25} min',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF1E8E3E), // Google Maps Green ETA
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '(${_selectedRoute['distance_km'] ?? '21.6'} km)',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Fastest route now • typical traffic',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: () {
                              setState(() {
                                _selectedRoute = null;
                                _routePolylinePoints = [];
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(height: 1),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.local_gas_station, size: 16, color: Colors.deepOrange),
                              const SizedBox(width: 6),
                              Text(
                                _selectedRoute['total_fare'] != null ? 'Fuel ${_selectedRoute['total_fare']}' : '₹150 Est. Fuel',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.schedule, size: 16, color: Color(0xFF1A73E8)),
                              const SizedBox(width: 6),
                              Text(
                                'Arr: ${_selectedRoute['expected_arrival'] ?? ''}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedRoute['mode_type'] == 'CAR' ? const Color(0xFF1A73E8) : const Color(0xFF00897B),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            icon: const Icon(Icons.navigation, size: 14),
                            label: const Text('Start', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            onPressed: () {
                              _fitMapToRoute();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Navigating via OpenStreetMap: $_source to $_destination'),
                                  backgroundColor: const Color(0xFF1A73E8),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── Exact Live Bus Telemetry Card (ONLY when specifically tracking a bus) ──────────────
          if (widget.isTrackBusMode == true && _selectedVehicle != null && _selectedVehicle['lat'] != null && _selectedVehicle['lng'] != null)
            Positioned(
              bottom: 16,
              left: 12,
              right: 12,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: const Color(0xFF1E293B),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.directions_bus, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        _selectedVehicle['name'] ?? _selectedVehicle['bus_name'] ?? 'Bus Live Location',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: const Color(0xFF10B981)),
                                      ),
                                      child: const Text(
                                        'LIVE GPS',
                                        style: TextStyle(color: Color(0xFF34D399), fontSize: 9, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Exact GPS: ${(_selectedVehicle['lat'] as num).toDouble().toStringAsFixed(5)}°N, ${(_selectedVehicle['lng'] as num).toDouble().toStringAsFixed(5)}°E • Speed: ${(_selectedVehicle['speed_kmh'] ?? 35).toString()} km/h',
                                  style: TextStyle(color: Colors.grey.shade400, fontSize: 10.5),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white70, size: 18),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              setState(() {
                                _selectedVehicle = null;
                                _autoFollowVehicle = false;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.pin_drop, size: 14, color: Color(0xFF38BDF8)),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Current Location: ${_selectedVehicle['current_stop'] ?? 'Transmitting live on corridor'}',
                                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.my_location, size: 14),
                            label: const Text('Center', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            onPressed: () {
                              final lat = (_selectedVehicle['lat'] as num).toDouble();
                              final lng = (_selectedVehicle['lng'] as num).toDouble();
                              _mapController.move(LatLng(lat, lng), 16.5);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── Bottom Sheet: Route Suggestions (Timings & Fares) ─────────────
          if (routes.isNotEmpty && _isSuggestionsVisible)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.42,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -3))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top drag pill
                    Container(
                      margin: const EdgeInsets.only(top: 8, bottom: 4),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2)),
                    ),

                    // Header row: Count & Toggle
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.directions_transit, size: 18, color: Color(0xFF1565C0)),
                              const SizedBox(width: 6),
                              Text(
                                'Available Options (${routes.length})',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Tap card to view path',
                                  style: TextStyle(fontSize: 10, color: Colors.green.shade800, fontWeight: FontWeight.bold),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => setState(() => _isSuggestionsVisible = false),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // Scrollable List of Route Suggestion Cards
                    Flexible(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shrinkWrap: true,
                        itemCount: routes.length,
                        itemBuilder: (ctx, i) {
                          final r = routes[i];
                          final isSelected = _selectedRoute != null && _selectedRoute['id'] == r['id'];
                          return _buildMapRouteCard(r, isSelected);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // If suggestions panel is minimized, show a small button to re-open it
          if (routes.isNotEmpty && !_isSuggestionsVisible)
            Positioned(
              bottom: 16,
              left: 16,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  elevation: 6,
                ),
                icon: const Icon(Icons.directions, size: 18),
                label: Text('Show ${routes.length} Route Options & Fares', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onPressed: () => setState(() => _isSuggestionsVisible = true),
              ),
            ),
        ],
      ),
    );
  }

  // ── Authentic Route Suggestion Card for Map View ─────────────────────────
  Widget _buildMapRouteCard(dynamic route, bool isSelected) {
    final modeType = route['mode_type'] ?? 'BUS';
    final isTrain = modeType == 'TRAIN';
    final isWalk = modeType == 'WALK';
    final isTaxi = modeType == 'TAXI' || modeType == 'CAB';

    final Color themeColor = isTrain
        ? Colors.deepOrange
        : (isWalk
            ? Colors.teal
            : (isTaxi ? Colors.amber.shade900 : const Color(0xFF1565C0)));

    final IconData modeIcon = isTrain
        ? Icons.train
        : (isWalk ? Icons.directions_walk : (isTaxi ? Icons.local_taxi : Icons.directions_bus));

    final totalFare = route['total_fare'] ?? '₹30';
    final totalTime = route['total_time_mins'] ?? 25;
    final expDeparture = route['expected_departure'] ?? '09:00 AM';
    final expArrival = route['expected_arrival'] ?? '09:30 AM';
    final countdownMins = route['departure_countdown_mins'] ?? 5;
    final intermediate = route['intermediate_stops'] as List? ?? [];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? themeColor : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            _selectedRoute = route;
            _updateRoutePolyline(route);
          });
          _fitMapToRoute();
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Departure status badge + Total Fare
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Countdown pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isWalk
                          ? Colors.teal.shade50
                          : (isTaxi
                              ? Colors.amber.shade50
                              : (countdownMins <= 5 ? Colors.green.shade50 : Colors.blue.shade50)),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isWalk
                            ? Colors.teal.shade300
                            : (isTaxi
                                ? Colors.amber.shade700
                                : (countdownMins <= 5 ? Colors.green.shade600 : Colors.blue.shade400)),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isWalk
                                ? Colors.teal
                                : (isTaxi
                                    ? Colors.amber.shade900
                                    : (countdownMins <= 5 ? Colors.green : Colors.blue)),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isWalk
                              ? 'Walk Directly • Free'
                              : (isTaxi ? 'ON DEMAND • ETA $countdownMins MINS' : 'IN $countdownMins MINS • $expDeparture'),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isWalk
                                ? Colors.teal.shade900
                                : (isTaxi
                                    ? Colors.amber.shade900
                                    : (countdownMins <= 5 ? Colors.green.shade900 : Colors.blue.shade900)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Fare Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$totalFare',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isWalk ? Colors.teal.shade800 : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Title and Mode
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(modeIcon, color: themeColor, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          route['title'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Arrives at $expArrival ($totalTime mins)${route['transfers'] == 0 ? ' • Direct' : ''}',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Train specific info (Platform & Train Route)
              if (isTrain && route['train_route_label'] != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Text(
                    'Corridor: ${route['train_route_label']} • Departs ${route['departure_pf'] ?? "PF 1"}',
                    style: TextStyle(fontSize: 10, color: Colors.deepOrange.shade900, fontWeight: FontWeight.bold),
                  ),
                ),
              ],

              // Intermediate stops timeline toggle
              if (intermediate.isNotEmpty) ...[
                const SizedBox(height: 4),
                InkWell(
                  onTap: () => _showStopSequenceModal(intermediate, route['title'] ?? 'Route Stops'),
                  child: Row(
                    children: [
                      Icon(Icons.alt_route, size: 12, color: Colors.blue.shade800),
                      const SizedBox(width: 4),
                      Text(
                        'View ${intermediate.length} intermediate stops along route',
                        style: TextStyle(fontSize: 10.5, color: Colors.blue.shade800, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showStopSequenceModal(List<dynamic> stops, String routeTitle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (_, scrollController) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.alt_route, color: Color(0xFF1565C0)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          routeTitle,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '${stops.length} stops along this corridor',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: stops.length,
                    itemBuilder: (ctx, i) {
                      final isFirst = i == 0;
                      final isLast = i == stops.length - 1;
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 12,
                          backgroundColor: isFirst
                              ? Colors.green
                              : (isLast ? Colors.red : Colors.grey.shade300),
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: (isFirst || isLast) ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        title: Text(
                          stops[i].toString(),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: (isFirst || isLast) ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        dense: true,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
