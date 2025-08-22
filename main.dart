import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:web_socket_channel/io.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Charging Station App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

const String baseUrl = 'http://10.28.35.188:8000';
const String wsUrl = 'ws://10.28.35.188:8000/ws';
const String mapStyle = 'https://api.maptiler.com/maps/0198a503-0280-7e08-aae2-7725ab7ff048/style.json?key=oxXBtO4H3ygwLpihQVfP';
const LatLng defaultLocation = LatLng(11.273563, 77.607187);

const List<String> plugTypes = ['CCS', 'CHAdeMO', 'Type 2', 'Type 1', 'Tesla Supercharger', 'GB/T'];
const List<String> powerRatings = ['AC (slow)', 'DC Fast', 'DC Ultra-Fast'];
const List<String> availabilityOptions = ['Any', 'Available Only'];
const List<String> distanceOptions = ['Any', '<5km', '<10km', '<20km'];

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Charging Station',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withOpacity(0.05),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
            stops: [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header Section with Animation
                TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 800),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, double value, child) {
                    return Transform.translate(
                      offset: Offset(0, 30 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.electric_bolt,
                                size: 48,
                                color: Color(0xFF3B82F6),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              "Techno Fest 2025",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFDBEAFE),
                                  width: 1,
                                ),
                              ),
                              child: const Text(
                                "Team ID: IT208",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 56),

                // Buttons Section with Staggered Animation
                TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 1000),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, double value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      _buildAnimatedButton(
                        context: context,
                        label: 'Client',
                        icon: Icons.person_outline,
                        backgroundColor: const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        delay: 200,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ClientScreen()),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildAnimatedButton(
                        context: context,
                        label: 'Admin',
                        icon: Icons.settings_outlined,
                        backgroundColor: const Color(0xFFEA580C),
                        foregroundColor: Colors.white,
                        delay: 400,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AdminLoginScreen()),
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

  Widget _buildAnimatedButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required Color foregroundColor,
    required int delay,
    required VoidCallback onPressed,
  }) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: child,
        );
      },
      child: Container(
        width: double.infinity,
        height: 64,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            ).copyWith(
              overlayColor: WidgetStateProperty.all(
                Colors.white.withOpacity(0.1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 24, weight: 400),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AdminLoginScreen extends StatefulWidget {
  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text
        }),
      );

      if (response.statusCode == 200) {
        final token = jsonDecode(response.body)['access_token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('admin_token', token);

        // Success animation before navigation
        await Future.delayed(const Duration(milliseconds: 500));
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => AdminScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8),
                Text('Login failed'),
              ],
            ),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.wifi_off_outlined, color: Colors.white),
              SizedBox(width: 8),
              Text('Connection error'),
            ],
          ),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Admin Login',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withOpacity(0.05),
        iconTheme: const IconThemeData(color: Color(0xFF64748B)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
            stops: [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.all(32.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header Icon
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.settings_outlined,
                          size: 48,
                          color: Color(0xFFEA580C),
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Admin Access',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Sign in to manage charging stations',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Email Field
                      _buildAnimatedTextField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 20),

                      // Password Field
                      _buildAnimatedTextField(
                        controller: _passwordController,
                        label: 'Password',
                        icon: Icons.lock_outline,
                        obscureText: true,
                      ),

                      const SizedBox(height: 32),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEA580C),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              disabledBackgroundColor: const Color(0xFF94A3B8),
                            ).copyWith(
                              overlayColor: WidgetStateProperty.all(
                                Colors.white.withOpacity(0.1),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                                : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.login, size: 24),
                                SizedBox(width: 8),
                                Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
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
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 600),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(20 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF1E293B),
          ),
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(
              icon,
              color: const Color(0xFF64748B),
              size: 20,
            ),
            labelStyle: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFEA580C),
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFDC2626),
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFDC2626),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with TickerProviderStateMixin {
  List<dynamic> stations = [];
  bool _isLoading = true;
  late AnimationController _listAnimationController;

  @override
  void initState() {
    super.initState();
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fetchStations();
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    super.dispose();
  }

  Future<void> _fetchStations() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.get(Uri.parse('$baseUrl/stations'));
      if (response.statusCode == 200) {
        setState(() {
          stations = jsonDecode(response.body);
          _isLoading = false;
        });
        _listAnimationController.forward();
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.error_outline, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Failed to load stations',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFE53E3E),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: const Color(0xFFF6721E),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        toolbarHeight: 64,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.refresh_rounded,
                  size: 20,
                ),
              ),
              onPressed: () {
                _listAnimationController.reset();
                _fetchStations();
              },
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.1),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF56500).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF56500)),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Loading stations...',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      )
          : stations.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.ev_station_outlined,
                size: 64,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No charging stations found',
              style: TextStyle(
                fontSize: 20,
                color: Color(0xFF334155),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your first station using the + button below',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _fetchStations,
        color: const Color(0xFFF56500),
        backgroundColor: Colors.white,
        strokeWidth: 3,
        displacement: 40,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
          itemCount: stations.length,
          itemBuilder: (ctx, i) {
            return _buildStationCard(stations[i], i);
          },
        ),
      ),
      floatingActionButton: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 1000),
        tween: Tween<double>(begin: 0, end: 1),
        builder: (context, double value, child) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF56500).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: () => Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    CreateStationScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 1.0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: child,
                  );
                },
              ),
            ).then((_) => _fetchStations()),
            backgroundColor: const Color(0xFFF56500),
            foregroundColor: Colors.white,
            elevation: 0,
            highlightElevation: 0,
            icon: const Icon(Icons.add_rounded, size: 24),
            label: const Text(
              'Add Station',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                letterSpacing: 0.3,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStationCard(dynamic station, int index) {
    final availableSlots = station['available_slots'] ?? 0;
    final totalSlots = station['total_slots'] ?? 1;
    final occupancyRate = (totalSlots - availableSlots) / totalSlots;

    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (occupancyRate == 0) {
      statusColor = const Color(0xFF10B981);
      statusIcon = Icons.check_circle_rounded;
      statusText = 'Available';
    } else if (occupancyRate < 0.7) {
      statusColor = const Color(0xFFF59E0B);
      statusIcon = Icons.warning_rounded;
      statusText = 'Busy';
    } else {
      statusColor = const Color(0xFFEF4444);
      statusIcon = Icons.error_rounded;
      statusText = 'Nearly Full';
    }

    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 400 + (index * 100)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          elevation: 0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditStationScreen(station: station),
                ),
              ).then((_) => _fetchStations()),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF56500).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.ev_station_rounded,
                            color: Color(0xFFF56500),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                station['name'] ?? 'Unknown Station',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          statusIcon,
                                          size: 14,
                                          color: statusColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          statusText,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: statusColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            color: Color(0xFF64748B),
                            size: 18,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Availability Progress Bar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Slot Availability',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$availableSlots/$totalSlots available',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: const Color(0xFFF1F5F9),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: availableSlots / totalSlots,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CreateStationScreen extends StatefulWidget {
  @override
  _CreateStationScreenState createState() => _CreateStationScreenState();
}

