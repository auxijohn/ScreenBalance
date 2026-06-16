import 'package:flutter/material.dart';
import 'dart:ui';
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
  bool _showWelcome = true;
  bool _isLoading = true;
  String _storedName = '';
  String _storedPin = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkExistingProfile();
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
        _showWelcome = true;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pinController.dispose();
    _loginPinController.dispose();
    super.dispose();
  }

  void _submitRegister() {
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

                            // Glassmorphic interactive form container (White backdrop)
                            Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 30,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: _isSignUpMode ? _buildSignUpForm() : _buildLoginForm(),
                            ),
                            
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

  Widget _buildSignUpForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Create Local Profile',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A192F),
            ),
          ),
          const SizedBox(height: 24),
          
          // Name Input
          TextFormField(
            controller: _nameController,
            style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              labelText: 'First Name / Nickname',
              labelStyle: TextStyle(color: Colors.blue[700]),
              prefixIcon: Icon(Icons.person_outline, color: Colors.blue[600]),
              filled: true,
              fillColor: Colors.white.withOpacity(0.7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),

          // Age Group
          DropdownButtonFormField<String>(
            value: _ageGroup,
            style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              labelText: 'Age Group',
              labelStyle: TextStyle(color: Colors.blue[700]),
              prefixIcon: Icon(Icons.calendar_today_outlined, color: Colors.blue[600]),
              filled: true,
              fillColor: Colors.white.withOpacity(0.7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            items: ['<18', '18-24', '25-34', '35-44', '45+'].map((group) {
              return DropdownMenuItem(value: group, child: Text(group));
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _ageGroup = val);
            },
          ),
          const SizedBox(height: 14),

          // Occupation
          DropdownButtonFormField<String>(
            value: _occupation,
            style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              labelText: 'Primary Occupation',
              labelStyle: TextStyle(color: Colors.blue[700]),
              prefixIcon: Icon(Icons.work_outline, color: Colors.blue[600]),
              filled: true,
              fillColor: Colors.white.withOpacity(0.7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            items: ['Student', 'Professional', 'Self-employed', 'Retired', 'Other'].map((job) {
              return DropdownMenuItem(value: job, child: Text(job));
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _occupation = val);
            },
          ),
          const SizedBox(height: 14),

          // PIN Input
          TextFormField(
            controller: _pinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              labelText: 'Create 4-Digit PIN',
              labelStyle: TextStyle(color: Colors.blue[700]),
              prefixIcon: Icon(Icons.lock_outline, color: Colors.blue[600]),
              filled: true,
              fillColor: Colors.white.withOpacity(0.7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().length != 4) {
                return 'PIN must be exactly 4 digits';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _submitRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D47A1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 2,
            ),
            child: const Text(
              'Continue to Onboarding',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Welcome Back, $_storedName',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0A192F),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Enter PIN to access your dashboard.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.blue),
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
          style: TextStyle(fontSize: 22, color: Colors.blue[900], fontWeight: FontWeight.bold, letterSpacing: 8),
          decoration: InputDecoration(
            hintText: '••••',
            hintStyle: TextStyle(color: Colors.blue.withOpacity(0.3), letterSpacing: 8),
            filled: true,
            fillColor: Colors.white.withOpacity(0.7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (val) {
            if (val.length == 4) {
              _submitLogin();
            }
          },
        ),
        const SizedBox(height: 24),

        ElevatedButton(
          onPressed: _submitLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[600],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: const Text('Unlock Dashboard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            setState(() {
              _isSignUpMode = true;
              _errorMessage = null;
            });
          },
          child: Text('Reset App / Create New Profile', style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
