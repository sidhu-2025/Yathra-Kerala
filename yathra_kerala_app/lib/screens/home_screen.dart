import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import '../services/api_service.dart';
import 'live_tracking_screen.dart';
import 'chatbot_screen.dart';
import 'osm_location_picker_screen.dart';
import 'auth_screen.dart';
import 'train_schedule_screen.dart';
import 'ksrtc_bus_schedule_screen.dart';
import 'train_live_map_screen.dart';
import '../widgets/google_weather_card.dart';
import '../services/location_service.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const HomeScreen({super.key, this.currentUser});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> _stops = [
    'Kannur',
    'Kannur Old Bus Stand',
    'Kannur New Bus Stand',
    'Kannur Railway Station',
    'Chemperi',
    'Chemperi Bus Stand',
    'Kudiyanmala',
    'Taliparamba',
    'Taliparamba Bus Stand',
    'Sreekandapuram',
    'Thalassery',
    'Thalassery Old Bus Stand',
    'Thalassery New Bus Stand',
    'Thalassery Railway Station',
    'Payyanur',
    'Payyanur Railway Station',
    'Payyambalam Beach',
    'Alakode',
    'Cherupuzha',
    'Iritty',
    'Mattannur',
    'Kannur Airport',
    'Kozhikode',
    'Kozhikode Railway Station',
    'Kasaragod',
    'Kasaragod Railway Station',
    'Kanhangad',
    'Pazhayangadi',
    'Pappinisseri',
    'Valapattanam',
    'Dharmadam',
    'Mahe',
    'Vadakara',
    'Koyilandy',
    'Thana',
    'Caltex',
    'Chala',
    'Mele Chovva',
    'South Bazar',
    'Pilathara',
    'Mangaluru',
    'Bengaluru',
    'Thrissur',
    'Ernakulam',
  ];
  String _source = 'kannur';
  String _destination = 'chemperi';
  String _preference = 'fastest'; // fastest, cheapest, longest, walk, train, bus
  bool _isLoading = false;
  Map<String, dynamic>? _journeyPlan;
  Map<String, dynamic>? _weather;
  Map<String, dynamic>? _currentUser;
  List<dynamic> _liveVehicles = [];
  Uint8List? _profileImageBytes;
  final ImagePicker _picker = ImagePicker();

  // Logged-in user physical device location for Live Weather API
  String _userLocationName = 'Chalingal, Kasaragod, Kerala';
  double? _userLat = 12.3816;
  double? _userLng = 75.1038;
  bool _isLoadingUserWeather = false;

  // Controllers for free-text source/destination inputs
  late TextEditingController _sourceCtrl;
  late TextEditingController _destCtrl;
  final FocusNode _sourceFocus = FocusNode();
  final FocusNode _destFocus = FocusNode();

  Timer? _liveVehiclesTimer;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.currentUser;
    _sourceCtrl = TextEditingController(text: _source);
    _destCtrl = TextEditingController(text: _destination);



    _loadInitialData();
    _searchRoutes();
    _liveVehiclesTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      final vehicles = await ApiService.fetchLiveVehicles();
      if (mounted) {
        setState(() {
          _liveVehicles = vehicles;
        });
      }
    });
  }

  @override
  void dispose() {
    _liveVehiclesTimer?.cancel();
    _sourceCtrl.dispose();
    _destCtrl.dispose();
    _sourceFocus.dispose();
    _destFocus.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    // 1. Detect physical user device location and load live weather
    _detectUserLocationAndWeather();

    final stops = await ApiService.fetchStops();
    final liveVehicles = await ApiService.fetchLiveVehicles();
    if (!mounted) return;
    setState(() {
      if (stops.isNotEmpty) {
        final existing = Set<String>.from(_stops);
        for (var s in stops) {
          if (!existing.contains(s)) {
            _stops.add(s);
          }
        }
      }
      _liveVehicles = liveVehicles;
    });
  }

  Future<void> _detectUserLocationAndWeather() async {
    setState(() => _isLoadingUserWeather = true);
    try {
      final pos = await getDeviceLocation();
      if (pos != null) {
        _userLat = (pos['lat'] as num).toDouble();
        _userLng = (pos['lng'] as num).toDouble();
      } else {
        _userLat = 12.3816;
        _userLng = 75.1038;
      }
    } catch (_) {
      _userLat = 12.3816;
      _userLng = 75.1038;
    }
    _userLocationName = 'Chalingal, Kasaragod, Kerala';

    final weather = await ApiService.fetchWeather(_userLocationName, _userLat, _userLng);
    if (!mounted) return;
    setState(() {
      _weather = weather;
      if (weather['location'] != null && weather['location'].toString().isNotEmpty) {
        _userLocationName = weather['location'];
      }
      _isLoadingUserWeather = false;
    });
  }

  Future<void> _updateWeatherForLocation([String? loc]) async {
    // Retain user's actual physical location weather
    if (_weather == null) {
      await _detectUserLocationAndWeather();
    }
  }

  /// Fetches the device GPS location and returns a human-readable place name.
  Future<String?> _fetchCurrentLocationName() async {
    try {
      final pos = await getDeviceLocation();
      if (pos != null) {
        final lat = (pos['lat'] as num).toDouble();
        final lng = (pos['lng'] as num).toDouble();
        // Use reverse-geocoded name from weather API or just lat,lng fallback
        final weather = await ApiService.fetchWeather('Current Location', lat, lng);
        if (weather['location'] != null && weather['location'].toString().isNotEmpty) {
          return weather['location'].toString();
        }
        return '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
      }
    } catch (e) {
      debugPrint('[GPS] fetchCurrentLocationName error: $e');
    }
    return null;
  }

  bool _isFetchingSourceLocation = false;
  bool _isFetchingDestLocation = false;

  Future<void> _useCurrentLocationAsSource() async {
    setState(() => _isFetchingSourceLocation = true);
    final name = await _fetchCurrentLocationName();
    if (mounted) {
      setState(() {
        _isFetchingSourceLocation = false;
        if (name != null) {
          _source = name;
          _sourceCtrl.text = name;
        }
      });
      if (name == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not get current location. Please check GPS permissions.'),
            backgroundColor: Colors.orangeAccent,
          ),
        );
      } else {
        _searchRoutes();
      }
    }
  }

  Future<void> _useCurrentLocationAsDest() async {
    setState(() => _isFetchingDestLocation = true);
    final name = await _fetchCurrentLocationName();
    if (mounted) {
      setState(() {
        _isFetchingDestLocation = false;
        if (name != null) {
          _destination = name;
          _destCtrl.text = name;
        }
      });
      if (name == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not get current location. Please check GPS permissions.'),
            backgroundColor: Colors.orangeAccent,
          ),
        );
      } else {
        _searchRoutes();
      }
    }
  }

  


  Future<void> _searchRoutes({bool showWarning = false}) async {
    final src = _sourceCtrl.text.trim().isNotEmpty ? _sourceCtrl.text.trim() : _source.trim();
    final dst = _destCtrl.text.trim().isNotEmpty ? _destCtrl.text.trim() : _destination.trim();
    _source = src;
    _destination = dst;
    if (_source.isEmpty || _destination.isEmpty) {
      if (showWarning && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter or select both Starting From (Origin) and Heading To (Destination).'),
            backgroundColor: Colors.orangeAccent,
          ),
        );
      }
      return;
    }
    setState(() => _isLoading = true);
    final plan = await ApiService.planJourney(
      source: _source,
      destination: _destination,
      preference: _preference,
    );

    if (mounted) {
      setState(() {
        _journeyPlan = plan;
        _isLoading = false;
      });
      if (plan == null && showWarning) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not reach backend (${ApiService.baseUrl}). Please verify Wi-Fi.'),
            backgroundColor: Colors.redAccent,
            action: SnackBarAction(label: 'Retry', textColor: Colors.white, onPressed: () => _searchRoutes(showWarning: true)),
          ),
        );
      }
    }
  }



  void _handleLogout() {
    setState(() => _currentUser = null);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out. Returning to Login screen...')),
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const AuthScreen(
          isRoot: true,
          initialRole: 'user',
        ),
      ),
    );
  }

  Future<void> _pickProfileImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _profileImageBytes = bytes;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Profile photo updated successfully!'),
              backgroundColor: Color(0xFF2E7D32),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not access image: $e'),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Add / Change Profile Photo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE3F2FD),
                  child: Icon(Icons.photo_library, color: Color(0xFF1565C0)),
                ),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickProfileImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE8F5E9),
                  child: Icon(Icons.camera_alt, color: Color(0xFF2E7D32)),
                ),
                title: const Text('Take a Photo with Camera'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickProfileImage(ImageSource.camera);
                },
              ),
              if (_profileImageBytes != null)
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFEBEE),
                    child: Icon(Icons.delete_outline, color: Colors.red),
                  ),
                  title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _profileImageBytes = null);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProfileDialog() {
    final name = _currentUser?['name'] ?? 'Kiran Raj';
    final username = _currentUser?['username'] ?? 'user1';
    final role = (_currentUser?['role'] ?? 'user').toString().toUpperCase();
    final email = _currentUser?['email'] ?? '$username@gmail.com';
    final phone = _currentUser?['phone'] ?? '+91 98471 23456';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // User Avatar with Camera Badge & Tap to Add Photo
            GestureDetector(
              onTap: () {
                Navigator.pop(ctx);
                _showImageSourceDialog();
              },
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFF1565C0),
                    backgroundImage: _profileImageBytes != null ? MemoryImage(_profileImageBytes!) : null,
                    child: _profileImageBytes == null
                        ? Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'U',
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                          )
                        : null,
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade800,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: () {
                Navigator.pop(ctx);
                _showImageSourceDialog();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_a_photo_outlined, size: 14, color: Colors.blue.shade700),
                    const SizedBox(width: 5),
                    Text(
                      _profileImageBytes == null ? 'Add Profile Photo' : 'Change Profile Photo',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                role == 'DRIVER' ? 'REGISTERED DRIVER' : 'REGISTERED PASSENGER',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1565C0)),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            _buildProfileDetailRow(Icons.person_outline, 'Full Name', name),
            _buildProfileDetailRow(Icons.alternate_email, 'Username', '@$username'),
            _buildProfileDetailRow(Icons.email_outlined, 'Email Address', email),
            _buildProfileDetailRow(Icons.phone_outlined, 'Mobile Number', phone),
            if (_currentUser?['vehicle_no'] != null && _currentUser!['vehicle_no'].toString().isNotEmpty && role == 'DRIVER')
              _buildProfileDetailRow(Icons.directions_bus, 'Assigned Vehicle', _currentUser!['vehicle_no'].toString()),
            const Divider(),
            const SizedBox(height: 14),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade700,
                  side: BorderSide(color: Colors.red.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.pop(ctx);
                  _handleLogout();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF1565C0)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showServerConfigDialog(BuildContext parentCtx) {
    final ctrl = TextEditingController(text: ApiService.baseUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.dns, color: Color(0xFF1565C0)),
            SizedBox(width: 8),
            Text('Server IP / URL', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the backend URL (PC Wi-Fi IP) so your phone connects to live GPS & schedules:',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              decoration: const InputDecoration(
                labelText: 'Backend Server URL',
                hintText: 'http://172.26.28.160:8000',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
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
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0)),
            onPressed: () {
              final newUrl = ctrl.text.trim();
              if (newUrl.isNotEmpty) {
                ApiService.setBaseUrl(newUrl);
                Navigator.pop(ctx);
                Navigator.pop(parentCtx);
                _loadInitialData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('✓ Server URL set to: $newUrl'), backgroundColor: Colors.green),
                );
              }
            },
            child: const Text('Save & Connect', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshWeather() async {
    setState(() => _isLoadingUserWeather = true);
    final weather = await ApiService.fetchWeather(_userLocationName, _userLat, _userLng);
    if (mounted) {
      setState(() {
        _weather = weather;
        if (weather['location'] != null && weather['location'].toString().isNotEmpty) {
          _userLocationName = weather['location'];
        }
        _isLoadingUserWeather = false;
      });
    }
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
        child: SingleChildScrollView(
          child: GoogleWeatherCard(
            initialWeather: _weather,
            location: _userLocationName,
            isModal: true,
            onClose: () => Navigator.pop(ctx),
          ),
        ),
      ),
    );
  }





  @override
  Widget build(BuildContext context) {
    // Filter routes: when clicking Car, show ONLY Car; when clicking Bike, show ONLY Bike!
    final rawRoutes = (_journeyPlan?['routes'] as List?) ?? [];
    final displayRoutes = rawRoutes.where((r) {
      if (_preference == 'car' || _preference == 'car driving mode') {
        return r['mode_type'] == 'CAR';
      }
      if (_preference == 'two_wheeler' || _preference == 'two wheeler mode') {
        return r['mode_type'] == 'TWO_WHEELER';
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text('Yathra', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.5)),
                SizedBox(width: 6),
                Text('Kerala', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15, color: Colors.amberAccent)),
              ],
            ),
            const Text(
              'Kerala AI Multi-Modal Transit',
              style: TextStyle(fontSize: 10, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1565C0), // Primary Royal Blue
        foregroundColor: Colors.white,
        actions: [
          // Separate Button for Map View
          IconButton(
            icon: const Icon(Icons.map, color: Colors.white, size: 22),
            tooltip: 'Live Map View',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LiveTrackingScreen(
                    initialSource: _source,
                    initialDestination: _destination,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 2),

          



          // Weather update icon
          IconButton(
            icon: const Icon(Icons.wb_sunny_outlined, color: Colors.amberAccent, size: 22),
            tooltip: 'Live Weather Update & Monsoon Alerts',
            onPressed: _refreshWeather,
          ),
          const SizedBox(width: 4),

          // User Profile Icon Button (Shows profile details, Login/Switch, and Logout)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white.withOpacity(0.25),
                backgroundImage: _profileImageBytes != null ? MemoryImage(_profileImageBytes!) : null,
                child: _profileImageBytes == null ? const Icon(Icons.person, color: Colors.white, size: 20) : null,
              ),
              tooltip: 'User Profile & Details',
              onPressed: _showProfileDialog,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [




            // Search Origin & Destination Box (YathraKerala Style)
            Padding(
              padding: const EdgeInsets.all(14),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // ── Origin Input ──────────────────────────────────────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 14, height: 14,
                            decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _sourceCtrl,
                              focusNode: _sourceFocus,
                              decoration: const InputDecoration(
                                labelText: 'Starting From (Origin)',
                                hintText: 'Enter origin or use 📍 GPS',
                                border: UnderlineInputBorder(),
                                isDense: true,
                                labelStyle: TextStyle(fontSize: 13),
                              ),
                              style: const TextStyle(fontSize: 13),
                              onChanged: (v) => setState(() => _source = v),
                              onSubmitted: (v) {
                                setState(() => _source = v.trim());
                                if (_source.isNotEmpty) _searchRoutes();
                              },
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                          // GPS Current Location button for source
                          _isFetchingSourceLocation
                              ? const SizedBox(
                                  width: 40, height: 40,
                                  child: Padding(
                                    padding: EdgeInsets.all(10),
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green),
                                  ),
                                )
                              : IconButton(
                                  icon: const Icon(Icons.my_location, color: Colors.green),
                                  tooltip: 'Use Current GPS Location as Origin',
                                  onPressed: _useCurrentLocationAsSource,
                                ),
                          IconButton(
                            icon: const Icon(Icons.pin_drop, color: Colors.green),
                            tooltip: 'Select on OpenStreetMap',
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
                                  if (!_stops.contains(picked)) _stops.add(picked);
                                });
                                _updateWeatherForLocation(picked);
                                _searchRoutes();
                              }
                            },
                          ),
                        ],
                      ),


                      // ── Swap Button ───────────────────────────────────────
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              final temp = _source;
                              _source = _destination;
                              _destination = temp;
                              _sourceCtrl.text = _source;
                              _destCtrl.text = _destination;
                            });
                            _updateWeatherForLocation(_source);
                            _searchRoutes();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            margin: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.swap_vert, size: 14, color: Color(0xFF1565C0)),
                                SizedBox(width: 4),
                                Text('Swap', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // ── Destination Input ─────────────────────────────────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 14, height: 14,
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _destCtrl,
                              focusNode: _destFocus,
                              decoration: const InputDecoration(
                                labelText: 'Heading To (Destination)',
                                hintText: 'Enter destination or use 📍 GPS',
                                border: UnderlineInputBorder(),
                                isDense: true,
                                labelStyle: TextStyle(fontSize: 13),
                              ),
                              style: const TextStyle(fontSize: 13),
                              onChanged: (v) => setState(() => _destination = v),
                              onSubmitted: (v) {
                                setState(() => _destination = v.trim());
                                if (_destination.isNotEmpty) _searchRoutes();
                              },
                              textInputAction: TextInputAction.search,
                            ),
                          ),
                          // GPS Current Location button for destination
                          _isFetchingDestLocation
                              ? const SizedBox(
                                  width: 40, height: 40,
                                  child: Padding(
                                    padding: EdgeInsets.all(10),
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
                                  ),
                                )
                              : IconButton(
                                  icon: const Icon(Icons.my_location, color: Colors.red),
                                  tooltip: 'Use Current GPS Location as Destination',
                                  onPressed: _useCurrentLocationAsDest,
                                ),
                          IconButton(
                            icon: const Icon(Icons.pin_drop, color: Colors.red),
                            tooltip: 'Select on OpenStreetMap',
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
                                  if (!_stops.contains(picked)) _stops.add(picked);
                                });
                                _searchRoutes();
                              }
                            },
                          ),
                        ],
                      ),




                      // ── Search & Map View Buttons ─────────────────────────
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.search, size: 18),
                              label: const Text('Suggestions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1565C0),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                _searchRoutes(showWarning: true);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.map, size: 18),
                              label: const Text('Map View', style: TextStyle(fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF005B41), // Yathra Emerald Green
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () {
                                final s = _sourceCtrl.text.trim().isNotEmpty ? _sourceCtrl.text.trim() : _source;
                                final d = _destCtrl.text.trim().isNotEmpty ? _destCtrl.text.trim() : _destination;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => LiveTrackingScreen(
                                      initialSource: s,
                                      initialDestination: d,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Dedicated Google Maps Style Car & Two-Wheeler Mode Buttons in Preference Area
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: Icon(
                                Icons.directions_car,
                                size: 18,
                                color: (_preference == 'car' || _preference == 'car driving mode') ? Colors.white : const Color(0xFF1A73E8),
                              ),
                              label: const Text(
                                'Car Driving Mode',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: (_preference == 'car' || _preference == 'car driving mode')
                                    ? const Color(0xFF1A73E8)
                                    : const Color(0xFFE8F0FE),
                                foregroundColor: (_preference == 'car' || _preference == 'car driving mode')
                                    ? Colors.white
                                    : const Color(0xFF1A73E8),
                                side: BorderSide(
                                  color: const Color(0xFF1A73E8),
                                  width: (_preference == 'car' || _preference == 'car driving mode') ? 1.5 : 1.0,
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                elevation: (_preference == 'car' || _preference == 'car driving mode') ? 3 : 0,
                              ),
                              onPressed: () {
                                setState(() => _preference = 'car');
                                _searchRoutes();
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: Icon(
                                Icons.two_wheeler,
                                size: 18,
                                color: (_preference == 'two_wheeler' || _preference == 'two wheeler mode') ? Colors.white : const Color(0xFF00897B),
                              ),
                              label: const Text(
                                'Two Wheeler Mode',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: (_preference == 'two_wheeler' || _preference == 'two wheeler mode')
                                    ? const Color(0xFF00897B)
                                    : const Color(0xFFE0F2F1),
                                foregroundColor: (_preference == 'two_wheeler' || _preference == 'two wheeler mode')
                                    ? Colors.white
                                    : const Color(0xFF00897B),
                                side: BorderSide(
                                  color: const Color(0xFF00897B),
                                  width: (_preference == 'two_wheeler' || _preference == 'two wheeler mode') ? 1.5 : 1.0,
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                elevation: (_preference == 'two_wheeler' || _preference == 'two wheeler mode') ? 3 : 0,
                              ),
                              onPressed: () {
                                setState(() => _preference = 'two_wheeler');
                                _searchRoutes();
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ChoiceChip(
                              avatar: const Icon(Icons.bolt, size: 14),
                              label: const Text('fastest'),
                              selected: _preference == 'fastest',
                              onSelected: (_) {
                                setState(() => _preference = 'fastest');
                                _searchRoutes();
                              },
                            ),
                            const SizedBox(width: 6),
                            ChoiceChip(
                              avatar: const Icon(Icons.savings_outlined, size: 14),
                              label: const Text('cheapest'),
                              selected: _preference == 'cheapest',
                              onSelected: (_) {
                                setState(() => _preference = 'cheapest');
                                _searchRoutes();
                              },
                            ),
                            const SizedBox(width: 6),
                            ChoiceChip(
                              avatar: const Icon(Icons.route_outlined, size: 14),
                              label: const Text('longest'),
                              selected: _preference == 'longest',
                              onSelected: (_) {
                                setState(() => _preference = 'longest');
                                _searchRoutes();
                              },
                            ),
                            const SizedBox(width: 6),
                            ChoiceChip(
                              avatar: const Icon(Icons.directions_walk, size: 14),
                              label: const Text('walk'),
                              selected: _preference == 'walk' || _preference == 'walking',
                              onSelected: (_) {
                                setState(() => _preference = 'walk');
                                _searchRoutes();
                              },
                            ),
                            const SizedBox(width: 6),
                            ChoiceChip(
                              avatar: const Icon(Icons.train, size: 14),
                              label: const Text('train'),
                              selected: _preference == 'train' || _preference == 'trains',
                              onSelected: (_) {
                                setState(() => _preference = 'train');
                                _searchRoutes();
                              },
                            ),
                            const SizedBox(width: 6),
                            ChoiceChip(
                              avatar: const Icon(Icons.directions_bus, size: 14),
                              label: const Text('bus'),
                              selected: _preference == 'bus' || _preference == 'buses',
                              onSelected: (_) {
                                setState(() => _preference = 'bus');
                                _searchRoutes();
                              },
                            ),
                            const SizedBox(width: 6),
                            ChoiceChip(
                              avatar: const Icon(Icons.directions_car, size: 14),
                              label: const Text('car driving mode'),
                              selected: _preference == 'car' || _preference == 'car driving mode',
                              onSelected: (_) {
                                setState(() => _preference = 'car');
                                _searchRoutes();
                              },
                            ),
                            const SizedBox(width: 6),
                            ChoiceChip(
                              avatar: const Icon(Icons.two_wheeler, size: 14),
                              label: const Text('two wheeler mode'),
                              selected: _preference == 'two_wheeler' || _preference == 'two wheeler mode',
                              onSelected: (_) {
                                setState(() => _preference = 'two_wheeler');
                                _searchRoutes();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Route Suggestions List Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    (_preference == 'car' || _preference == 'car driving mode')
                        ? 'Car Driving Route (${displayRoutes.length})'
                        : ((_preference == 'two_wheeler' || _preference == 'two wheeler mode')
                            ? 'Two Wheeler Route (${displayRoutes.length})'
                            : 'Journey Suggestions (${displayRoutes.length})'),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.map, size: 16, color: Color(0xFF1565C0)),
                    label: const Text('Live Map', style: TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.bold, fontSize: 12)),
                    onPressed: () {
                      final s = _sourceCtrl.text.trim().isNotEmpty ? _sourceCtrl.text.trim() : _source;
                      final d = _destCtrl.text.trim().isNotEmpty ? _destCtrl.text.trim() : _destination;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LiveTrackingScreen(
                            initialSource: s,
                            initialDestination: d,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Route Cards List
            if (_isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: Color(0xFF1565C0))))
            else ...[
              if (_preference == 'car' || _preference == 'car driving mode')
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F0FE),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF1A73E8)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.directions_car, color: Color(0xFF1A73E8), size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Car Driving Mode • Best Highway & City Route via OpenStreetMap',
                          style: TextStyle(fontSize: 12, color: Color(0xFF1A73E8), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                )
              else if (_preference == 'two_wheeler' || _preference == 'two wheeler mode')
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF00897B)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.two_wheeler, color: Color(0xFF00897B), size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Two Wheeler Mode • Fastest Agile Bike Route via OpenStreetMap',
                          style: TextStyle(fontSize: 12, color: Color(0xFF00897B), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                )
              else if (_journeyPlan != null && _journeyPlan!['has_train_available'] == true)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.deepOrange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.route, color: Colors.deepOrange.shade800, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Trains (${_journeyPlan!['trains_count'] ?? 0}), Buses (${_journeyPlan!['buses_count'] ?? 0}) & Walk • Sorted by Timings',
                          style: TextStyle(fontSize: 12, color: Colors.deepOrange.shade900, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                )
              else if (_journeyPlan != null && _journeyPlan!['has_train_available'] == false)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.directions_bus, color: Color(0xFF1565C0), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Inland Sector (No direct railway) • Showing Bus & Walk Timings below',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF0D47A1), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_journeyPlan != null && _journeyPlan!['has_train_available'] == true)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.table_chart, color: Colors.white, size: 16),
                      label: const Text('OPEN TRAIN SCHEDULE & TIMETABLE BOARD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange.shade800,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TrainScheduleScreen(
                              initialFrom: _source,
                              initialTo: _destination,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              if (_journeyPlan != null && _journeyPlan!['rail_fallback_notice'] != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.shade400),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFFE65100), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _journeyPlan!['rail_fallback_notice'],
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFE65100)),
                        ),
                      ),
                    ],
                  ),
                ),
              if (displayRoutes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    children: displayRoutes.map((r) => _buildCityMapperCard(r)).toList(),
                  ),
                )
              else if (_journeyPlan != null && _journeyPlan!['routes'] != null && (_journeyPlan!['routes'] as List).isEmpty)
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.search_off, size: 48, color: Colors.grey),
                      const SizedBox(height: 10),
                      Text(
                        'No direct routes found for "$_preference" between $_source and $_destination',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.restart_alt, size: 16),
                        label: const Text('Show All Transit Modes (Best)'),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0), foregroundColor: Colors.white),
                        onPressed: () {
                          setState(() => _preference = 'best');
                          _searchRoutes();
                        },
                      ),
                    ],
                  ),
                ),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.mic, color: Colors.amberAccent, size: 22),
        label: const Text('Voice AI Search (LLM)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        tooltip: 'Voice Search with LLM TransitGPT',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ChatbotScreen(autoStartVoice: false),
            ),
          );
        },
      ),
    );
  }

  // Authentic YathraKerala Style Route Card
  Widget _buildCityMapperCard(dynamic route) {
    try {
      final modeType = route['mode_type'] ?? 'BUS';
    final isTrain = modeType == 'TRAIN';
    final isWalk = modeType == 'WALK';
    final isTaxi = modeType == 'TAXI';
    final isCar = modeType == 'CAR';
    final isTwoWheeler = modeType == 'TWO_WHEELER';

    Color themeColor = const Color(0xFF1565C0);
    IconData modeIcon = Icons.directions_bus;
    if (isTrain) {
      themeColor = Colors.deepOrange;
      modeIcon = Icons.train;
    } else if (isWalk) {
      themeColor = Colors.teal;
      modeIcon = Icons.directions_walk;
    } else if (isTaxi) {
      themeColor = Colors.amber.shade900;
      final subType = route['sub_type']?.toString().toLowerCase() ?? '';
      modeIcon = subType.contains('auto') ? Icons.electric_rickshaw : Icons.local_taxi;
    } else if (isCar) {
      themeColor = const Color(0xFF1A73E8);
      modeIcon = Icons.directions_car;
    } else if (isTwoWheeler) {
      themeColor = const Color(0xFF00897B);
      modeIcon = Icons.two_wheeler;
    }

    final countdownMins = route['departure_countdown_mins'] ?? 0;
    final expDeparture = route['expected_departure'] ?? 'Now';
    final expArrival = route['expected_arrival'] ?? '';
    final totalTime = route['total_time_mins'] ?? 0;
    final totalFare = route['total_fare'] ?? '₹0';
    final viaPreview = route['via_preview'] ?? '';
    final intermediateStops = route['intermediate_stops'] as List?;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          if (intermediateStops != null && intermediateStops.isNotEmpty) {
            _showStopSequenceModal(intermediateStops, route['title']);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Departure Status Pill & Total Fare
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Countdown badge (YathraKerala status pill)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isWalk ? Colors.teal.shade50 : (isTaxi ? Colors.amber.shade50 : (countdownMins <= 5 ? Colors.green.shade50 : Colors.blue.shade50)),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isWalk ? Colors.teal.shade300 : (isTaxi ? Colors.amber.shade700 : (countdownMins <= 5 ? Colors.green.shade600 : Colors.blue.shade400)),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isWalk ? Colors.teal : (isTaxi ? Colors.amber.shade900 : (countdownMins <= 5 ? Colors.green : Colors.blue)),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isWalk ? 'Walk Directly • Free' : (isCar ? 'Drive Directly • On Demand' : (isTwoWheeler ? 'Bike Ride • Fastest Direct' : (isTaxi ? 'ON DEMAND • ETA $countdownMins MINS' : 'IN $countdownMins MINS • $expDeparture'))),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isWalk ? Colors.teal.shade900 : (isTaxi ? Colors.amber.shade900 : (countdownMins <= 5 ? Colors.green.shade900 : Colors.blue.shade900)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Fare Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$totalFare',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: isWalk ? Colors.teal.shade800 : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Bus / Train / Walk Mode Identification
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: themeColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(modeIcon, color: themeColor, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          route['title'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            Text(
                              'Arrives at $expArrival ($totalTime mins)',
                              style: TextStyle(color: Colors.grey.shade700, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                            if (route['transfers'] != null && route['transfers'] == 0) ...[
                              const Text(' • Direct', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Train Route & Station Timings (Source to Destination)
              if (isTrain) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (route['train_route_label'] != null && (route['train_route_label'] as String).isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(Icons.alt_route, size: 14, color: Colors.deepOrange),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Train Route: ${route['train_route_label']}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  route['source'] ?? _source,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Dep: $expDeparture (${route['departure_pf'] ?? 'PF 1'})',
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade800, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.deepOrange.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.arrow_forward, size: 12, color: Colors.deepOrange),
                                const SizedBox(width: 4),
                                Text(
                                  '$totalTime min',
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  route['destination'] ?? _destination,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Arr: $expArrival (${route['arrival_pf'] ?? 'PF 1'})',
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade800, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              // Intermediate Stops Preview pill (Clickable to see all stops)
              if (viaPreview.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.alt_route, size: 14, color: Color(0xFF1565C0)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          viaPreview,
                          style: const TextStyle(fontSize: 11, color: Colors.black87, fontStyle: FontStyle.italic),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Text(
                        'View Stops',
                        style: TextStyle(fontSize: 10, color: Color(0xFF1565C0), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],

              const Divider(height: 20),

              // Visual Step Timeline (YathraKerala flow)
              ...?((route['legs'] as List?)?.map((leg) {
                final legMode = leg['mode'];
                IconData legIcon = Icons.directions_walk;
                Color legColor = Colors.grey.shade700;
                if (legMode == 'BUS') {
                  legIcon = Icons.directions_bus;
                  legColor = const Color(0xFF1565C0);
                } else if (legMode == 'TRAIN') {
                  legIcon = Icons.train;
                  legColor = Colors.deepOrange;
                } else if (legMode == 'TAXI') {
                  legIcon = Icons.local_taxi;
                  legColor = Colors.amber.shade900;
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(legIcon, size: 16, color: legColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          leg['instruction'] ?? '',
                          style: const TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                      ),
                      if (leg['mode'] == 'BUS' || leg['is_live_trackable'] == true) ...[
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () {
                            _handleBusTracking(route, vehicleId: leg['vehicle_id']);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.green),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.gps_fixed, size: 10, color: Colors.green),
                                SizedBox(width: 3),
                                Text('Live GPS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList()),

              // Google Maps Style Driving & Two-Wheeler Action Button
              if (modeType == 'CAR' || modeType == 'TWO_WHEELER') ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton.icon(
                    icon: Icon(
                      modeType == 'CAR' ? Icons.directions_car : Icons.two_wheeler,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: Text(
                      modeType == 'CAR' ? 'VIEW BEST CAR ROUTE ON OPENSTREETMAP' : 'VIEW BEST BIKE ROUTE ON OPENSTREETMAP',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white, letterSpacing: 0.3),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: modeType == 'CAR' ? const Color(0xFF1A73E8) : const Color(0xFF00897B),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      _openGoogleMapsStyleOsmNavigation(route);
                    },
                  ),
                ),
              ],

              // Prominent Action Button for Live GPS Bus Tracking
              if (modeType == 'BUS') ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.gps_fixed, size: 16, color: Color(0xFF1565C0)),
                    label: Text(
                      'Track ${route['bus_name'] ?? 'Bus'} Live on OpenStreetMap',
                      style: const TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF1565C0), width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      backgroundColor: Colors.green.shade50.withOpacity(0.3),
                    ),
                    onPressed: () {
                      _handleBusTracking(route);
                    },
                  ),
                ),
              ],

              // Train Specific Timing Banner
              if (modeType == 'TRAIN') ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.deepOrange.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.schedule, size: 16, color: Colors.deepOrange),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Departs: $expDeparture | Arrives: $expArrival | Fare: $totalFare',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.deepOrange.shade900),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade700,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('ON TIME', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      if (route['api_source'] != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.check_circle_outline, size: 12, color: Colors.teal),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${route['api_source']} • Indian Railways Corridor',
                                style: const TextStyle(fontSize: 10, color: Colors.teal, fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 32,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.satellite_alt, size: 13, color: Colors.white),
                                label: const Text('Live Track', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1565C0),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  padding: EdgeInsets.zero,
                                ),
                                onPressed: () {
                                  final tNo = (route['train_no'] ?? route['train_number'] ?? '12081').toString();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TrainLiveMapScreen(trainNo: tNo),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: SizedBox(
                              height: 32,
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.table_chart_outlined, size: 13, color: Colors.deepOrange),
                                label: const Text('Timetable', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.deepOrange),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  padding: EdgeInsets.zero,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TrainScheduleScreen(
                                        initialFrom: _source,
                                        initialTo: _destination,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              // Taxi / Cab Specific Action Banner
              if (isTaxi) ...[
                const SizedBox(height: 10),
                Builder(
                  builder: (context) {
                    final isAuto = route['is_auto'] == true || route['sub_type']?.toString().toLowerCase().contains('auto') == true;
                    final distKm = route['distance_km'] ?? '0';
                    final tripMins = route['trip_duration_mins'] ?? route['total_time_mins'] ?? 0;
                    final fare = route['total_fare'] ?? '₹0';
                    final serviceProvider = route['service_provider']?.toString() ?? '';

                    if (isAuto) {
                      // ========================================================
                      // AUTORICKSHAW: Price, Kilometers & Time ONLY (NO BOOKING)
                      // ========================================================
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFDE7), // soft auto yellow
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.shade400),
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
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.shade700,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.electric_rickshaw, size: 16, color: Colors.white),
                                    ),
                                    const SizedBox(width: 8),
                                    const Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Auto Rickshaw', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFE65100))),
                                        Text('Official Govt. MVD Meter', style: TextStyle(fontSize: 10, color: Colors.black54)),
                                      ],
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.amber.shade600),
                                  ),
                                  child: const Text('METER TARIFF', style: TextStyle(color: Color(0xFFE65100), fontSize: 9, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // 3-Column Metric Display: Price | Kilometers | Time Taken
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.amber.shade200),
                                    ),
                                    child: Column(
                                      children: [
                                        const Text('PRICE / FARE', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 2),
                                        Text(fare, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.amber.shade200),
                                    ),
                                    child: Column(
                                      children: [
                                        const Text('DISTANCE', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 2),
                                        Text('$distKm km', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.amber.shade200),
                                    ),
                                    child: Column(
                                      children: [
                                        const Text('TIME TAKEN', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 2),
                                        Text('~$tripMins mins', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Explanatory tariff notice (No booking button!)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade100.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.info_outline, size: 14, color: Color(0xFFE65100)),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      '${route['fare_rate_summary'] ?? '₹30 min fare (1.5 km) + ₹15/km'}. Direct hail at nearest auto stand or en-route (no booking needed).',
                                      style: TextStyle(fontSize: 10.5, color: Colors.brown.shade800),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // ========================================================
                    // CAB SERVICES: Real Data & Direct Branded Booking Button
                    // ========================================================
                    final isKeralaSavaari = serviceProvider == 'Kerala Savaari' || route['title']?.toString().contains('Kerala Savaari') == true;
                    final isUber = serviceProvider == 'Uber' || route['title']?.toString().contains('Uber') == true;
                    final isOla = serviceProvider == 'Ola' || route['title']?.toString().contains('Ola') == true;

                    Color brandColor = const Color(0xFF1565C0);
                    Color cardBg = const Color(0xFFF5F9FF);
                    String buttonLabel = 'Book Cab ($fare)';
                    IconData buttonIcon = Icons.local_taxi;

                    if (isKeralaSavaari) {
                      brandColor = const Color(0xFF005B41); // Kerala emerald green
                      cardBg = const Color(0xFFE0F2F1);
                      buttonLabel = 'Book on Kerala Savaari ($fare)';
                      buttonIcon = Icons.verified_user;
                    } else if (isUber) {
                      brandColor = const Color(0xFF1C1C1C); // Uber black
                      cardBg = const Color(0xFFF5F5F5);
                      buttonLabel = 'Book on Uber ($fare)';
                      buttonIcon = Icons.directions_car;
                    } else if (isOla) {
                      brandColor = const Color(0xFF1C8D38); // Ola green
                      cardBg = const Color(0xFFE8F5E9);
                      buttonLabel = 'Book on Ola Cabs ($fare)';
                      buttonIcon = Icons.local_taxi;
                    }

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: brandColor.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: brandColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(buttonIcon, size: 16, color: Colors.white),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  route['title'] ?? '${route['sub_type'] ?? 'Cab'}',
                                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: brandColor),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: brandColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isKeralaSavaari ? 'GOVT CAB' : 'ON DEMAND',
                                  style: TextStyle(color: brandColor, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // 3-Column Metrics: Price | Distance | Time
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: brandColor.withOpacity(0.15)),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text('EST. FARE', style: TextStyle(fontSize: 8.5, color: Colors.grey, fontWeight: FontWeight.bold)),
                                      Text(fare, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: brandColor)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: brandColor.withOpacity(0.15)),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text('DISTANCE', style: TextStyle(fontSize: 8.5, color: Colors.grey, fontWeight: FontWeight.bold)),
                                      Text('$distKm km', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: brandColor.withOpacity(0.15)),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text('DURATION', style: TextStyle(fontSize: 8.5, color: Colors.grey, fontWeight: FontWeight.bold)),
                                      Text('~$tripMins mins', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          Text(
                            route['fare_rate_summary'] ?? 'Door-to-door direct ride',
                            style: TextStyle(fontSize: 10.5, color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 8),

                          // Branded Cab Booking Button
                          SizedBox(
                            width: double.infinity,
                            height: 38,
                            child: ElevatedButton.icon(
                              icon: Icon(buttonIcon, size: 16, color: Colors.white),
                              label: Text(
                                buttonLabel,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: brandColor,
                                foregroundColor: Colors.white,
                                elevation: 1,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () async {
                                final pickupEncoded = Uri.encodeComponent(_source);
                                final dropEncoded = Uri.encodeComponent(_destination);

                                if (isKeralaSavaari) {
                                  final uri = Uri.parse('https://keralasavaari.kerala.gov.in/');
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                } else if (isUber) {
                                  final uberDeep = 'uber://?action=setPickup&pickup[formatted_address]=$pickupEncoded&dropoff[formatted_address]=$dropEncoded';
                                  final uberWeb = 'https://m.uber.com/looking?pickup=$pickupEncoded&dropoff=$dropEncoded';
                                  if (await canLaunchUrl(Uri.parse(uberDeep))) {
                                    await launchUrl(Uri.parse(uberDeep), mode: LaunchMode.externalApplication);
                                  } else {
                                    await launchUrl(Uri.parse(uberWeb), mode: LaunchMode.externalApplication);
                                  }
                                } else if (isOla) {
                                  final olaDeep = 'olacabs://app/launch?lat=0&lng=0&drop_lat=0&drop_lng=0&category=auto&pickup_name=$pickupEncoded&drop_name=$dropEncoded';
                                  final olaWeb = 'https://book.olacabs.com/?pickup=$pickupEncoded&drop=$dropEncoded';
                                  if (await canLaunchUrl(Uri.parse(olaDeep))) {
                                    await launchUrl(Uri.parse(olaDeep), mode: LaunchMode.externalApplication);
                                  } else {
                                    await launchUrl(Uri.parse(olaWeb), mode: LaunchMode.externalApplication);
                                  }
                                } else {
                                  _showCabBookingDialog(route);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
    } catch (e, stack) {
      debugPrint('Error building route card: $e\n$stack');
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(route['title'] ?? 'Route Option', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 4),
              Text('${route['total_fare'] ?? '₹0'} • ${route['total_time_mins'] ?? 0} mins'),
            ],
          ),
        ),
      );
    }
  }

  void _openGoogleMapsStyleOsmNavigation(dynamic route) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LiveTrackingScreen(
          initialSource: _source,
          initialDestination: _destination,
          initialMode: route['mode_type'],
          initialRoute: route,
        ),
      ),
    );
  }

  Future<void> _handleBusTracking(dynamic route, {String? vehicleId}) async {
    final busName = (route['bus_name'] ?? 'Bus').toString().trim();
    final vId = (vehicleId ?? route['bus_number'] ?? (route['legs'] as List?)?.firstWhere((l) => l['vehicle_id'] != null, orElse: () => {})['vehicle_id'] ?? busName)?.toString().trim();

    if (vId == null || vId.isEmpty) {
      _showTrackingNotPossibleDialog(busName);
      return;
    }

    // Show quick progress while checking backend
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1565C0)),
                ),
                SizedBox(width: 14),
                Text('Connecting to bus GPS...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
        ),
      ),
    );

    Map<String, dynamic>? trackRes;
    try {
      trackRes = await ApiService.fetchVehicleTracking(vId);
      if ((trackRes == null || trackRes['driver_registered'] != true) && busName.isNotEmpty && busName != vId) {
        final fallback = await ApiService.fetchVehicleTracking(busName);
        if (fallback != null && fallback['driver_registered'] == true) {
          trackRes = fallback;
        }
      }
    } catch (_) {}

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // dismiss loading dialog

    final bool isDriverRegistered = trackRes?['driver_registered'] == true;
    final bool isLiveActive = trackRes?['is_active'] == true;
    final bool hasValidGps = trackRes != null && trackRes['lat'] != null && trackRes['lng'] != null && trackRes['lat'] is num && trackRes['lng'] is num;

    // IF DRIVER IS NOT REGISTERED OR NOT BROADCASTING LIVE: Show pop-up message!
    if (!isDriverRegistered || !isLiveActive || !hasValidGps || trackRes?['status'] == 'not_registered') {
      _showTrackingNotPossibleDialog(busName, vId: vId, isOffline: isDriverRegistered && !isLiveActive);
      return;
    }

    // DRIVER IS REGISTERED: Open OpenStreetMap showing the EXACT live location!
    final lat = (trackRes['lat'] as num).toDouble();
    final lng = (trackRes['lng'] as num).toDouble();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LiveTrackingScreen(
          initialVehicleId: vId,
          exactBusLocation: LatLng(lat, lng),
          selectedVehicleData: trackRes,
          initialSource: _source,
          initialDestination: _destination,
          isTrackBusMode: true, // Specifically opened via Track Bus button!
        ),
      ),
    );
  }

  void _showTrackingNotPossibleDialog(String busName, {String? vId, bool isOffline = false}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: const Icon(Icons.location_off, color: Colors.deepOrange, size: 22),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Tracking Not Possible',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tracking is not possible for $busName${vId != null ? " ($vId)" : ""}.',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              isOffline
                  ? 'The driver has registered for this bus but is currently offline. Real-time GPS location is only available when the driver turns ON location broadcast.'
                  : 'The driver for this bus has not registered on YathraKerala. Real-time GPS tracking on OpenStreetMap is only possible when a registered bus driver is transmitting live location.',
              style: const TextStyle(fontSize: 12, color: Colors.black54, height: 1.4),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Modal for Cab/Taxi booking — opens Ola / Uber / Rapido
  void _showCabBookingDialog(dynamic route) {
    final subType = route['sub_type'] ?? 'Cab';
    final fare = route['total_fare'] ?? '₹0';
    final isAuto = subType.toString().toLowerCase().contains('auto');
    final pickupEncoded = Uri.encodeComponent(_source);
    final dropEncoded = Uri.encodeComponent(_destination);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.72,
          maxChildSize: 0.92,
          minChildSize: 0.4,
          builder: (_, scrollCtrl) {
            return SingleChildScrollView(
              controller: scrollCtrl,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isAuto ? Icons.electric_rickshaw : Icons.local_taxi,
                          color: Colors.amber.shade900,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Book ${route['title'] ?? subType}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                            Text(
                              'Estimated: $fare • Direct ride',
                              style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  // Trip details card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.circle, color: Colors.green, size: 10),
                            const SizedBox(width: 8),
                            const Text('Pickup: ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Expanded(child: Text(_source.isEmpty ? 'Not set' : _source, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.circle, color: Colors.red, size: 10),
                            const SizedBox(width: 8),
                            const Text('Drop: ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Expanded(child: Text(_destination.isEmpty ? 'Not set' : _destination, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Text('Choose a Cab Service', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 10),

                                    // ─── Kerala Savaari (Official Kerala Govt Cab/Auto) ───
                  _buildCabServiceCard(
                    ctx: ctx,
                    name: 'Kerala Savaari',
                    subtitle: 'Govt. of Kerala Official Online Taxi & Auto Service',
                    icon: Icons.verified_user,
                    color: const Color(0xFF005B41), // Kerala emerald green
                    bgColor: const Color(0xFFE0F2F1),
                    badgeText: 'KERALA GOVT',
                    badgeColor: const Color(0xFF005B41),
                    onTap: () async {
                      Navigator.pop(ctx);
                      final kKeralaWeb = 'https://keralasavaari.kerala.gov.in/';
                      await launchUrl(Uri.parse(kKeralaWeb), mode: LaunchMode.externalApplication);
                    },
                  ),

                  const SizedBox(height: 10),
                  // ─── Ola Cabs ───────────────────────────
                  _buildCabServiceCard(
                    ctx: ctx,
                    name: 'Ola Cabs',
                    subtitle: 'India\'s largest ride-hailing service',
                    icon: Icons.local_taxi,
                    color: const Color(0xFF1C8D38), // Ola green
                    bgColor: const Color(0xFFE8F5E9),
                    badgeText: 'POPULAR',
                    badgeColor: Colors.green.shade700,
                    onTap: () async {
                      Navigator.pop(ctx);
                      // Try Ola deep link first, fallback to website
                      final olaDeepLink = 'olacabs://app/launch?lat=0&lng=0&drop_lat=0&drop_lng=0&category=auto&pickup_name=$pickupEncoded&drop_name=$dropEncoded';
                      final olaWeb = 'https://book.olacabs.com/?pickup=$pickupEncoded&drop=$dropEncoded';
                      if (await canLaunchUrl(Uri.parse(olaDeepLink))) {
                        await launchUrl(Uri.parse(olaDeepLink), mode: LaunchMode.externalApplication);
                      } else {
                        await launchUrl(Uri.parse(olaWeb), mode: LaunchMode.externalApplication);
                      }
                    },
                  ),

                  const SizedBox(height: 10),

                  // ─── Uber ───────────────────────────
                  _buildCabServiceCard(
                    ctx: ctx,
                    name: 'Uber',
                    subtitle: 'Reliable rides at every price point',
                    icon: Icons.directions_car,
                    color: const Color(0xFF000000), // Uber black
                    bgColor: const Color(0xFFF5F5F5),
                    badgeText: 'GLOBAL',
                    badgeColor: Colors.grey.shade800,
                    onTap: () async {
                      Navigator.pop(ctx);
                      final uberDeepLink = 'uber://?action=setPickup&pickup[formatted_address]=$pickupEncoded&dropoff[formatted_address]=$dropEncoded';
                      final uberWeb = 'https://m.uber.com/looking?pickup=$pickupEncoded&dropoff=$dropEncoded';
                      if (await canLaunchUrl(Uri.parse(uberDeepLink))) {
                        await launchUrl(Uri.parse(uberDeepLink), mode: LaunchMode.externalApplication);
                      } else {
                        await launchUrl(Uri.parse(uberWeb), mode: LaunchMode.externalApplication);
                      }
                    },
                  ),

                  const SizedBox(height: 10),

                  // ─── Rapido ───────────────────────────
                  _buildCabServiceCard(
                    ctx: ctx,
                    name: 'Rapido',
                    subtitle: 'Bike taxi & auto at lowest fares',
                    icon: Icons.two_wheeler,
                    color: const Color(0xFFFFCC00), // Rapido yellow
                    bgColor: const Color(0xFFFFF9E6),
                    badgeText: 'BUDGET',
                    badgeColor: Colors.amber.shade800,
                    onTap: () async {
                      Navigator.pop(ctx);
                      final rapidoWeb = 'https://www.rapido.bike/';
                      await launchUrl(Uri.parse(rapidoWeb), mode: LaunchMode.externalApplication);
                    },
                  ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Local dispatch option
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.contact_phone, color: Color(0xFF1565C0), size: 18),
                            SizedBox(width: 8),
                            Text('Local Taxi / Auto Stand', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1565C0))),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '📞 +91 94470 12345  •  📞 +91 98460 54321',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1565C0)),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.call, size: 16),
                            label: const Text('Call Local Dispatch', style: TextStyle(fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF1565C0),
                              side: const BorderSide(color: Color(0xFF1565C0)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () async {
                              Navigator.pop(ctx);
                              final telUri = Uri.parse('tel:+919447012345');
                              if (await canLaunchUrl(telUri)) {
                                await launchUrl(telUri);
                              } else {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Dialing Kerala Cab/Auto Dispatch: +91 94470 12345...'),
                                      backgroundColor: Colors.blue,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Reusable cab service card widget
  Widget _buildCabServiceCard({
    required BuildContext ctx,
    required String name,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required String badgeText,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(badgeText, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: badgeColor)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: color.withOpacity(0.6)),
          ],
        ),
      ),
    );
  }

  // Modal to show intermediate stops timeline
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
