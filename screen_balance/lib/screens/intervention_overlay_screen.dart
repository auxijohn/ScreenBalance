 import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';
import '../logic/intervention_engine.dart';
import 'post_validation_screen.dart';

class InterventionOverlayScreen extends StatefulWidget {
  final List<Map<String, String>> interventions;
  final VoidCallback onDismissed;
  final ValueChanged<String> onDismissSingle;

  const InterventionOverlayScreen({
    super.key,
    required this.interventions,
    required this.onDismissed,
    required this.onDismissSingle,
  });

  @override
  State<InterventionOverlayScreen> createState() => _InterventionOverlayScreenState();
}

class _InterventionOverlayScreenState extends State<InterventionOverlayScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;

  // Timers and interactive states mapped by triggerId
  final Map<String, int> _secondsRemainingMap = {};
  final Map<String, Timer?> _timersMap = {};
  final Map<String, int> _tapCountsMap = {};
  final Map<String, List<String>> _checklistItemsMap = {};
  final Map<String, List<bool>> _checkedItemsMap = {};
  final Set<String> _completedTriggers = {};
  
  // Shared Breathing animation
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;
  String _breathDirection = "Inhale...";

  @override
  void initState() {
    super.initState();

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
          _breathDirection = "Breathe In...";
        });
      } else if (status == AnimationStatus.reverse) {
        setState(() {
          _breathDirection = "Breathe Out...";
        });
      }
    });

    for (final item in widget.interventions) {
      final triggerId = item['triggerId'] ?? '';
      _initSpecializedInteractionFor(triggerId, item);
    }
  }

  void _initSpecializedInteractionFor(String triggerId, Map<String, String> data) {
    // 1. Time-based resets
    if (triggerId == 'dopamine_loop' || 
        triggerId == 'reactive_mode' || 
        triggerId == 'midnight_drift' || 
        triggerId == 'last_scroll_loop' ||
        triggerId == 'work_life_blur' || 
        triggerId == 'novelty_hunt' || 
        triggerId == 'interaction_spike' ||
        triggerId == 'daily_cap_limit') {
      _secondsRemainingMap[triggerId] = 60;
      _startTimerFor(triggerId);
    } else if (triggerId == 'info_overload') {
      _secondsRemainingMap[triggerId] = 30;
      _startTimerFor(triggerId);
    }

    // 2. Checklist items
    if (triggerId == 'the_void') {
      final items = [
        "Object 1",
        "Object 2",
        "Object 3",
        "Object 4",
        "Object 5",
      ];
      _checklistItemsMap[triggerId] = items;
      _checkedItemsMap[triggerId] = List.filled(items.length, false);
    } else if (triggerId == 'midnight_drift') {
      final items = [
        "Cold table or surface",
        "Soft pillow or fabric",
        "Your own palms pressed together",
      ];
      _checklistItemsMap[triggerId] = items;
      _checkedItemsMap[triggerId] = List.filled(items.length, false);
    }

    // 3. Tap/Counter
    if (triggerId == 'phantom_check') {
      _tapCountsMap[triggerId] = 0;
    }
  }

  void _startTimerFor(String triggerId) {
    _timersMap[triggerId] = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemainingMap[triggerId] != null && _secondsRemainingMap[triggerId]! > 0) {
        setState(() {
          _secondsRemainingMap[triggerId] = _secondsRemainingMap[triggerId]! - 1;
        });
      } else {
        _timersMap[triggerId]?.cancel();
        setState(() {
          _completedTriggers.add(triggerId);
        });
      }
    });
  }

  @override
  void dispose() {
    for (final timer in _timersMap.values) {
      timer?.cancel();
    }
    _breathingController.dispose();
    super.dispose();
  }

  bool _isInterventionCompleteFor(String triggerId) {
    if (_completedTriggers.contains(triggerId)) return true;

    if (triggerId == 'the_void' || triggerId == 'midnight_drift') {
      final checked = _checkedItemsMap[triggerId];
      if (checked != null && !checked.contains(false)) {
        _completedTriggers.add(triggerId);
        return true;
      }
      return false;
    }

    if (triggerId == 'phantom_check') {
      final taps = _tapCountsMap[triggerId] ?? 0;
      if (taps >= 5) {
        _completedTriggers.add(triggerId);
        return true;
      }
      return false;
    }

    final remaining = _secondsRemainingMap[triggerId];
    if (remaining != null && remaining <= 0) {
      _completedTriggers.add(triggerId);
      return true;
    }

    return false;
  }

  bool _areAllInterventionsComplete() {
    return widget.interventions.every((item) {
      final triggerId = item['triggerId'] ?? '';
      return _isInterventionCompleteFor(triggerId);
    });
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

  IconData _getIconForTrigger(String triggerId) {
    switch (triggerId) {
      case 'dopamine_loop': return Icons.loop;
      case 'reactive_mode': return Icons.bolt;
      case 'midnight_drift': return Icons.nights_stay;
      case 'last_scroll_loop': return Icons.sync;
      case 'work_life_blur': return Icons.domain_disabled;
      case 'novelty_hunt': return Icons.search;
      case 'interaction_spike': return Icons.trending_up;
      case 'info_overload': return Icons.layers;
      case 'the_void': return Icons.circle_outlined;
      case 'phantom_check': return Icons.phonelink_ring;

      case 'ghosting_anxiety': return Icons.chat_bubble_outline;
      case 'social_spiral': return Icons.sync_problem;
      default: return Icons.self_improvement;
    }
  }

  void _snoozeCurrent() {
    final currentTriggerId = widget.interventions[_selectedIndex]['triggerId'] ?? '';
    // Cancel timer of the snoozed one if any
    _timersMap[currentTriggerId]?.cancel();
    
    widget.onDismissSingle(currentTriggerId);
    
    if (widget.interventions.length > 1) {
      setState(() {
        _selectedIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Guard against index out of bounds when items are dismissed
    if (_selectedIndex >= widget.interventions.length) {
      _selectedIndex = 0;
    }

    final hasMultiple = widget.interventions.length > 1;
    final currentIntervention = widget.interventions.isNotEmpty 
        ? widget.interventions[_selectedIndex] 
        : <String, String>{};
        
    final triggerId = currentIntervention['triggerId'] ?? '';
    final title = currentIntervention['title'] ?? '';
    final message = currentIntervention['message'] ?? '';
    final somaticReset = currentIntervention['somaticReset'] ?? '';
    
    final allComplete = _areAllInterventionsComplete();
    final currentComplete = _isInterventionCompleteFor(triggerId);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFE3F2FD),
                    const Color(0xFFBBDEFB).withOpacity(0.98),
                    const Color(0xFFE3F2FD),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.self_improvement_rounded, size: 48, color: Colors.blue[800]),
                    ),
                    const SizedBox(height: 16),
                    
                    if (hasMultiple) ...[
                      Text(
                        'Multiple Boundaries Triggered',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.blue[900],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Please perform the somatic resets below to unlock your screen.',
                        style: TextStyle(fontSize: 12, color: Colors.blue[900]?.withOpacity(0.6)),
                      ),
                      const SizedBox(height: 16),
                      
                      // Segregation Tabs
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: widget.interventions.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final item = entry.value;
                              final itemTriggerId = item['triggerId'] ?? '';
                              final itemTitle = item['title'] ?? '';
                              final isSelected = idx == _selectedIndex;
                              final isItemComplete = _isInterventionCompleteFor(itemTriggerId);
                              
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedIndex = idx;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected 
                                        ? Colors.blue[900] 
                                        : (isItemComplete ? Colors.green.withOpacity(0.12) : Colors.white.withOpacity(0.6)),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected 
                                          ? Colors.blue[900]! 
                                          : (isItemComplete ? Colors.green : Colors.blue.withOpacity(0.2)),
                                      width: 1.5
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isItemComplete)
                                        const Icon(Icons.check_circle, color: Colors.green, size: 14)
                                      else
                                        Icon(
                                          _getIconForTrigger(itemTriggerId),
                                          color: isSelected ? Colors.white : Colors.blue[900],
                                          size: 14
                                        ),
                                      const SizedBox(width: 6),
                                      Text(
                                        itemTitle,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? Colors.white : Colors.blue[900],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ] else ...[
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.blue[900],
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                    ],

                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[900]?.withOpacity(0.7),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Interactive reset box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.9), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.04),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            somaticReset,
                            style: TextStyle(
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[900],
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          _buildInteractiveBodyFor(triggerId),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Navigation buttons
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton.icon(
                              onPressed: _snoozeCurrent,
                              icon: const Icon(Icons.alarm, size: 16),
                              label: const Text(
                                'Snooze Limit',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.blue[700],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: allComplete ? _completeReset : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[600],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                elevation: allComplete ? 3 : 0,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(allComplete ? 'Proceed to Validation' : 'Perform Resets'),
                                  const SizedBox(width: 8),
                                  Icon(allComplete ? Icons.arrow_forward_rounded : Icons.lock_outline, size: 16),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (hasMultiple) ...[
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: widget.onDismissed,
                            child: Text(
                              'Snooze All Triggered Limits',
                              style: TextStyle(color: Colors.blue[900]?.withOpacity(0.5), fontSize: 12, decoration: TextDecoration.underline),
                            ),
                          ),
                        ]
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

  Widget _buildInteractiveBodyFor(String triggerId) {
    if (triggerId.isEmpty) return const SizedBox();

    // 1. Time-based resets UI
    if (triggerId == 'dopamine_loop' || 
        triggerId == 'reactive_mode' || 
        triggerId == 'last_scroll_loop' ||
        triggerId == 'work_life_blur' || 
        triggerId == 'novelty_hunt' || 
        triggerId == 'interaction_spike' ||
        triggerId == 'info_overload' ||
        triggerId == 'daily_cap_limit') {
      final seconds = _secondsRemainingMap[triggerId] ?? 60;
      return Column(
        children: [
          Text(
            '$seconds',
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.blue[700]),
          ),
          const SizedBox(height: 6),
          const Text('Seconds Remaining', style: TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      );
    }

    // 2. Checklist resets UI
    if (triggerId == 'the_void' || triggerId == 'midnight_drift') {
      final items = _checklistItemsMap[triggerId] ?? [];
      final checked = _checkedItemsMap[triggerId] ?? [];
      return Column(
        children: List.generate(items.length, (index) {
          final isChecked = checked[index];
          return CheckboxListTile(
            title: Text(
              items[index],
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isChecked ? Colors.grey : Colors.blue[900],
              ),
            ),
            value: isChecked,
            activeColor: Colors.blue,
            onChanged: (val) {
              setState(() {
                checked[index] = val ?? false;
              });
            },
          );
        }),
      );
    }

    // 3. Breathing resets UI
    if (triggerId == 'ghosting_anxiety' || triggerId == 'social_spiral') {
      return Column(
        children: [
          ScaleTransition(
            scale: _breathingAnimation,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue[300]!.withOpacity(0.3),
                border: Border.all(color: Colors.blue[600]!, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _breathDirection,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[800]),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _completedTriggers.add(triggerId);
              });
            },
            child: const Text('Complete 3 Breath Cycles'),
          ),
        ],
      );
    }

    // 4. Tap / Counter resets UI
    if (triggerId == 'phantom_check') {
      final taps = _tapCountsMap[triggerId] ?? 0;
      return Column(
        children: [
          Text(
            '$taps / 5',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.blue[700]),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _tapCountsMap[triggerId] = taps + 1;
              });
            },
            icon: const Icon(Icons.done, size: 16),
            label: Text(triggerId == 'phantom_check' ? 'Log 1 Shoulder Roll' : 'I am Mindful of this Comparison'),
          ),
        ],
      );
    }

    return const SizedBox();
  }
}
