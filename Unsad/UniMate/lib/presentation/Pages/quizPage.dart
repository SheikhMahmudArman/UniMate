import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({Key? key}) : super(key: key);

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _newSubjectController = TextEditingController();
  String currentQuiz = 'Quiz1';
  bool showAddSubject = false;

  String userRole = 'user';
  String userSemester = '';
  bool isLoading = true;

  // Store quiz data by quiz name
  Map<String, List<Map<String, dynamic>>> quizData = {
    'Quiz1': [],
    'Quiz2': [],
    'Quiz3': [],
  };

  // Controllers per docId for each quiz
  final Map<String, Map<String, Map<String, TextEditingController>>> _controllers = {
    'Quiz1': {},
    'Quiz2': {},
    'Quiz3': {},
  };

  @override
  void initState() {
    super.initState();
    _firestore.settings = const Settings(persistenceEnabled: true);
    _initializeUser();
  }

  @override
  void dispose() {
    _newSubjectController.dispose();
    // Dispose all controllers
    for (var quiz in _controllers.keys) {
      for (var controllerMap in _controllers[quiz]!.values) {
        controllerMap.values.forEach((c) => c.dispose());
      }
    }
    super.dispose();
  }

  Future<void> _initializeUser() async {
    await _getUserRole();
    await _loadLocalData();
    setState(() => isLoading = false);
  }

  Future<void> _getUserRole() async {
    try {
      final uid = _auth.currentUser!.uid;
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return;

      final data = doc.data()!;
      setState(() {
        userRole = (data['role'] ?? 'user').toString().toLowerCase();
        userSemester = (data['semester'] ?? '').toString();
      });
    } catch (e) {
      print('Error fetching user role: $e');
    }
  }

  Future<void> _loadLocalData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      for (String quiz in quizData.keys) {
        List<String>? storedList = prefs.getStringList('${userSemester}_$quiz');
        if (storedList != null) {
          quizData[quiz] = storedList
              .map((e) => Map<String, dynamic>.from(jsonDecode(e)))
              .toList();
        }
      }
    } catch (e) {
      print('Error loading local data: $e');
    }
  }

  Future<void> _saveToLocal(String quiz, List<Map<String, dynamic>> data) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> strList = data.map((e) {
        final copy = Map<String, dynamic>.from(e);
        // Convert Timestamp to string for local storage
        if (copy['createdAt'] is Timestamp) {
          copy['createdAt'] = (copy['createdAt'] as Timestamp).millisecondsSinceEpoch;
        }
        return jsonEncode(copy);
      }).toList();

      await prefs.setStringList('${userSemester}_$quiz', strList);
      quizData[quiz] = data;
    } catch (e) {
      print('Error saving to local: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> _loadQuizStream(String quiz) {
    if (userSemester.isEmpty) return const Stream.empty();

    return _firestore
        .collection('semesters')
        .doc(userSemester)
        .collection('quizzes')
        .doc(quiz)
        .collection('subjects')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      List<Map<String, dynamic>> data = snapshot.docs.map((doc) {
        final map = Map<String, dynamic>.from(doc.data());
        map['id'] = doc.id;
        return map;
      }).toList();
      _saveToLocal(quiz, data);
      return data;
    });
  }

  void _syncControllersWithData(String quiz, List<Map<String, dynamic>> data) {
    final Set<String> incomingIds = {};

    for (var item in data) {
      String id = (item['id'] ?? '').toString();
      if (id.isEmpty) {
        id = 'local_${data.indexOf(item)}_${DateTime.now().millisecondsSinceEpoch}';
        item['id'] = id;
      }
      incomingIds.add(id);

      if (!_controllers[quiz]!.containsKey(id)) {
        _controllers[quiz]![id] = {
          'subject': TextEditingController(text: item['subject']?.toString() ?? ''),
          'date': TextEditingController(text: item['date']?.toString() ?? ''),
          'room': TextEditingController(text: item['room']?.toString() ?? ''),
          'time': TextEditingController(text: item['time']?.toString() ?? ''),
        };
      } else {
        final c = _controllers[quiz]![id]!;
        if ((item['subject'] ?? '') != c['subject']!.text) c['subject']!.text = item['subject']?.toString() ?? '';
        if ((item['date'] ?? '') != c['date']!.text) c['date']!.text = item['date']?.toString() ?? '';
        if ((item['room'] ?? '') != c['room']!.text) c['room']!.text = item['room']?.toString() ?? '';
        if ((item['time'] ?? '') != c['time']!.text) c['time']!.text = item['time']?.toString() ?? '';
      }
    }

    final toRemove = _controllers[quiz]!.keys.where((k) => !incomingIds.contains(k)).toList();
    for (var k in toRemove) {
      _controllers[quiz]![k]!.values.forEach((c) => c.dispose());
      _controllers[quiz]!.remove(k);
    }
  }

  Future<void> _addSubject(String quiz) async {
    if (_newSubjectController.text.trim().isEmpty || userSemester.isEmpty) return;

    final subjectData = {
      'subject': _newSubjectController.text.trim(),
      'date': '',
      'room': '',
      'time': '',
      'examDone': false,
      'createdBy': _auth.currentUser!.uid,
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      await _firestore
          .collection('semesters')
          .doc(userSemester)
          .collection('quizzes')
          .doc(quiz)
          .collection('subjects')
          .add(subjectData);

      _newSubjectController.clear();
      setState(() => showAddSubject = false);
    } catch (e) {
      print('Add subject error: $e');
    }
  }

  Future<void> _updateSubject(String quiz, String docId, String field, dynamic value) async {
    if (docId.startsWith('local_')) return;

    try {
      await _firestore
          .collection('semesters')
          .doc(userSemester)
          .collection('quizzes')
          .doc(quiz)
          .collection('subjects')
          .doc(docId)
          .update({field: value});
    } catch (e) {
      print('Update error: $e');
    }
  }

  Future<void> _removeSubject(String quiz, String docId) async {
    if (docId.startsWith('local_')) {
      setState(() {
        quizData[quiz]!.removeWhere((d) => d['id'] == docId);
        if (_controllers[quiz]!.containsKey(docId)) {
          _controllers[quiz]![docId]!.values.forEach((c) => c.dispose());
          _controllers[quiz]!.remove(docId);
        }
      });
      await _saveToLocal(quiz, quizData[quiz]!);
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this subject?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _firestore
          .collection('semesters')
          .doc(userSemester)
          .collection('quizzes')
          .doc(quiz)
          .collection('subjects')
          .doc(docId)
          .delete();
    } catch (e) {
      print('Delete error: $e');
    }
  }

  Widget _buildSubjectRow(String quiz, Map<String, dynamic> subjectData) {
    final docId = subjectData['id']?.toString() ?? '';
    final isAdmin = userRole == 'admin';

    if (!_controllers[quiz]!.containsKey(docId)) {
      _controllers[quiz]![docId] = {
        'subject': TextEditingController(text: subjectData['subject']?.toString() ?? ''),
        'date': TextEditingController(text: subjectData['date']?.toString() ?? ''),
        'room': TextEditingController(text: subjectData['room']?.toString() ?? ''),
        'time': TextEditingController(text: subjectData['time']?.toString() ?? ''),
      };
    }

    final ctrls = _controllers[quiz]![docId]!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Flexible(
            flex: 6,
            child: TextField(
              controller: ctrls['subject'],
              readOnly: !isAdmin,
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Subject',
                border: const OutlineInputBorder(),
                suffixIcon: Checkbox(
                  value: subjectData['examDone'] ?? false,
                  onChanged: isAdmin
                      ? (val) => _updateSubject(quiz, docId, 'examDone', val ?? false)
                      : null,
                ),
              ),
              onSubmitted: (val) => isAdmin ? _updateSubject(quiz, docId, 'subject', val) : null,
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            flex: 6,
            child: TextField(
              controller: ctrls['date'],
              readOnly: !isAdmin,
              style: const TextStyle(fontSize: 12),
              decoration: const InputDecoration(hintText: 'Date', border: OutlineInputBorder()),
              onSubmitted: (val) => isAdmin ? _updateSubject(quiz, docId, 'date', val) : null,
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            flex: 4,
            child: TextField(
              controller: ctrls['room'],
              readOnly: !isAdmin,
              style: const TextStyle(fontSize: 12),
              decoration: const InputDecoration(hintText: 'Room', border: OutlineInputBorder()),
              onSubmitted: (val) => isAdmin ? _updateSubject(quiz, docId, 'room', val) : null,
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            flex: 4,
            child: TextField(
              controller: ctrls['time'],
              readOnly: !isAdmin,
              style: const TextStyle(fontSize: 12),
              decoration: const InputDecoration(hintText: 'Time', border: OutlineInputBorder()),
              onSubmitted: (val) => isAdmin ? _updateSubject(quiz, docId, 'time', val) : null,
            ),
          ),
          const SizedBox(width: 2),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () => _removeSubject(quiz, docId),
            ),
        ],
      ),
    );
  }

  Widget _buildQuizSection(String quiz) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _loadQuizStream(quiz),
      initialData: quizData[quiz],
      builder: (context, snapshot) {
        final data = snapshot.data ?? quizData[quiz]!;
        _syncControllersWithData(quiz, data);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(quiz, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.length,
              itemBuilder: (_, index) => _buildSubjectRow(quiz, data[index]),
            ),
            if (userRole == 'admin' && showAddSubject && currentQuiz == quiz)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newSubjectController,
                        style: const TextStyle(fontSize: 12),
                        decoration: const InputDecoration(
                          hintText: 'Enter Subject Name',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _addSubject(quiz),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(onPressed: () => _addSubject(quiz), child: const Text('Add')),
                  ],
                ),
              ),
            if (userRole == 'admin')
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentQuiz = quiz;
                    showAddSubject = !showAddSubject;
                  });
                },
                child: Text(showAddSubject && currentQuiz == quiz ? 'Cancel' : 'Add Subject'),
              ),
            const Divider(thickness: 2),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Page', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.purpleAccent.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: quizData.keys.map((quiz) => _buildQuizSection(quiz)).toList(),
        ),
      ),
    );
  }
}