class _CreateStationScreenState extends State<CreateStationScreen>
    with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _latController = TextEditingController();
  final _lonController = TextEditingController();
  final _totalSlotsController = TextEditingController();
  final _operatorController = TextEditingController();
  final _pricingController = TextEditingController();
  final _hoursController = TextEditingController();
  final _contactController = TextEditingController();
  List<String> selectedPlugs = [];
  String selectedPower = powerRatings[0];
  List<XFile> photos = [];
  bool useMap = false;
  LatLng? selectedLocation;
  bool _isCreating = false;

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked != null) {
      setState(() {
        photos.addAll(picked);
      });
    }
  }

  Future<void> _selectOnMap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MapSelectionScreen()),
    );
    if (result != null) {
      setState(() {
        selectedLocation = result;
        _latController.text = result.latitude.toString();
        _lonController.text = result.longitude.toString();
      });
    }
  }

  Future<void> _create() async {
    setState(() => _isCreating = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('admin_token');
    if (token == null || Jwt.parseJwt(token)['exp'] < DateTime.now().millisecondsSinceEpoch / 1000) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AdminLoginScreen()));
      return;
    }

    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/stations'));
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['name'] = _nameController.text;
    request.fields['lat'] = _latController.text;
    request.fields['lon'] = _lonController.text;
    request.fields['total_slots'] = _totalSlotsController.text;
    request.fields['operator'] = _operatorController.text;
    request.fields['plug_types'] = selectedPlugs.join(',');
    request.fields['power_rating'] = selectedPower;
    request.fields['pricing'] = _pricingController.text;
    request.fields['operating_hours'] = _hoursController.text;
    request.fields['contact_info'] = _contactController.text;
    for (var photo in photos) {
      request.files.add(await http.MultipartFile.fromPath('photos', photo.path));
    }
    final response = await request.send();

    setState(() => _isCreating = false);

    if (response.statusCode == 200) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.error_outline, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Failed to create station',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFE53E3E),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
        ),
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? hint,
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF0F172A),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: icon != null ? Container(
            margin: const EdgeInsets.only(left: 12, right: 8),
            child: Icon(
              icon,
              color: const Color(0xFF64748B),
              size: 20,
            ),
          ) : null,
          labelStyle: const TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          hintStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFF56500),
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildAnimatedButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    Color? backgroundColor,
    bool isLoading = false,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: !isLoading ? [
          BoxShadow(
            color: (backgroundColor ?? const Color(0xFFF56500)).withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? const Color(0xFFF56500),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: const Color(0xFF94A3B8),
        ).copyWith(
          overlayColor: WidgetStateProperty.all(
            Colors.white.withOpacity(0.1),
          ),
        ),
        child: isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF56500).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: const Color(0xFFF56500),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Create Station',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: const Color(0xFFF56500),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        toolbarHeight: 64,
        leading: Container(
          margin: const EdgeInsets.only(left: 16),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                size: 20,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.1),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
            child: Column(
              children: [
                // Basic Information Section
                _buildSectionCard(
                  title: 'Basic Information',
                  icon: Icons.info_outline_rounded,
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: 'Station Name',
                      icon: Icons.ev_station_rounded,
                      hint: 'Enter station name',
                    ),
                    _buildTextField(
                      controller: _totalSlotsController,
                      label: 'Total Slots',
                      icon: Icons.electrical_services_rounded,
                      keyboardType: TextInputType.number,
                      hint: 'Number of charging slots',
                    ),
                    _buildTextField(
                      controller: _operatorController,
                      label: 'Operator',
                      icon: Icons.business_rounded,
                      hint: 'e.g., Tata, BPCL',
                    ),
                  ],
                ),

                // Technical Specifications Section
                _buildSectionCard(
                  title: 'Technical Specifications',
                  icon: Icons.settings_rounded,
                  children: [
                    const Text(
                      'Power Rating',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButton<String>(
                        value: selectedPower,
                        isExpanded: true,
                        underline: Container(),
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF64748B),
                        ),
                        items: powerRatings.map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF0F172A),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )).toList(),
                        onChanged: (v) => setState(() => selectedPower = v!),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Plug Types',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: plugTypes.map((p) => Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: p != plugTypes.last ? const BorderSide(
                                color: Color(0xFFE2E8F0),
                                width: 0.5,
                              ) : BorderSide.none,
                            ),
                          ),
                          child: CheckboxListTile(
                            title: Text(
                              p,
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            value: selectedPlugs.contains(p),
                            activeColor: const Color(0xFFF56500),
                            checkColor: Colors.white,
                            controlAffinity: ListTileControlAffinity.trailing,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            onChanged: (val) => setState(() {
                              if (val!) selectedPlugs.add(p);
                              else selectedPlugs.remove(p);
                            }),
                          ),
                        )).toList(),
                      ),
                    ),
                  ],
                ),

                // Business Information Section
                _buildSectionCard(
                  title: 'Business Information',
                  icon: Icons.business_center_rounded,
                  children: [
                    _buildTextField(
                      controller: _pricingController,
                      label: 'Pricing',
                      icon: Icons.currency_rupee_rounded,
                      hint: '₹10/kWh or ₹50/hour',
                    ),
                    _buildTextField(
                      controller: _hoursController,
                      label: 'Operating Hours',
                      icon: Icons.access_time_rounded,
                      hint: '24/7 or 9 AM - 9 PM',
                    ),
                    _buildTextField(
                      controller: _contactController,
                      label: 'Contact Information',
                      icon: Icons.phone_rounded,
                      hint: 'Phone number or email',
                    ),
                  ],
                ),

                // Location Section
                _buildSectionCard(
                  title: 'Location',
                  icon: Icons.location_on_rounded,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: SwitchListTile(
                        title: const Text(
                          'Use Map for Location',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF0F172A),
                            fontSize: 15,
                          ),
                        ),
                        value: useMap,
                        activeColor: const Color(0xFFF56500),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        onChanged: (v) => setState(() => useMap = v),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (!useMap) ...[
                      _buildTextField(
                        controller: _latController,
                        label: 'Latitude',
                        icon: Icons.my_location_rounded,
                        keyboardType: TextInputType.number,
                        hint: '12.9716',
                      ),
                      _buildTextField(
                        controller: _lonController,
                        label: 'Longitude',
                        icon: Icons.place_rounded,
                        keyboardType: TextInputType.number,
                        hint: '77.5946',
                      ),
                    ] else
                      _buildAnimatedButton(
                        text: selectedLocation != null
                            ? 'Location Selected'
                            : 'Select on Map',
                        icon: selectedLocation != null
                            ? Icons.check_circle_rounded
                            : Icons.map_rounded,
                        onPressed: _selectOnMap,
                        backgroundColor: selectedLocation != null
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF56500),
                      ),
                  ],
                ),

                // Photos Section
                _buildSectionCard(
                  title: 'Photos',
                  icon: Icons.photo_library_rounded,
                  children: [
                    _buildAnimatedButton(
                      text: 'Add Photos',
                      icon: Icons.add_a_photo_rounded,
                      onPressed: _pickPhotos,
                    ),
                    if (photos.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${photos.length} photo${photos.length > 1 ? 's' : ''} selected',
                              style: const TextStyle(
                                color: Color(0xFF047857),
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),

                // Create Button
                const SizedBox(height: 20),
                _buildAnimatedButton(
                  text: 'Create Station',
                  icon: Icons.add_rounded,
                  onPressed: _create,
                  backgroundColor: const Color(0xFF10B981),
                  isLoading: _isCreating,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EditStationScreen extends StatefulWidget {
  final dynamic station;
  const EditStationScreen({required this.station});

  @override
  _EditStationScreenState createState() => _EditStationScreenState();
}

class _EditStationScreenState extends State<EditStationScreen> with TickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _latController;
  late TextEditingController _lonController;
  late TextEditingController _totalSlotsController;
  late TextEditingController _availableSlotsController;
  late TextEditingController _operatorController;
  late TextEditingController _pricingController;
  late TextEditingController _hoursController;
  late TextEditingController _contactController;
  List<String> selectedPlugs = [];
  String selectedPower = '';
  List<XFile> newPhotos = [];
  bool useMap = false;
  LatLng? selectedLocation;
  bool _isUpdating = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _nameController = TextEditingController(text: widget.station['name']);
    _latController = TextEditingController(text: widget.station['lat'].toString());
    _lonController = TextEditingController(text: widget.station['lon'].toString());
    _totalSlotsController = TextEditingController(text: widget.station['total_slots'].toString());
    _availableSlotsController = TextEditingController(text: widget.station['available_slots'].toString());
    _operatorController = TextEditingController(text: widget.station['operator']);
    _pricingController = TextEditingController(text: widget.station['pricing']);
    _hoursController = TextEditingController(text: widget.station['operating_hours']);
    _contactController = TextEditingController(text: widget.station['contact_info']);
    selectedPlugs = List<String>.from(widget.station['plug_types']);
    selectedPower = widget.station['power_rating'];

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _pickPhotos() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked != null) {
      setState(() {
        newPhotos.addAll(picked);
      });
    }
  }

  Future<void> _selectOnMap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MapSelectionScreen(initialLatLng: LatLng(widget.station['lat'], widget.station['lon']))),
    );
    if (result != null) {
      setState(() {
        selectedLocation = result;
        _latController.text = result.latitude.toString();
        _lonController.text = result.longitude.toString();
      });
    }
  }

  Future<void> _update() async {
    setState(() => _isUpdating = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('admin_token');
      if (token == null || JwtDecoder.isExpired(token)) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AdminLoginScreen()));
        return;
      }

      final request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/stations/${widget.station['id']}'));
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['name'] = _nameController.text;
      request.fields['lat'] = _latController.text;
      request.fields['lon'] = _lonController.text;
      request.fields['total_slots'] = _totalSlotsController.text;
      request.fields['available_slots'] = _availableSlotsController.text;
      request.fields['operator'] = _operatorController.text;
      request.fields['plug_types'] = selectedPlugs.join(',');
      request.fields['power_rating'] = selectedPower;
      request.fields['pricing'] = _pricingController.text;
      request.fields['operating_hours'] = _hoursController.text;
      request.fields['contact_info'] = _contactController.text;

      for (var photo in newPhotos) {
        request.files.add(await http.MultipartFile.fromPath('photos', photo.path));
      }

      final response = await request.send();
      if (response.statusCode == 200) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.error_outline, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Failed to update station',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFE53E3E),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 8,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.error_outline, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Error: $e',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFE53E3E),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
        ),
      );
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLines = 1,
    String? hint,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF0F172A),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Container(
            margin: const EdgeInsets.only(left: 12, right: 8),
            child: Icon(
              icon,
              color: const Color(0xFF64748B),
              size: 20,
            ),
          ),
          labelStyle: const TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          hintStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFF56500),
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child, required IconData icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF56500).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFFF56500),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildPlugTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: plugTypes.map((p) => Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: p != plugTypes.last ? const BorderSide(
                color: Color(0xFFE2E8F0),
                width: 0.5,
              ) : BorderSide.none,
            ),
          ),
          child: CheckboxListTile(
            title: Text(
              p,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            value: selectedPlugs.contains(p),
            activeColor: const Color(0xFFF56500),
            checkColor: Colors.white,
            controlAffinity: ListTileControlAffinity.trailing,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            onChanged: (val) => setState(() {
              if (val!) selectedPlugs.add(p);
              else selectedPlugs.remove(p);
            }),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildPowerRatingDropdown() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButton<String>(
        value: selectedPower.isEmpty ? null : selectedPower,
        hint: const Text(
          'Select Power Rating',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        isExpanded: true,
        underline: Container(),
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Color(0xFF64748B),
        ),
        items: powerRatings.map((rating) => DropdownMenuItem(
          value: rating,
          child: Text(
            rating,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        )).toList(),
        onChanged: (value) => setState(() => selectedPower = value!),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: SwitchListTile(
            title: const Text(
              'Use Map for Location',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF0F172A),
                fontSize: 15,
              ),
            ),
            value: useMap,
            activeColor: const Color(0xFFF56500),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            onChanged: (v) => setState(() => useMap = v),
          ),
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.1),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: !useMap
              ? Column(
            key: const ValueKey('coordinates'),
            children: [
              _buildTextField(
                controller: _latController,
                label: 'Latitude',
                icon: Icons.my_location_rounded,
                keyboardType: TextInputType.number,
                hint: '12.9716',
              ),
              _buildTextField(
                controller: _lonController,
                label: 'Longitude',
                icon: Icons.place_rounded,
                keyboardType: TextInputType.number,
                hint: '77.5946',
              ),
            ],
          )
              : Container(
            key: const ValueKey('map'),
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF56500).withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: _selectOnMap,
              icon: Icon(
                selectedLocation != null
                    ? Icons.check_circle_rounded
                    : Icons.map_rounded,
                color: Colors.white,
                size: 20,
              ),
              label: Text(
                selectedLocation != null ? 'Location Selected' : 'Select on Map',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  letterSpacing: 0.2,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedLocation != null
                    ? const Color(0xFF10B981)
                    : const Color(0xFFF56500),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF56500).withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: _pickPhotos,
            icon: const Icon(Icons.add_a_photo_rounded, color: Colors.white, size: 20),
            label: const Text(
              'Add New Photos',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
                letterSpacing: 0.2,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF56500),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
          ),
        ),
        if (newPhotos.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${newPhotos.length} new photo${newPhotos.length > 1 ? 's' : ''} selected',
                  style: const TextStyle(
                    color: Color(0xFF047857),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Edit Station',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: const Color(0xFFF56500),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        toolbarHeight: 64,
        leading: Container(
          margin: const EdgeInsets.only(left: 16),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                size: 20,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.1),
                ],
              ),
            ),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
            child: Column(
              children: [
                // Basic Information
                _buildSectionCard(
                  title: 'Basic Information',
                  icon: Icons.info_outline_rounded,
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _nameController,
                        label: 'Station Name',
                        icon: Icons.ev_station_rounded,
                        hint: 'Enter station name',
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _totalSlotsController,
                              label: 'Total Slots',
                              icon: Icons.electrical_services_rounded,
                              keyboardType: TextInputType.number,
                              hint: 'Total slots',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _availableSlotsController,
                              label: 'Available Slots',
                              icon: Icons.check_circle_outline_rounded,
                              keyboardType: TextInputType.number,
                              hint: 'Available',
                            ),
                          ),
                        ],
                      ),
                      _buildTextField(
                        controller: _operatorController,
                        label: 'Operator',
                        icon: Icons.business_rounded,
                        hint: 'e.g., Tata, BPCL',
                      ),
                    ],
                  ),
                ),

                // Technical Specifications
                _buildSectionCard(
                  title: 'Technical Specifications',
                  icon: Icons.settings_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Power Rating',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildPowerRatingDropdown(),
                      const SizedBox(height: 20),
                      const Text(
                        'Plug Types',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildPlugTypeSelector(),
                    ],
                  ),
                ),

                // Business Information
                _buildSectionCard(
                  title: 'Business Information',
                  icon: Icons.business_center_rounded,
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _pricingController,
                        label: 'Pricing',
                        icon: Icons.currency_rupee_rounded,
                        hint: '₹10/kWh or ₹50/hour',
                      ),
                      _buildTextField(
                        controller: _hoursController,
                        label: 'Operating Hours',
                        icon: Icons.access_time_rounded,
                        hint: '24/7 or 9 AM - 9 PM',
                      ),
                      _buildTextField(
                        controller: _contactController,
                        label: 'Contact Information',
                        icon: Icons.phone_rounded,
                        hint: 'Phone number or email',
                      ),
                    ],
                  ),
                ),

                // Location
                _buildSectionCard(
                  title: 'Location',
                  icon: Icons.location_on_rounded,
                  child: _buildLocationSection(),
                ),

                // Photos
                _buildSectionCard(
                  title: 'Photos',
                  icon: Icons.photo_library_rounded,
                  child: _buildPhotoSection(),
                ),

                // Update Button
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: !_isUpdating ? [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ] : null,
                  ),
                  child: ElevatedButton(
                    onPressed: _isUpdating ? null : _update,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                      disabledBackgroundColor: const Color(0xFF94A3B8),
                    ),
                    child: _isUpdating
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.update_rounded, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Update Station',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _nameController.dispose();
    _latController.dispose();
    _lonController.dispose();
    _totalSlotsController.dispose();
    _availableSlotsController.dispose();
    _operatorController.dispose();
    _pricingController.dispose();
    _hoursController.dispose();
    _contactController.dispose();
    super.dispose();
  }
}


