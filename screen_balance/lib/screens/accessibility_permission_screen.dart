import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AccessibilityPermissionScreen extends StatefulWidget {
  final VoidCallback onPermissionGranted;
  const AccessibilityPermissionScreen({super.key, required this.onPermissionGranted});

  @override
  State<AccessibilityPermissionScreen> createState() => _AccessibilityPermissionScreenState();
}

class _AccessibilityPermissionScreenState extends State<AccessibilityPermissionScreen> with WidgetsBindingObserver {
  static const _commandChannel = MethodChannel('com.screenbalance.tracker/commands');
  bool _isChecking = false;
  Timer? _checkTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
    // Also poll every 1.5 seconds in case lifecycle resume doesn't fire correctly on some devices
    _checkTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      _checkPermission();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _checkTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
    }
  }

  Future<void> _checkPermission() async {
    if (_isChecking) return;
    setState(() {
      _isChecking = true;
    });

    try {
      final bool isEnabled = await _commandChannel.invokeMethod<bool>('isAccessibilityServiceEnabled') ?? false;
      if (isEnabled) {
        _checkTimer?.cancel();
        widget.onPermissionGranted();
      }
    } catch (e) {
      debugPrint('Error checking accessibility permission: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  Future<void> _openSettings() async {
    try {
      await _commandChannel.invokeMethod('openAccessibilitySettings');
    } catch (e) {
      debugPrint('Error launching accessibility settings: $e');
    }
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                
                // Icon Header
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.15), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0D47A1).withOpacity(0.4),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.accessibility_new,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Title
                const Text(
                  'Mindful Telemetry',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                
                // Subtitle
                Text(
                  'To protect your attention spans, ScreenBalance requires Accessibility Service to detect scroll loops, passive scrolling, and app switching.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                // Guide steps
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'HOW TO ENABLE IT:',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white60,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildStep(1, 'Tap the button below to open system settings'),
                      _buildStep(2, 'Navigate to "Installed apps" or "Downloaded services"'),
                      _buildStep(3, 'Select "screen_balance" and switch it ON'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Action Button
                ElevatedButton(
                  onPressed: _openSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0A192F),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 5,
                    shadowColor: const Color(0xFF0D47A1).withOpacity(0.5),
                  ),
                  child: const Text(
                    'Grant Accessibility Permission',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Status
                Center(
                  child: Text(
                    'Awaiting service activation...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
                
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white70,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
