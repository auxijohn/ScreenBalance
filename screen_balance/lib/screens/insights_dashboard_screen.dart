import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';
import '../logic/intervention_engine.dart';

class InsightsDashboardScreen extends StatefulWidget {
  const InsightsDashboardScreen({super.key});

  @override
  State<InsightsDashboardScreen> createState() => _InsightsDashboardScreenState();
}

class _InsightsDashboardScreenState extends State<InsightsDashboardScreen> {
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

  // Mock data for graphs if history is empty
  int _lastScrollCount = 0;
  int _phantomCheckCount = 0;
  int _dopamineLoopCount = 0;
  List<BehavioralEvent> _recentEvents = [];
  StreamSubscription? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _loadStatistics(showFeedback: false);
    _eventSubscription = InterventionEngine().eventBusStream.stream.listen((event) {
      if (event == "EVENT_NEW_LOGGED_EVENT") {
        _loadStatistics(showFeedback: false);
      }
    });
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  void _loadStatistics({bool showFeedback = false}) {
    final history = InterventionEngine().behavioralHistory;
    
    int lastScroll = 0;
    int phantom = 0;
    int dopamine = 0;

    for (var event in history) {
      if (event.eventType == "Intervention Triggered") {
        if (event.detail.contains("last_scroll_loop")) {
          lastScroll++;
        } else if (event.detail.contains("phantom_check")) {
          phantom++;
        } else if (event.detail.contains("dopamine_loop")) {
          dopamine++;
        }
      }
    }

    setState(() {
      _lastScrollCount = 2 + lastScroll;
      _phantomCheckCount = 5 + phantom;
      _dopamineLoopCount = 4 + dopamine;
      _recentEvents = history.reversed.take(6).toList();
    });

    if (showFeedback && mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insights refreshed successfully!'),
          backgroundColor: Color(0xFF0D47A1),
          duration: Duration(seconds: 1),
        ),
      );
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

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Circadian & Insights',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Circadian Core Score Card
                  _buildGlassCard(
                    padding: const EdgeInsets.all(24),
                    borderRadius: 28,
                    child: Row(
                      children: [
                        // Circular Indicator
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: CircularProgressIndicator(
                                value: 0.82,
                                strokeWidth: 8,
                                backgroundColor: Colors.white.withOpacity(0.1),
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00F2FE)),
                              ),
                            ),
                            const Text(
                              '82%',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Circadian Alignment',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Your sleep boundaries are highly stable. Continue avoiding midday dopamine loops to protect bedtime ease.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.7),
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sleep & Wake Baseline Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildValueCard(
                          title: "Avg Wakeup",
                          value: "07:15 AM",
                          icon: Icons.wb_sunny_outlined,
                          color: Colors.amberAccent,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildValueCard(
                          title: "Bedtime Goal",
                          value: "11:30 PM",
                          icon: Icons.nights_stay_outlined,
                          color: Colors.indigo[300]!,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Weekly Sleep Quality Chart
                  _buildGlassCard(
                    padding: const EdgeInsets.all(24),
                    borderRadius: 28,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'WEEKLY SLEEP QUALITY TRENDS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00F2FE),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 120,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildBar("Mon", 0.8),
                              _buildBar("Tue", 0.65),
                              _buildBar("Wed", 0.9),
                              _buildBar("Thu", 0.75),
                              _buildBar("Fri", 0.85),
                              _buildBar("Sat", 0.95),
                              _buildBar("Sun", 0.82),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Trigger Analytics Breakdowns
                  _buildGlassCard(
                    padding: const EdgeInsets.all(24),
                    borderRadius: 28,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TRIGGER FREQUENCY ANALYSIS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00F2FE),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTriggerIndicator("Phantom Check", _phantomCheckCount, 10, Colors.deepOrangeAccent),
                        const SizedBox(height: 12),
                        _buildTriggerIndicator("Dopamine Loop", _dopamineLoopCount, 10, Colors.amber[400]!),
                        const SizedBox(height: 12),
                        _buildTriggerIndicator("Last Scroll Loop", _lastScrollCount, 10, Colors.indigo[300]!),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Real-time Event Log list
                  _buildGlassCard(
                    padding: const EdgeInsets.all(24),
                    borderRadius: 28,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'RECENT TELEMETRY FEED',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00F2FE),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_recentEvents.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.0),
                            child: Text(
                              'No logged telemetry events. Interact with apps or locks to populate.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: Colors.white54),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _recentEvents.length,
                            separatorBuilder: (context, index) => const Divider(height: 12, color: Colors.white10),
                            itemBuilder: (context, index) {
                              final event = _recentEvents[index];
                              final timeStr = "${event.timestamp.hour.toString().padLeft(2, '0')}:${event.timestamp.minute.toString().padLeft(2, '0')}";
                              return Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      event.eventType.contains("Triggered") 
                                          ? Icons.warning_amber_rounded 
                                          : Icons.info_outline,
                                      size: 16,
                                      color: event.eventType.contains("Triggered") 
                                          ? Colors.orangeAccent 
                                          : const Color(0xFF00F2FE),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          event.eventType,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          event.detail,
                                          style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.7)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    timeStr,
                                    style: const TextStyle(fontSize: 11, color: Colors.white60),
                                  ),
                                ],
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return _buildGlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: Colors.white60, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String label, double scale) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 14,
          height: 80 * scale,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Color(0xFF0D47A1),
                Color(0xFF00F2FE),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white60),
        ),
      ],
    );
  }

  Widget _buildTriggerIndicator(String label, int value, int maxVal, Color color) {
    final double fraction = (value / maxVal).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('$value pings', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: fraction,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
