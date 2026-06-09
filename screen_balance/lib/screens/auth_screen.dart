import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import 'quiz_screen.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback onAuthenticated;
  const AuthScreen({super.key, required this.onAuthenticated});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _loginPinController = TextEditingController();
  
  String _ageGroup = '18-24';
  String _occupation = 'Student';
  bool _isSignUpMode = true;
  String _storedName = '';
  String _storedPin = '';
  String? _errorMessage;

  // Calibration Onboarding state
  bool _consentApproved = false;
  String _selectedPath = 'quiz'; // 'quiz' or 'observe'

  // Entrance & Interactive Animations
  late final AnimationController _entranceController;
  late final Animation<double> _bannerFade;
  late final Animation<Offset> _bannerSlide;
  
  late final Animation<double> _quizFade;
  late final Animation<Offset> _quizSlide;
  
  late final Animation<double> _observeFade;
  late final Animation<Offset> _observeSlide;

  late final AnimationController _sparkController;
  late final Animation<double> _sparkPulse;

  @override
  void initState() {
    super.initState();
    
    // Entrance animations
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _bannerFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _bannerSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    ));

    _quizFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.25, 0.8, curve: Curves.easeOut),
    );
    _quizSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.25, 0.8, curve: Curves.easeOutCubic),
    ));

    _observeFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
    );
    _observeSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.45, 1.0, curve: Curves.easeOutCubic),
    ));

    // Spark gentle icon pulse
    _sparkController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    
    _sparkPulse = Tween<double>(begin: 0.9, end: 1.25).animate(
      CurvedAnimation(parent: _sparkController, curve: Curves.easeInOut),
    );

    _checkExistingProfile();
    
    // Start entrance animation
    _entranceController.forward();
  }

  Future<void> _checkExistingProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final pin = prefs.getString('user_pin') ?? '';
    final profile = await UserProfile.loadFromStorage();
    if (profile != null && pin.isNotEmpty) {
      setState(() {
        _isSignUpMode = false;
        _storedName = profile.name;
        _storedPin = pin;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pinController.dispose();
    _loginPinController.dispose();
    _entranceController.dispose();
    _sparkController.dispose();
    super.dispose();
  }

  Future<void> _submitRegister() async {
    if (!_consentApproved) {
      setState(() {
        _errorMessage = 'Consent approval is required to calibrate your pattern.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please check the authorization consent box to proceed.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final pin = _pinController.text.trim();
      
      final profile = UserProfile(
        name: name,
        ageGroup: _ageGroup,
        occupation: _occupation,
        calibrationPath: _selectedPath,
        observationDay: 1,
        isCalibrated: false,
      );
      
      await profile.saveToStorage();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_pin', pin);

      if (mounted) {
        if (_selectedPath == 'quiz') {
          // Start onboarding quiz
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizScreen(
                userName: name,
                onAuthenticated: widget.onAuthenticated,
              ),
            ),
          );
        } else {
          // Start passive 7-day observation, route straight to dashboard shell
          widget.onAuthenticated();
        }
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
    return Scaffold(
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
                    // Mascot Image (re-added as requested)
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
          const SizedBox(height: 16),

          // Quick App Intro Banner
          FadeTransition(
            opacity: _bannerFade,
            child: SlideTransition(
              position: _bannerSlide,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue[100]!, width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AnimatedBuilder(
                          animation: _sparkPulse,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _sparkController.value * 0.15 * math.pi,
                              child: Transform.scale(
                                scale: _sparkPulse.value,
                                child: Icon(Icons.auto_awesome, color: Colors.blue[800], size: 18),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Your Digital Harmony Companion",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D47A1),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "ScreenBalance acts as an ambient companion, subtly mapping your screen rhythms to build a personalized portrait of your digital wellness. When focus drifts or stress loops trigger, it delivers gentle, real-time somatic resets to guide you back to center.",
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
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
          const SizedBox(height: 16),

          // User Consent Switch/Checkbox
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.15)),
            ),
            child: CheckboxListTile(
              value: _consentApproved,
              onChanged: (val) {
                setState(() {
                  _consentApproved = val ?? false;
                });
              },
              title: const Text(
                "I authorize ScreenBalance to observe screen patterns to calibrate my focus pattern.",
                style: TextStyle(fontSize: 10.5, color: Colors.black87, fontWeight: FontWeight.w500),
              ),
              activeColor: const Color(0xFF0D47A1),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ),
          const SizedBox(height: 16),

          // Calibration Path Choice
          const Text(
            "SELECT CALIBRATION METHOD",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D47A1),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),

          FadeTransition(
            opacity: _quizFade,
            child: SlideTransition(
              position: _quizSlide,
              child: _buildPathCard(
                id: 'quiz',
                icon: Icons.question_answer_outlined,
                title: "Take Instant Quiz (3 mins)",
                desc: "Answer 10 brief, intuitive questions about your screen habits to immediately reveal your digital wellness archetype and unlock your first custom Intervention Card.",
              ),
            ),
          ),
          const SizedBox(height: 8),

          FadeTransition(
            opacity: _observeFade,
            child: SlideTransition(
              position: _observeSlide,
              child: _buildPathCard(
                id: 'observe',
                icon: Icons.visibility_outlined,
                title: "7-Day Background Calibration",
                desc: "Embark on a silent 7-day observation. ScreenBalance will quietly calibrate your natural interaction patterns in the background to build an in-depth focus profile without manual tracking.",
              ),
            ),
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
            child: Text(
              _selectedPath == 'quiz' ? 'Initialize & Begin Quiz' : 'Initialize & Start Calibration',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPathCard({
    required String id,
    required IconData icon,
    required String title,
    required String desc,
  }) {
    final isSelected = _selectedPath == id;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPath = id;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedScale(
        scale: isSelected ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected 
                ? const Color(0xFF0D47A1).withOpacity(0.06) 
                : Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected 
                  ? const Color(0xFF0D47A1) 
                  : Colors.grey.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF0D47A1).withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    )
                  ]
                : [],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF0D47A1).withOpacity(0.12) : Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon, 
                  color: isSelected ? const Color(0xFF0D47A1) : Colors.grey[600], 
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? const Color(0xFF0D47A1) : const Color(0xFF0A192F),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? Colors.black87 : Colors.black54,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
            _entranceController.forward(from: 0.0);
          },
          child: Text('Reset App / Create New Profile', style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
