import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'dart:ui' show ImageFilter;
import 'package:device_apps/device_apps.dart';

import '../models/boundary_settings.dart';
import '../logic/intervention_engine.dart';
import 'tranquility_success_screen.dart';
import 'dashboard_shell.dart';
import 'app_categorization_screen.dart';
import 'schedules_screen.dart';
import 'accountability_screen.dart';
import 'balanced_apps_screen.dart';

class BoundaryConfigScreen extends StatefulWidget {
  const BoundaryConfigScreen({super.key});

  @override
  State<BoundaryConfigScreen> createState() => _BoundaryConfigScreenState();
}

class _BoundaryConfigScreenState extends State<BoundaryConfigScreen> with WidgetsBindingObserver {
  BoundarySettings _settings = BoundarySettings();
  List<Application> _installedApps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSettings();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadSettings();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final loaded = await BoundarySettings.loadFromStorage();
    if (mounted) {
      setState(() {
        _settings = loaded;
      });
    }
    await _loadApps();
  }

  Future<void> _loadApps() async {
    try {
      if (kIsWeb || (!kIsWeb && !Platform.isAndroid)) {
        if (mounted) {
          setState(() {
            _installedApps = [];
            _isLoading = false;
          });
        }
        return;
      }

      List<Application> apps = await DeviceApps.getInstalledApplications(
        includeAppIcons: true,
        includeSystemApps: true,
        onlyAppsWithLaunchIntent: true,
      );

      apps.sort((a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));

      if (mounted) {
        setState(() {
          _installedApps = apps;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading apps: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildNavBanner({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 30, top: 20),
                    child: Text(
                      'Configure your digital boundaries below.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  _buildNavBanner(
                    title: 'Balanced Applications',
                    subtitle: 'Set focus shields & daily mindful allowances',
                    icon: Icons.tune,
                    gradientColors: const [Color(0xFF1E88E5), Color(0xFF0D47A1)],
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BalancedAppsScreen(
                            settings: _settings,
                            installedApps: _installedApps,
                          ),
                        ),
                      );
                      _loadSettings();
                    },
                  ),

                  _buildNavBanner(
                    title: 'Schedules & Sleep Quiet',
                    subtitle: 'Bedtime, Focus Modes, and Morning Buffers',
                    icon: Icons.nights_stay,
                    gradientColors: const [Color(0xFF1E88E5), Color(0xFF0D47A1)],
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SchedulesScreen(
                            settings: _settings,
                          ),
                        ),
                      );
                      _loadSettings();
                    },
                  ),

                  _buildNavBanner(
                    title: 'Accountability Partners',
                    subtitle: 'Notify friends when you break boundaries',
                    icon: Icons.group,
                    gradientColors: const [Color(0xFF1E88E5), Color(0xFF0D47A1)],
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AccountabilityScreen(
                            settings: _settings,
                          ),
                        ),
                      );
                      _loadSettings();
                    },
                  ),

                  _buildNavBanner(
                    title: 'App Categorization',
                    subtitle: 'Drag and drop apps into behavior buckets',
                    icon: Icons.category,
                    gradientColors: [const Color(0xFF1E88E5), const Color(0xFF0D47A1)],
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppCategorizationScreen(
                            settings: _settings,
                            installedApps: _installedApps,
                          ),
                        ),
                      );
                      _loadSettings();
                    },
                  ),

                  const SizedBox(height: 40),

                  // LARGE SAVE BUTTON
                  ElevatedButton(
                    onPressed: () async {
                      await _settings.saveToStorage();
                      if (!context.mounted) return;

                      final transformation = _getIdentityTransformation();
                      final proceed = await showDialog<bool>(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => IdentityTransformationDialog(
                          transformation: transformation,
                        ),
                      );

                      if (proceed == true && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Boundaries Saved Successfully!')),
                        );
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TranquilitySuccessScreen(),
                          ),
                        );
                        if (result == true && mounted) {
                          final shellState = context.findAncestorStateOfType<DashboardShellState>();
                          if (shellState != null) {
                            shellState.setSelectedIndex(0);
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0D47A1),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      elevation: 4,
                      shadowColor: Colors.black.withOpacity(0.3),
                    ),
                    child: const Text('Save & Apply Limits', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
      ),
    );
  }

  Map<String, String> _getIdentityTransformation() {
    final hasBedtime = _settings.targetBedtime != null;
    final hasBedtimeShield = _settings.categorizedApps['Emotional Distraction']?.isNotEmpty ?? false;
    final hasFocusSchedule = _settings.syncFocusWithSun || _settings.focusStartTime != null || _settings.focusEndTime != null;
    final hasFocusShield = _settings.categorizedApps['Productivity']?.isNotEmpty ?? false;
    final hasSocialCap = _settings.categorizedApps['Social']?.isNotEmpty ?? false;
    final hasEntertainmentCap = _settings.categorizedApps['Entertainment']?.isNotEmpty ?? false;

    const sleepAdj = ['Restful', 'Calm', 'Peaceful', 'Tranquil'];
    const focusAdj = ['Sharp', 'Clear', 'Focused', 'Determined'];
    const limitAdj = ['Mindful', 'Balanced', 'Conscious'];
    const defaultAdj = ['Balanced', 'Mindful', 'Centered'];

    if (hasBedtime || hasBedtimeShield) {
      final app = _getPrimaryAppName('Emotional Distraction');
      final adjective = sleepAdj[0];
      final before = app.isNotEmpty
          ? "Your $app experience is easing into a $adjective night"
          : "Your device is easing into a $adjective night";
      return {
        'before': before,
        'after': "You become a $adjective sleep champion",
        'type': 'Sleep',
        'title': 'Sleep Quiet Shift',
      };
    } else if (hasFocusSchedule || hasFocusShield) {
      final app = _getPrimaryAppName('Productivity');
      final adjective = focusAdj[0];
      final before = app.isNotEmpty
          ? "Your $app experience is gearing up for $adjective focus"
          : "Your device is gearing up for $adjective focus";
      return {
        'before': before,
        'after': "You become a $adjective focus champion",
        'type': 'Focus',
        'title': 'Focus Mindset Shift',
      };
    } else if (hasSocialCap || hasEntertainmentCap) {
      final cat = hasSocialCap ? 'Social' : 'Entertainment';
      final app = _getPrimaryAppName(cat);
      final adjective = limitAdj[0];
      final before = app.isNotEmpty
          ? "Your $app usage is drifting, limiting to $adjective time"
          : "Your usage is drifting, limiting to $adjective time";
      return {
        'before': before,
        'after': "You become a $adjective limit master",
        'type': 'Limits',
        'title': 'Mindful Limit Shift',
      };
    } else {
      final adjective = defaultAdj[0];
      return {
        'before': "Your digital habits feel $adjective",
        'after': "You stay $adjective and mindful",
        'type': 'Default',
        'title': 'Mindful Shift',
      };
    }
  }

  String _getAppName(String appIdentifier) {
    if (kIsWeb || !Platform.isAndroid) {
      return appIdentifier;
    }
    try {
      final app = _installedApps.firstWhere((a) => a.packageName == appIdentifier);
      return app.appName;
    } catch (_) {}
    return appIdentifier.split('.').last;
  }

  String _getPrimaryAppName(String category) {
    final apps = _settings.categorizedApps[category];
    if (apps != null && apps.isNotEmpty) {
      final name = _getAppName(apps.first);
      return name.split(' ').first;
    }
    return '';
  }
}

