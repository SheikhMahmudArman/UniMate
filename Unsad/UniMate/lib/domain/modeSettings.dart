

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ModeSettings extends StatefulWidget {
  const ModeSettings({super.key});

  @override
  State<ModeSettings> createState() => _ModeSettingsState();
}

class _ModeSettingsState extends State<ModeSettings> {
  String _selectedMode = 'Light';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Theme Mode',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        RadioListTile<String>(
          title: const Text('Light'),
          value: 'Light',
          groupValue: _selectedMode,
          onChanged: (value) {
            setState(() {
              _selectedMode = value!;
            });
          },
        ),
        RadioListTile<String>(
          title: const Text('Dark'),
          value: 'Dark',
          groupValue: _selectedMode,
          onChanged: (value) {
            setState(() {
              _selectedMode = value!;
            });
          },
        ),
      ],
    );
  }
}