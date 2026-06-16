import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../logic/intervention_engine.dart';
import '../logic/adaptive_engine.dart';
import 'profile_card_screen.dart';
import 'boundary_config_screen.dart';
import 'insights_dashboard_screen.dart';

class DashboardShell extends StatefulWidget {
  final VoidCallback onLogout;
  const DashboardShell({super.key, required this.onLogout});

  @override
  State<DashboardShell> createState() => DashboardShellState();
}

class DashboardShellState extends State<DashboardShell> {
  int _currentIndex = 0;
  bool _isLoading = true;

  void setSelectedIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await UserProfile.loadFromStorage();
    setState(() {
      _profile = profile ?? UserProfile(name: 'User');
      _isLoading = false;
    });
  }

  void _showDebugMenu() {
    final triggers = [
      {'id': 'dopamine_loop', 'name': 'Dopamine Loop', 'desc': '3+ apps in <60 seconds'},
      {'id': 'the_void', 'name': 'The Void', 'desc': '20+ mins of continuous scrolling'},
      {'id': 'reactive_mode', 'name': 'Reactive Mode', 'desc': '5+ notification opens in 10 mins'},
      {'id': 'social_spiral', 'name': 'Social Spiral', 'desc': '10+ rapid profile views on social'},
      {'id': 'ghosting_anxiety', 'name': 'Ghosting Anxiety', 'desc': 'Typing, deleting all, closing'},
      {'id': 'upward_comparison', 'name': 'Upward Comparison Risk', 'desc': 'Prolonged passive social scrolling'},
      {'id': 'midnight_drift', 'name': 'Midnight Drift', 'desc': 'Usage 1 hour past target bedtime'},
      {'id': 'last_scroll_loop', 'name': 'Last Scroll Loop', 'desc': '3+ unlocks in 2 mins at night'},
      {'id': 'work_life_blur', 'name': 'Work-Life Blur', 'desc': 'Slack/Email outside Focus Hours'},
      {'id': 'phantom_check', 'name': 'Phantom Check', 'desc': '10+ unlocks in 15 mins'},
      {'id': 'novelty_hunt', 'name': 'Novelty Hunt', 'desc': '5+ shopping apps in 10 mins'},
      {'id': 'info_overload', 'name': 'Info Overload', 'desc': '5+ news apps in 15 mins'},
      {'id': 'interaction_spike', 'name': 'Interaction Spike', 'desc': 'Rapid scrolling speed doubling'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.bug_report, color: Colors.blue[700]),
                const SizedBox(width: 8),
                const Text("Local Simulator Dashboard", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              "Simulate any of the 13 raw OS telemetry triggers to verify boundaries and somatic resets overlays!",
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[50],
                      foregroundColor: Colors.blue[900],
                      padding: const EdgeInsets.all(16),
                    ),
                    icon: const Icon(Icons.autorenew),
                    label: const Text("Simulate Weekly Adaptation Analysis", style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () async {
                      Navigator.pop(context);
                      await AdaptiveEngine().runWeeklyAdaptation();
                      await _loadProfile(); // reload profile card
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Weekly Adaptation Check Executed! Check log/dashboard.')),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  ...triggers.map((trigger) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ListTile(
                        leading: Icon(Icons.play_arrow, color: Colors.blue[600]),
                        title: Text(trigger['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(trigger['desc']!),
                        tileColor: Colors.blue[50]?.withOpacity(0.3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        onTap: () {
                          Navigator.pop(context);
                          InterventionEngine().simulateTrigger(trigger['id']!);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 12,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF0A192F), Color(0xFF0D47A1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(24),
          border: isSelected
              ? Border.all(color: Colors.white.withOpacity(0.15), width: 1.5)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0D47A1).withOpacity(0.35),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, 5),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF0A192F).withOpacity(0.6),
              size: 20,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final List<Widget> pages = [
      ProfileCardScreen(
        profile: _profile!,
        onProfileUpdated: _loadProfile,
        onLogout: widget.onLogout,
      ),
      const BoundaryConfigScreen(),
      const InsightsDashboardScreen(),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Capsule Navigation Bar
            Container(
              margin: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: const Color(0xFF0D47A1).withOpacity(0.08), width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.spa, 'Wellness'),
                  _buildNavItem(1, Icons.phonelink_lock, 'Boundaries'),
                  _buildNavItem(2, Icons.insights, 'Insights'),
                ],
              ),
            ),
            
            // Screen Content
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: pages,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showDebugMenu,
        backgroundColor: const Color(0xFF0D47A1),
        mini: true,
        child: const Icon(Icons.bug_report, color: Colors.white),
      ),
    );
  }
}
