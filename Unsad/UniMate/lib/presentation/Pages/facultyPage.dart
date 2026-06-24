import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FacultyPage extends StatefulWidget {
  const FacultyPage({Key? key}) : super(key: key);

  @override
  State<FacultyPage> createState() => _FacultyPageState();
}

class _FacultyPageState extends State<FacultyPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _consultationController = TextEditingController();
  List<Map<String, dynamic>> facultyList = [];
  bool showAddFaculty = false;
  int? _editingFacultyIndex; // Track which faculty is being edited for consultation hours

  @override
  void initState() {
    super.initState();
    _loadFaculty();
  }

  Future<void> _loadFaculty() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? storedFaculty = prefs.getStringList('faculty_list');
    print('Stored Faculty: $storedFaculty'); // Debug print
    if (storedFaculty != null) {
      setState(() {
        facultyList = storedFaculty.map((e) => Map<String, dynamic>.from(jsonDecode(e))).toList();
        print('Faculty List Loaded: $facultyList'); // Debug print
      });
    } else {
      print('No faculty data found in SharedPreferences'); // Debug print
    }
  }

  Future<void> _saveFaculty() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> storedFaculty = facultyList.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList('faculty_list', storedFaculty);
    print('Faculty List Saved: $storedFaculty'); // Debug print
  }

  void _addFaculty(String name, String email) {
    if (name.isNotEmpty && email.isNotEmpty) {
      setState(() {
        facultyList.add({
          'name': name,
          'email': email,
          'consultation_hours': <String>[],
        });
        showAddFaculty = false;
        _nameController.clear();
        _emailController.clear();
      });
      _saveFaculty();
    }
  }

  void _removeFaculty(int index) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this faculty member and their consultation hours?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm) {
      setState(() {
        facultyList.removeAt(index);
      });
      _saveFaculty();
    }
  }

  void _addConsultationHour(int facultyIndex, String consultationHour) {
    if (consultationHour.isNotEmpty && facultyIndex < facultyList.length) {
      setState(() {
        facultyList[facultyIndex]['consultation_hours'].add(consultationHour);
        _consultationController.clear();
        _editingFacultyIndex = null;
      });
      _saveFaculty();
    }
  }

  void _removeConsultationHour(int facultyIndex, int hourIndex) {
    if (facultyIndex < facultyList.length && hourIndex < facultyList[facultyIndex]['consultation_hours'].length) {
      setState(() {
        facultyList[facultyIndex]['consultation_hours'].removeAt(hourIndex);
      });
      _saveFaculty();
    }
  }

  Widget _buildFacultyCard(int index) {
    List<String> hours = facultyList[index]['consultation_hours'] ?? [];
    bool isAddingHours = _editingFacultyIndex == index;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        facultyList[index]['name'] ?? '',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        facultyList[index]['email'] ?? '',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeFaculty(index),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Consultation Hours:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            hours.isEmpty
                ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text('No consultation hours added'),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: hours.length,
              itemBuilder: (context, hourIndex) {
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                  title: Text(hours[hourIndex]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeConsultationHour(index, hourIndex),
                  ),
                );
              },
            ),
            if (isAddingHours)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _consultationController,
                        decoration: const InputDecoration(
                          hintText: 'e.g., Sun 1:00PM-1:50PM',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        _addConsultationHour(index, _consultationController.text);
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _editingFacultyIndex = isAddingHours ? null : index;
                    _consultationController.clear();
                  });
                },
                child: Text(isAddingHours ? 'Cancel' : 'Add Consultation Hour'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Faculty', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.purpleAccent.shade100,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: facultyList.isEmpty
                    ? const Center(
                  child: Text(
                    'No faculty added yet',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                )
                    : ListView.builder(
                  itemCount: facultyList.length,
                  itemBuilder: (context, index) {
                    return _buildFacultyCard(index);
                  },
                ),
              ),
              if (showAddFaculty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'Enter Faculty Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          hintText: 'Enter Email Address',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                _addFaculty(_nameController.text, _emailController.text);
                              },
                              child: const Text('Add Faculty'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                showAddFaculty = false;
                                _nameController.clear();
                                _emailController.clear();
                              });
                            },
                            child: const Text('Cancel'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    showAddFaculty = !showAddFaculty;
                    _editingFacultyIndex = null;
                    _nameController.clear();
                    _emailController.clear();
                    _consultationController.clear();
                  });
                },
                child: Text(showAddFaculty ? 'Cancel' : 'Add Faculty'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}