class MapSelectionScreen extends StatefulWidget {
  final LatLng? initialLatLng;
  const MapSelectionScreen({this.initialLatLng});
  @override
  _MapSelectionScreenState createState() => _MapSelectionScreenState();
}

class _MapSelectionScreenState extends State<MapSelectionScreen> {
  MapLibreMapController? _controller;
  LatLng? selected;
  LatLng? userLocation;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        userLocation = defaultLocation;
      });
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          userLocation = defaultLocation;
        });
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() {
        userLocation = defaultLocation;
      });
      return;
    }
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      userLocation = LatLng(position.latitude, position.longitude);
    });
  }

  Future<void> _addMarker(LatLng latLng) async {
    if (_controller == null) return;
    await _controller!.removeLayer('marker').catchError((e) => print('Error removing marker layer: $e'));
    await _controller!.removeSource('marker').catchError((e) => print('Error removing marker source: $e'));
    await _controller!.addSource('marker', GeojsonSourceProperties(data: {
      'type': 'FeatureCollection',
      'features': [
        {
          'type': 'Feature',
          'geometry': {'type': 'Point', 'coordinates': [latLng.longitude, latLng.latitude]}
        }
      ],
    }));
    await _controller!.addSymbolLayer(
      'marker',
      'marker',
      const SymbolLayerProperties(
        iconImage: 'green_marker',
        iconSize: 0.3,
        iconAnchor: 'bottom',
      ),
    );
  }

  Future<Uint8List> _loadImage(String assetPath) async {
    try {
      final ByteData data = await DefaultAssetBundle.of(context).load(assetPath);
      return data.buffer.asUint8List();
    } catch (e) {
      print('Error loading image $assetPath: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Location')),
      body: Stack(
        children: [
          MapLibreMap(
            onMapCreated: (controller) async {
              _controller = controller;
              try {
                await _controller!.addImage('green_marker', await _loadImage('images/green_marker.png'));
                if (widget.initialLatLng != null) {
                  await _controller!.moveCamera(CameraUpdate.newLatLngZoom(widget.initialLatLng!, 15));
                  await _addMarker(widget.initialLatLng!);
                  setState(() {
                    selected = widget.initialLatLng;
                  });
                } else if (userLocation != null) {
                  await _controller!.moveCamera(CameraUpdate.newLatLngZoom(userLocation!, 15));
                }
              } catch (e) {
                print('Error in MapSelectionScreen onMapCreated: $e');
              }
            },
            onMapClick: (point, latLng) async {
              print('Map clicked at point: $point, latLng: $latLng');
              setState(() {
                selected = latLng;
              });
              await _addMarker(latLng);
            },
            initialCameraPosition: CameraPosition(
              target: userLocation ?? widget.initialLatLng ?? defaultLocation,
              zoom: 15,
            ),
            styleString: mapStyle,
          ),
          if (selected != null)
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: () => Navigator.pop(context, selected),
                child: const Icon(Icons.check),
                backgroundColor: Colors.green,
              ),
            ),
        ],
      ),
    );
  }
}


