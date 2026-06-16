import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'dart:ui' show ImageFilter;
import 'package:device_apps/device_apps.dart';
import '../models/boundary_settings.dart';
import 'tranquility_success_screen.dart';
import 'dashboard_shell.dart';
import '../logic/intervention_engine.dart';
class BoundaryConfigScreen extends StatefulWidget {
  const BoundaryConfigScreen({super.key});

  @override
  State<BoundaryConfigScreen> createState() => _BoundaryConfigScreenState();
}

class _BoundaryConfigScreenState extends State<BoundaryConfigScreen> {
  BoundarySettings _settings = BoundarySettings();
  List<Application> _installedApps = [];
  bool _isLoading = true;
  bool _isSchedulesExpanded = false; // Collapsible schedules card state
  bool _isPartnersExpanded = false; // Collapsible partners card state

  final TextEditingController _customAppController = TextEditingController();
  final TextEditingController _contactNameController = TextEditingController();
  final TextEditingController _contactInfoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _customAppController.dispose();
    _contactNameController.dispose();
    _contactInfoController.dispose();
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

  Future<void> _selectTime(BuildContext context, bool isBedtime, bool isFocusStart) async {
    TimeOfDay initial = TimeOfDay.now();
    if (isBedtime && _settings.targetBedtime != null) {
      initial = _settings.targetBedtime!;
    } else if (isFocusStart && _settings.focusStartTime != null) {
      initial = _settings.focusStartTime!;
    } else if (!isBedtime && !isFocusStart && _settings.focusEndTime != null) {
      initial = _settings.focusEndTime!;
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: Colors.blue[400]!),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        if (isBedtime) {
          _settings.targetBedtime = picked;
        } else if (isFocusStart) {
          _settings.focusStartTime = picked;
        } else {
          _settings.focusEndTime = picked;
        }
      });
      _settings.saveToStorage();
    }
  }

  void _addNewContact() {
    final name = _contactNameController.text.trim();
    final info = _contactInfoController.text.trim();
    if (name.isNotEmpty && info.isNotEmpty) {
      setState(() {
        _settings.accountabilityContacts.add('$name ($info)');
        _contactNameController.clear();
        _contactInfoController.clear();
      });
      _settings.saveToStorage();
    }
  }

  void _removeContact(int index) {
    setState(() {
      _settings.accountabilityContacts.removeAt(index);
    });
    _settings.saveToStorage();
  }

  // DIRECT PER-APP CONFIGURATION GETTERS
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

  // DIRECT PER-APP CONFIGURATION SETTERS
  void _toggleFocusShield(String appId) {
    setState(() {
      final isEnabled = _isFocusShieldEnabled(appId);
      if (isEnabled) {
        _settings.categorizedApps['Productivity']!.remove(appId);
        // If it has no other rules, make it Utility (exempt)
        if (!_isBedtimeShieldEnabled(appId) && _getDailyLimit(appId) == 0) {
          _settings.categorizedApps['Utility']!.add(appId);
        }
      } else {
        // Remove from Utility (exempt) if there
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
        // If it has no other rules, make it Utility (exempt)
        if (!_isFocusShieldEnabled(appId) && _getDailyLimit(appId) == 0) {
          _settings.categorizedApps['Utility']!.add(appId);
        }
      } else {
        // Remove from Utility (exempt) if there
        _settings.categorizedApps['Utility']!.remove(appId);
        _settings.categorizedApps['Emotional Distraction']!.add(appId);
      }
    });
    _settings.saveToStorage();
  }

  void _setDailyLimit(String appId, int limitMinutes) {
    setState(() {
      // Remove from older limit categories
      _settings.categorizedApps['Social']!.remove(appId);
      _settings.categorizedApps['Entertainment']!.remove(appId);
      _settings.categorizedApps['Utility']!.remove(appId);

      if (limitMinutes == 15) {
        _settings.categorizedApps['Social']!.add(appId);
      } else if (limitMinutes == 30) {
        _settings.categorizedApps['Entertainment']!.add(appId);
      } else {
        // No Limit: if no other rules are set, make it Utility (exempt)
        if (!_isFocusShieldEnabled(appId) && !_isBedtimeShieldEnabled(appId)) {
          _settings.categorizedApps['Utility']!.add(appId);
        }
      }
    });
    _settings.saveToStorage();
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
      'WhatsApp',
      'Discord',
      'TikTok',
      'Instagram',
      'Notion',
      'Slack',
      'Spotify',
      'YouTube',
      'Tinder',
      'Netflix',
      'Twitter'
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
                  List<Application> filteredApps = _installedApps.where((app) {
                    final alreadyAdded = _settings.customApps.contains(app.packageName);
                    return !alreadyAdded;
                  }).toList();

                  return Column(
                    children: [
                      // Header
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
                      
                      // Search bar
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
                      
                      // Apps List
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
      final app = _installedApps.firstWhere((a) => a.packageName == appIdentifier);
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
      final app = _installedApps.firstWhere((a) => a.packageName == appIdentifier);
      return app.appName;
    } catch (_) {}
    return appIdentifier.split('.').last;
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
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // 1. UNIQUE COLLAPSIBLE SCHEDULES CARD
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        initiallyExpanded: _isSchedulesExpanded,
                        onExpansionChanged: (val) {
                          setState(() {
                            _isSchedulesExpanded = val;
                          });
                        },
                        leading: const Icon(Icons.schedule, color: Color(0xFF0D47A1), size: 24),
                        title: const Text(
                          'Schedules & Sleep Quiet',
                          style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0A192F), fontSize: 16),
                        ),
                        subtitle: Text(
                          _isSchedulesExpanded ? 'Collapse config' : 'Bedtime, Focus, & Accountability Partner',
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        children: [
                          const Divider(height: 10, color: Colors.black12),
                          const SizedBox(height: 12),
                          
                          // Bedtime Card
                          _buildScheduleCard(
                            icon: Icons.nights_stay,
                            color: Colors.indigo,
                            label: 'Target Bedtime',
                            value: _settings.targetBedtime?.format(context) ?? 'Not set',
                            onTap: () => _selectTime(context, true, false),
                          ),
                          const SizedBox(height: 10),
                          
                          // Focus Start
                          _buildScheduleCard(
                            icon: Icons.work,
                            color: Colors.orange,
                            label: 'Focus Mode Start',
                            value: _settings.focusStartTime?.format(context) ?? 'Not set',
                            onTap: () => _selectTime(context, false, true),
                          ),
                          const SizedBox(height: 10),
 
                          // Focus End
                          _buildScheduleCard(
                            icon: Icons.free_breakfast,
                            color: Colors.brown,
                            label: 'Focus Mode End',
                            value: _settings.focusEndTime?.format(context) ?? 'Not set',
                            onTap: () => _selectTime(context, false, false),
                          ),
                          const SizedBox(height: 10),
 
                          // Morning Buffer Zone
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.wb_sunny, color: Colors.amber, size: 20),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Morning Buffer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0A192F))),
                                      Text('${_settings.morningBufferMinutes} min screen-free', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                                    ],
                                  ),
                                ),
                                DropdownButton<int>(
                                  value: _settings.morningBufferMinutes,
                                  underline: Container(),
                                  dropdownColor: Colors.white,
                                  items: [15, 30, 45, 60, 90, 120].map((int val) {
                                    return DropdownMenuItem<int>(
                                      value: val,
                                      child: Text('$val min', style: const TextStyle(color: Color(0xFF0A192F))),
                                    );
                                  }).toList(),
                                  onChanged: (int? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        _settings.morningBufferMinutes = newValue;
                                      });
                                      _settings.saveToStorage();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. standalone collapsible accountability partners card
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        initiallyExpanded: _isPartnersExpanded,
                        onExpansionChanged: (val) {
                          setState(() {
                            _isPartnersExpanded = val;
                          });
                        },
                        leading: const Icon(Icons.people_outline, color: Color(0xFF0D47A1), size: 24),
                        title: const Text(
                          'Accountability Partners',
                          style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0A192F), fontSize: 16),
                        ),
                        subtitle: Text(
                          _isPartnersExpanded ? 'Collapse config' : '${_settings.accountabilityContacts.length} partner(s) configured',
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        children: [
                          const Divider(height: 10, color: Colors.black12),
                          const SizedBox(height: 12),
                          
                          // Accountability Inputs
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.withOpacity(0.2)),
                            ),
                            child: Column(
                              children: [
                                TextField(
                                  controller: _contactNameController,
                                  style: const TextStyle(color: Color(0xFF0A192F)),
                                  decoration: const InputDecoration(
                                    labelText: 'Partner Name',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    border: InputBorder.none,
                                    prefixIcon: Icon(Icons.person_outline, size: 20, color: Color(0xFF0D47A1)),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                                TextField(
                                  controller: _contactInfoController,
                                  style: const TextStyle(color: Color(0xFF0A192F)),
                                  decoration: const InputDecoration(
                                    labelText: 'Phone or Email',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    border: InputBorder.none,
                                    prefixIcon: Icon(Icons.contact_mail_outlined, size: 20, color: Color(0xFF0D47A1)),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                                const Divider(height: 10, color: Colors.black12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed: _addNewContact,
                                    icon: const Icon(Icons.add, color: Color(0xFF0D47A1), size: 18),
                                    label: const Text('Add Partner', style: TextStyle(color: Color(0xFF0D47A1), fontWeight: FontWeight.bold, fontSize: 13)),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Contacts List
                          if (_settings.accountabilityContacts.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            ...List.generate(_settings.accountabilityContacts.length, (index) {
                              return Card(
                                color: const Color(0xFF0D47A1).withOpacity(0.06),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: ListTile(
                                  dense: true,
                                  leading: const Icon(Icons.verified_user, color: Color(0xFF0D47A1), size: 16),
                                  title: Text(_settings.accountabilityContacts[index], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF0A192F))),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                                    onPressed: () => _removeContact(index),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ],
                      ),
                    ),
                  ),
 
                  // 2. MAIN SECTION HEADER & ADD BUTTON
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'BALANCED APPLICATIONS',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 1.2),
                      ),
                      ElevatedButton.icon(
                        onPressed: _showAddAppPicker,
                        icon: const Icon(Icons.add_moderator, size: 16, color: Colors.white),
                        label: const Text('Add App', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D47A1),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
 
                  // 3. APPS LIST VIEW (NO CATEGORIZATION)
                  if (_settings.customApps.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.spa_outlined, size: 64, color: Color(0xFF0D47A1)),
                          const SizedBox(height: 16),
                          const Text(
                            'Your focus path is clear.',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A192F)),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the "+ Add App" button above to add distracting apps to your balance system and protect your peace.',
                            style: TextStyle(fontSize: 13, color: const Color(0xFF0F172A).withOpacity(0.8)),
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
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Card Top Row (Icon, Name, Delete)
                            Row(
                              children: [
                                _getAppIconWidget(appId, 32),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    name,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A192F)),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                  onPressed: () => _removeApp(appId),
                                ),
                              ],
                            ),
                            const Divider(height: 24, color: Colors.black12),
 
                            // Card Mid Row: Bedtime & Focus Shields
                            Row(
                              children: [
                                // Bedtime Shield Toggle
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.nights_stay_outlined,
                                        size: 18,
                                        color: isBedtimeShield ? Colors.indigo : Colors.grey,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Bedtime Shield',
                                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0A192F)),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              isBedtimeShield ? 'Blocks late' : 'No block',
                                              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
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
                                          activeColor: Colors.indigo,
                                          onChanged: (_) => _toggleBedtimeShield(appId),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                
                                // Focus Shield Toggle
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.work_outline,
                                        size: 18,
                                        color: isFocusShield ? Colors.orange[800] : Colors.grey,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Focus Shield',
                                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0A192F)),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              isFocusShield ? 'Blocks active' : 'No block',
                                              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
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
                                          activeColor: Colors.orange[800],
                                          onChanged: (_) => _toggleFocusShield(appId),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
 
                            // Card Bottom Row: Daily Allowance selector chips (tactile!)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.hourglass_empty, size: 14, color: Color(0xFF0D47A1)),
                                    SizedBox(width: 4),
                                    Text(
                                      'Daily Mindful Allowance:',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
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
                    }),
                  
                  const SizedBox(height: 28),

                  // 3.5. MOTIVATIONAL FOCUS INPUT CARD
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),

                  // 4. LARGE SAVE BUTTON
                  ElevatedButton(
                    onPressed: () async {
                      await _settings.saveToStorage();
                      if (!context.mounted) return;

                      // Get custom 5-word personality transformation mapping
                      final transformation = _getIdentityTransformation();

                      // Show shift transition dialog
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
                      backgroundColor: const Color(0xFF0D47A1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      elevation: 2,
                      shadowColor: Colors.black.withOpacity(0.2),
                    ),
                    child: const Text('Save & Apply Limits', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
      ),
    );
  }

  Widget _buildScheduleCard({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: color, size: 20),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text(value, style: TextStyle(fontSize: 11, color: Colors.grey[700])),
        trailing: const Icon(Icons.edit, size: 16),
        onTap: onTap,
      ),
    );
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
            color: isSelected ? Colors.blue[500] : Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.blue[500]! : Colors.blue.withOpacity(0.12),
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
              color: isSelected ? Colors.white : Colors.blue[900],
            ),
          ),
        ),
      ),
    );
  }

  Map<String, String> _getIdentityTransformation() {
    final hasBedtime = _settings.targetBedtime != null;
    final hasBedtimeShield = _settings.categorizedApps['Emotional Distraction']?.isNotEmpty ?? false;
    final hasFocusSchedule = _settings.focusStartTime != null || _settings.focusEndTime != null;
    final hasFocusShield = _settings.categorizedApps['Productivity']?.isNotEmpty ?? false;
    final hasSocialCap = _settings.categorizedApps['Social']?.isNotEmpty ?? false;
    final hasEntertainmentCap = _settings.categorizedApps['Entertainment']?.isNotEmpty ?? false;

    // adjective pools for natural language
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
    // Fetch dynamic phrase based on digital mindfulness score
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
                              color: Color(0xFF0A192F),
                              fontWeight: FontWeight.bold,
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
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: glowColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: glowColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: glowColor.withOpacity(0.25),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: glowColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: glowColor.withOpacity(0.7),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  phrase,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
