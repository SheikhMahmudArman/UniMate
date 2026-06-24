// schedule.dart - This file contains the SchedulePage widget.
import 'package:flutter/material.dart';

// This widget displays exam schedules in a structured format with separate blocks.
class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  // Sample data for exam dates, separated by exam type.
  final Map<String, List<Map<String, dynamic>>> quizData = {
    'Quiz 1': [
      {'date': 'Oct 2, 2024', 'time': '10:00 AM', 'subject': 'MATH 2101'},
      {'date': 'Oct 3, 2024', 'time': '02:00 PM', 'subject': 'EEE 2141'},
      {'date': 'Oct 4, 2024', 'time': '11:00 AM', 'subject': 'CSE 2103'},
      {'date': 'Oct 5, 2024', 'time': '03:00 PM', 'subject': 'CSE 2105'},
      {'date': 'Oct 6, 2024', 'time': '12:00 PM', 'subject': 'HUM 2109'},
    ],
    'Quiz 2': [
      {'date': 'Nov 1, 2024', 'time': '10:00 AM', 'subject': 'MATH 2101'},
      {'date': 'Nov 5, 2024', 'time': '02:00 PM', 'subject': 'EEE 2141'},
      {'date': 'Nov 6, 2024', 'time': '11:00 AM', 'subject': 'CSE 2103'},
      {'date': 'Nov 7, 2024', 'time': '03:00 PM', 'subject': 'CSE 2105'},
      {'date': 'Nov 8, 2024', 'time': '12:00 PM', 'subject': 'HUM 2109'},
    ],
    'Quiz 3': [
      {'date': 'Nov 29, 2024', 'time': '10:00 AM', 'subject': 'MATH 2101'},
      {'date': 'Dec 1, 2024', 'time': '02:00 PM', 'subject': 'EEE 2141'},
      {'date': 'Dec 3, 2024', 'time': '11:00 AM', 'subject': 'CSE 2103'},
      {'date': 'Dec 4, 2024', 'time': '03:00 PM', 'subject': 'CSE 2105'},
      {'date': 'Dec 5, 2024', 'time': '12:00 PM', 'subject': 'HUM 2109'},
    ],
  };

  final List<Map<String, dynamic>> midTermData = [
    {'date': 'Oct 21, 2024', 'time': '09:00 AM', 'subject': 'MATH 2101'},
    {'date': 'Oct 23, 2024', 'time': '01:00 PM', 'subject': 'EEE 2141'},
    {'date': 'Oct 25, 2024', 'time': '10:00 AM', 'subject': 'CSE 2103'},
    {'date': 'Oct 27, 2024', 'time': '03:00 PM', 'subject': 'CSE 2105'},
    {'date': 'Oct 29, 2024', 'time': '12:00 PM', 'subject': 'HUM 2109'},
  ];

  final List<Map<String, dynamic>> finalData = [
    {'date': 'Dec 18, 2024', 'time': '09:00 AM', 'subject': 'MATH 2101'},
    {'date': 'Dec 20, 2024', 'time': '01:00 PM', 'subject': 'EEE 2141'},
    {'date': 'Dec 22, 2024', 'time': '10:00 AM', 'subject': 'CSE 2103'},
    {'date': 'Dec 24, 2024', 'time': '03:00 PM', 'subject': 'CSE 2105'},
    {'date': 'Dec 26, 2024', 'time': '12:00 PM', 'subject': 'HUM 2109'},
  ];

  // A map to store the checked state of each list item.
  // The key is a unique string for the row, and the value is a boolean.
  final Map<String, bool> _checkedStates = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Schedule'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Quizzes Section
            Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quizzes',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ...quizData.entries.map((entry) {
                      return _buildQuizSubSection(entry.key, entry.value);
                    }).toList(),
                  ],
                ),
              ),
            ),
            // Mid-terms Section
            const Divider(height: 32, thickness: 2, color: Colors.grey),
            _buildExamCard('Mid-terms', midTermData),
            // Finals Section
            const Divider(height: 32, thickness: 2, color: Colors.grey),
            _buildExamCard('Finals', finalData),
          ],
        ),
      ),
    );
  }

  // A helper method to build a sub-section for each quiz.
  Widget _buildQuizSubSection(String title, List<Map<String, dynamic>> schedules) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != 'Quiz 1') // Add a divider before Quiz 2 and 3
          const Divider(height: 32, thickness: 1, color: Colors.grey),
        Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _buildScheduleTable(schedules),
      ],
    );
  }

  // A helper method to build a Card for each exam type.
  Widget _buildExamCard(String title, List<Map<String, dynamic>> schedules) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            _buildScheduleTable(schedules),
          ],
        ),
      ),
    );
  }

  // A helper method to build the common table structure.
  Widget _buildScheduleTable(List<Map<String, dynamic>> schedules) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1.5), // Date
        1: FlexColumnWidth(1), // Time
        2: FlexColumnWidth(2), // Subject
      },
      children: [
        // Table headers
        const TableRow(
          children: [
            Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Time', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Subject', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        // Table rows with data
        ...schedules.map((schedule) {
          final uniqueKey = '${schedule['subject']}-${schedule['date']}-${schedule['time']}';
          final isChecked = _checkedStates[uniqueKey] ?? false;
          final textStyle = TextStyle(
            color: isChecked ? Colors.grey : Colors.black,
          );

          return TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  schedule['date']!,
                  style: textStyle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  schedule['time']!,
                  style: textStyle,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        schedule['subject']!,
                        style: textStyle,
                      ),
                    ),
                  ),
                  Checkbox(
                    value: isChecked,
                    onChanged: (bool? newValue) {
                      setState(() {
                        _checkedStates[uniqueKey] = newValue!;
                      });
                    },
                  ),
                ],
              ),
            ],
          );
        }).toList(),
      ],
    );
  }
}