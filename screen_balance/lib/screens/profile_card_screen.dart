import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/boundary_settings.dart';
import '../logic/intervention_engine.dart';
import 'quiz_screen.dart';

class ProfileCardScreen extends StatefulWidget {
  final UserProfile profile;
  final VoidCallback onProfileUpdated;
  final VoidCallback onLogout;

  const ProfileCardScreen({
    super.key,
    required this.profile,
    required this.onProfileUpdated,
    required this.onLogout,
  });

  @override
  State<ProfileCardScreen> createState() => _ProfileCardScreenState();
}

class _ProfileCardScreenState extends State<ProfileCardScreen> with SingleTickerProviderStateMixin {
  // Habit checkbox state
  final List<bool> _habitChecks = [false, false, false];

  // Dynamically calculate metrics based on the archetype
  late double _dopamineReactivity;
  late double _phantomHabitUrge;
  late double _focusImpact;
  late List<String> _tailoredHabits;

  // Animation controller for radar pulse
  late AnimationController _radarController;
  
  // Real-time telemetry event bus subscription
  StreamSubscription? _eventSubscription;

  // 7-day observation simulation data
  final List<Map<String, dynamic>> _observationDaysData = [
    {'focus': 45, 'sleep': 6.2, 'distractions': 28, 'status': 'Day 1 Active'},
    {'focus': 52, 'sleep': 6.8, 'distractions': 22, 'status': 'Calibrating...'},
    {'focus': 63, 'sleep': 7.0, 'distractions': 16, 'status': 'Syncing...'},
    {'focus': 50, 'sleep': 5.5, 'distractions': 29, 'status': 'Calibrating...'},
    {'focus': 75, 'sleep': 7.4, 'distractions': 11, 'status': 'Pattern Identified...'},
    {'focus': 82, 'sleep': 7.8, 'distractions': 8, 'status': 'Refining details...'},
    {'focus': 90, 'sleep': 8.1, 'distractions': 4, 'status': 'Calibration complete!'},
  ];

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _initializeArchetypeData();
    
    // Refresh stats when any lock, unlock, app open, or intervention triggers
    _eventSubscription = InterventionEngine().eventBusStream.stream.listen((event) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _radarController.dispose();
    _eventSubscription?.cancel();
    super.dispose();
  }

  void _initializeArchetypeData() {
    final title = widget.profile.activeIntentionCard['title'] ?? 'The Intentional Seeker';

    if (title.contains('Morning Scroller')) {
      _dopamineReactivity = 0.75;
      _phantomHabitUrge = 0.60;
      _focusImpact = 0.65;
      _tailoredHabits = [
        "Wait 15 minutes after waking up before picking up your phone.",
        "Stretch or drink a full glass of water first.",
        "Do a brief, 5-minute screen-free breathing check-in."
      ];
    } else if (title.contains('Evening Escapist')) {
      _dopamineReactivity = 0.70;
      _phantomHabitUrge = 0.55;
      _focusImpact = 0.90; // High sleep/evening impact
      _tailoredHabits = [
        "Turn off your device exactly 30 minutes before bedtime.",
        "Place your phone charger across the room or in another drawer.",
        "Perform a progress somatic body scan to ease tension before sleep."
      ];
    } else if (title.contains('Midday Slumper')) {
      _dopamineReactivity = 0.85; // High dopamine seek
      _phantomHabitUrge = 0.65;
      _focusImpact = 0.50;
      _tailoredHabits = [
        "Replace your afternoon screen scroll with a brief 5-minute walk.",
        "Look out a window at the distant sky for 60 seconds (The Sky Reset).",
        "Drink a cold glass of lemon water to stimulate energy naturally."
      ];
    } else if (title.contains('Task Avoidant')) {
      _dopamineReactivity = 0.90; // High avoidance
      _phantomHabitUrge = 0.70;
      _focusImpact = 0.80;
      _tailoredHabits = [
        "Commit to sitting with task-boredom for 90 seconds without unlocking.",
        "Keep non-work app tabs completely closed during deep focus sprints.",
        "Reward a completed focus session with 3 deep, restorative breaths."
      ];
    } else if (title.contains('Phantom Checker')) {
      _dopamineReactivity = 0.60;
      _phantomHabitUrge = 0.95; // Extreme habit loop
      _focusImpact = 0.55;
      _tailoredHabits = [
        "Put your phone in a desk drawer or bag instead of keeping it in view.",
        "Perform a physical shoulder roll when you feel the check urge arise.",
        "Turn off all non-human notifications (newsletters, reminders)."
      ];
    } else if (title.contains('Notification Reactive')) {
      _dopamineReactivity = 0.80;
      _phantomHabitUrge = 0.75;
      _focusImpact = 0.70;
      _tailoredHabits = [
        "Disable lock-screen banners for all social apps.",
        "Put your phone on 'Do Not Disturb' during focused work sessions.",
        "Batch check messages 3 times a day instead of instantly replying."
      ];
    } else if (title.contains('Doomscroller')) {
      _dopamineReactivity = 0.85;
      _phantomHabitUrge = 0.80;
      _focusImpact = 0.85;
      _tailoredHabits = [
        "Unfollow anxiety-inducing channels and news alerts.",
        "Limit news/feed reviews strictly to once in the morning.",
        "Trigger the 'Darkroom Reset' when negative scroll loops take over."
      ];
    } else if (title.contains('Social Comparer')) {
      _dopamineReactivity = 0.75;
      _phantomHabitUrge = 0.70;
      _focusImpact = 0.75;
      _tailoredHabits = [
        "Limit social feed consumption to 15 minutes a day.",
        "Write down three personal wins before opening social feeds.",
        "Channel scroll urges into a simple physical creative project."
      ];
    } else {
      _dopamineReactivity = 0.50;
      _phantomHabitUrge = 0.50;
      _focusImpact = 0.50;
      _tailoredHabits = [
        "Implement a 30-minute screen-free morning buffer zone.",
        "Disconnect your screens 30 minutes before turning off lights.",
        "Exempt critical banking, map, and utility apps from block lists."
      ];
    }
  }

