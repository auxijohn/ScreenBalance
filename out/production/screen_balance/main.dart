import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui';
import 'screens/auth_screen.dart';
import 'screens/dashboard_shell.dart';
import 'screens/intervention_overlay_screen.dart';
import 'screens/accessibility_permission_screen.dart';
import 'logic/intervention_engine.dart';
import 'logic/accountability_dispatcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ScreenBalanceApp());
}

class ScreenBalanceApp extends StatefulWidget {
  const ScreenBalanceApp({super.key});

  @override
  State<ScreenBalanceApp> createState() => _ScreenBalanceAppState();
}

class _ScreenBalanceAppState extends State<ScreenBalanceApp> {

  Map<String, String>? _activeIntervention;
  bool _isAuthenticated = false;
  bool _isAccessibilityEnabled = true;

  @override
  void initState() {
    super.initState();
    // Start tracking in the background
    InterventionEngine().startListening();
    AccountabilityDispatcher().startListening();

    // Check accessibility status
    _checkAccessibility();
    
    // Listen for triggers to show the overlay
    InterventionEngine().interventionStream.stream.listen((data) {
      setState(() {
        _activeIntervention = data;
      });
    });
  }

  Future<void> _checkAccessibility() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    try {
      const commandChannel = MethodChannel('com.screenbalance.tracker/commands');
      final isEnabled = await commandChannel.invokeMethod<bool>('isAccessibilityServiceEnabled') ?? false;
      setState(() {
        _isAccessibilityEnabled = isEnabled;
      });
    } catch (e) {
      debugPrint('Error checking startup accessibility: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScreenBalance',
      scrollBehavior: const AppScrollBehavior(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5), // Calming primary blue
          brightness: Brightness.light,
        ),
        fontFamily: 'Outfit',
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: Stack(
        children: [
          // If accessibility service is not enabled on Android, guide user to enable it
          !_isAccessibilityEnabled
              ? AccessibilityPermissionScreen(
                  onPermissionGranted: () {
                    setState(() {
                      _isAccessibilityEnabled = true;
                    });
                  },
                )
              : (_isAuthenticated
                  ? DashboardShell(
                      onLogout: () {
                        setState(() {
                          _isAuthenticated = false;
                        });
                      },
                    )
                  : AuthScreen(
                      onAuthenticated: () {
                        setState(() {
                          _isAuthenticated = true;
                        });
                      },
                    )),
          
          // Global Intervention Overlay
          if (_activeIntervention != null)
            InterventionOverlayScreen(
              data: _activeIntervention!,
              onDismissed: () {
                setState(() {
                  _activeIntervention = null;
                });
              },
            ),
        ],
      ),
    );
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}
