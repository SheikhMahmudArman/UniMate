//notification

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationSettings extends StatefulWidget {
  const NotificationSettings({super.key});

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  bool _notificationsEnabled = false;
  int _selectedHour = 1;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Notifications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Switch(
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
          ],
        ),
        if (_notificationsEnabled) ...[
          const SizedBox(height: 16),
          const Text(
            'Choose when to be notified for your exams and classes',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          DropdownButton<int>(
            value: _selectedHour,
            isExpanded: true,
            items: List.generate(24, (index) => index + 1)
                .map((hour) => DropdownMenuItem(
              value: hour,
              child: Text('$hour hour${hour > 1 ? 's' : ''} before'),
            ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedHour = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Notification set for $_selectedHour hour${_selectedHour > 1 ? 's' : ''} before')),
              );
            },
            child: const Text('Save Changes'),
          ),
        ],
      ],
    );
  }
}