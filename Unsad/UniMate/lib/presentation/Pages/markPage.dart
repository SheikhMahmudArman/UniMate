import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MarksPage extends StatefulWidget {
  const MarksPage({Key? key}) : super(key: key);

  @override
  State<MarksPage> createState() => _MarksPageState();
}

class _MarksPageState extends State<MarksPage> {
  final TextEditingController _subjectController = TextEditingController();
  List<Map<String, dynamic>> subjects = [];
  List<Map<String, TextEditingController>> controllers = [];
  bool showAddSubject = false;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? storedSubjects = prefs.getStringList('subjects');
    if (storedSubjects != null) {
      setState(() {
        subjects = storedSubjects
            .map((e) => Map<String, dynamic>.from(jsonDecode(e)))
            .toList();
        controllers = subjects.map((subj) {
          return {
            'quiz1': TextEditingController(text: subj['quiz1'] ?? ''),
            'quiz2': TextEditingController(text: subj['quiz2'] ?? ''),
            'quiz3': TextEditingController(text: subj['quiz3'] ?? ''),
            'mid': TextEditingController(text: subj['mid'] ?? ''),
            'final': TextEditingController(text: subj['final'] ?? ''),
          };
        }).toList();
      });
    }
  }

  Future<void> _saveSubjects() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> storedSubjects = subjects.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList('subjects', storedSubjects);
  }

  void _addSubject(String name) {
    setState(() {
      subjects.add({
        'name': name,
        'quiz1': '',
        'quiz2': '',
        'quiz3': '',
        'mid': '',
        'final': '',
      });
      controllers.add({
        'quiz1': TextEditingController(),
        'quiz2': TextEditingController(),
        'quiz3': TextEditingController(),
        'mid': TextEditingController(),
        'final': TextEditingController(),
      });
      showAddSubject = false;
      _subjectController.clear();
    });
    _saveSubjects();
  }

  void _removeSubject(int index) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this subject?'),
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
        subjects.removeAt(index);
        controllers.removeAt(index);
      });
      _saveSubjects();
    }
  }

  Widget _buildTextField(int index, String key) {
    // Null safety check
    if (index >= controllers.length || controllers[index][key] == null) {
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: TextField(
        controller: controllers[index][key],
        onChanged: (val) {
          if (index < subjects.length) {
            subjects[index][key] = val;
            _saveSubjects();
          }
        },
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectRow(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                subjects[index]['name'] ?? '',
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(child: _buildTextField(index, 'quiz1')),
          Expanded(child: _buildTextField(index, 'quiz2')),
          Expanded(child: _buildTextField(index, 'quiz3')),
          Expanded(child: _buildTextField(index, 'mid')),
          Expanded(child: _buildTextField(index, 'final')),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              _removeSubject(index);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marks', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.purpleAccent.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (subjects.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.grey[300],
                child: Row(
                  children: const [
                    Expanded(
                        flex: 2,
                        child: Text('Subject',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(
                        child: Text('Quiz1',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(
                        child: Text('Quiz2',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(
                        child: Text('Quiz3',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(
                        child: Text('Mid',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(
                        child: Text('Final',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    SizedBox(width: 40),
                  ],
                ),
              ),
            Expanded(
              child: subjects.isEmpty
                  ? const Center(child: Text('No subjects added yet'))
                  : ListView.builder(
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  return _buildSubjectRow(index);
                },
              ),
            ),
            if (showAddSubject)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _subjectController,
                        decoration: const InputDecoration(
                          hintText: 'Enter Subject Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (_subjectController.text.isNotEmpty) {
                          _addSubject(_subjectController.text);
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  showAddSubject = !showAddSubject;
                });
              },
              child: Text(showAddSubject ? 'Cancel' : 'Add Subject'),
            ),
          ],
        ),
      ),
    );
  }
}
