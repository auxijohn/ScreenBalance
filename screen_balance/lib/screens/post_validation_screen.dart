import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../logic/intervention_engine.dart';

class PostValidationScreen extends StatefulWidget {
  const PostValidationScreen({super.key});

  @override
  State<PostValidationScreen> createState() => _PostValidationScreenState();
}

class _PostValidationScreenState extends State<PostValidationScreen> {
  String? _selectedMood;

  // Randomized painter parameters generated once per screen load
  late List<Offset> _chaoticPoints1;
  late List<Offset> _chaoticPoints2;
  late List<double> _relaxedYFactors;
  late Offset _focusedCenterOffset;
  late Offset _focusedDotOffset;
  late List<double> _focusedRadii;
  late List<List<double>> _drainedLineFactors;

  @override
  void initState() {
    super.initState();
    _randomizePainters();
  }

  void _randomizePainters() {
    final random = math.Random();
    
    // 1. Chaotic
    _chaoticPoints1 = List.generate(6, (i) {
      final x = 0.1 + (0.8 * i / 5);
      final y = 0.15 + 0.7 * random.nextDouble();
      return Offset(x, y);
    });
    _chaoticPoints2 = List.generate(5, (i) {
      final x = 0.15 + (0.7 * i / 4);
      final y = 0.15 + 0.7 * random.nextDouble();
      return Offset(x, y);
    });

    // 2. Relaxed
    _relaxedYFactors = List.generate(8, (_) => 0.15 + 0.7 * random.nextDouble());

    // 3. Focused
    _focusedCenterOffset = Offset(
      -0.08 + 0.16 * random.nextDouble(),
      -0.08 + 0.16 * random.nextDouble(),
    );
    _focusedDotOffset = Offset(
      -0.05 + 0.10 * random.nextDouble(),
      -0.05 + 0.10 * random.nextDouble(),
    );
    _focusedRadii = [
      0.30 + 0.08 * random.nextDouble(),
      0.18 + 0.06 * random.nextDouble(),
    ];

    // 4. Drained
    _drainedLineFactors = List.generate(4, (i) {
      final y = 0.25 + 0.5 * (i / 3) + (random.nextDouble() * 0.05);
      final start = 0.1 + 0.15 * random.nextDouble();
      final end = 0.75 + 0.15 * random.nextDouble();
      final opacity = 0.15 + 0.65 * random.nextDouble();
      final stroke = 1.5 + 2.0 * random.nextDouble();
      return [y, start, end, opacity, stroke];
    });
  }

  void _selectMood(String mood) {
    setState(() {
      _selectedMood = mood;
    });

    // Log the validation check to Behavioral History
    InterventionEngine().logEvent("Mood Validation Check", "Selected state: $mood");
    
    String predictedState;
    switch (mood) {
      case 'Chaotic':
        predictedState = 'Chaotic / Scattered';
        break;
      case 'Relaxed':
        predictedState = 'Relaxed / Grounded';
        break;
      case 'Focused':
        predictedState = 'Focused / Centered';
        break;
      case 'Drained':
        predictedState = 'Faded / Drained';
        break;
      default:
        predictedState = mood;
    }

    // Auto-pop after selection and show a nice feedback snackbar
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Predicted state: $predictedState. Regulated state logged.'),
          backgroundColor: const Color(0xFF0D47A1),
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
                          _buildEntropyOption("Chaotic", ChaoticFlowPainter(points1: _chaoticPoints1, points2: _chaoticPoints2)),
                          _buildEntropyOption("Relaxed", RelaxedFlowPainter(yFactors: _relaxedYFactors)),
                          _buildEntropyOption("Focused", FocusedFlowPainter(centerOffset: _focusedCenterOffset, dotOffset: _focusedDotOffset, radii: _focusedRadii)),
                          _buildEntropyOption("Drained", DrainedFlowPainter(lineFactors: _drainedLineFactors)),
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

  Widget _buildEntropyOption(String key, CustomPainter painter) {
    final isSelected = _selectedMood == key;
    return SizedBox(
      width: 170,
      height: 170,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isSelected ? const Color(0xFF0D47A1) : Colors.white.withOpacity(0.95),
            width: isSelected ? 3.0 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
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
                ],
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
  final List<Offset> points1;
  final List<Offset> points2;

  const ChaoticFlowPainter({required this.points1, required this.points2});

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
    if (points1.isNotEmpty) {
      path1.moveTo(points1[0].dx * size.width, points1[0].dy * size.height);
      for (int i = 1; i < points1.length; i++) {
        path1.lineTo(points1[i].dx * size.width, points1[i].dy * size.height);
      }
    }

    final path2 = Path();
    if (points2.isNotEmpty) {
      path2.moveTo(points2[0].dx * size.width, points2[0].dy * size.height);
      for (int i = 1; i < points2.length; i++) {
        path2.lineTo(points2[i].dx * size.width, points2[i].dy * size.height);
      }
    }

    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 2. Relaxed Flow Painter (Smooth calming blue/teal curves)
class RelaxedFlowPainter extends CustomPainter {
  final List<double> yFactors;

  const RelaxedFlowPainter({required this.yFactors});

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
    path1.moveTo(size.width * 0.05, size.height * yFactors[0]);
    path1.cubicTo(
      size.width * 0.3, size.height * yFactors[1],
      size.width * 0.7, size.height * yFactors[2],
      size.width * 0.95, size.height * yFactors[3],
    );

    final path2 = Path();
    path2.moveTo(size.width * 0.05, size.height * yFactors[4]);
    path2.cubicTo(
      size.width * 0.3, size.height * yFactors[5],
      size.width * 0.7, size.height * yFactors[6],
      size.width * 0.95, size.height * yFactors[7],
    );

    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 3. Focused Flow Painter (Concentric target circles)
class FocusedFlowPainter extends CustomPainter {
  final Offset centerOffset;
  final Offset dotOffset;
  final List<double> radii;

  const FocusedFlowPainter({
    required this.centerOffset,
    required this.dotOffset,
    required this.radii,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width * 0.5 + centerOffset.dx * size.width,
      size.height * 0.5 + centerOffset.dy * size.height,
    );
    
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

    canvas.drawCircle(center, size.width * radii[0], paintOuter);
    canvas.drawCircle(center, size.width * radii[1], paintInner);
    
    final dotCenter = Offset(
      center.dx + dotOffset.dx * size.width,
      center.dy + dotOffset.dy * size.height,
    );
    canvas.drawCircle(dotCenter, size.width * 0.08, paintDot);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 4. Drained Flow Painter (Horizontal fading/descending lines)
class DrainedFlowPainter extends CustomPainter {
  final List<List<double>> lineFactors;

  const DrainedFlowPainter({required this.lineFactors});

  @override
  void paint(Canvas canvas, Size size) {
    for (var factor in lineFactors) {
      final y = factor[0] * size.height;
      final start = factor[1] * size.width;
      final end = factor[2] * size.width;
      final opacity = factor[3];
      final stroke = factor[4];

      final paint = Paint()
        ..color = Colors.grey[500]!.withOpacity(opacity)
        ..strokeWidth = stroke
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(Offset(start, y), Offset(end, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
