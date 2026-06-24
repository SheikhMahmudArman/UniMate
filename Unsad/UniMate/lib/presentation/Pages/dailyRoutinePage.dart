// routine.dart - This file contains the RoutinePage widget.
import 'package:flutter/material.dart';

// This widget displays two routines side-by-side.
class RoutinePage extends StatefulWidget {
  const RoutinePage({super.key});

  @override
  State<RoutinePage> createState() => _RoutinePageState();
}

class _RoutinePageState extends State<RoutinePage> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<Map<String, dynamic>> routineA = [
    // Added Sunday entries for Routine A
    {'day': 'SUN', 'time': '09:00 AM - 10:00 AM', 'subject': 'CSE 2101', 'section': '8A01 (TBA)'},
    {'day': 'SUN', 'time': '10:00 AM - 11:00 AM', 'subject': 'CSE 2102', 'section': '8A01 (TBA)'},
    {'day': 'SUN', 'time': '02:00 PM - 03:00 PM', 'subject': 'CSE 2109(A2)', 'section': '7A07 (TBA)'},
    {'day': 'MON', 'time': '08:00 AM - 08:50 AM', 'subject': 'EEE 2142(A2)', 'section': '7B07 (Hasan, Muntakina)'},
    {'day': 'MON', 'time': '08:50 AM - 09:40 AM', 'subject': 'EEE 2142(A2)', 'section': '7B07 (Hasan, Muntakina)'},
    {'day': 'MON', 'time': '09:40 AM - 10:30 AM', 'subject': 'MATH 2101', 'section': '7C06 (TBA)'},
    {'day': 'MON', 'time': '10:30 AM - 11:20 AM', 'subject': 'MATH 2101', 'section': '7C06 (TBA)'},
    {'day': 'MON', 'time': '11:20 AM - 12:10 PM', 'subject': 'HUM 2109', 'section': '7C06 (TBA)'},
    {'day': 'MON', 'time': '01:00 PM - 01:50 PM', 'subject': 'CSE 2103', 'section': '7C07 (Rab)'},
    {'day': 'MON', 'time': '01:50 PM - 02:40 PM', 'subject': 'CSE 2106(A1)', 'section': '9A06 (Chowdhury, Hasan)'},
    {'day': 'MON', 'time': '02:40 PM - 03:30 PM', 'subject': 'CSE 2103', 'section': '7C07 (Rab)'},
    {'day': 'MON', 'time': '05:10 PM - 06:00 PM', 'subject': 'EEE 2142(A1)', 'section': '3B06 (TBA)'},
    {'day': 'TUE', 'time': '08:00 AM - 08:50 AM', 'subject': 'CSE 2100(A1/A2)', 'section': '7B07 (Siam)'},
    {'day': 'TUE', 'time': '09:40 AM - 10:30 AM', 'subject': 'MATH 2101', 'section': '7C06 (TBA)'},
    {'day': 'TUE', 'time': '10:30 AM - 11:20 AM', 'subject': 'CSE 2105', 'section': '7C06 (TBA)'},
    {'day': 'TUE', 'time': '11:20 AM - 12:10 PM', 'subject': 'CSE 2103', 'section': '7C06 (TBA)'},
    {'day': 'WED', 'time': '01:50 PM - 02:40 PM', 'subject': 'CSE 2100(A2)', 'section': '9A06 (Chowdhury, Hasan)'},
    {'day': 'WED', 'time': '02:40 PM - 03:30 PM', 'subject': 'EEE 2141', 'section': '7C07 (TBA)'},
    {'day': 'WED', 'time': '03:30 PM - 04:20 PM', 'subject': 'CSE 2103', 'section': '7C07 (Hasan)'},
    {'day': 'WED', 'time': '04:20 PM - 05:10 PM', 'subject': 'HUM 2109', 'section': '7C07 (TBA)'},
    {'day': 'THU', 'time': '10:30 AM - 11:20 AM', 'subject': 'CSE 2104(A1)', 'section': '7B07 (Islam, Rab)'},
    {'day': 'THU', 'time': '11:20 AM - 12:10 PM', 'subject': 'CSE 2104(A1)', 'section': '7B07 (Islam, Rab)'},
    {'day': 'THU', 'time': '01:50 PM - 02:40 PM', 'subject': 'MATH 2101', 'section': '7A07 (TBA)'},
    {'day': 'THU', 'time': '02:40 PM - 03:30 PM', 'subject': 'EEE 2141', 'section': '7A07 (TBA)'},
    {'day': 'THU', 'time': '03:30 PM - 04:20 PM', 'subject': 'CSE 2103', 'section': '7A07 (Rab)'},
  ];

  final List<Map<String, dynamic>> routineB = [
    // Added Sunday entries for Routine B
    {'day': 'SUN', 'time': '08:30 AM - 09:30 AM', 'subject': 'CSE 2105', 'section': '9B02 (TBA)'},
    {'day': 'SUN', 'time': '11:00 AM - 12:00 PM', 'subject': 'CSE 2104', 'section': '9B02 (TBA)'},
    {'day': 'MON', 'time': '08:00 AM - 08:50 AM', 'subject': 'CSE 2100(B1/B2)', 'section': '7B07 (Siam)'},
    {'day': 'MON', 'time': '08:50 AM - 09:40 AM', 'subject': 'CSE 2100(B1/B2)', 'section': '7B07 (Siam)'},
    {'day': 'MON', 'time': '10:30 AM - 11:20 AM', 'subject': 'MATH 2101', 'section': '7C07 (TBA)'},
    {'day': 'MON', 'time': '11:20 AM - 12:10 PM', 'subject': 'HUM 2109', 'section': '7C07 (TBA)'},
    {'day': 'MON', 'time': '01:00 PM - 01:50 PM', 'subject': 'CSE 2106(A1)', 'section': '7A07 (TBA)'},
    {'day': 'MON', 'time': '01:50 PM - 02:40 PM', 'subject': 'CSE 2106(A1)', 'section': '7A07 (TBA)'},
    {'day': 'TUE', 'time': '09:40 AM - 10:30 AM', 'subject': 'HUM 2109', 'section': '7A07 (TBA)'},
    {'day': 'TUE', 'time': '10:30 AM - 11:20 AM', 'subject': 'MATH 2101', 'section': '7A07 (TBA)'},
    {'day': 'TUE', 'time': '11:20 AM - 12:10 PM', 'subject': 'CSE 2105', 'section': '7A07 (TBA)'},
    {'day': 'TUE', 'time': '01:50 PM - 02:40 PM', 'subject': 'CSE 2106(B1)', 'section': '9A06 (Chowdhury, Hasan)'},
    {'day': 'TUE', 'time': '04:20 PM - 05:10 PM', 'subject': 'EEE 2142(B2)', 'section': '3B06 (TBA)'},
    {'day': 'WED', 'time': '08:00 AM - 08:50 AM', 'subject': 'CSE 2104(B1)', 'section': '7B07 (Rab, Islam)'},
    {'day': 'WED', 'time': '08:50 AM - 09:40 AM', 'subject': 'EEE 2142(B2)', 'section': '3B06 (TBA)'},
    {'day': 'WED', 'time': '11:20 AM - 12:10 PM', 'subject': 'EEE 2142(B2)', 'section': '3B06 (TBA)'},
    {'day': 'WED', 'time': '01:50 PM - 02:40 PM', 'subject': 'CSE 2103', 'section': '7C06 (TBA)'},
    {'day': 'WED', 'time': '02:40 PM - 03:30 PM', 'subject': 'CSE 2103', 'section': '7C06 (TBA)'},
    {'day': 'WED', 'time': '04:20 PM - 05:10 PM', 'subject': 'CSE 2105', 'section': '7C06 (Hasan)'},
    {'day': 'THU', 'time': '01:50 PM - 02:40 PM', 'subject': 'EEE 2141', 'section': '7A07 (TBA)'},
    {'day': 'THU', 'time': '02:40 PM - 03:30 PM', 'subject': 'CSE 2103', 'section': '7A07 (TBA)'},
    {'day': 'THU', 'time': '03:30 PM - 04:20 PM', 'subject': 'MATH 2101', 'section': '7C07 (Rab)'},
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Routines'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 4,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                _buildRoutineTable(routineA, 'Routine A'),
                _buildRoutineTable(routineB, 'Routine B'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _currentPage == 0 ? null : () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Previous'),
                ),
                Text(
                  'Routine ${_currentPage == 0 ? 'A' : 'B'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                ElevatedButton(
                  onPressed: _currentPage == 1 ? null : () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // A helper method to build the routine table.
  Widget _buildRoutineTable(List<Map<String, dynamic>> routineData, String title) {
    // Group data by day
    final Map<String, List<Map<String, dynamic>>> groupedData = {};
    for (var item in routineData) {
      final day = item['day'];
      if (!groupedData.containsKey(day)) {
        groupedData[day] = [];
      }
      groupedData[day]!.add(item);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // Enable horizontal scrolling for the days.
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: groupedData.entries.map((entry) {
            final day = entry.key;
            final schedules = entry.value;
            return Container(
              width: MediaQuery.of(context).size.width * 0.8,
              margin: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const Divider(color: Colors.deepPurple),
                      // Use an Expanded widget to prevent vertical overflow
                      Expanded(
                        child: ListView.builder(
                          itemCount: schedules.length,
                          itemBuilder: (context, index) {
                            final schedule = schedules[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    schedule['time']!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    schedule['subject']!,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    schedule['section']!,
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontStyle: FontStyle.italic,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
