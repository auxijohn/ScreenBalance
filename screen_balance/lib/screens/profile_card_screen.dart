import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
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
  }

  @override
  void dispose() {
    _radarController.dispose();
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

  void _showProfileDetailsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          backgroundColor: Colors.white,
          title: const Row(
            children: [
              Icon(Icons.account_circle, color: Color(0xFF0D47A1), size: 28),
              SizedBox(width: 12),
              Text(
                'Profile Details',
                style: TextStyle(
                  color: Color(0xFF0A192F),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfileDetailRow('Name', widget.profile.name),
              const Divider(height: 20, color: Colors.black12),
              _buildProfileDetailRow('Age Group', widget.profile.ageGroup),
              const Divider(height: 20, color: Colors.black12),
              _buildProfileDetailRow('Occupation', widget.profile.occupation),
              const Divider(height: 20, color: Colors.black12),
              _buildProfileDetailRow(
                'Calibration',
                widget.profile.calibrationPath == 'quiz' ? 'Interactive Quiz' : '7-Day Observation',
              ),
              const Divider(height: 20, color: Colors.black12),
              _buildProfileDetailRow(
                'Status',
                widget.profile.isCalibrated ? 'Calibrated' : 'Calibration Pending',
                valueColor: widget.profile.isCalibrated ? Colors.green[700]! : Colors.orange[700]!,
              ),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0D47A1),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
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
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: valueColor ?? const Color(0xFF0A192F),
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      color: Colors.white.withOpacity(0.95),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 8,
                              backgroundColor: Colors.grey[200],
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Calibration Progress",
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue[900]),
                              ),
                              Text(
                                "${(progress * 100).toInt()}% Done",
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue[900]),
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
                  ),
                  const SizedBox(height: 20),

                  // Metrics cards grid
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Focus Index", style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text("${data['focus']}%", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0A192F))),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Sleep Log", style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text("${data['sleep']} hrs", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0A192F))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Distractions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Context Interruptions Logged", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                        Text("${data['distractions']} times", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A192F))),
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
                  Container(
                    height: 110,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(24),
                    ),
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
                                              : [const Color(0xFF0D47A1).withOpacity(0.4), const Color(0xFF0D47A1)])
                                          : [Colors.grey[200]!, Colors.grey[200]!],
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  height: isCompleted ? (dayFocus.toDouble()) : 0.0,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text("D${index + 1}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Simulation Panel Controls
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white12, width: 1),
                    ),
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
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.12),
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
                          )
                        else
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00E5FF),
                              foregroundColor: const Color(0xFF0A192F),
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
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.help_outline_outlined, size: 60, color: Colors.white70),
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
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0D47A1),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _resetProfile,
                    child: const Text("Back to Welcome Onboarding", style: TextStyle(color: Colors.white70)),
                  ),
                ],
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
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Mascot Image replaced circular emoji
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF0D47A1), width: 3),
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
                            color: Color(0xFF0D47A1),
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
                              color: Color(0xFF0A192F),
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
                            color: Color(0xFFD32F2F),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Divider(height: 40, color: Colors.black12),
                        
                        Text(
                          widget.profile.activeIntentionCard['description'] ?? 'Your digital wellness boundary configurations.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF0F172A),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Digital Vulnerability Metric Gauges (White Card)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'VULNERABILITY METRICS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D47A1),
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
                          color: Colors.indigo[600]!,
                          tooltip: "Degree to which devices displace core productivity and night rest.",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Interactive Action Checklist Panel (White/Glass Card)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'TAILORED HABIT ACTIONS',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0D47A1),
                                letterSpacing: 1.2,
                              ),
                            ),
                            Text(
                              '${_habitChecks.where((c) => c).length}/3 Done',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0D47A1),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        ...List.generate(3, (index) {
                          final isChecked = _habitChecks[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _habitChecks[index] = !isChecked;
                                });
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: isChecked 
                                      ? const Color(0xFF0D47A1).withOpacity(0.06) 
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isChecked 
                                        ? const Color(0xFF0D47A1).withOpacity(0.3) 
                                        : Colors.grey.withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: isChecked ? const Color(0xFF0D47A1) : Colors.transparent,
                                        border: Border.all(
                                          color: isChecked ? const Color(0xFF0D47A1) : Colors.grey,
                                          width: 1.5,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: isChecked 
                                          ? const Icon(Icons.check, size: 14, color: Colors.white) 
                                          : null,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        _tailoredHabits[index],
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: isChecked ? const Color(0xFF0A192F).withOpacity(0.5) : const Color(0xFF0A192F),
                                          decoration: isChecked ? TextDecoration.lineThrough : null,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Save & Proceed Button
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Use the navigation bar to access Boundary controls!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D47A1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      elevation: 2,
                      shadowColor: Colors.black.withOpacity(0.2),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A192F),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Tooltip(
                    message: tooltip,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A192F).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(color: Colors.white, fontSize: 11),
                    child: const Icon(Icons.info_outline, size: 14, color: Color(0xFF0D47A1)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${(value * 100).toInt()}%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.6), color],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
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
