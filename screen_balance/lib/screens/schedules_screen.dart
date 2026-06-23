import 'package:flutter/material.dart';
import '../models/boundary_settings.dart';
import '../logic/timezone_location_helper.dart';

class SchedulesScreen extends StatefulWidget {
  final BoundarySettings settings;

  const SchedulesScreen({
    super.key,
    required this.settings,
  });

  @override
  State<SchedulesScreen> createState() => _SchedulesScreenState();
}

class _SchedulesScreenState extends State<SchedulesScreen> {
  late BoundarySettings _settings;
  Map<String, TimeOfDay>? _calculatedSunTimes;
  bool _isLoadingSunTimes = false;

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
    if (_settings.syncFocusWithSun) {
      _fetchSunTimes();
    }
  }

  Future<void> _fetchSunTimes() async {
    setState(() => _isLoadingSunTimes = true);
    final times = await TimezoneLocationHelper.getTodaySunriseSunset();
    if (mounted) {
      setState(() {
        _calculatedSunTimes = times;
        _isLoadingSunTimes = false;
      });
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
      await _settings.saveToStorage();
    }
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
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: color, size: 24),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
        subtitle: Text(value, style: const TextStyle(fontSize: 12, color: Colors.white70)),
        trailing: const Icon(Icons.edit, size: 20, color: Colors.white54),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A192F),
        elevation: 0,
        title: const Text('Schedules & Sleep Quiet', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
              child: Text(
                'Configure your daily routines to automatically enable Focus and Bedtime Shields.',
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  _buildScheduleCard(
                    icon: Icons.nights_stay,
                    color: Colors.indigoAccent,
                    label: 'Target Bedtime',
                    value: _settings.targetBedtime?.format(context) ?? 'Not set',
                    onTap: () => _selectTime(context, true, false),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: SwitchListTile(
                      activeColor: Colors.amberAccent,
                      title: const Text('Sync Focus with Sunrise/Sunset', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                      subtitle: const Text('Automatically aligns focus hours with daylight.', style: TextStyle(fontSize: 12, color: Colors.white70)),
                      value: _settings.syncFocusWithSun,
                      onChanged: (bool value) async {
                        setState(() {
                          _settings.syncFocusWithSun = value;
                        });
                        await _settings.saveToStorage();
                        if (value) {
                          _fetchSunTimes();
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildScheduleCard(
                    icon: Icons.work,
                    color: Colors.orangeAccent,
                    label: 'Focus Mode Start',
                    value: _settings.syncFocusWithSun 
                        ? (_isLoadingSunTimes ? 'Calculating...' : (_calculatedSunTimes?['sunrise']?.format(context) ?? 'Auto-synced'))
                        : (_settings.focusStartTime?.format(context) ?? 'Not set'),
                    onTap: _settings.syncFocusWithSun ? () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Focus Start is currently synced with Sunrise.')));
                    } : () => _selectTime(context, false, true),
                  ),
                  const SizedBox(height: 12),
                  _buildScheduleCard(
                    icon: Icons.free_breakfast,
                    color: Colors.amberAccent,
                    label: 'Focus Mode End',
                    value: _settings.syncFocusWithSun 
                        ? (_isLoadingSunTimes ? 'Calculating...' : (_calculatedSunTimes?['sunset']?.format(context) ?? 'Auto-synced'))
                        : (_settings.focusEndTime?.format(context) ?? 'Not set'),
                    onTap: _settings.syncFocusWithSun ? () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Focus End is currently synced with Sunset.')));
                    } : () => _selectTime(context, false, false),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.wb_sunny, color: Colors.amber, size: 24),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Morning Buffer',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                              ),
                              Text(
                                '${_settings.morningBufferMinutes} min screen-free',
                                style: const TextStyle(fontSize: 12, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        Theme(
                          data: Theme.of(context).copyWith(
                            canvasColor: const Color(0xFF0D47A1),
                          ),
                          child: DropdownButton<int>(
                            value: _settings.morningBufferMinutes,
                            underline: Container(),
                            iconEnabledColor: Colors.white,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            items: [15, 30, 45, 60, 90, 120].map((int val) {
                              return DropdownMenuItem<int>(
                                value: val,
                                child: Text('$val min'),
                              );
                            }).toList(),
                            onChanged: (int? newValue) async {
                              if (newValue != null) {
                                setState(() {
                                  _settings.morningBufferMinutes = newValue;
                                });
                                await _settings.saveToStorage();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
