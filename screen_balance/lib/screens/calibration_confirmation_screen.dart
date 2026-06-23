import 'package:flutter/material.dart';
import 'dart:ui';
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
  String _selectedPath = 'quiz'; // 'quiz' or 'observe'

  // Entrance & Interactive Animations
  late final AnimationController _entranceController;
  
  late final Animation<double> _quizFade;
  late final Animation<Offset> _quizSlide;
  
  late final Animation<double> _observeFade;
  late final Animation<Offset> _observeSlide;

  @override
  void initState() {
    super.initState();
    
    // Entrance animations
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

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

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _submitCalibration({String? path}) async {
    final activePath = path ?? _selectedPath;
    final profile = UserProfile(
      name: widget.userName,
      ageGroup: widget.ageGroup,
      occupation: widget.occupation,
      calibrationPath: activePath,
      observationDay: 1,
      isCalibrated: false,
    );
    
    await profile.saveToStorage();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_pin', widget.userPin);

    if (mounted) {
      if (activePath == 'quiz') {
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

                          const Text(
                            'Calibration Setup',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Option 1: Quiz Option Card
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

                          // Option 2: 7-Day Observation Card
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
                          const SizedBox(height: 12),

                          // Submit Action Button
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
                              onPressed: _submitCalibration,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: Text(
                                _selectedPath == 'quiz' ? 'Initialize & Begin Quiz' : 'Initialize & Start Calibration',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
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
    final cardBorderColor = isSelected ? const Color(0xFF00F2FE) : Colors.white.withOpacity(0.12);
    final cardBgColor = isSelected ? const Color(0xFF00F2FE).withOpacity(0.08) : Colors.white.withOpacity(0.04);
    final cardBorderWidth = isSelected ? 2.0 : 1.5;
    
    return InkWell(
      onTap: () async {
        setState(() {
          _selectedPath = id;
        });
        await _submitCalibration(path: id);
      },
      borderRadius: BorderRadius.circular(24),
      child: AnimatedScale(
        scale: isSelected ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: cardBorderColor,
              width: cardBorderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected ? const Color(0xFF00F2FE).withOpacity(0.15) : Colors.black.withOpacity(0.1),
                blurRadius: isSelected ? 24 : 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF00F2FE).withOpacity(0.15) : Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon, 
                        color: isSelected ? const Color(0xFF00F2FE) : Colors.white70, 
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? const Color(0xFF00F2FE) : Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            desc,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.7),
                              height: 1.4,
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
        ),
      ),
    );
  }
}
