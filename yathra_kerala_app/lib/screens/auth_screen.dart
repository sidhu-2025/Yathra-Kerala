import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'driver_screen.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  final Function(Map<String, dynamic> user)? onRoleDetermined;
  final String initialRole; // 'user' or 'driver'
  final bool isRoot;

  const AuthScreen({
    super.key,
    this.onLoginSuccess,
    this.onRoleDetermined,
    this.initialRole = 'user',
    this.isRoot = false,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSignUp = false;
  
  // Passenger Form Controllers
  final _userUsernameCtrl = TextEditingController(text: 'user1');
  final _userPasswordCtrl = TextEditingController(text: 'pass123');
  final _userNameCtrl = TextEditingController();
  final _userEmailCtrl = TextEditingController();
  final _userPhoneCtrl = TextEditingController();

  // Driver Form Controllers
  final _driverUsernameCtrl = TextEditingController(text: 'driver1');
  final _driverPasswordCtrl = TextEditingController(text: 'driver123');
  final _driverNameCtrl = TextEditingController();
  final _driverEmailCtrl = TextEditingController();
  final _driverPhoneCtrl = TextEditingController();
  final _driverVehicleNoCtrl = TextEditingController(text: 'KL-13-AB-8429');

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialRole == 'driver' ? 1 : 0,
    );
    _tabController.addListener(() {
      setState(() {
        _isSignUp = false; // Reset to sign-in on tab change
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _userUsernameCtrl.dispose();
    _userPasswordCtrl.dispose();
    _userNameCtrl.dispose();
    _userEmailCtrl.dispose();
    _userPhoneCtrl.dispose();
    _driverUsernameCtrl.dispose();
    _driverPasswordCtrl.dispose();
    _driverNameCtrl.dispose();
    _driverEmailCtrl.dispose();
    _driverPhoneCtrl.dispose();
    _driverVehicleNoCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleUserAuth() async {
    final username = _userUsernameCtrl.text.trim();
    final password = _userPasswordCtrl.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showSnack('Please enter username and password', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    if (!_isSignUp) {
      // User Sign In
      final res = await ApiService.login(username: username, password: password);
      setState(() => _isLoading = false);

      if (res != null && res['status'] == 'success') {
        final userData = res['user'];
        _showSnack('Welcome, ${userData['name']}!');
        if (widget.onRoleDetermined != null) {
          try {
            widget.onRoleDetermined!(userData);
          } catch (_) {}
        }
        if (widget.onLoginSuccess != null) {
          try {
            widget.onLoginSuccess!();
          } catch (_) {}
        }
        if (mounted) {
          if (userData['role'] == 'driver') {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => DriverScreen(driverUser: userData),
              ),
              (route) => false,
            );
          } else {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => HomeScreen(currentUser: userData),
              ),
              (route) => false,
            );
          }
        }
      } else {
        _showSnack('Invalid passenger credentials. Please check your username and password.', isError: true);
      }
    } else {
      // User Sign Up
      final name = _userNameCtrl.text.trim().isEmpty ? username : _userNameCtrl.text.trim();
      final res = await ApiService.register(
        username: username,
        password: password,
        name: name,
        email: _userEmailCtrl.text.trim().isEmpty ? '$username@gmail.com' : _userEmailCtrl.text.trim(),
        phone: _userPhoneCtrl.text.trim().isEmpty ? '9847123456' : _userPhoneCtrl.text.trim(),
        role: 'user',
      );
      setState(() => _isLoading = false);

      if (res != null && res['status'] == 'success') {
        _showSnack('Welcome, $name! Opening YathraKerala...');
        final loginRes = await ApiService.login(username: username, password: password);
        final userData = (loginRes != null && loginRes['status'] == 'success')
            ? loginRes['user']
            : {
                'username': username,
                'name': name,
                'role': 'user',
                'email': _userEmailCtrl.text.trim().isEmpty ? '$username@gmail.com' : _userEmailCtrl.text.trim(),
                'phone': _userPhoneCtrl.text.trim().isEmpty ? '9847123456' : _userPhoneCtrl.text.trim(),
                'vehicle_no': 'KL-13-AB-8429',
              };
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => HomeScreen(currentUser: userData),
            ),
            (route) => false,
          );
        }
      } else {
        _showSnack('Registration failed. Username may already exist.', isError: true);
      }
    }
  }

  Future<void> _handleDriverAuth() async {
    final username = _driverUsernameCtrl.text.trim();
    final password = _driverPasswordCtrl.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showSnack('Please enter driver username and password', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    if (!_isSignUp) {
      // Driver Sign In
      final res = await ApiService.login(username: username, password: password);
      setState(() => _isLoading = false);

      if (res != null && res['status'] == 'success') {
        final userData = res['user'];
        if (widget.onRoleDetermined != null) {
          try {
            widget.onRoleDetermined!(userData);
          } catch (_) {}
        }
        if (widget.onLoginSuccess != null) {
          try {
            widget.onLoginSuccess!();
          } catch (_) {}
        }
        if (mounted) {
          if (userData['role'] == 'driver') {
            _showSnack('Driver login verified: ${userData['name']}');
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => DriverScreen(driverUser: userData),
              ),
              (route) => false,
            );
          } else {
            _showSnack('Passenger account detected. Opening YathraKerala...');
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => HomeScreen(currentUser: userData),
              ),
              (route) => false,
            );
          }
        }
      } else {
        _showSnack('Invalid driver credentials. Please check your username and password.', isError: true);
      }
    } else {
      // Driver Sign Up - Vehicle number is strictly required
      final vNo = _driverVehicleNoCtrl.text.trim().toUpperCase();
      if (vNo.isEmpty) {
        setState(() => _isLoading = false);
        _showSnack('Vehicle / Bus number is required for driver sign up! (e.g. KL-13-AB-8429)', isError: true);
        return;
      }
      final res = await ApiService.register(
        username: username,
        password: password,
        name: _driverNameCtrl.text.trim().isEmpty ? username : _driverNameCtrl.text.trim(),
        email: _driverEmailCtrl.text.trim().isEmpty ? '$username@keralatransit.in' : _driverEmailCtrl.text.trim(),
        phone: _driverPhoneCtrl.text.trim().isEmpty ? '9447112233' : _driverPhoneCtrl.text.trim(),
        role: 'driver',
        vehicleNo: vNo,
      );
      setState(() => _isLoading = false);

      if (res != null && res['status'] == 'success') {
        _showSnack('Bus Driver ($vNo) registered! Please sign in.');
        setState(() => _isSignUp = false);
      } else {
        _showSnack('Driver registration failed. Username may exist.', isError: true);
      }
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade700 : const Color(0xFF1565C0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1565C0);
    const deepBlue = Color(0xFF0D47A1);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8), // Soft blue-tinted clean background
      appBar: widget.isRoot
          ? null
          : AppBar(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Top App Badge
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: primaryBlue.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, 6)),
                    ],
                  ),
                  child: const Icon(Icons.directions_bus_filled_rounded, size: 44, color: primaryBlue),
                ),
                const SizedBox(height: 12),
                const Text(
                  'YathraKerala',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: deepBlue, letterSpacing: -0.5),
                ),
                const Text(
                  'Kerala Transit & Intelligent Multi-Modal Platform',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 20),

                // Main Authentication Card
                Card(
                  elevation: 6,
                  color: Colors.white,
                  shadowColor: Colors.black12,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    children: [
                      // Dual Role Tab Bar (Passenger vs Driver)
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD), // Light blue container
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicatorColor: primaryBlue,
                          indicatorWeight: 3.5,
                          labelColor: deepBlue,
                          unselectedLabelColor: Colors.black54,
                          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          tabs: const [
                            Tab(icon: Icon(Icons.person), text: 'User / Passenger'),
                            Tab(icon: Icon(Icons.drive_eta), text: 'Bus Driver'),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(22),
                        child: SizedBox(
                          height: _isSignUp ? 640 : 380,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              // ── Tab 1: User / Passenger Form ────────────────────────
                              _buildAuthForm(
                                isDriver: false,
                                usernameCtrl: _userUsernameCtrl,
                                passwordCtrl: _userPasswordCtrl,
                                nameCtrl: _userNameCtrl,
                                emailCtrl: _userEmailCtrl,
                                phoneCtrl: _userPhoneCtrl,
                                onSubmit: _handleUserAuth,
                                demoHint: 'Demo User: user1 / pass123',
                              ),

                              // ── Tab 2: Bus Driver Portal Form ───────────────────────
                              _buildAuthForm(
                                isDriver: true,
                                usernameCtrl: _driverUsernameCtrl,
                                passwordCtrl: _driverPasswordCtrl,
                                nameCtrl: _driverNameCtrl,
                                emailCtrl: _driverEmailCtrl,
                                phoneCtrl: _driverPhoneCtrl,
                                vehicleCtrl: _driverVehicleNoCtrl,
                                onSubmit: _handleDriverAuth,
                                demoHint: 'Demo Driver: driver1 / driver123',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthForm({
    required bool isDriver,
    required TextEditingController usernameCtrl,
    required TextEditingController passwordCtrl,
    required TextEditingController nameCtrl,
    required TextEditingController emailCtrl,
    required TextEditingController phoneCtrl,
    TextEditingController? vehicleCtrl,
    required VoidCallback onSubmit,
    required String demoHint,
  }) {
    const primaryBlue = Color(0xFF1565C0);
    const deepBlue = Color(0xFF0D47A1);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Toggle Sign In vs Sign Up
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !_isSignUp ? primaryBlue : Colors.grey.shade100,
                    foregroundColor: !_isSignUp ? Colors.white : Colors.black87,
                    elevation: !_isSignUp ? 2 : 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => setState(() => _isSignUp = false),
                  child: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSignUp ? primaryBlue : Colors.grey.shade100,
                    foregroundColor: _isSignUp ? Colors.white : Colors.black87,
                    elevation: _isSignUp ? 2 : 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => setState(() => _isSignUp = true),
                  child: const Text('Sign Up', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Extra fields on registration
          if (_isSignUp) ...[
            if (isDriver && vehicleCtrl != null) ...[
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: vehicleCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Bus / Vehicle Number * (Mandatory)',
                    hintText: 'e.g. KL-13-AB-8429',
                    prefixIcon: Icon(Icons.directions_bus, color: primaryBlue, size: 22),
                    border: OutlineInputBorder(),
                    isDense: true,
                    helperText: 'Required: Bus plate number for live GPS tracking',
                    helperStyle: TextStyle(fontSize: 11, color: deepBlue, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: isDriver ? 'Driver Full Name *' : 'Full Name *',
                prefixIcon: const Icon(Icons.badge_outlined, color: primaryBlue, size: 20),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(
                labelText: 'Mobile Phone Number',
                prefixIcon: Icon(Icons.phone, color: primaryBlue, size: 20),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Username
          TextField(
            controller: usernameCtrl,
            decoration: InputDecoration(
              labelText: isDriver ? 'Driver ID / Username' : 'Username',
              prefixIcon: Icon(isDriver ? Icons.drive_eta : Icons.person_outline, color: primaryBlue, size: 20),
              border: const OutlineInputBorder(),
              isDense: true,
              helperText: !_isSignUp ? demoHint : null,
              helperStyle: const TextStyle(fontSize: 10, color: deepBlue, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 10),

          // Password
          TextField(
            controller: passwordCtrl,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outline, color: primaryBlue, size: 20),
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 18),

          // Action Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDriver ? deepBlue : primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
            ),
            onPressed: _isLoading ? null : onSubmit,
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(
                    !_isSignUp
                        ? (isDriver ? 'Sign In as Driver' : 'Sign In as Passenger')
                        : (isDriver ? 'Sign Up as Driver' : 'Sign Up as Passenger'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
          ),
          const SizedBox(height: 14),

          // Sign In <-> Sign Up switch prompt
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                !_isSignUp ? "Don't have an account? " : "Already have an account? ",
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              InkWell(
                onTap: () => setState(() => _isSignUp = !_isSignUp),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                  child: Text(
                    !_isSignUp ? (isDriver ? 'Sign Up as Driver' : 'Sign Up as Passenger') : 'Sign In',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryBlue),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