  // Trigger a full profile reset to return to onboarding selection
  Future<void> _resetProfile() async {
    widget.profile.isCalibrated = false;
    widget.profile.calibrationPath = 'quiz';
    widget.profile.observationDay = 1;
    widget.profile.activeIntentionCard = const {
      'title': 'The Intentional Seeker',
      'emoji': '🌱',
      'subtitle': 'Digital Growth',
      'description': 'You are looking to build healthier boundaries. We will build a customized system to protect your peace and focus.'
    };
    await widget.profile.saveToStorage();
    
    // Clear boundary settings
    await BoundarySettings.clearFromStorage();
    
    // Clear user_pin to force AuthScreen registers
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_pin');
    
    widget.onProfileUpdated();
    widget.onLogout();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile reset successful. Welcome screen reloaded.')),
      );
    }
  }

  Widget _buildGlassCard({required Widget child, EdgeInsetsGeometry? padding, double borderRadius = 28}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding ?? const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  void _showProfileDetailsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          content: _buildGlassCard(
            borderRadius: 28,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_circle, color: Color(0xFF00F2FE), size: 28),
                    const SizedBox(width: 12),
                    const Text(
                      'Profile Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildProfileDetailRow('Name', widget.profile.name),
                const Divider(height: 20, color: Colors.white10),
                _buildProfileDetailRow('Age Group', widget.profile.ageGroup),
                const Divider(height: 20, color: Colors.white10),
                _buildProfileDetailRow('Occupation', widget.profile.occupation),
                const Divider(height: 20, color: Colors.white10),
                _buildProfileDetailRow(
                  'Calibration',
                  widget.profile.calibrationPath == 'quiz' ? 'Interactive Quiz' : '7-Day Observation',
                ),
                const Divider(height: 20, color: Colors.white10),
                _buildProfileDetailRow(
                  'Status',
                  widget.profile.isCalibrated ? 'Calibrated' : 'Calibration Pending',
                  valueColor: widget.profile.isCalibrated ? const Color(0xFF00E5FF) : Colors.orangeAccent,
                ),
                const SizedBox(height: 24),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF00F2FE),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.white.withOpacity(0.12)),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white60,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: valueColor ?? Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // 7-Day Calibration View for Passive Observation Path
  Widget _buildCalibrationView() {
    final currentDay = widget.profile.observationDay.clamp(1, 7);
    final data = _observationDaysData[currentDay - 1];
    final progress = currentDay / 7.0;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
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
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Bar with reset trigger
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'FOCUS PATTERN SYNC',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                          letterSpacing: 1.5,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white70),
                        tooltip: "Reset & Onboard again",
                        onPressed: _resetProfile,
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  const Text(
                    "Calibration Active",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "ScreenBalance is quietly calibrating your natural interaction patterns and sleep cadences in the background. Your custom focus profile will unlock once calibration is complete.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12.5, color: Colors.white70, height: 1.45),
                  ),
                  const SizedBox(height: 32),

                  // Radar Pulse Circle Graphic
                  Center(
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.03),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _radarController,
                            builder: (context, child) {
                              return CustomPaint(
                                size: const Size(150, 150),
                                painter: RadarWavePainter(_radarController.value),
                              );
                            },
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "DAY",
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white60),
                              ),
                              Text(
                                "$currentDay",
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF00E5FF),
                                  height: 1.1,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Circular Progress Bar
                  _buildGlassCard(
                    borderRadius: 24,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor: Colors.white.withOpacity(0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Calibration Progress",
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF00F2FE)),
                            ),
                            Text(
                              "${(progress * 100).toInt()}% Done",
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Status: ${data['status']}",
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.redAccent),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Metrics cards grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildGlassCard(
                          borderRadius: 20,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Focus Index", style: TextStyle(fontSize: 11, color: Colors.white60, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text("${data['focus']}%", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildGlassCard(
                          borderRadius: 20,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Sleep Log", style: TextStyle(fontSize: 11, color: Colors.white60, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text("${data['sleep']} hrs", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Distractions
                  _buildGlassCard(
                    borderRadius: 20,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Context Interruptions Logged", style: TextStyle(fontSize: 12, color: Colors.white60, fontWeight: FontWeight.bold)),
                        Text("${data['distractions']} times", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Focus Chart
                  const Text(
                    "DAILY FOCUS PROFILE CHART",
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white60, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 10),
                  _buildGlassCard(
                    borderRadius: 24,
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      height: 78,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(7, (index) {
                          final isCompleted = (index + 1) <= currentDay;
                          final isCurrent = (index + 1) == currentDay;
                          final dayFocus = _observationDaysData[index]['focus'];

                          return Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Container(
                                    width: 14,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: isCompleted
                                            ? (isCurrent
                                                ? [const Color(0xFF00E5FF).withOpacity(0.4), const Color(0xFF00E5FF)]
                                                : [const Color(0xFF00F2FE).withOpacity(0.4), const Color(0xFF00F2FE)])
                                            : [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.1)],
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    height: isCompleted ? (dayFocus.toDouble()) : 0.0,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text("D${index + 1}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white60)),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Simulation Panel Controls
                  _buildGlassCard(
                    borderRadius: 24,
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "TIME ACCELERATOR UTILITY",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 1.2),
                        ),
                        const SizedBox(height: 12),
                        if (currentDay < 7)
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF00F2FE), Color(0xFF0D47A1)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              icon: const Icon(Icons.fast_forward, size: 18),
                              label: const Text("Simulate Next Day", style: TextStyle(fontWeight: FontWeight.bold)),
                              onPressed: () async {
                                widget.profile.observationDay++;
                                await widget.profile.saveToStorage();
                                widget.onProfileUpdated();
                                
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Passive Calibration: Day ${widget.profile.observationDay} sync complete.'),
                                      backgroundColor: const Color(0xFF00E5FF),
                                    ),
                                  );
                                }
                              },
                            ),
                          )
                        else
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF00F2FE), Color(0xFF0D47A1)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              icon: const Icon(Icons.auto_awesome, size: 18),
                              label: const Text("Reveal Intervention Card", style: TextStyle(fontWeight: FontWeight.w800)),
                              onPressed: () async {
                                widget.profile.isCalibrated = true;
                                // Passive calibration yields the Circadian Chrono Shift
                                widget.profile.activeIntentionCard = const {
                                  'title': 'Circadian Chrono Shift',
                                  'emoji': '🌙',
                                  'subtitle': 'Bio-Sync Protocol',
                                  'description': 'Designed for deep-wave focus structures. Your peak performance window is late afternoon/evening, requiring morning shielding blocks to protect energy reserves.'
                                };
                                await widget.profile.saveToStorage();
                                
                                // Trigger reload
                                widget.onProfileUpdated();

                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Pattern Calibrated! Circadian Chrono Shift card unlocked.'),
                                      backgroundColor: Color(0xFF0D47A1),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Quiz Path pending screen
  Widget _buildUncalibratedQuizView() {
    return Scaffold(
      body: Stack(
        children: [
          Container(
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
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28.0),
                child: _buildGlassCard(
                  borderRadius: 28,
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.help_outline_outlined, size: 60, color: Color(0xFF00F2FE)),
                      const SizedBox(height: 24),
                      const Text(
                        "Calibration Pending",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Your profile focus pattern has not been calibrated yet. Take the digital habit quiz to identify your active intervention settings.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.white70, height: 1.4),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00F2FE), Color(0xFF0D47A1)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QuizScreen(
                                  userName: widget.profile.name,
                                  onAuthenticated: widget.onProfileUpdated,
                                ),
                              ),
                            );
                          },
                          child: const Text("Start Calibration Quiz", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _resetProfile,
                        child: const Text("Back to Welcome Onboarding", style: TextStyle(color: Colors.white70)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.profile.isCalibrated) {
      if (widget.profile.calibrationPath == 'observe') {
        return _buildCalibrationView();
      } else {
        return _buildUncalibratedQuizView();
      }
    }



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

          // 2. Ambient soft lighting glow (top left)
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),

          // Ambient soft lighting glow (bottom right)
          Positioned(
            bottom: 100,
            right: -50,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.03),
              ),
            ),
          ),

          // 3. Watermarked Mascot image on the bottom right background
          Positioned(
            bottom: 40,
            right: -40,
            child: Opacity(
              opacity: 0.12,
              child: Image.asset(
                'assets/images/mascot.png',
                width: 300,
                height: 300,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // 4. Watermarked Mascot image on the top left background
          Positioned(
            top: 100,
            left: -40,
            child: Opacity(
              opacity: 0.10,
              child: Image.asset(
                'assets/images/mascot.png',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // 5. Main Dashboard Interactive UI Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Wellness Dashboard',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _showProfileDetailsDialog,
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.person_outline, size: 14, color: Colors.white),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.profile.name,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.refresh, color: Colors.white70, size: 20),
                            tooltip: "Logout & Reset Profile",
                            onPressed: _resetProfile,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Archetype Presentation White/Glass Card
                  _buildGlassCard(
                    padding: const EdgeInsets.all(28),
                    borderRadius: 32,
                    child: Column(
                      children: [
                        // Mascot Image container (reverted back to default mascot representation)
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF00F2FE), width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: Image.asset(
                              'assets/images/mascot.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        const Text(
                          'DIGITAL PROFILE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00F2FE),
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 10),
                        
                        Text(
                          widget.profile.activeIntentionCard['title'] ?? 'The Intentional Seeker',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.2,
                            ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "(${widget.profile.activeIntentionCard['subtitle'] ?? 'Digital Growth'})",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF00E5FF),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Divider(height: 40, color: Colors.white10),
                        
                        Text(
                          widget.profile.activeIntentionCard['description'] ?? 'Your digital wellness boundary configurations.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Digital Mindfulness Score (White Card)
                  Builder(
                    builder: (context) {
                      final score = InterventionEngine().getDigitalMindfulnessScore();
                      final double scoreFraction = score / 100.0;
                      final phraseData = InterventionEngine().getMindfulnessPhrase(score);
                      final phraseTitle = phraseData['title'] ?? '';
                      final phraseDesc = phraseData['description'] ?? '';

                      Color scoreColor = const Color(0xFF00BFA5); // Teal
                      if (score >= 90) {
                        scoreColor = const Color(0xFF00E5FF); // Cyan
                      } else if (score >= 75) {
                        scoreColor = Colors.green[600]!;
                      } else if (score >= 60) {
                        scoreColor = Colors.amber[700]!;
                      } else if (score >= 40) {
                        scoreColor = Colors.orange[800]!;
                      } else {
                        scoreColor = Colors.redAccent;
                      }

                      final totalInterventions = InterventionEngine().behavioralHistory.where((e) => e.eventType == "Intervention Triggered").length;

                      return _buildGlassCard(
                        padding: const EdgeInsets.all(24),
                        borderRadius: 28,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'DIGITAL MINDFULNESS SCORE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00F2FE),
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Minimalist Solar Eclipse Graphic
                                SizedBox(
                                  width: 90,
                                  height: 90,
                                  child: CustomPaint(
                                    painter: SolarEclipsePainter(
                                      scoreFraction: scoreFraction,
                                      glowColor: scoreColor,
                                      score: score,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 24),
                                
                                // Details Column
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: const [
// Score is now rendered inside the SolarEclipsePainter graphic
// The large numeric display has been removed to avoid duplication
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      
                                      // Category title badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: scoreColor.withOpacity(0.10),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: scoreColor.withOpacity(0.25), width: 1),
                                        ),
                                        child: Text(
                                          phraseTitle.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: scoreColor,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Description text below the graphic
                            Text(
                              phraseDesc,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                                height: 1.45,
                              ),
                            ),
                            const Divider(height: 32, color: Colors.white10),
                            
                            // Daily Activity Telemetry Row
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTelemetryStats(
                                    icon: Icons.screen_lock_portrait,
                                    label: 'Daily Unlocks',
                                    value: '${InterventionEngine().unlockCountToday}',
                                    color: const Color(0xFF00F2FE),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTelemetryStats(
                                    icon: Icons.privacy_tip_outlined,
                                    label: 'Interventions',
                                    value: '$totalInterventions',
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Digital Vulnerability Metric Gauges (White Card)
                  _buildGlassCard(
                    padding: const EdgeInsets.all(24),
                    borderRadius: 28,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'VULNERABILITY METRICS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00F2FE),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        _buildMetricProgress(
                          label: "Dopamine Sensitivity",
                          value: _dopamineReactivity,
                          color: Colors.amber[700]!,
                          tooltip: "Measures susceptibility to immediate gratification loop triggers.",
                        ),
                        const SizedBox(height: 16),
                        
                        _buildMetricProgress(
                          label: "Phantom Habit Strength",
                          value: _phantomHabitUrge,
                          color: Colors.deepOrangeAccent,
                          tooltip: "Unconscious urge to unlock device driven by muscle memory.",
                        ),
                        const SizedBox(height: 16),
                        
                        _buildMetricProgress(
                          label: "Rest & Focus Impact",
                          value: _focusImpact,
                          color: Colors.indigo[300]!,
                          tooltip: "Degree to which devices displace core productivity and night rest.",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Save & Proceed Button
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00F2FE), Color(0xFF0D47A1)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00F2FE).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Use the navigation bar to access Boundary controls!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Boundaries Configured',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.check_circle_outline, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricProgress({
    required String label,
    required double value,
    required Color color,
    required String tooltip,
  }) {
    // Determine severity badge and status description based on metric type and value
    String status = "Optimal";
    String desc = "Your response to digital triggers is balanced and steady.";
    Color badgeColor = const Color(0xFF00BFA5); // Teal
    
    if (label.contains("Dopamine")) {
      if (value >= 0.88) {
        status = "Critical";
        desc = "Your brain is highly sensitised to instant notification triggers. You experience frequent focus fragments.";
        badgeColor = const Color(0xFFD50000); // Red
      } else if (value >= 0.75) {
        status = "High Risk";
        desc = "You are easily drawn in by notifications. Setting quiet hours will help rest your attention spans.";
        badgeColor = const Color(0xFFFF6D00); // Orange
      } else if (value >= 0.60) {
        status = "Moderate";
        desc = "Moderate susceptibility. Occasional scroll loops occur during midday exhaustion states.";
        badgeColor = const Color(0xFFFFB300); // Amber
      }
    } else if (label.contains("Phantom")) {
      if (value >= 0.88) {
        status = "Critical";
        desc = "Extreme phantom checking. You unconsciously reach for your device up to 40 times a day without a reason.";
        badgeColor = const Color(0xFFD50000); // Red
      } else if (value >= 0.75) {
        status = "High Risk";
        desc = "Strong muscle memory checking patterns. Placing the device out of sight is recommended.";
        badgeColor = const Color(0xFFFF6D00); // Orange
      } else if (value >= 0.60) {
        status = "Moderate";
        desc = "Occasional habit checks, primarily when experiencing boredom or transition moments.";
        badgeColor = const Color(0xFFFFB300); // Amber
      }
    } else {
      // Rest & Focus Impact
      if (value >= 0.88) {
        status = "Critical";
        desc = "Severe displacement. Night screen time is directly reducing your deep-wave sleep cycle.";
        badgeColor = const Color(0xFFD50000); // Red
      } else if (value >= 0.75) {
        status = "High Risk";
        desc = "High impact. Device usage is interfering with your evening wind-down rhythm and morning energy.";
        badgeColor = const Color(0xFFFF6D00); // Orange
      } else if (value >= 0.60) {
        status = "Moderate";
        desc = "Moderate impact on your focus flow. Tasks are interrupted but core rest is stable.";
        badgeColor = const Color(0xFFFFB300); // Amber
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _buildGlassCard(
        borderRadius: 20,
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Radial Speedometer Gauge
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 76,
                  height: 76,
                  child: CustomPaint(
                    painter: RadialGaugePainter(value: value, color: badgeColor),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 4), // Shift down slightly due to arc angle
                    Text(
                      '${(value * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: badgeColor.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 18),
            
            // Details Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Tooltip(
                        message: tooltip,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A192F).withOpacity(0.95),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(color: Colors.white, fontSize: 11),
                        child: const Icon(Icons.info_outline, size: 14, color: Color(0xFF00F2FE)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  
                  // Severity Badge Chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: badgeColor.withOpacity(0.25), width: 1),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: badgeColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Explanatory Status Description
                  Text(
                    desc,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryStats({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return _buildGlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 10, color: Colors.white60, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Radar Circle Wave Pulse Painter
class RadarWavePainter extends CustomPainter {
  final double animationValue;

  RadarWavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw 3 expanding concentric rings
    for (int i = 0; i < 3; i++) {
      final t = (animationValue + i / 3.0) % 1.0;
      final radius = (size.width / 2) * t;
      final opacity = (1.0 - t) * 0.45;
      
      paint.color = const Color(0xFF00E5FF).withOpacity(opacity);
      canvas.drawCircle(center, radius, paint);
    }

    // Outer dashed ring boundary
    paint.color = Colors.white.withOpacity(0.08);
    paint.strokeWidth = 1.0;
    canvas.drawCircle(center, size.width / 2, paint);
  }

  @override
  bool shouldRepaint(RadarWavePainter oldDelegate) => true;
}

// Custom Painter for Vulnerability Speedometer Radial Gauge
class RadialGaugePainter extends CustomPainter {
  final double value;
  final Color color;

  RadialGaugePainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;
    
    // Background Track Paint (Slate Grey)
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.85, // Starts bottom-left
      math.pi * 1.3,  // Sweeps 234 degrees
      false,
      bgPaint,
    );

    // Dynamic sweep angle based on value
    final sweepAngle = math.pi * 1.3 * value;

    // Draw a subtle soft ambient glow beneath the active track
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round
      ..color = color.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.85,
      sweepAngle,
      false,
      glowPaint,
    );

    // Active Gauge Paint
    final activePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [color.withOpacity(0.55), color],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.85,
      sweepAngle,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant RadialGaugePainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.color != color;
  }
}

class SolarEclipsePainter extends CustomPainter {
  final double scoreFraction;
  final Color glowColor;
  final int score;

  SolarEclipsePainter({required this.scoreFraction, required this.glowColor, required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.5;

    // Draw corona glow
    final double coronaRadius = radius + 6.0 + (1.0 - scoreFraction) * 4.0;
    final coronaPaint = Paint()
      ..color = glowColor.withOpacity(0.45)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0);

    canvas.drawCircle(center, coronaRadius, coronaPaint);

    // Draw active sun core
    final sunPaint = Paint()
      ..color = glowColor
      ..style = PaintingStyle.fill;
    
    final sunGlowPaint = Paint()
      ..color = Colors.white.withOpacity(0.65)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
    
    // Score text will be drawn later for proper layering

    canvas.drawCircle(center, radius, sunPaint);
    canvas.drawCircle(center, radius - 2, sunGlowPaint);

    // Draw score text in the center
// Score text will be drawn after shadow
// Draw eclipsing shadow (dark moon body representing screen usage blocking the light)
    if (scoreFraction < 1.0) {
      final shadowOffset = Offset(
        center.dx + (radius * 1.8 * scoreFraction),
        center.dy,
      );
      final shadowPaint = Paint()
        ..color = const Color(0xFF0A192F)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(shadowOffset, radius - 0.5, shadowPaint);
    }

    // Draw score text in the center
    final textSpan = TextSpan(
      text: '$score',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final offset = center - Offset(textPainter.width / 2, textPainter.height / 2);
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant SolarEclipsePainter oldDelegate) {
    return oldDelegate.scoreFraction != scoreFraction || oldDelegate.glowColor != glowColor || oldDelegate.score != score;
  }
}
