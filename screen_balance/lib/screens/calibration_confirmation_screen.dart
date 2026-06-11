import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import 'quiz_screen.dart';

class CalibrationConfirmationScreen extends StatefulWidget {
  final String userName;
  final String userPin;
  final String ageGroup;
  final String occupation;
  final VoidCallback onAuthenticated;

  const CalibrationConfirmationScreen({
    super.key,
    required this.userName,
    required this.userPin,
    required this.ageGroup,
    required this.occupation,
    required this.onAuthenticated,
  });

  @override
  State<CalibrationConfirmationScreen> createState() => _CalibrationConfirmationScreenState();
}

class _CalibrationConfirmationScreenState extends State<CalibrationConfirmationScreen> with TickerProviderStateMixin {
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

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _sparkController.dispose();
    super.dispose();
  }

  Future<void> _submitCalibration() async {
    if (!_consentApproved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please check the authorization consent box to proceed.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final profile = UserProfile(
      name: widget.userName,
      ageGroup: widget.ageGroup,
      occupation: widget.occupation,
      calibrationPath: _selectedPath,
      observationDay: 1,
      isCalibrated: false,
    );
    
    await profile.saveToStorage();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_pin', widget.userPin);

    if (mounted) {
      if (_selectedPath == 'quiz') {
        // Start onboarding quiz
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizScreen(
              userName: widget.userName,
              onAuthenticated: widget.onAuthenticated,
            ),
          ),
        );
      } else {
        // Start passive 7-day observation, route straight to dashboard shell
        widget.onAuthenticated();
        Navigator.pop(context); // Pops CalibrationConfirmationScreen so root (DashboardShell) shows
      }
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
            child: Column(
              children: [
                // Top Custom Header Row with Back Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      const Row(
                        children: [
                          Icon(Icons.spa_rounded, color: Colors.white, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'ScreenBalance',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const SizedBox(width: 48), // Balancing width for back button
                    ],
                  ),
                ),
                
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Mascot Image
                          Container(
                            height: 100,
                            width: 100,
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
                              borderRadius: BorderRadius.circular(50),
                              child: Image.asset(
                                'assets/images/mascot.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  'Calibration Setup',
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

                                // User Consent Checkbox
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
                                  onPressed: _submitCalibration,
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
                          ),
                          
                          const SizedBox(height: 20),
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
}
