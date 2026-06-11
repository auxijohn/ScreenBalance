import 'package:flutter/material.dart';
import 'dart:ui';

class ProfileCardScreen extends StatefulWidget {
  final String userName;
  final Map<String, String> archetypeDetails;

  const ProfileCardScreen({
    super.key,
    required this.userName,
    required this.archetypeDetails,
  });

  @override
  State<ProfileCardScreen> createState() => _ProfileCardScreenState();
}

class _ProfileCardScreenState extends State<ProfileCardScreen> {
  // Habit checkbox state
  final List<bool> _habitChecks = [false, false, false];

  // Dynamically calculate metrics based on the archetype
  late final double _dopamineReactivity;
  late final double _phantomHabitUrge;
  late final double _focusImpact;
  late final List<String> _tailoredHabits;

  @override
  void initState() {
    super.initState();
    _initializeArchetypeData();
  }

  void _initializeArchetypeData() {
    final title = widget.archetypeDetails['title'] ?? 'The Intentional Seeker';

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
                    Container(
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
                            widget.userName,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Archetype Presentation White/Glass Card
                ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
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
                            widget.archetypeDetails['title'] ?? 'The Intentional Seeker',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0A192F),
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "(${widget.archetypeDetails['subtitle'] ?? 'Digital Growth'})",
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
                            widget.archetypeDetails['description'] ?? 'Your digital wellness boundary configurations.',
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
                  ),
                ),
                const SizedBox(height: 20),

                // Digital Vulnerability Metric Gauges (White/Glass Card)
                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
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
                  ),
                ),
                const SizedBox(height: 20),

                // Interactive Action Checklist Panel (White/Glass Card)
                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
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
            Row(
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A192F),
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
