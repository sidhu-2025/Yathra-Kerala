import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DriverScreen extends StatefulWidget {
  const DriverScreen({super.key});

  @override
  State<DriverScreen> createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
  final String _busNo = 'KL-13-AB-8429';
  final String _busName = 'Royal Travels';
  final List<String> _stops = [
    'Kannur',
    'Caltex',
    'Taliparamba',
    'Sreekandapuram',
    'Madampam',
    'Chemperi'
  ];

  int _currentStopIndex = 2; // Taliparamba
  bool _isTripActive = false;
  double _speed = 45.0;
  int _delayMins = 3;
  Timer? _gpsSimulationTimer;

  void _toggleTrip() {
    setState(() {
      _isTripActive = !_isTripActive;
    });

    if (_isTripActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip Started! GPS Broadcast Live')),
      );
      _startSimulatedBroadcast();
    } else {
      _gpsSimulationTimer?.cancel();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip Ended. GPS Broadcast Stopped')),
      );
    }
  }

  void _startSimulatedBroadcast() {
    _gpsSimulationTimer = Timer.periodic(const Duration(seconds: 4), (timer) async {
      if (!_isTripActive) return;

      // Broadcast update to backend
      final currentStop = _stops[_currentStopIndex];
      final nextStop = _currentStopIndex + 1 < _stops.length
          ? _stops[_currentStopIndex + 1]
          : 'Terminus';

      await ApiService.updateDriverLocation(
        vehicleId: _busNo,
        lat: 12.0289 + (_currentStopIndex * 0.005),
        lng: 75.4744 + (_currentStopIndex * 0.003),
        currentStop: currentStop,
        nextStop: nextStop,
        speedKmh: _speed,
        delayMins: _delayMins,
      );
    });
  }

  void _advanceToNextStop() {
    if (_currentStopIndex < _stops.length - 1) {
      setState(() {
        _currentStopIndex++;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Arrived at: ${_stops[_currentStopIndex]}')),
      );
    }
  }

  @override
  void dispose() {
    _gpsSimulationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentStop = _stops[_currentStopIndex];
    final nextStop = _currentStopIndex + 1 < _stops.length ? _stops[_currentStopIndex + 1] : 'Terminus';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver & Conductor Terminal'),
        backgroundColor: Colors.teal.shade900,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.teal.shade100,
                          radius: 28,
                          child: const Icon(Icons.directions_bus, color: Colors.teal, size: 30),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_busName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              Text('Bus No: $_busNo', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _isTripActive ? Colors.green.shade100 : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _isTripActive ? '● BROADCASTING GPS' : 'IDLE / NOT STARTED',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: _isTripActive ? Colors.green.shade800 : Colors.grey.shade700,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    ListTile(
                      leading: const Icon(Icons.location_on, color: Colors.teal),
                      title: const Text('Current Stop'),
                      subtitle: Text(currentStop, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      trailing: ElevatedButton(
                        onPressed: _isTripActive ? _advanceToNextStop : null,
                        child: const Text('Arrived'),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.navigation, color: Colors.blueGrey),
                      title: const Text('Next Destination'),
                      subtitle: Text(nextStop, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Live Trip Controls', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Current Speed: ${_speed.toInt()} km/h'),
                        Slider(
                          value: _speed,
                          min: 10,
                          max: 80,
                          divisions: 14,
                          onChanged: (val) => setState(() => _speed = val),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Delay: $_delayMins mins'),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () {
                                if (_delayMins > 0) setState(() => _delayMins--);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => setState(() => _delayMins++),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon: Icon(_isTripActive ? Icons.stop : Icons.play_arrow),
                label: Text(
                  _isTripActive ? 'STOP GPS BROADCAST' : 'START LIVE TRIP & TRANSMIT GPS',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isTripActive ? Colors.red.shade700 : Colors.teal.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _toggleTrip,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
