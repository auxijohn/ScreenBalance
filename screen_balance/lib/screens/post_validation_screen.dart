import 'package:flutter/material.dart';
import 'dart:ui';
import '../logic/intervention_engine.dart';

class PostValidationScreen extends StatefulWidget {
  const PostValidationScreen({super.key});

  @override
  State<PostValidationScreen> createState() => _PostValidationScreenState();
}

class _PostValidationScreenState extends State<PostValidationScreen> {
  String? _selectedMood;

  void _selectMood(String mood) {
    setState(() {
      _selectedMood = mood;
    });

    // Log the validation check to Behavioral History
    InterventionEngine().logEvent("Mood Validation Check", "Selected state: $mood");
    
    // Auto-pop after selection and show a nice feedback snackbar
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you! Regulated state logged.'),
          backgroundColor: Color(0xFF0D47A1),
        ),
      );
      Navigator.pop(context); // pop back
    });
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

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Mascot Image integration
                    Center(
                      child: Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(35),
                          child: Image.asset(
                            'assets/images/mascot.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Somatic Verification Check',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                        letterSpacing: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Which image aligns with your state?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose the geometric flow that mirrors your current mental baseline.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),

                    // Centered Wrap container instead of GridView to prevent giant desktop scaling and overflows
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 20,
                        runSpacing: 20,
                        children: [
                          _buildEntropyOption("Chaotic", const ChaoticFlowPainter(), "Chaotic / Scattered"),
                          _buildEntropyOption("Relaxed", const RelaxedFlowPainter(), "Relaxed / Grounded"),
                          _buildEntropyOption("Focused", const FocusedFlowPainter(), "Focused / Centered"),
                          _buildEntropyOption("Drained", const DrainedFlowPainter(), "Faded / Drained"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntropyOption(String key, CustomPainter painter, String label) {
    final isSelected = _selectedMood == key;
    return SizedBox(
      width: 170,
      height: 190,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white.withOpacity(0.95) : Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isSelected ? const Color(0xFF0D47A1) : Colors.white,
                width: isSelected ? 3.0 : 1.5,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 6))]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _selectMood(key),
                borderRadius: BorderRadius.circular(28),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: CustomPaint(painter: painter),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? const Color(0xFF0D47A1) : const Color(0xFF0A192F),
                        ),
                        textAlign: TextAlign.center,
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
}

// 1. Chaotic Flow Painter (Erratic red/orange zig-zag lines)
class ChaoticFlowPainter extends CustomPainter {
  const ChaoticFlowPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = Colors.deepOrangeAccent
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final paint2 = Paint()
      ..color = Colors.amber
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path1 = Path();
    path1.moveTo(size.width * 0.1, size.height * 0.7);
    path1.lineTo(size.width * 0.25, size.height * 0.2);
    path1.lineTo(size.width * 0.4, size.height * 0.8);
    path1.lineTo(size.width * 0.55, size.height * 0.3);
    path1.lineTo(size.width * 0.7, size.height * 0.85);
    path1.lineTo(size.width * 0.9, size.height * 0.15);

    final path2 = Path();
    path2.moveTo(size.width * 0.15, size.height * 0.4);
    path2.lineTo(size.width * 0.35, size.height * 0.8);
    path2.lineTo(size.width * 0.5, size.height * 0.15);
    path2.lineTo(size.width * 0.7, size.height * 0.6);
    path2.lineTo(size.width * 0.85, size.height * 0.3);

    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 2. Relaxed Flow Painter (Smooth calming blue/teal curves)
class RelaxedFlowPainter extends CustomPainter {
  const RelaxedFlowPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = const Color(0xFF0D47A1)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paint2 = Paint()
      ..color = Colors.teal[400]!
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path1 = Path();
    path1.moveTo(size.width * 0.05, size.height * 0.5);
    path1.cubicTo(
      size.width * 0.3, size.height * 0.1,
      size.width * 0.7, size.height * 0.9,
      size.width * 0.95, size.height * 0.5,
    );

    final path2 = Path();
    path2.moveTo(size.width * 0.05, size.height * 0.6);
    path2.cubicTo(
      size.width * 0.3, size.height * 0.85,
      size.width * 0.7, size.height * 0.35,
      size.width * 0.95, size.height * 0.6,
    );

    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 3. Focused Flow Painter (Concentric target circles)
class FocusedFlowPainter extends CustomPainter {
  const FocusedFlowPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.5);
    
    final paintOuter = Paint()
      ..color = const Color(0xFF0D47A1).withOpacity(0.4)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final paintInner = Paint()
      ..color = const Color(0xFF0D47A1)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final paintDot = Paint()
      ..color = Colors.teal[500]!
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, size.width * 0.35, paintOuter);
    canvas.drawCircle(center, size.width * 0.22, paintInner);
    canvas.drawCircle(center, size.width * 0.08, paintDot);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 4. Drained Flow Painter (Horizontal fading/descending lines)
class DrainedFlowPainter extends CustomPainter {
  const DrainedFlowPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = Colors.grey[500]!
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paint2 = Paint()
      ..color = Colors.grey[400]!.withOpacity(0.5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Fading horizontal step-down lines
    canvas.drawLine(
      Offset(size.width * 0.15, size.height * 0.3),
      Offset(size.width * 0.85, size.height * 0.3),
      paint1,
    );
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.55),
      Offset(size.width * 0.75, size.height * 0.55),
      paint2,
    );
    canvas.drawLine(
      Offset(size.width * 0.35, size.height * 0.8),
      Offset(size.width * 0.65, size.height * 0.8),
      paint2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
