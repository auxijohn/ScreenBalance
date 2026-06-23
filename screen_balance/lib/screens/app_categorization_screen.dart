import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:device_apps/device_apps.dart';
import '../models/boundary_settings.dart';

class AppCategorizationScreen extends StatefulWidget {
  final BoundarySettings settings;
  final List<Application> installedApps;

  const AppCategorizationScreen({
    super.key,
    required this.settings,
    required this.installedApps,
  });

  @override
  State<AppCategorizationScreen> createState() => _AppCategorizationScreenState();
}

class _AppCategorizationScreenState extends State<AppCategorizationScreen> {
  late BoundarySettings _settings;

  final Map<String, IconData> _categoryIcons = {
    'Social': Icons.forum,
    'Entertainment': Icons.play_circle_filled,
    'Productivity': Icons.work,
    'Emotional Distraction': Icons.favorite,
    'Utility': Icons.build,
  };

  final Map<String, Color> _categoryColors = {
    'Social': Colors.purple[400]!,
    'Entertainment': Colors.orange[400]!,
    'Productivity': Colors.green[400]!,
    'Emotional Distraction': Colors.red[400]!,
    'Utility': Colors.blueGrey[400]!,
  };

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }

  void _moveAppToCategory(String appId, String newCategory) {
    setState(() {
      // Remove from all categories first
      _settings.categorizedApps.forEach((key, list) {
        list.remove(appId);
      });
      // Add to new category
      _settings.categorizedApps.putIfAbsent(newCategory, () => []).add(appId);
    });
    _settings.saveToStorage();
  }

  String _getAppName(String appIdentifier) {
    if (kIsWeb || !Platform.isAndroid) return appIdentifier;
    try {
      final app = widget.installedApps.firstWhere((a) => a.packageName == appIdentifier);
      return app.appName;
    } catch (_) {
      return appIdentifier.split('.').last;
    }
  }

  Widget _getAppIcon(String appIdentifier, double size) {
    if (kIsWeb || !Platform.isAndroid) {
      return Icon(Icons.android, size: size, color: Colors.blue[300]);
    }
    try {
      final app = widget.installedApps.firstWhere((a) => a.packageName == appIdentifier);
      if (app is ApplicationWithIcon) {
        return Image.memory(app.icon, width: size, height: size);
      }
    } catch (_) {}
    return Icon(Icons.android, size: size, color: Colors.blue[300]);
  }

  Widget _buildAppChip(String appId) {
    return Draggable<String>(
      data: appId,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF0D47A1).withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _getAppIcon(appId, 24),
              const SizedBox(width: 8),
              Text(
                _getAppName(appId),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildStaticAppChip(appId, isInteractive: false),
      ),
      child: _buildStaticAppChip(appId, isInteractive: true),
    );
  }

  Widget _buildStaticAppChip(String appId, {bool isInteractive = false}) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: EdgeInsets.only(left: 10, right: isInteractive ? 4 : 10, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _getAppIcon(appId, 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              _getAppName(appId),
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isInteractive) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () {
                setState(() {
                  _settings.customApps.remove(appId);
                  _settings.categorizedApps.forEach((key, list) {
                    list.remove(appId);
                  });
                });
                _settings.saveToStorage();
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 10, color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryBucket(String categoryName) {
    final appsInCategory = _settings.categorizedApps[categoryName] ?? [];
    final trackedAppsInCategory = appsInCategory;

    return DragTarget<String>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) {
        if (!trackedAppsInCategory.contains(details.data)) {
          _moveAppToCategory(details.data, categoryName);
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        final color = _categoryColors[categoryName] ?? Colors.blue;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isHovering ? color.withOpacity(0.2) : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHovering ? color : Colors.white.withOpacity(0.1),
              width: isHovering ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: Row(
                  children: [
                    Icon(_categoryIcons[categoryName], color: color, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      categoryName.toUpperCase(),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${trackedAppsInCategory.length}',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: trackedAppsInCategory.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'Drag apps here',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white.withOpacity(0.3), fontStyle: FontStyle.italic),
                        ),
                      )
                    : Wrap(
                        children: trackedAppsInCategory.map((appId) => _buildAppChip(appId)).toList(),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A192F),
        elevation: 0,
        title: const Text('App Categorization', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A192F),
              Color(0xFF0D47A1),
            ],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Text(
                'Drag and drop your balanced apps between categories. This dictates which rules (like Social limits or Midnight drift) apply to them.',
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                children: [
                  _buildCategoryBucket('Social'),
                  _buildCategoryBucket('Entertainment'),
                  _buildCategoryBucket('Productivity'),
                  _buildCategoryBucket('Emotional Distraction'),
                  _buildCategoryBucket('Utility'),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
