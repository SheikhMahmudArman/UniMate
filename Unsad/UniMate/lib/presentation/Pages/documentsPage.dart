import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TheoryPage extends StatefulWidget {
  const TheoryPage({Key? key}) : super(key: key);

  @override
  State<TheoryPage> createState() => _TheoryPageState();
}

class _TheoryPageState extends State<TheoryPage> {
  String userRole = '';
  String userSemester = '';
  bool isLoading = true;

  List<Map<String, dynamic>> theories = [];
  Map<String, List<bool>> localProgress = {}; // topic click progress per theory

  final TextEditingController _theoryController = TextEditingController();
  final Map<int, TextEditingController> _topicControllers = {};

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    await _getUserRole();
    await _loadTheories();
    await _loadLocalProgress();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _getUserRole() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!doc.exists) return;
      final data = doc.data()!;
      userRole = (data['role'] ?? '').toString().toLowerCase();
      userSemester = (data['semester'] ?? '').toString();
    } catch (e) {
      print('Error fetching user role: $e');
    }
  }

  Future<void> _loadTheories() async {
    if (userSemester.isEmpty) return;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('semesters')
          .doc(userSemester)
          .collection('theories')
          .orderBy('createdAt', descending: false)
          .get();

      theories = snapshot.docs.map((doc) {
        final map = Map<String, dynamic>.from(doc.data());
        map['id'] = doc.id;
        map['topics'] ??= [];
        return map;
      }).toList();
    } catch (e) {
      print('Error loading theories: $e');
    }
  }

  Future<void> _loadLocalProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('local_progress_${userSemester}');
    if (stored != null) {
      final decoded = jsonDecode(stored) as Map<String, dynamic>;
      localProgress = decoded.map((key, value) => MapEntry(key, List<bool>.from(value)));
    }

    // Ensure each theory has localProgress
    for (var theory in theories) {
      final id = theory['id'];
      if (id == null) continue;
      final topics = theory['topics'] as List<dynamic>? ?? [];
      if (localProgress[id] == null || localProgress[id]!.length != topics.length) {
        localProgress[id] = List.generate(topics.length, (_) => false);
      }
      for (int i = 0; i < topics.length; i++) {
        topics[i]['done'] = i < localProgress[id]!.length ? localProgress[id]![i] : false;
      }
    }

    setState(() {});
  }

  Future<void> _saveLocalProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('local_progress_${userSemester}', jsonEncode(localProgress));
  }

  Future<void> _addTheory(String name) async {
    if (name.isEmpty || userSemester.isEmpty) return;
    try {
      final docRef = await FirebaseFirestore.instance
          .collection('semesters')
          .doc(userSemester)
          .collection('theories')
          .add({
        'name': name,
        'topics': [],
        'createdAt': FieldValue.serverTimestamp(),
      });
      setState(() {
        theories.add({'id': docRef.id, 'name': name, 'topics': []});
        localProgress[docRef.id] = [];
      });
      _saveLocalProgress();
    } catch (e) {
      print('Error adding theory: $e');
    }
  }

  Future<void> _addTopic(int theoryIndex, String topicName) async {
    if (topicName.isEmpty) return;

    final theory = theories[theoryIndex];
    final id = theory['id'];

    if (userRole == 'admin') {
      try {
        await FirebaseFirestore.instance
            .collection('semesters')
            .doc(userSemester)
            .collection('theories')
            .doc(id)
            .update({
          'topics': FieldValue.arrayUnion([{'name': topicName}])
        });
      } catch (e) {
        print('Error adding topic: $e');
      }
    }

    setState(() {
      theory['topics'].add({'name': topicName});
      localProgress[id] ??= [];
      localProgress[id]!.add(false);
    });
    _topicControllers[theoryIndex]?.clear();
    _saveLocalProgress();
  }

  void _toggleTopic(int theoryIndex, int topicIndex) {
    final theory = theories[theoryIndex];
    final id = theory['id'];
    localProgress[id] ??= List.generate(theory['topics'].length, (_) => false);
    if (topicIndex >= localProgress[id]!.length) return; // safety check
    localProgress[id]![topicIndex] = !localProgress[id]![topicIndex]!;

    setState(() {
      theory['topics'][topicIndex]['done'] = localProgress[id]![topicIndex]!;
    });

    _saveLocalProgress();
  }

  double _calculateProgress(int theoryIndex) {
    final theory = theories[theoryIndex];
    final id = theory['id'];
    final topics = theory['topics'] as List<dynamic>;
    if (topics.isEmpty) return 0;
    localProgress[id] ??= List.generate(topics.length, (_) => false);
    final doneCount = localProgress[id]!.where((v) => v).isNotEmpty ? localProgress[id]!.where((v) => v).length : 0;
    return (doneCount / topics.length) * 100;
  }

  Future<void> _deleteTheory(int theoryIndex) async {
    if (userRole != 'admin') return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this theory?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm != true) return;

    final id = theories[theoryIndex]['id'];
    try {
      await FirebaseFirestore.instance
          .collection('semesters')
          .doc(userSemester)
          .collection('theories')
          .doc(id)
          .delete();
      setState(() {
        theories.removeAt(theoryIndex);
        localProgress.remove(id);
      });
      _saveLocalProgress();
    } catch (e) {
      print('Error deleting theory: $e');
    }
  }

  Future<void> _deleteTopic(int theoryIndex, int topicIndex) async {
    if (userRole != 'admin') return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this topic?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm != true) return;

    final theory = theories[theoryIndex];
    final id = theory['id'];
    final topic = theory['topics'][topicIndex];

    try {
      await FirebaseFirestore.instance
          .collection('semesters')
          .doc(userSemester)
          .collection('theories')
          .doc(id)
          .update({
        'topics': FieldValue.arrayRemove([topic])
      });
      setState(() {
        theory['topics'].removeAt(topicIndex);
        localProgress[id]?.removeAt(topicIndex);
      });
      _saveLocalProgress();
    } catch (e) {
      print('Error deleting topic: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final isAdmin = userRole == 'admin';

    return Scaffold(
      appBar: AppBar(title: const Text('Theories'), backgroundColor: Colors.deepPurple),
      body: ListView.builder(
        itemCount: theories.length,
        itemBuilder: (context, theoryIndex) {
          final theory = theories[theoryIndex];
          _topicControllers[theoryIndex] ??= TextEditingController();
          final topics = theory['topics'] as List<dynamic>;
          final progress = _calculateProgress(theoryIndex);

          return Card(
            margin: const EdgeInsets.all(8),
            child: ExpansionTile(
              title: Text(theory['name'] ?? 'Unnamed Theory',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: progress / 100,
                        backgroundColor: Colors.grey[300],
                        color: Colors.green,
                        minHeight: 6,
                      ),
                      const SizedBox(height: 6),
                      Text('Progress: ${progress.toStringAsFixed(1)}%'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                ...List.generate(topics.length, (topicIndex) {
                  final topic = topics[topicIndex];
                  final doneList = localProgress[theory['id']] ?? List.filled(topics.length, false);
                  final done = topicIndex < doneList.length ? doneList[topicIndex] : false;
                  return ListTile(
                    leading: IconButton(
                      icon: Icon(
                        done ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: done ? Colors.green : Colors.grey,
                      ),
                      onPressed: () => _toggleTopic(theoryIndex, topicIndex),
                    ),
                    title: Text(topic['name'] ?? 'Unnamed Topic'),
                    trailing: isAdmin
                        ? IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteTopic(theoryIndex, topicIndex),
                    )
                        : null,
                  );
                }),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _topicControllers[theoryIndex],
                          decoration: const InputDecoration(labelText: 'Add Topic'),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.deepPurple),
                        onPressed: () => _addTopic(theoryIndex, _topicControllers[theoryIndex]!.text),
                      ),
                    ],
                  ),
                ),
                if (isAdmin)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => _deleteTheory(theoryIndex),
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text('Delete Theory', style: TextStyle(color: Colors.red)),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Add Theory'),
              content: TextField(
                controller: _theoryController,
                decoration: const InputDecoration(hintText: 'Theory name'),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                TextButton(
                  onPressed: () {
                    _addTheory(_theoryController.text);
                    _theoryController.clear();
                    Navigator.pop(context);
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
          );
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      )
          : null,
    );
  }

  @override
  void dispose() {
    _theoryController.dispose();
    _topicControllers.values.forEach((c) => c.dispose());
    super.dispose();
  }
}
