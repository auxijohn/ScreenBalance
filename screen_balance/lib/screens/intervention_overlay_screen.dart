import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';
import '../logic/intervention_engine.dart';
import 'post_validation_screen.dart';

class InterventionOverlayScreen extends StatefulWidget {
  final Map<String, String> data;
  final VoidCallback onDismissed;

  const InterventionOverlayScreen({
    super.key,
    required this.data,
    required this.onDismissed,
  });

  @override
  State<InterventionOverlayScreen> createState() => _InterventionOverlayScreenState();
}

class _InterventionOverlayScreenState extends State<InterventionOverlayScreen> with TickerProviderStateMixin {
  late final String _triggerId;
  late final String _title;
  late final String _message;
  late final String _somaticReset;

  // Timers and interactive states
  int _secondsRemaining = 60;
  Timer? _timer;
  int _tapCount = 0;
  final List<String> _checklistItems = [];
  final List<bool> _checkedItems = [];
  
  // Breathing animation
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;
  String _breathDirection = "Inhale...";

  @override
  void initState() {
    super.initState();
    _triggerId = widget.data['triggerId'] ?? 'dopamine_loop';
    _title = widget.data['title'] ?? 'Dopamine Loop';
    _message = widget.data['message'] ?? '';
    _somaticReset = widget.data['somaticReset'] ?? '';

    _initSpecializedInteraction();
  }

  void _initSpecializedInteraction() {
    // 1. Time-based resets
    if (_triggerId == 'dopamine_loop' || 
        _triggerId == 'reactive_mode' || 
        _triggerId == 'midnight_drift' || 
        _triggerId == 'last_scroll_loop' ||
        _triggerId == 'work_life_blur' || 
        _triggerId == 'novelty_hunt' || 
        _triggerId == 'interaction_spike') {
      _secondsRemaining = 60;
      _startTimer();
    } else if (_triggerId == 'info_overload') {
      _secondsRemaining = 30;
      _startTimer();
    }

    // 2. Checklist items (e.g. 5-Object Scan, 3-Texture Scan)
    if (_triggerId == 'the_void') {
      _checklistItems.addAll([
        "Object 1",
        "Object 2",
        "Object 3",
        "Object 4",
        "Object 5",
      ]);
      _checkedItems.addAll(List.filled(5, false));
    } else if (_triggerId == 'midnight_drift') {
      _checklistItems.addAll([
        "Cold table or surface",
        "Soft pillow or fabric",
        "Your own palms pressed together",
      ]);
      _checkedItems.addAll(List.filled(3, false));
    }

    // 3. Breathing resets (4-7-8, Heart-Hand)
    if (_triggerId == 'ghosting_anxiety' || _triggerId == 'social_spiral') {
      _breathingController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 4),
      )..repeat(reverse: true);
      _breathingAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
        CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
      );

      _breathingController.addStatusListener((status) {
        if (status == AnimationStatus.forward) {
          setState(() {
            _breathDirection = _triggerId == 'ghosting_anxiety' ? "Inhale (4s)..." : "Breathe In...";
          });
        } else if (status == AnimationStatus.reverse) {
          setState(() {
            _breathDirection = _triggerId == 'ghosting_anxiety' ? "Exhale (8s)..." : "Breathe Out...";
          });
        }
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (_triggerId == 'ghosting_anxiety' || _triggerId == 'social_spiral') {
      _breathingController.dispose();
    }
    super.dispose();
  }

  bool _isInteractionComplete() {
    if (_triggerId == 'the_void' || _triggerId == 'midnight_drift') {
      return !_checkedItems.contains(false);
    }
    if (_triggerId == 'phantom_check' || _triggerId == 'upward_comparison') {
      return _tapCount >= 5;
    }
    return _secondsRemaining <= 0;
  }

  void _completeReset() {
    // Notify InterventionEngine
    InterventionEngine().completeSomaticReset();
    widget.onDismissed();
    
    // Launch Mood Validation Overlay Screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PostValidationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final complete = _isInteractionComplete();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Blurred background
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                color: const Color(0xFFE3F2FD).withOpacity(0.85), // Premium light blue opacity
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.self_improvement_rounded, size: 56, color: Colors.blue[800]),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _title,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.blue[900],
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _message,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.blue[900]?.withOpacity(0.7),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 36),

                    // Interactive reset box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: Colors.white.withOpacity(0.9), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            _somaticReset,
                            style: TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[900],
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          _buildInteractiveBody(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Complete/Cancel Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: widget.onDismissed,
                          child: Text(
                            'Snooze Limit',
                            style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: complete ? _completeReset : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            elevation: complete ? 4 : 0,
                          ),
                          child: Row(
                            children: [
                              Text(complete ? 'Proceed to Validation' : 'Perform Reset'),
                              const SizedBox(width: 8),
                              Icon(complete ? Icons.arrow_forward_rounded : Icons.lock_outline, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveBody() {
    // 1. Time-based resets UI
    if (_triggerId == 'dopamine_loop' || 
        _triggerId == 'reactive_mode' || 
        _triggerId == 'last_scroll_loop' ||
        _triggerId == 'work_life_blur' || 
        _triggerId == 'novelty_hunt' || 
        _triggerId == 'interaction_spike' ||
        _triggerId == 'info_overload') {
      return Column(
        children: [
          Text(
            '$_secondsRemaining',
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.blue[700]),
          ),
          const SizedBox(height: 8),
          const Text('Seconds Remaining', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      );
    }

    // 2. Checklist resets UI
    if (_triggerId == 'the_void' || _triggerId == 'midnight_drift') {
      return Column(
        children: List.generate(_checklistItems.length, (index) {
          final isChecked = _checkedItems[index];
          return CheckboxListTile(
            title: Text(
              _checklistItems[index],
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isChecked ? Colors.grey : Colors.blue[900],
              ),
            ),
            value: isChecked,
            activeColor: Colors.blue,
            onChanged: (val) {
              setState(() {
                _checkedItems[index] = val ?? false;
              });
            },
          );
        }),
      );
    }

    // 3. Breathing resets UI
    if (_triggerId == 'ghosting_anxiety' || _triggerId == 'social_spiral') {
      return Column(
        children: [
          ScaleTransition(
            scale: _breathingAnimation,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue[300]!.withOpacity(0.3),
                border: Border.all(color: Colors.blue[600]!, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _breathDirection,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[800]),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _secondsRemaining = 0; // instantly complete breathing cycle
              });
            },
            child: const Text('Complete 3 Breath Cycles'),
          ),
        ],
      );
    }

    // 4. Tap / Counter resets UI
    if (_triggerId == 'phantom_check' || _triggerId == 'upward_comparison') {
      return Column(
        children: [
          Text(
            '$_tapCount / 5',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.blue[700]),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _tapCount++;
              });
            },
            icon: const Icon(Icons.done),
            label: Text(_triggerId == 'phantom_check' ? 'Log 1 Shoulder Roll' : 'I am Mindful of this Comparison'),
          ),
        ],
      );
    }

    return const SizedBox();
  }
}
