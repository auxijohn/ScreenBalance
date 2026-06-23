import 'package:flutter/material.dart';
import '../models/boundary_settings.dart';

class AccountabilityScreen extends StatefulWidget {
  final BoundarySettings settings;

  const AccountabilityScreen({
    super.key,
    required this.settings,
  });

  @override
  State<AccountabilityScreen> createState() => _AccountabilityScreenState();
}

class _AccountabilityScreenState extends State<AccountabilityScreen> {
  late BoundarySettings _settings;
  final TextEditingController _contactNameController = TextEditingController();
  final TextEditingController _contactInfoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }

  @override
  void dispose() {
    _contactNameController.dispose();
    _contactInfoController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A192F),
        elevation: 0,
        title: const Text('Accountability Partners', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
                'Add partners to help you stay accountable. They will receive updates when you break your digital boundaries.',
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
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _contactNameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Partner Name',
                            labelStyle: const TextStyle(color: Colors.white54),
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.person_outline, size: 20, color: Colors.blue[300]),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        TextField(
                          controller: _contactInfoController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Phone or Email',
                            labelStyle: const TextStyle(color: Colors.white54),
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.contact_mail_outlined, size: 20, color: Colors.blue[300]),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        Divider(height: 10, color: Colors.white.withOpacity(0.2)),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: _addNewContact,
                            icon: Icon(Icons.add, color: Colors.blue[300], size: 18),
                            label: Text('Add Partner', style: TextStyle(color: Colors.blue[300], fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_settings.accountabilityContacts.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ...List.generate(_settings.accountabilityContacts.length, (index) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: ListTile(
                          dense: true,
                          leading: const Icon(Icons.verified_user, color: Colors.greenAccent, size: 16),
                          title: Text(_settings.accountabilityContacts[index], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white)),
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
          ],
        ),
      ),
    );
  }
}
