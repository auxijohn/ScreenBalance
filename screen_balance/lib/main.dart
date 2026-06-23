import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/auth_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/dashboard_shell.dart';
import 'screens/intervention_overlay_screen.dart';
import 'screens/accessibility_permission_screen.dart';
import 'logic/intervention_engine.dart';
import 'logic/accountability_dispatcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences? prefs;
  try {
    prefs = await SharedPreferences.getInstance();
  } catch (e) {
    debugPrint('Error pre-initializing SharedPreferences: $e');
  }
  runApp(ScreenBalanceApp(prefs: prefs));
}

class ScreenBalanceApp extends StatefulWidget {
  final SharedPreferences? prefs;
  const ScreenBalanceApp({super.key, this.prefs});

  @override
  State<ScreenBalanceApp> createState() => _ScreenBalanceAppState();
}

class _ScreenBalanceAppState extends State<ScreenBalanceApp> {

  final List<Map<String, String>> _activeInterventions = [];
  bool _isAuthenticated = false;
  bool _isAccessibilityEnabled = true;
  bool _showWelcome = true; // Always show welcome on every cold launch
  StreamSubscription<Map<String, String>>? _interventionSubscription;

  @override
  void initState() {
    super.initState();
    // Start tracking in the background
    InterventionEngine().startListening();
    AccountabilityDispatcher().startListening();

    // Check accessibility status
    _checkAccessibility();
    
    if (widget.prefs != null) {
      _isAuthenticated = widget.prefs!.getBool('is_authenticated') ?? false;
    } else {
      _loadAuthStatus();
    }
    
    // Listen for triggers to show the overlay
    _interventionSubscription = InterventionEngine().interventionStream.stream.listen((data) {
      if (mounted) {
        setState(() {
          final alreadyPresent = _activeInterventions.any((element) => element['triggerId'] == data['triggerId']);
          if (!alreadyPresent) {
            _activeInterventions.add(data);
            try {
              const commandChannel = MethodChannel('com.screenbalance.tracker/commands');
              commandChannel.invokeMethod('bringToForeground');
            } catch (e) {
              debugPrint('Error bringing app to foreground: $e');
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _interventionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isAuth = prefs.getBool('is_authenticated') ?? false;
      if (isAuth) {
        if (mounted) {
          setState(() {
            _isAuthenticated = isAuth;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading authentication status: $e');
    }
  }

  Future<void> _checkAccessibility() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    try {
      const commandChannel = MethodChannel('com.screenbalance.tracker/commands');
      final isEnabled = await commandChannel.invokeMethod<bool>('isAccessibilityServiceEnabled') ?? false;
      if (mounted) {
        setState(() {
          _isAccessibilityEnabled = isEnabled;
        });
      }
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
          // 1. Welcome screen always plays first on cold launch
          if (_showWelcome)
            WelcomeScreen(
              key: const ValueKey('welcome'),
              onStart: () {
                setState(() {
                  _showWelcome = false;
                });
              },
            )
          else if (!_isAuthenticated)
              AuthScreen(
                onAuthenticated: () async {
                  try {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('is_authenticated', true);
                  } catch (e) {
                    debugPrint('Error saving authentication status: $e');
                  }
                  await _checkAccessibility();
                  setState(() {
                    _isAuthenticated = true;
                  });
                },
              )
          else
            DashboardShell(
              onLogout: () async {
                try {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('is_authenticated', false);
                } catch (e) {
                  debugPrint('Error clearing authentication status: $e');
                }
                setState(() {
                  _isAuthenticated = false;
                  _showWelcome = true;
                });
              },
            ),

          // Global Intervention Overlay
          if (_activeInterventions.isNotEmpty)
            InterventionOverlayScreen(
              interventions: List.from(_activeInterventions),
              onDismissed: () {
                setState(() {
                  _activeInterventions.clear();
                });
              },
              onDismissSingle: (triggerId) {
                setState(() {
                  _activeInterventions.removeWhere((element) => element['triggerId'] == triggerId);
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
