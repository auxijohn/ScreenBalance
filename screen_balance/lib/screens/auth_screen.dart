import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import 'calibration_confirmation_screen.dart';
import 'welcome_screen.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback onAuthenticated;
  const AuthScreen({super.key, required this.onAuthenticated});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _loginPinController = TextEditingController();
  
  String _ageGroup = '18-24';
  String _occupation = 'Student';
  bool _isSignUpMode = true;
  bool _showWelcome = false;
  bool _isLoading = true;
  String _storedName = '';
  String _storedPin = '';
  String? _errorMessage;

  static const _commandChannel = MethodChannel('com.screenbalance.tracker/commands');
  bool _isAccessibilityEnabled = false;
  Timer? _permissionCheckTimer;

  @override
  void initState() {
    super.initState();
    _checkExistingProfile();
    _checkAccessibilityPermission();
    final bool isTesting = !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    if (!isTesting) {
      _permissionCheckTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
        _checkAccessibilityPermission();
      });
    }
  }

  Future<void> _checkExistingProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final pin = prefs.getString('user_pin') ?? '';
    final profile = await UserProfile.loadFromStorage();
    if (profile != null && pin.isNotEmpty) {
      setState(() {
        _isSignUpMode = false;
        _showWelcome = false;
        _storedName = profile.name;
        _storedPin = pin;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isSignUpMode = true;
        _showWelcome = false;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pinController.dispose();
    _loginPinController.dispose();
    _permissionCheckTimer?.cancel();
    super.dispose();
  }

  void _submitRegister() {
    if (!_isAccessibilityEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 10),
              Expanded(child: Text('Please enable Accessibility Permission to proceed.')),
            ],
          ),
          backgroundColor: Colors.orange[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final pin = _pinController.text.trim();
      
      if (mounted) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => CalibrationConfirmationScreen(
              userName: name,
              userPin: pin,
              ageGroup: _ageGroup,
              occupation: _occupation,
              onAuthenticated: widget.onAuthenticated,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.05, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeOutCubic;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 350),
          ),
        );
      }
    }
  }

  Future<void> _checkAccessibilityPermission() async {
    try {
      final bool isEnabled = await _commandChannel.invokeMethod<bool>('isAccessibilityServiceEnabled') ?? false;
      if (mounted && _isAccessibilityEnabled != isEnabled) {
        setState(() {
          _isAccessibilityEnabled = isEnabled;
        });
      }
    } catch (e) {
      debugPrint('Error checking accessibility permission in login: $e');
    }
  }

  Future<void> _openAccessibilitySettings() async {
    try {
      await _commandChannel.invokeMethod('openAccessibilitySettings');
    } catch (e) {
      debugPrint('Error launching accessibility settings from login: $e');
    }
  }

  Widget _buildGlassCard({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(24),
    EdgeInsetsGeometry margin = const EdgeInsets.only(bottom: 20),
  }) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }

  InputDecoration _glassInputDecoration({
    required String labelText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
      prefixIcon: Icon(prefixIcon, color: Colors.white.withOpacity(0.8)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF00F2FE), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.redAccent.withOpacity(0.5)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent),
    );
  }

  Widget _buildSignUpCard() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_add_alt_1_rounded, color: const Color(0xFF00F2FE), size: 22),
              const SizedBox(width: 10),
              const Text(
                'Create Login Profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Name Input
          TextFormField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            decoration: _glassInputDecoration(
              labelText: 'First Name / Nickname',
              prefixIcon: Icons.person_outline_rounded,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),

          // PIN Input
          TextFormField(
            controller: _pinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            decoration: _glassInputDecoration(
              labelText: 'Create 4-Digit PIN',
              prefixIcon: Icons.lock_outline_rounded,
            ),
            validator: (value) {
              if (value == null || value.trim().length != 4) {
                return 'PIN must be exactly 4 digits';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Submit Button (Modern neon-gradient style)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00F2FE), Color(0xFF0D47A1)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00F2FE).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _submitRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text(
                'Continue to Onboarding',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataStorageGuidelines() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security_rounded, color: const Color(0xFF00F2FE), size: 18),
              const SizedBox(width: 8),
              const Text(
                'Data Storage Guidelines',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStoragePoint(Icons.wifi_off_rounded, 'Strictly Offline', 'All screen telemetry is processed entirely on your device.'),
          _buildStoragePoint(Icons.sd_card_outlined, 'Private Storage', 'Configurations and PIN are saved in secure private storage.'),
          _buildStoragePoint(Icons.analytics_outlined, 'Zero Trackers', 'No advertising, marketing trackers, or third-party telemetry.'),
        ],
      ),
    );
  }

  Widget _buildStoragePoint(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF00F2FE)),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.4,
                  fontFamily: 'Outfit',
                ),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  TextSpan(
                    text: desc,
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionCard() {
    final statusColor = _isAccessibilityEnabled ? Colors.greenAccent : Colors.orangeAccent;
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isAccessibilityEnabled ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                color: statusColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _isAccessibilityEnabled ? 'Mindful Telemetry Active' : 'Accessibility Permission Required',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _isAccessibilityEnabled
                ? 'Accessibility service is active and guarding your digital limits.'
                : 'Required only to detect scrolling and show mindfulness pauses. Rest assured: all processing runs 100% locally and offline—your messages and private data remain completely confidential.',
            style: TextStyle(
              fontSize: 12.5,
              color: Colors.white.withOpacity(0.7),
              height: 1.4,
            ),
          ),
          if (!_isAccessibilityEnabled) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openAccessibilitySettings,
                icon: const Icon(Icons.settings_applications_rounded, size: 18),
                label: const Text('Enable Accessibility'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent.withOpacity(0.15),
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.orangeAccent.withOpacity(0.5), width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _submitLogin() {
    final pinInput = _loginPinController.text.trim();
    if (pinInput == _storedPin) {
      widget.onAuthenticated();
    } else {
      setState(() {
        _errorMessage = 'Invalid PIN code. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0A192F),
                Color(0xFF0D47A1),
                Color(0xFF0F172A),
              ],
            ),
          ),
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _showWelcome
          ? WelcomeScreen(
              key: const ValueKey('welcome'),
              onStart: () {
                setState(() {
                  _showWelcome = false;
                });
              },
            )
          : Scaffold(
              key: const ValueKey('auth_main'),
              body: Stack(
                children: [
                  // 1. Dark Blue Gradient Background
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF0A192F), // Deep navy background
                          Color(0xFF0D47A1), // Rich dark blue
                          Color(0xFF0F172A), // Dark slate blue
                        ],
                      ),
                    ),
                  ),

                  // Ambient lighting effects (soft glowing circles)
                  Positioned(
                    top: -100,
                    left: -100,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  
                  SafeArea(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Mascot Image
                            Container(
                              height: 120,
                              width: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 25,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(60),
                                child: Image.asset(
                                  'assets/images/mascot.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Premium App Header
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.spa_rounded, color: Colors.white, size: 28),
                                SizedBox(width: 12),
                                Text(
                                  'ScreenBalance',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Stacked glassy form components
                            if (_isSignUpMode)
                              Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    _buildSignUpCard(),
                                    _buildPermissionCard(),
                                    _buildDataStorageGuidelines(),
                                    if (_storedPin.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            _isSignUpMode = false;
                                            _errorMessage = null;
                                          });
                                        },
                                        child: const Text(
                                          'Back to Login',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              )
                            else
                              _buildLoginForm(),
                            
                            const SizedBox(height: 24),
                            Text(
                              'All profile information is stored safely on this device.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildLoginForm() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Welcome Back, $_storedName',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Enter PIN to access your dashboard.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.7)),
          ),
          const SizedBox(height: 24),

          if (_errorMessage != null) ...[
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
          ],

          // PIN Input
          TextField(
            controller: _loginPinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 10),
            decoration: InputDecoration(
              hintText: '••••',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), letterSpacing: 10),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF00F2FE), width: 1.5),
              ),
            ),
            onChanged: (val) {
              if (val.length == 4) {
                _submitLogin();
              }
            },
          ),
          const SizedBox(height: 24),

          // Unlock Dashboard Button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00F2FE), Color(0xFF0D47A1)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00F2FE).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _submitLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Unlock Dashboard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              setState(() {
                _isSignUpMode = true;
                _errorMessage = null;
              });
            },
            child: const Text('Reset App / Create New Profile', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