class IdentityTransformationDialog extends StatelessWidget {
  final Map<String, String> transformation;

  const IdentityTransformationDialog({
    super.key,
    required this.transformation,
  });

  @override
  Widget build(BuildContext context) {
    final int score = InterventionEngine().getDigitalMindfulnessScore();
    final Map<String, String> phraseData = InterventionEngine().getMindfulnessPhrase(score);
    final beforeText = transformation['before'] ?? phraseData['description'] ?? '';
    final afterText = transformation['after'] ?? InterventionEngine().getRandomMotivation(score);
    final type = transformation['type'] ?? 'Default';

    IconData beforeIcon = Icons.sensors_off_outlined;
    IconData afterIcon = Icons.spa_outlined;
    String transformationTitle = 'Identity Transformation';

    if (type == 'Sleep') {
      beforeIcon = Icons.nights_stay_outlined;
      afterIcon = Icons.wb_twilight_outlined;
      transformationTitle = 'Sleep Quiet Shift';
    } else if (type == 'Focus') {
      beforeIcon = Icons.blur_on_outlined;
      afterIcon = Icons.psychology_outlined;
      transformationTitle = 'Focus Mindset Shift';
    } else if (type == 'Limits') {
      beforeIcon = Icons.hourglass_disabled_outlined;
      afterIcon = Icons.hourglass_full_outlined;
      transformationTitle = 'Mindful Limit Shift';
    }

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0A192F).withOpacity(0.85),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00F2FE).withOpacity(0.1),
                blurRadius: 40,
                spreadRadius: 2,
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00F2FE).withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF00F2FE).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.swap_calls_outlined,
                    color: Color(0xFF00F2FE),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  transformationTitle.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Based on your custom boundary limits, your digital self is changing.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildIdentityCard(
                  context: context,
                  isBefore: true,
                  icon: beforeIcon,
                  title: 'CURRENT STATE',
                  phrase: beforeText,
                  glowColor: const Color(0xFFFF5252),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_downward_rounded,
                      color: Color(0xFF00F2FE),
                      size: 20,
                    ),
                  ),
                ),
                _buildIdentityCard(
                  context: context,
                  isBefore: false,
                  icon: afterIcon,
                  title: 'EVOLVED SELF',
                  phrase: afterText,
                  glowColor: const Color(0xFF00F2FE),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white.withOpacity(0.2)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00F2FE), Color(0xFF4FACFE)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00F2FE).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Apply Shift',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIdentityCard({
    required BuildContext context,
    required bool isBefore,
    required IconData icon,
    required String title,
    required String phrase,
    required Color glowColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isBefore ? Colors.white.withOpacity(0.1) : glowColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: isBefore
            ? []
            : [
                BoxShadow(
                  color: glowColor.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: -5,
                ),
              ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isBefore ? Colors.white54 : glowColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: isBefore ? Colors.white54 : glowColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            phrase,
            style: TextStyle(
              color: isBefore ? Colors.white70 : Colors.white,
              fontSize: 15,
              fontWeight: isBefore ? FontWeight.w500 : FontWeight.w700,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
