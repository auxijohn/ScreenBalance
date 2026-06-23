import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:device_apps/device_apps.dart';
import '../models/boundary_settings.dart';

class BalancedAppsScreen extends StatefulWidget {
  final BoundarySettings settings;
  final List<Application> installedApps;

  const BalancedAppsScreen({
    super.key,
    required this.settings,
    required this.installedApps,
  });

  @override
  State<BalancedAppsScreen> createState() => _BalancedAppsScreenState();
}

class _BalancedAppsScreenState extends State<BalancedAppsScreen> {
  late BoundarySettings _settings;
  final TextEditingController _customAppController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }

  @override
  void dispose() {
    _customAppController.dispose();
    super.dispose();
  }

  void _addAppToBalance(String appId) {
    setState(() {
      if (!_settings.customApps.contains(appId)) {
        _settings.customApps.add(appId);
        // Default: Exempt/Utility until configured
        _settings.categorizedApps['Utility']!.add(appId);
      }
    });
    _settings.saveToStorage();
  }

  void _removeApp(String appId) {
    setState(() {
      _settings.customApps.remove(appId);
      _settings.categorizedApps.forEach((key, list) {
        list.remove(appId);
      });
    });
    _settings.saveToStorage();
  }

  void _showAddAppPicker() {
    final bool isWindowsOrWeb = kIsWeb || (!kIsWeb && !Platform.isAndroid);

    if (isWindowsOrWeb) {
      _showCustomAddDialog();
    } else {
      _showAndroidAppPickerSheet();
    }
  }

  void _showCustomAddDialog() {
    final List<String> presets = [
      'WhatsApp', 'Discord', 'TikTok', 'Instagram', 'Notion',
      'Slack', 'Spotify', 'YouTube', 'Tinder', 'Netflix', 'Twitter'
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Add Application', style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _customAppController,
                  decoration: InputDecoration(
                    labelText: 'Application Name',
                    hintText: 'e.g. Netflix, Telegram',
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue[400]!)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Or select a preset:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: presets.map((preset) {
                    return ActionChip(
                      label: Text(preset),
                      onPressed: () {
                        _addAppToBalance(preset);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[400],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final name = _customAppController.text.trim();
                if (name.isNotEmpty) {
                  _addAppToBalance(name);
                  Navigator.pop(context);
                  _customAppController.clear();
                }
              },
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showAndroidAppPickerSheet() {
    String searchQuery = "";
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: StatefulBuilder(
                builder: (context, setModalState) {
                  List<Application> filteredApps = widget.installedApps.where((app) {
                    final alreadyAdded = _settings.customApps.contains(app.packageName);
                    return !alreadyAdded;
                  }).toList();

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Add App from Device',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[900]),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Search installed apps...',
                              prefixIcon: Icon(Icons.search, color: Colors.grey),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 14),
                            ),
                            onChanged: (val) {
                              setModalState(() {
                                searchQuery = val.toLowerCase();
                              });
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            final displayList = filteredApps.where((app) {
                              return app.appName.toLowerCase().contains(searchQuery);
                            }).toList();

                            if (displayList.isEmpty) {
                              return const Center(child: Text('No matching applications found.'));
                            }

                            return ListView.builder(
                              controller: scrollController,
                              itemCount: displayList.length,
                              itemBuilder: (context, index) {
                                Application app = displayList[index];
                                return ListTile(
                                  leading: app is ApplicationWithIcon
                                      ? Image.memory(app.icon, width: 40, height: 40)
                                      : const Icon(Icons.android, size: 40),
                                  title: Text(app.appName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text(app.packageName, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                  onTap: () {
                                    _addAppToBalance(app.packageName);
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _getAppIconWidget(String appIdentifier, double size) {
    if (kIsWeb || !Platform.isAndroid) {
      IconData iconData = Icons.phone_android;
      Color iconColor = Colors.blue[300]!;

      final lowerName = appIdentifier.toLowerCase();
      if (lowerName.contains('whatsapp') || lowerName.contains('discord') || lowerName.contains('telegram')) {
        iconData = Icons.forum;
        iconColor = Colors.amber[700]!;
      } else if (lowerName.contains('tiktok') || lowerName.contains('instagram') || lowerName.contains('tinder') || lowerName.contains('twitter')) {
        iconData = Icons.camera_alt;
        iconColor = Colors.red;
      } else if (lowerName.contains('notion') || lowerName.contains('slack') || lowerName.contains('trello')) {
        iconData = Icons.work;
        iconColor = Colors.green;
      } else if (lowerName.contains('spotify') || lowerName.contains('youtube') || lowerName.contains('netflix')) {
        iconData = Icons.play_circle_filled;
        iconColor = Colors.grey;
      } else if (lowerName.contains('banking') || lowerName.contains('maps') || lowerName.contains('calculator')) {
        iconData = Icons.star;
        iconColor = Colors.blue;
      }

      return Icon(iconData, size: size, color: iconColor);
    }

    try {
      final app = widget.installedApps.firstWhere((a) => a.packageName == appIdentifier);
      if (app is ApplicationWithIcon) {
        return Image.memory(app.icon, width: size, height: size);
      }
    } catch (_) {}

    return Icon(Icons.android, size: size, color: Colors.blue[400]);
  }

  String _getAppName(String appIdentifier) {
    if (kIsWeb || !Platform.isAndroid) {
      return appIdentifier;
    }
    try {
      final app = widget.installedApps.firstWhere((a) => a.packageName == appIdentifier);
      return app.appName;
    } catch (_) {}
    return appIdentifier.split('.').last;
  }

  bool _isFocusShieldEnabled(String appId) {
    return _settings.categorizedApps['Productivity']!.contains(appId);
  }

  bool _isBedtimeShieldEnabled(String appId) {
    return _settings.categorizedApps['Emotional Distraction']!.contains(appId);
  }

  int _getDailyLimit(String appId) {
    if (_settings.categorizedApps['Social']!.contains(appId)) return 15;
    if (_settings.categorizedApps['Entertainment']!.contains(appId)) return 30;
    return 0; // Unlimited / No Limit
  }

  void _toggleFocusShield(String appId) {
    setState(() {
      final isEnabled = _isFocusShieldEnabled(appId);
      if (isEnabled) {
        _settings.categorizedApps['Productivity']!.remove(appId);
        if (!_isBedtimeShieldEnabled(appId) && _getDailyLimit(appId) == 0) {
          _settings.categorizedApps['Utility']!.add(appId);
        }
      } else {
        _settings.categorizedApps['Utility']!.remove(appId);
        _settings.categorizedApps['Productivity']!.add(appId);
      }
    });
    _settings.saveToStorage();
  }

  void _toggleBedtimeShield(String appId) {
    setState(() {
      final isEnabled = _isBedtimeShieldEnabled(appId);
      if (isEnabled) {
        _settings.categorizedApps['Emotional Distraction']!.remove(appId);
        if (!_isFocusShieldEnabled(appId) && _getDailyLimit(appId) == 0) {
          _settings.categorizedApps['Utility']!.add(appId);
        }
      } else {
        _settings.categorizedApps['Utility']!.remove(appId);
        _settings.categorizedApps['Emotional Distraction']!.add(appId);
      }
    });
    _settings.saveToStorage();
  }

  void _setDailyLimit(String appId, int limitMinutes) {
    setState(() {
      _settings.categorizedApps['Social']!.remove(appId);
      _settings.categorizedApps['Entertainment']!.remove(appId);
      _settings.categorizedApps['Utility']!.remove(appId);

      if (limitMinutes == 15) {
        _settings.categorizedApps['Social']!.add(appId);
      } else if (limitMinutes == 30) {
        _settings.categorizedApps['Entertainment']!.add(appId);
      } else {
        if (!_isFocusShieldEnabled(appId) && !_isBedtimeShieldEnabled(appId)) {
          _settings.categorizedApps['Utility']!.add(appId);
        }
      }
    });
    _settings.saveToStorage();
  }

  Widget _buildAllowanceChip(String appId, int valueMinutes, String label) {
    final currentLimit = _getDailyLimit(appId);
    final isSelected = currentLimit == valueMinutes;

    return Expanded(
      child: InkWell(
        onTap: () => _setDailyLimit(appId, valueMinutes),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue[500] : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.blue[500]! : Colors.white.withOpacity(0.1),
              width: 1.2,
            ),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.blue.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A192F),
        elevation: 0,
        title: const Text('Balanced Applications', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A192F), Color(0xFF0D47A1)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Tracked apps can be configured with shields or daily mindful limits.',
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _showAddAppPicker,
                    icon: const Icon(Icons.add_moderator, size: 16, color: Colors.white),
                    label: const Text('Add App', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                    ),
                  ),
                ],
              ),
            ),
            if (_settings.customApps.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.spa_outlined, size: 64, color: Colors.white54),
                    const SizedBox(height: 16),
                    const Text(
                      'Your focus path is clear.',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the "+ Add App" button above to add distracting apps to your balance system and protect your peace.',
                      style: TextStyle(fontSize: 13, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ..._settings.customApps.map((appId) {
                final name = _getAppName(appId);
                final isFocusShield = _isFocusShieldEnabled(appId);
                final isBedtimeShield = _isBedtimeShieldEnabled(appId);

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          _getAppIconWidget(appId, 32),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                            onPressed: () => _removeApp(appId),
                          ),
                        ],
                      ),
                      Divider(height: 24, color: Colors.white.withOpacity(0.2)),
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.nights_stay_outlined,
                                  size: 18,
                                  color: isBedtimeShield ? Colors.indigoAccent : Colors.white54,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Bedtime Shield',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        isBedtimeShield ? 'Blocks late' : 'No block',
                                        style: const TextStyle(fontSize: 10, color: Colors.white70),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Transform.scale(
                                  scale: 0.8,
                                  child: Switch(
                                    value: isBedtimeShield,
                                    activeColor: Colors.indigoAccent,
                                    onChanged: (_) => _toggleBedtimeShield(appId),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.work_outline,
                                  size: 18,
                                  color: isFocusShield ? Colors.orangeAccent : Colors.white54,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Focus Shield',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        isFocusShield ? 'Blocks active' : 'No block',
                                        style: const TextStyle(fontSize: 10, color: Colors.white70),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Transform.scale(
                                  scale: 0.8,
                                  child: Switch(
                                    value: isFocusShield,
                                    activeColor: Colors.orangeAccent,
                                    onChanged: (_) => _toggleFocusShield(appId),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.hourglass_empty, size: 14, color: Colors.blueAccent),
                              SizedBox(width: 4),
                              Text(
                                'Daily Mindful Allowance:',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildAllowanceChip(appId, 0, "Unlimited"),
                              const SizedBox(width: 8),
                              _buildAllowanceChip(appId, 15, "15m Cap"),
                              const SizedBox(width: 8),
                              _buildAllowanceChip(appId, 30, "30m Cap"),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
