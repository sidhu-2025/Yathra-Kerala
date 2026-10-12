import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'live_tracking_screen.dart';
import 'chatbot_screen.dart';
import 'driver_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> _stops = [];
  String _source = 'Chemperi';
  String _destination = 'Kannur';
  String _preference = 'best'; // fastest, cheapest, best
  bool _isLoading = false;
  Map<String, dynamic>? _journeyPlan;
  Map<String, dynamic>? _weather;
  Map<String, dynamic>? _predictedEta;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final stops = await ApiService.fetchStops();
    final weather = await ApiService.fetchWeather('Kannur');
    setState(() {
      _stops = stops;
      _weather = weather;
      if (!_stops.contains(_source) && _stops.isNotEmpty) {
        _source = _stops.first;
      }
      if (!_stops.contains(_destination) && _stops.length > 1) {
        _destination = _stops[1];
      }
    });
    _searchRoutes();
  }

  Future<void> _searchRoutes() async {
    setState(() => _isLoading = true);
    final plan = await ApiService.planJourney(
      source: _source,
      destination: _destination,
      preference: _preference,
    );

    // Predict ETA using Random Forest Model
    final eta = await ApiService.predictETA(
      distanceKm: (plan != null ? (plan['distance_km'] as num).toDouble() : 25.0),
      hourOfDay: DateTime.now().hour,
      trafficLevel: 1,
      weatherImpact: _weather != null && _weather!['weather'].toString().contains('Rain') ? 1 : 0,
    );

    setState(() {
      _journeyPlan = plan;
      _predictedEta = eta;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('YathraKerala', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text('AI Multi-Modal Journey Planner', style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        backgroundColor: Colors.teal.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.drive_eta),
            tooltip: 'Driver Mode',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const DriverScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.smart_toy_outlined),
            tooltip: 'TransitGPT AI Assistant',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatbotScreen()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weather Card Banner (Weather context awareness Slide 6 & 24)
            if (_weather != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade700, Colors.teal.shade500],
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cloud, color: Colors.white, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_weather!['location']} • ${_weather!['weather']} (${_weather!['temperature_celsius']}°C)',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            _weather!['recommendation'] ?? '',
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Search Origin & Destination Box
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.trip_origin, color: Colors.green),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _stops.contains(_source) ? _source : null,
                              decoration: const InputDecoration(
                                labelText: 'Origin (From)',
                                border: UnderlineInputBorder(),
                              ),
                              items: _stops.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _source = val);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.red),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _stops.contains(_destination) ? _destination : null,
                              decoration: const InputDecoration(
                                labelText: 'Destination (To)',
                                border: UnderlineInputBorder(),
                              ),
                              items: _stops.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _destination = val);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Filter options
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ChoiceChip(
                            label: const Text('Best Route'),
                            selected: _preference == 'best',
                            onSelected: (_) {
                              setState(() => _preference = 'best');
                              _searchRoutes();
                            },
                          ),
                          ChoiceChip(
                            label: const Text('Fastest'),
                            selected: _preference == 'fastest',
                            onSelected: (_) {
                              setState(() => _preference = 'fastest');
                              _searchRoutes();
                            },
                          ),
                          ChoiceChip(
                            label: const Text('Cheapest'),
                            selected: _preference == 'cheapest',
                            onSelected: (_) {
                              setState(() => _preference = 'cheapest');
                              _searchRoutes();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.search),
                          label: const Text('SEARCH MULTI-MODAL ROUTES', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal.shade800,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _searchRoutes,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Random Forest Regressor Prediction Box (Slide 10, 14, 24)
            if (_predictedEta != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.precision_manufacturing, color: Colors.amber.shade900, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ML Predicted Arrival Time: ${_predictedEta!['predicted_arrival_minutes']} mins',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade900, fontSize: 13),
                            ),
                            Text(
                              'Random Forest Regressor • Confidence: ${((_predictedEta!['confidence_score'] as num) * 100).toInt()}% (Traffic & Weather adjusted)',
                              style: TextStyle(color: Colors.brown.shade700, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Route Itinerary Results
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Available Options',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.map, size: 18),
                        label: const Text('Open Map'),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveTrackingScreen()));
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_isLoading)
                    const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
                  else if (_journeyPlan != null && _journeyPlan!['routes'] != null)
                    ...(_journeyPlan!['routes'] as List).map((r) => _buildRouteCard(r)).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.teal.shade800,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.chat),
        label: const Text('TransitGPT'),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatbotScreen()));
        },
      ),
    );
  }

  Widget _buildRouteCard(dynamic route) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    route['title'] ?? 'Route Option',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    route['badge'] ?? '',
                    style: TextStyle(color: Colors.teal.shade900, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade700),
                const SizedBox(width: 4),
                Text('${route['total_time_mins']} mins', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                Icon(Icons.currency_rupee, size: 16, color: Colors.grey.shade700),
                Text('${route['total_fare']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                const SizedBox(width: 16),
                Icon(Icons.alt_route, size: 16, color: Colors.grey.shade700),
                Text('${route['transfers']} transfer(s)'),
              ],
            ),
            const Divider(height: 24),
            // Multi-modal segments (Legs)
            ...?((route['legs'] as List?)?.map((leg) {
              final mode = leg['mode'];
              IconData modeIcon = Icons.directions_walk;
              Color modeColor = Colors.grey;

              if (mode == 'BUS') {
                modeIcon = Icons.directions_bus;
                modeColor = Colors.blue;
              } else if (mode == 'TRAIN') {
                modeIcon = Icons.train;
                modeColor = Colors.orange.shade800;
              } else if (mode == 'AUTO') {
                modeIcon = Icons.electric_rickshaw;
                modeColor = Colors.amber.shade800;
              } else if (mode == 'TAXI') {
                modeIcon = Icons.local_taxi;
                modeColor = Colors.purple;
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: modeColor.withOpacity(0.15),
                      child: Icon(modeIcon, size: 16, color: modeColor),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            leg['instruction'] ?? '',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                          Row(
                            children: [
                              Text(
                                '${leg['duration_mins']} mins • ₹${leg['fare']}',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                              ),
                              if (leg['is_live_trackable'] == true) ...[
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => LiveTrackingScreen(
                                          initialVehicleId: leg['vehicle_id'],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      border: Border.all(color: Colors.green.shade400),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.gps_fixed, size: 10, color: Colors.green),
                                        SizedBox(width: 4),
                                        Text('Track Live', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList()),
          ],
        ),
      ),
    );
  }
}
