import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../models/quiz_data.dart';
import '../logic/quiz_engine.dart';
import '../models/user_profile.dart';

class Feather {
  double x; // Horizontal percentage (0..1)
  double y; // Vertical percentage (0..1)
  final double size;
  final double driftSpeed;
  final double floatSpeed;
  final double phase;
  final double baseRotation;

  Feather({
    required this.x,
    required this.y,
    required this.size,
    required this.driftSpeed,
    required this.floatSpeed,
    required this.phase,
    required this.baseRotation,
  });
}

class QuizScreen extends StatefulWidget {
  final String userName;
  final VoidCallback onAuthenticated;

  const QuizScreen({
    super.key,
    required this.userName,
    required this.onAuthenticated,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  final QuizEngine _engine = QuizEngine();
  int _currentIndex = 0;
  final Map<int, Option> _userAnswers = {};

  // Active highlighted option to simulate hover/tap glow
  Option? _selectedOption;

  // Organic Background elements
  final List<Feather> _feathers = [];
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    
    // Generate organic floating feathers
    final random = math.Random();
    for (int i = 0; i < 28; i++) {
      _feathers.add(Feather(
        x: random.nextDouble(),
        y: random.nextDouble() * 1.2, // Start some off screen bottom
        size: 10.0 + random.nextDouble() * 14.0, // Substantial feather size
        driftSpeed: 0.15 + random.nextDouble() * 0.25,
        floatSpeed: 0.08 + random.nextDouble() * 0.12,
        phase: random.nextDouble() * math.pi * 2,
        baseRotation: random.nextDouble() * math.pi * 2,
      ));
    }

    // Smooth natural breathing/drifting animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _answerQuestion(Option option) {
    setState(() {
      _selectedOption = option;
      _userAnswers[_currentIndex] = option;
    });

    // Short tactile pause before transition
    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;

      if (_currentIndex < QuizData.questions.length - 1) {
        setState(() {
          _currentIndex++;
          _selectedOption = _userAnswers[_currentIndex];
        });
      } else {
        // Tally all answers
        for (var i = 0; i < QuizData.questions.length; i++) {
          if (_userAnswers.containsKey(i)) {
            _engine.recordAnswer(_userAnswers[i]!);
          }
        }

        // Quiz completed, save profile and navigate to dashboard
        final details = _engine.getArchetypeDetails();
        final profile = UserProfile(
          name: widget.userName,
          activeIntentionCard: details,
          isCalibrated: true,
          calibrationPath: 'quiz',
        );
        profile.saveToStorage().then((_) {
          if (!mounted) return;
          widget.onAuthenticated();
          Navigator.popUntil(context, (route) => route.isFirst);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final question = QuizData.questions[_currentIndex];
    final progress = (_currentIndex + 1) / QuizData.questions.length;

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

          // 2. Animated Wellness Background (Floating Feathers, Drifting Breeze & Ambient Glowing Aura)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return CustomPaint(
                  painter: WellnessBackgroundPainter(
                    feathers: _feathers,
                    animationValue: _animationController.value,
                  ),
                );
              },
            ),
          ),

          // 3. Immersive Interactive UI overlay
          SafeArea(
            child: Column(
              children: [
                // Top Navigation & Progress Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                        onPressed: () {
                          if (_currentIndex > 0) {
                            setState(() {
                              _currentIndex--;
                              _selectedOption = _userAnswers[_currentIndex];
                            });
                          } else {
                            Navigator.pop(context);
                          }
                        },
                      ),
                      Expanded(
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.transparent,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${_currentIndex + 1}/${QuizData.questions.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Quiz Card Column
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.04, 0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          )),
                          child: child,
                        ),
                      );
                    },
                    child: LayoutBuilder(
                      key: ValueKey<int>(_currentIndex),
                      builder: (context, viewportConstraints) {
                        return SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: viewportConstraints.maxHeight - 32,
                            ),
                            child: IntrinsicHeight(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Glowing Habit Test Tag
                                   Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                                      ),
                                      child: Text(
                                        'DIGITAL HABIT TEST',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white.withOpacity(0.9),
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  
                                  // Question text with rich contrast
                                  Text(
                                    question.text,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      height: 1.35,
                                      letterSpacing: -0.3,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 40),

                                  // Interactive Option Cards (tactile glassmorphism)
                                  ...question.options.map((option) {
                                    final isSelected = _selectedOption == option;
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 14.0),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        curve: Curves.easeOut,
                                        decoration: BoxDecoration(
                                          color: isSelected 
                                              ? Colors.white
                                              : Colors.white.withOpacity(0.92),
                                          borderRadius: BorderRadius.circular(22),
                                          border: Border.all(
                                            color: isSelected 
                                                ? Colors.white
                                                : Colors.white.withOpacity(0.6),
                                            width: isSelected ? 2.5 : 1.2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.05),
                                              blurRadius: 20,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () => _answerQuestion(option),
                                            borderRadius: BorderRadius.circular(22),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 22),
                                              child: Row(
                                                children: [
                                                  // Glowing Radio Bullet
                                                  AnimatedContainer(
                                                    duration: const Duration(milliseconds: 200),
                                                    width: 18,
                                                    height: 18,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: isSelected ? const Color(0xFF0D47A1) : Colors.blue.withOpacity(0.3),
                                                        width: isSelected ? 5.5 : 1.5,
                                                      ),
                                                      color: isSelected ? Colors.white : Colors.transparent,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Text(
                                                      option.text,
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        color: const Color(0xFF0A192F),
                                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                                        height: 1.3,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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
}

class WellnessBackgroundPainter extends CustomPainter {
  final List<Feather> feathers;
  final double animationValue;

  WellnessBackgroundPainter({required this.feathers, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // 1. Draw Slow Breathing Wellness Sunburst Aura
    final auraCenter = Offset(size.width * 0.5, size.height * 0.85);
    final auraRadius = size.width * (0.65 + 0.08 * math.sin(animationValue * 2 * math.pi));
    final auraGradient = RadialGradient(
      colors: [
        Colors.blue[200]!.withOpacity(0.35), // Soft glowing blue
        Colors.lightBlue[100]!.withOpacity(0.15), // Soft sky blue
        Colors.transparent,
      ],
    );
    paint.shader = auraGradient.createShader(Rect.fromCircle(center: auraCenter, radius: auraRadius));
    canvas.drawCircle(auraCenter, auraRadius, paint);

    // 2. Draw Gentle Drifting Wind / Breeze Curves
    paint.shader = null;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.2;
    
    final path1 = Path();
    path1.moveTo(0, size.height * 0.35);
    path1.quadraticBezierTo(
      size.width * 0.3 + 20 * math.sin(animationValue * 2 * math.pi),
      size.height * 0.3 + 15 * math.cos(animationValue * 2 * math.pi),
      size.width,
      size.height * 0.4,
    );
    paint.color = Colors.white.withOpacity(0.12);
    canvas.drawPath(path1, paint);

    final path2 = Path();
    path2.moveTo(0, size.height * 0.6);
    path2.quadraticBezierTo(
      size.width * 0.7 - 20 * math.cos(animationValue * 2 * math.pi),
      size.height * 0.65 + 15 * math.sin(animationValue * 2 * math.pi),
      size.width,
      size.height * 0.5,
    );
    paint.color = Colors.blue.withOpacity(0.08);
    canvas.drawPath(path2, paint);

    // 3. Update & Draw Floating Feathers
    paint.style = PaintingStyle.fill;
    for (var feather in feathers) {
      // Float feather slowly upwards
      feather.y -= feather.floatSpeed * 0.0012;
      // Wrap around at the top of the screen
      if (feather.y < -0.05) {
        feather.y = 1.05;
        feather.x = math.Random().nextDouble();
      }
      
      // Swaying horizontal drift representing breeze currents
      final sway = math.sin(animationValue * 2 * math.pi * feather.driftSpeed + feather.phase);
      feather.x += sway * 0.0008;

      // Soft feather color: translucent white/teal
      final opacity = 0.15 + 0.15 * math.sin(animationValue * 2 * math.pi * 0.5 + feather.phase);
      final featherColor = Colors.white.withOpacity(opacity.clamp(0.05, 0.45));

      final offset = Offset(feather.x * size.width, feather.y * size.height);
      
      // Calculate dynamic wind rotation
      final rotation = feather.baseRotation + sway * 0.3;
      
      _drawFeather(canvas, offset, feather.size, rotation, featherColor);
    }
  }

  void _drawFeather(Canvas canvas, Offset center, double size, double rotation, Color color) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    
    // 1. Draw central shaft/rachis (slightly brighter, curved)
    final shaftPaint = Paint()
      ..color = Colors.white.withOpacity((color.opacity * 0.95).clamp(0.0, 1.0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;
      
    final shaftPath = Path();
    shaftPath.moveTo(0, -size);
    // Make it curve slightly to the right to look very natural and organic
    shaftPath.quadraticBezierTo(size * 0.08, -size * 0.2, 0, size * 1.1);
    canvas.drawPath(shaftPath, shaftPaint);
    
    // 2. Draw fine diagonal soft barbs (feather strands) branching off the central shaft
    final barbPaint = Paint()
      ..color = color.withOpacity((color.opacity * 0.85).clamp(0.0, 1.0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round;
      
    const barbCount = 18;
    for (int i = 0; i < barbCount; i++) {
      // t goes from 0.0 (top tip of feather) to 1.0 (bottom base of feather)
      final t = i / (barbCount - 1);
      
      // Interpolate along the shaft curve to find the exact start point for each barb
      final double y = -size + (size * 2.1) * t;
      // Approximate the slight curve of the shaft at y
      final double shaftX = size * 0.08 * (1.0 - (y / size).abs());
      
      // The barbs are wider in the middle-bottom section of the feather and taper at the tip and base
      final double barbLength = size * 0.45 * math.sin(t * math.pi);
      
      // Angle the barbs upwards towards the tip of the feather (sharper angle near the top)
      final double angleFactor = 0.35 + 0.45 * (1.0 - t);
      
      // Draw left barb (extends out and curves slightly up)
      canvas.drawLine(
        Offset(shaftX, y),
        Offset(shaftX - barbLength, y - barbLength * angleFactor),
        barbPaint,
      );
      
      // Draw right barb (extends out and curves slightly up)
      canvas.drawLine(
        Offset(shaftX, y),
        Offset(shaftX + barbLength, y - barbLength * angleFactor),
        barbPaint,
      );
    }
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant WellnessBackgroundPainter oldDelegate) {
    return true; // Repaint continuously to support smooth feather floating
  }
}