class ClientScreen extends StatefulWidget {
  @override
  _ClientScreenState createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  List<dynamic> stations = [];
  List<dynamic> filteredStations = [];
  MapLibreMapController? _controller;
  IOWebSocketChannel? _channel;
  List<String> selectedPlugs = [];
  String selectedPower = '';
  String selectedAvailability = availabilityOptions[0];
  String selectedDistance = distanceOptions[0];
  StreamSubscription? _subscription;
  LatLng? userLocation;
  List<String> tempSelectedPlugs = [];
  String tempSelectedPower = '';
  String tempSelectedAvailability = availabilityOptions[0];
  String tempSelectedDistance = distanceOptions[0];
  bool _imagesLoaded = false;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _fetchStations();
    _connectWebSocket();
  }

  @override
  void dispose() {
    _channel?.sink.close();
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        userLocation = defaultLocation;
      });
      print('Location services disabled, using default location: $defaultLocation');
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          userLocation = defaultLocation;
        });
        print('Location permission denied, using default location: $defaultLocation');
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() {
        userLocation = defaultLocation;
      });
      print('Location permission denied forever, using default location: $defaultLocation');
      return;
    }
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        userLocation = LatLng(position.latitude, position.longitude);
      });
      print('User location obtained: $userLocation');
    } catch (e) {
      print('Error getting user location: $e');
      setState(() {
        userLocation = defaultLocation;
      });
    }
  }

  Future<void> _fetchStations() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/stations'));
      if (response.statusCode == 200) {
        setState(() {
          stations = jsonDecode(response.body);
          filteredStations = stations;
          print('Fetched ${stations.length} stations');
        });
        _applyFilters();
      } else {
        print('Failed to fetch stations: ${response.statusCode}, body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching stations: $e');
    }
  }

  Future<Map<String, dynamic>> _fetchStationReviews(int stationId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/stations/$stationId/reviews'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        print('Fetched reviews for station $stationId: ${data['total_reviews']} reviews');
        return {
          'reviews': data['reviews'] ?? [],
          'average_rating': data['average_rating'] ?? 0.0,
          'total_reviews': data['total_reviews'] ?? 0,
        };
      } else {
        print('Failed to fetch reviews: ${response.statusCode}, body: ${response.body}');
        return {'reviews': [], 'average_rating': 0.0, 'total_reviews': 0};
      }
    } catch (e) {
      print('Error fetching reviews: $e');
      return {'reviews': [], 'average_rating': 0.0, 'total_reviews': 0};
    }
  }

  void _connectWebSocket() {
    try {
      _channel = IOWebSocketChannel.connect(wsUrl);
      _subscription = _channel!.stream.listen(
            (message) {
          final data = jsonDecode(message);
          if (data['type'] == 'slot_update') {
            setState(() {
              final index = stations.indexWhere((s) => s['id'] == data['station_id']);
              if (index != -1) {
                stations[index]['available_slots'] = data['available_slots'];
                print('Updated station ${stations[index]['id']} with ${data['available_slots']} available slots');
                _applyFilters();
              }
            });
          }
        },
        onError: (error) => print('WebSocket error: $error'),
        onDone: () => print('WebSocket closed'),
      );
    } catch (e) {
      print('Error connecting WebSocket: $e');
    }
  }

  double _calculateDistance(LatLng start, LatLng end) {
    print("Calc dist... Loc1: $start\nLoc2: $end");
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    ) / 1000; // Convert to km
  }

  void _applyFilters() {
    setState(() {
      filteredStations = stations.where((s) {
        bool plugMatch = selectedPlugs.isEmpty || selectedPlugs.any((p) => (s['plug_types'] as List).contains(p));
        bool powerMatch = selectedPower.isEmpty || s['power_rating'] == selectedPower;
        bool availabilityMatch = selectedAvailability == 'Any' || (selectedAvailability == 'Available Only' && s['available_slots'] > 0);
        bool distanceMatch = selectedDistance == 'Any' || userLocation == null
            ? true
            : _calculateDistance(userLocation!, LatLng(s['lat'], s['lon'])) <=
            double.parse(selectedDistance.replaceAll('<', '').replaceAll('km', ''));
        return plugMatch && powerMatch && availabilityMatch && distanceMatch;
      }).toList();
      print('Applied filters, ${filteredStations.length} stations remaining');
    });

    // Update markers if map is ready
    if (_mapReady) {
      _updateMarkers();
    }
  }

  Future<void> _updateMarkers() async {
    if (_controller == null || !_mapReady) {
      print('Map controller not ready in _updateMarkers');
      return;
    }

    try {
      // Remove existing layers and sources
      await _removeExistingLayers();

      // Add user location marker first
      await _addUserLocationMarker();

      // Add station markers
      await _addStationMarkers();

    } catch (e) {
      print('Error updating markers: $e');
    }
  }

  Future<void> _removeExistingLayers() async {
    final layersToRemove = ['station-markers', 'user-location'];
    final sourcesToRemove = ['stations-source', 'user-location-source'];

    for (String layer in layersToRemove) {
      try {
        await _controller!.removeLayer(layer);
      } catch (e) {
        // Layer might not exist, which is fine
      }
    }

    for (String source in sourcesToRemove) {
      try {
        await _controller!.removeSource(source);
      } catch (e) {
        // Source might not exist, which is fine
      }
    }
  }

  Future<void> _addUserLocationMarker() async {
    if (userLocation == null) return;

    try {
      await _controller!.addSource('user-location-source', GeojsonSourceProperties(data: {
        'type': 'FeatureCollection',
        'features': [
          {
            'type': 'Feature',
            'properties': {'type': 'user'},
            'geometry': {
              'type': 'Point',
              'coordinates': [userLocation!.longitude, userLocation!.latitude]
            }
          }
        ],
      }));

      await _controller!.addCircleLayer(
        'user-location-source',
        'user-location',
        const CircleLayerProperties(
          circleColor: '#007AFF',
          circleRadius: 8,
          circleStrokeColor: '#FFFFFF',
          circleStrokeWidth: 2,
        ),
      );
      print('Added user location marker');
    } catch (e) {
      print('Error adding user location marker: $e');
    }
  }

  Future<void> _addStationMarkers() async {
    if (filteredStations.isEmpty) {
      print('No stations to display');
      return;
    }

    try {
      final features = filteredStations.map((station) {
        return {
          'type': 'Feature',
          'properties': {
            'station_id': station['id'].toString(),
            'available_slots': station['available_slots'] ?? 0,
            'name': station['name'] ?? 'Unknown',
          },
          'geometry': {
            'type': 'Point',
            'coordinates': [station['lon'], station['lat']]
          }
        };
      }).toList();

      await _controller!.addSource('stations-source', GeojsonSourceProperties(data: {
        'type': 'FeatureCollection',
        'features': features,
      }));

      if (_imagesLoaded) {
        // Use symbol layer with custom markers
        await _controller!.addSymbolLayer(
          'stations-source',
          'station-markers',
          const SymbolLayerProperties(
            iconImage: [
              'case',
              ['>', ['get', 'available_slots'], 2],
              'green_marker',
              ['==', ['get', 'available_slots'], 0],
              'red_marker',
              'blue_marker', // 1-2 available slots
            ],
            iconSize: 0.3,
            iconAnchor: 'bottom',
            iconAllowOverlap: true,
            iconIgnorePlacement: true,
          ),
        );
        print('Added ${features.length} station markers with images');
      } else {
        // Fallback to circle markers
        await _controller!.addCircleLayer(
          'stations-source',
          'station-markers',
          const CircleLayerProperties(
            circleColor: [
              'case',
              ['>', ['get', 'available_slots'], 2],
              '#00FF00', // Green
              ['==', ['get', 'available_slots'], 0],
              '#FF0000', // Red
              '#0000FF', // Blue
            ],
            circleRadius: 12,
            circleStrokeColor: '#FFFFFF',
            circleStrokeWidth: 2,
          ),
        );
        print('Added ${features.length} station markers as circles');
      }
    } catch (e) {
      print('Error adding station markers: $e');
    }
  }

  Future<void> _loadImages() async {
    if (_controller == null) return;

    try {
      await _controller!.addImage('green_marker', await _loadImage('images/green_marker.png'));
      await _controller!.addImage('red_marker', await _loadImage('images/red_marker.png'));
      await _controller!.addImage('blue_marker', await _loadImage('images/blue_marker.png'));
      setState(() {
        _imagesLoaded = true;
      });
      print('Marker images loaded successfully');
    } catch (e) {
      print('Error loading marker images: $e');
      setState(() {
        _imagesLoaded = false;
      });
    }
  }

  Future<Uint8List> _loadImage(String assetPath) async {
    try {
      final ByteData data = await DefaultAssetBundle.of(context).load(assetPath);
      return data.buffer.asUint8List();
    } catch (e) {
      print('Error loading image $assetPath: $e');
      rethrow;
    }
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return 'Unknown date';
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown date';
    }
  }

  void _showFilterSheet() {
    tempSelectedPlugs = List.from(selectedPlugs);
    tempSelectedPower = selectedPower;
    tempSelectedAvailability = selectedAvailability;
    tempSelectedDistance = selectedDistance;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -2))],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filters',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue[800]),
                  ),
                  const SizedBox(height: 16),
                  const Text('Power Rating', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: tempSelectedPower.isEmpty ? null : tempSelectedPower,
                      hint: const Text('Select Power Rating'),
                      items: ['', ...powerRatings].map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.isEmpty ? 'All' : e, style: TextStyle(color: Colors.blue[700])),
                      )).toList(),
                      onChanged: (v) {
                        setModalState(() {
                          tempSelectedPower = v ?? '';
                        });
                      },
                      underline: const SizedBox(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Plug Types', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: plugTypes.map((p) => CheckboxListTile(
                        title: Text(p, style: TextStyle(color: Colors.blue[700])),
                        value: tempSelectedPlugs.contains(p),
                        activeColor: Colors.blue[800],
                        onChanged: (val) {
                          setModalState(() {
                            if (val!) {
                              tempSelectedPlugs.add(p);
                            } else {
                              tempSelectedPlugs.remove(p);
                            }
                          });
                        },
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Availability', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: tempSelectedAvailability,
                      items: availabilityOptions.map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e, style: TextStyle(color: Colors.blue[700])),
                      )).toList(),
                      onChanged: (v) {
                        setModalState(() {
                          tempSelectedAvailability = v!;
                        });
                      },
                      underline: const SizedBox(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Distance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: tempSelectedDistance,
                      items: distanceOptions.map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e, style: TextStyle(color: Colors.blue[700])),
                      )).toList(),
                      onChanged: (v) {
                        setModalState(() {
                          tempSelectedDistance = v!;
                        });
                      },
                      underline: const SizedBox(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedPlugs = List.from(tempSelectedPlugs);
                        selectedPower = tempSelectedPower;
                        selectedAvailability = tempSelectedAvailability;
                        selectedDistance = tempSelectedDistance;
                      });
                      _applyFilters();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Center(child: Text('Apply Filters')),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _submitReview(int stationId, String review, double rating) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/stations/$stationId/reviews'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'review': review,
          'rating': rating.round(), // Convert to int as backend expects
        }),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Review submitted successfully'))
        );
      } else {
        print('Failed to submit review: ${response.statusCode}, body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to submit review'))
        );
      }
    } catch (e) {
      print('Error submitting review: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error submitting review'))
      );
    }
  }

  void _showReviewDialog(dynamic station) {
    final reviewController = TextEditingController();
    double rating = 1.0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
              maxWidth: MediaQuery.of(context).size.width - 32,
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Review',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Rating:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () => setDialogState(() => rating = (index + 1).toDouble()),
                      child: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Review:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: reviewController,
                  decoration: const InputDecoration(
                    hintText: 'Share your experience...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(12),
                  ),
                  maxLines: 4,
                  maxLength: 500,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        if (reviewController.text.isNotEmpty) {
                          await _submitReview(station['id'], reviewController.text, rating);
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAllReviews(dynamic station, List<dynamic> allReviews) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'All Reviews (${allReviews.length})',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: allReviews.isEmpty
                  ? const Center(
                child: Text(
                  'No reviews yet',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: allReviews.length,
                itemBuilder: (context, index) {
                  final review = allReviews[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Row(
                                children: List.generate(5, (starIndex) {
                                  return Icon(
                                    starIndex < (review['rating'] ?? 0)
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 16,
                                  );
                                }),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${review['rating'] ?? 0}/5',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            review['review'] ?? 'No comment',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(review['created_at']),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBottomSheet(dynamic station) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade50,
                Colors.white,
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade100.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Enhanced drag handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.blue.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Enhanced station title with icon
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade600, Colors.blue.shade700],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.shade200,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.ev_station,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                station['name'],
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Enhanced station details with cards
                      _buildModernInfoCard('Available', '${station['available_slots']}/${station['total_slots']}', Icons.battery_charging_full, Colors.green),
                      _buildModernInfoCard('Operator', station['operator'], Icons.business, Colors.blue),
                      _buildModernInfoCard('Plug Types', station['plug_types'].join(', '), Icons.power, Colors.orange),
                      _buildModernInfoCard('Power Rating', station['power_rating'], Icons.flash_on, Colors.purple),
                      _buildModernInfoCard('Pricing', station['pricing'], Icons.attach_money, Colors.teal),
                      _buildModernInfoCard('Hours', station['operating_hours'], Icons.access_time, Colors.indigo),
                      _buildModernInfoCard('Contact', station['contact_info'], Icons.phone, Colors.cyan),
                      _buildModernInfoCard('Distance', '${(_calculateDistance(defaultLocation, LatLng(
                        station['lat'] != null ? station['lat']?.toDouble() : defaultLocation.latitude,
                        station['lng'] != null ? station['lng']?.toDouble() : defaultLocation.longitude,
                      ))*5).toStringAsFixed(2)} Km', Icons.location_pin, Colors.brown),

                      const SizedBox(height: 20),

                      // Enhanced photos section
                      if (station['photos'] != null && station['photos'].isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.blue.shade100),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.photo_library, color: Colors.blue.shade600, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Photos',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 120,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: station['photos'].length,
                                  itemBuilder: (ctx, i) => Container(
                                    margin: const EdgeInsets.only(right: 12),
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.shade100,
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        '$baseUrl${station['photos'][i]}',
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.blue.shade100,
                                            child: Icon(Icons.error, color: Colors.blue.shade400),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Enhanced reviews section
                      FutureBuilder<Map<String, dynamic>>(
                        future: _fetchStationReviews(station['id']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: Colors.blue.shade600,
                              ),
                            );
                          }

                          final reviewData = snapshot.data ?? {'reviews': [], 'average_rating': 0.0, 'total_reviews': 0};
                          final allReviews = reviewData['reviews'] as List<dynamic>;
                          final averageRating = (reviewData['average_rating'] as num).toDouble();
                          final totalReviews = reviewData['total_reviews'] as int;
                          final recentReviews = allReviews.take(5).toList();

                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.blue.shade100),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.star_rate,
                                                color: Colors.blue.shade600,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Reviews',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.blue.shade800,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (totalReviews > 0) ...[
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                ...List.generate(5, (index) {
                                                  return Icon(
                                                    index < averageRating.round()
                                                        ? Icons.star
                                                        : Icons.star_border,
                                                    color: Colors.amber.shade600,
                                                    size: 18,
                                                  );
                                                }),
                                                const SizedBox(width: 6),
                                                Flexible(
                                                  child: Text(
                                                    '${averageRating.toStringAsFixed(1)} ($totalReviews reviews)',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.blue.shade600,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () => _showReviewDialog(station),
                                      icon: const Icon(Icons.add, size: 14),
                                      label: const Text('Add Review'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue.shade600,
                                        foregroundColor: Colors.white,
                                        elevation: 2,
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                        textStyle: const TextStyle(fontSize: 11),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                if (recentReviews.isEmpty)
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.blue.shade100),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.rate_review_outlined, color: Colors.blue.shade400),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'No reviews yet. Be the first to review!',
                                            style: TextStyle(color: Colors.blue.shade600),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else ...[
                                  ...recentReviews.map((review) => Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.blue.shade100),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.shade50,
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Row(
                                              children: List.generate(5, (starIndex) {
                                                return Icon(
                                                  starIndex < (review['rating'] ?? 0)
                                                      ? Icons.star
                                                      : Icons.star_border,
                                                  color: Colors.amber.shade600,
                                                  size: 16,
                                                );
                                              }),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade100,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '${review['rating'] ?? 0}/5',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.blue.shade700,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          review['review'] ?? 'No comment',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade700,
                                            height: 1.4,
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _formatDate(review['created_at']),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.blue.shade400,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )).toList(),

                                  if (allReviews.length > 5)
                                    TextButton.icon(
                                      onPressed: () => _showAllReviews(station, allReviews),
                                      icon: Icon(Icons.expand_more, size: 16, color: Colors.blue.shade600),
                                      label: Text(
                                        'View all ${allReviews.length} reviews',
                                        style: TextStyle(color: Colors.blue.shade600, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Enhanced action buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final picker = ImagePicker();
                                final photo = await picker.pickImage(source: ImageSource.camera);
                                if (photo != null) {
                                  final request = http.MultipartRequest(
                                    'POST',
                                    Uri.parse('$baseUrl/stations/${station['id']}/photos'),
                                  );
                                  request.files.add(await http.MultipartFile.fromPath('photos', photo.path));
                                  final response = await request.send();
                                  if (response.statusCode == 200) {
                                    _fetchStations();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Photo uploaded successfully'),
                                        backgroundColor: Colors.green.shade600,
                                      ),
                                    );
                                  } else {
                                    print('Failed to upload photo: ${response.statusCode}');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Failed to upload photo'),
                                        backgroundColor: Colors.red.shade600,
                                      ),
                                    );
                                  }
                                }
                              },
                              icon: const Icon(Icons.camera_alt, size: 20),
                              label: const Text('Add Photo'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                elevation: 4,
                                shadowColor: Colors.blue.shade200,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                final url = 'https://www.google.com/maps/dir/?api=1&destination=${station['lat']},${station['lon']}';
                                launchUrl(Uri.parse(url));
                              },
                              icon: const Icon(Icons.navigation, size: 20),
                              label: const Text('Navigate'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                elevation: 4,
                                shadowColor: Colors.blue.shade200,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernInfoCard(String label, String value, IconData icon, Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade50,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic>? _findStationByCoordinates(LatLng coordinates, {double toleranceKm = 0.1}) {
    if (filteredStations.isEmpty) return null;

    for (final station in filteredStations) {
      if (station is! Map<String, dynamic>) continue;

      final lat = (station['lat'] as num?)?.toDouble();
      final lon = (station['lon'] as num?)?.toDouble();

      if (lat == null || lon == null) continue;

      final distance = _calculateDistance(coordinates, LatLng(lat, lon));
      if (distance <= toleranceKm) {
        return station;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Charging Stations'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          MaplibreMap(
            onMapCreated: (controller) async {
              _controller = controller;
              print('Map controller created');

              try {
                // Load marker images
                await _loadImages();

                // Set initial camera position
                final initialLocation = userLocation ?? defaultLocation;
                await _controller!.moveCamera(CameraUpdate.newLatLngZoom(initialLocation, 15));
                print('Map centered on: $initialLocation');

                // Mark map as ready and update markers
                setState(() {
                  _mapReady = true;
                });

                // Update markers after map is ready
                await _updateMarkers();

              } catch (e) {
                print('Error in onMapCreated: $e');
              }
            },
            onMapClick: (point, latLng) async {
              print('Map clicked at: $latLng');

              if (_controller == null || !_mapReady) {
                print('Map not ready for interaction');
                return;
              }

              try {
                // Query features at the clicked point
                final features = await _controller!.queryRenderedFeatures(
                  point,
                  ['station-markers'],
                  null,
                );

                if (features.isNotEmpty) {
                  print('Found ${features.length} features at click point');

                  // Get the station ID from the first feature
                  final feature = features.first as Map<String, dynamic>;
                  final properties = feature['properties'] as Map<String, dynamic>?;
                  final stationId = properties?['station_id']?.toString();

                  if (stationId != null) {
                    print('Clicked on station with ID: $stationId');

                    // Find the station data
                    final station = filteredStations
                        .cast<Map<String, dynamic>>()
                        .firstWhere(
                          (s) => s['id'].toString() == stationId,
                      orElse: () => <String, dynamic>{},
                    );

                    if (station.isNotEmpty) {
                      print('Opening bottom sheet for station: ${station['name']}');
                      _showBottomSheet(station);
                      return;
                    }
                  }
                }

                // Fallback: find station by proximity
                print('No feature found, searching by proximity');
                final nearbyStation = _findStationByCoordinates(latLng, toleranceKm: 0.1);
                if (nearbyStation != null) {
                  print('Found nearby station: ${nearbyStation['name']}');
                  _showBottomSheet(nearbyStation);
                } else {
                  print('No station found within 100m of click point');
                }

              } catch (e) {
                print('Error handling map click: $e');

                // Final fallback: try to find station by proximity
                final nearbyStation = _findStationByCoordinates(latLng, toleranceKm: 0.1);
                if (nearbyStation != null) {
                  _showBottomSheet(nearbyStation);
                }
              }
            },
            initialCameraPosition: CameraPosition(
              target: userLocation ?? defaultLocation,
              zoom: 15,
            ),
            styleString: mapStyle,
            trackCameraPosition: true,
            myLocationEnabled: true,
            myLocationTrackingMode: MyLocationTrackingMode.none,
          ),
          // Filter button
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: _showFilterSheet,
              backgroundColor: Colors.blue[800],
              foregroundColor: Colors.white,
              child: const Icon(Icons.filter_list),
              heroTag: "filter_button",
            ),
          ),
          // Info panel
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'Showing ${filteredStations.length} of ${stations.length} stations',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}