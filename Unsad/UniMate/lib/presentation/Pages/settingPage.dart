import 'package:flutter/material.dart';
import 'package:unimate/presentation/Pages/menuPage.dart';

import '../../domain/changepasswordSettings.dart';
import '../../domain/modeSettings.dart';
import '../../domain/notificationSettings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MenuPage()),
            );
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          NotificationSettings(),
          SizedBox(height: 24),
          ModeSettings(),
          SizedBox(height: 24),
          ChangePassword(),
        ],
      ),
    );
  }
}









