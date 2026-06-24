import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MidPage extends StatefulWidget {
  const MidPage({Key? key}) : super(key: key);

  @override
  State<MidPage> createState() => _MidPageState();
}

class _MidPageState extends State<MidPage> {
  final TextEditingController _newSubjectController = TextEditingController();
  bool showAddSubject = false;

  String userRole = "";
  String userSemester = "";
  bool isLoading = true;

  List<Map<String, dynamic>> localData = [];

  // Controllers per docId
  final Map<String, Map<String, TextEditingController>> _controllers = {};

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    await _getUserRole();
    await _loadLocalData();
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
      print('Fetched role=$userRole semester=$userSemester');
    } catch (e) {
      print('Error fetching user role: $e');
    }
  }

  Future<void> _loadLocalData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? storedList = prefs.getStringList('mid_${userSemester}');
      if (storedList != null) {
        localData = storedList
            .map((e) => Map<String, dynamic>.from(jsonDecode(e)))
            .toList();
      }
    } catch (e) {
      print('Error loading local data: $e');
    }
  }

  Future<void> _saveToLocal(List<Map<String, dynamic>> midData) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> strList = midData.map((e) {
        final copy = Map<String, dynamic>.from(e);
        // Convert Timestamp to string for local storage
        if (copy['createdAt'] is Timestamp) {
          copy['createdAt'] = (copy['createdAt'] as Timestamp).millisecondsSinceEpoch;
        }
        return jsonEncode(copy);
      }).toList();
      await prefs.setStringList('mid_${userSemester}', strList);
      localData = midData;
    } catch (e) {
      print('Error saving to local: $e');
    }
  }

  void _syncControllersWithData(List<Map<String, dynamic>> data) {
    final Set<String> incomingIds = {};
    for (var item in data) {
      String id = (item['id'] ?? '').toString();
      if (id.isEmpty) {
        id = 'local_${data.indexOf(item)}_${DateTime.now().millisecondsSinceEpoch}';
        item['id'] = id;
      }
      incomingIds.add(id);

      if (!_controllers.containsKey(id)) {
        _controllers[id] = {
          'subject': TextEditingController(text: item['subject']?.toString() ?? ''),
          'date': TextEditingController(text: item['date']?.toString() ?? ''),
          'room': TextEditingController(text: item['room']?.toString() ?? ''),
          'time': TextEditingController(text: item['time']?.toString() ?? ''),
        };
      } else {
        final c = _controllers[id]!;
        if ((item['subject'] ?? '') != c['subject']!.text) c['subject']!.text = item['subject']?.toString() ?? '';
        if ((item['date'] ?? '') != c['date']!.text) c['date']!.text = item['date']?.toString() ?? '';
        if ((item['room'] ?? '') != c['room']!.text) c['room']!.text = item['room']?.toString() ?? '';
        if ((item['time'] ?? '') != c['time']!.text) c['time']?.toString() ?? '';
      }
    }

    final toRemove = _controllers.keys.where((k) => !incomingIds.contains(k)).toList();
    for (var k in toRemove) {
      _controllers[k]!.values.forEach((c) => c.dispose());
      _controllers.remove(k);
    }
  }

  Stream<List<Map<String, dynamic>>> _loadMidStream() {
    if (userSemester.isEmpty) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('semesters')
        .doc(userSemester)
        .collection('mid')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      List<Map<String, dynamic>> data = snapshot.docs.map((doc) {
        final map = Map<String, dynamic>.from(doc.data());
        map['id'] = doc.id;
        return map;
      }).toList();
      _saveToLocal(data);
      return data;
    });
  }

  Future<void> _addSubject() async {
    if (_newSubjectController.text.trim().isEmpty) return;
    if (userSemester.isEmpty) return;

    final subjectData = {
      'subject': _newSubjectController.text.trim(),
      'date': '',
      'room': '',
      'time': '',
      'examDone': false,
      'createdBy': FirebaseAuth.instance.currentUser!.uid,
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('semesters')
          .doc(userSemester)
          .collection('mid')
          .add(subjectData);
      _newSubjectController.clear();
      setState(() {
        showAddSubject = false;
      });
    } catch (e) {
      print('Add subject error: $e');
    }
  }

  Future<void> _updateSubject(String docId, String field, dynamic value) async {
    if (docId.startsWith('local_')) return;

    try {
      await FirebaseFirestore.instance
          .collection('semesters')
          .doc(userSemester)
          .collection('mid')
          .doc(docId)
          .update({field: value});
    } catch (e) {
      print('Update error: $e');
    }
  }

  Future<void> _removeSubject(String docId) async {
    if (docId.startsWith('local_')) {
      setState(() {
        localData.removeWhere((d) => d['id'] == docId);
        if (_controllers.containsKey(docId)) {
          _controllers[docId]!.values.forEach((c) => c.dispose());
          _controllers.remove(docId);
        }
      });
      await _saveToLocal(localData);
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
      await FirebaseFirestore.instance
          .collection('semesters')
          .doc(userSemester)
          .collection('mid')
          .doc(docId)
          .delete();
    } catch (e) {
      print('Delete error: $e');
    }
  }

  Widget _buildSubjectRow(Map<String, dynamic> subjectData, bool isAdmin) {
    final docId = subjectData['id']?.toString() ?? '';
    if (!_controllers.containsKey(docId)) {
      _controllers[docId] = {
        'subject': TextEditingController(text: subjectData['subject']?.toString() ?? ''),
        'date': TextEditingController(text: subjectData['date']?.toString() ?? ''),
        'room': TextEditingController(text: subjectData['room']?.toString() ?? ''),
        'time': TextEditingController(text: subjectData['time']?.toString() ?? ''),
      };
    }
    final ctrls = _controllers[docId]!;
    final canEdit = isAdmin;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Flexible(
            flex: 6,
            child: TextField(
              controller: ctrls['subject'],
              readOnly: !canEdit,
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Subject',
                border: const OutlineInputBorder(),
                suffixIcon: Checkbox(
                  value: subjectData['examDone'] ?? false,
                  onChanged: canEdit
                      ? (val) => _updateSubject(docId, 'examDone', val ?? false)
                      : null,
                ),
              ),
              onSubmitted: (val) => canEdit ? _updateSubject(docId, 'subject', val) : null,
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            flex: 6,
            child: TextField(
              controller: ctrls['date'],
              readOnly: !canEdit,
              style: const TextStyle(fontSize: 12),
              decoration: const InputDecoration(hintText: 'Date', border: OutlineInputBorder()),
              onSubmitted: (val) => canEdit ? _updateSubject(docId, 'date', val) : null,
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            flex: 4,
            child: TextField(
              controller: ctrls['room'],
              readOnly: !canEdit,
              style: const TextStyle(fontSize: 12),
              decoration: const InputDecoration(hintText: 'Room', border: OutlineInputBorder()),
              onSubmitted: (val) => canEdit ? _updateSubject(docId, 'room', val) : null,
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            flex: 4,
            child: TextField(
              controller: ctrls['time'],
              readOnly: !canEdit,
              style: const TextStyle(fontSize: 12),
              decoration: const InputDecoration(hintText: 'Time', border: OutlineInputBorder()),
              onSubmitted: (val) => canEdit ? _updateSubject(docId, 'time', val) : null,
            ),
          ),
          const SizedBox(width: 2),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () => _removeSubject(docId),
            ),
        ],
      ),
    );
  }

  Widget _buildMidSection(List<Map<String, dynamic>> midData, bool isAdmin) {
    _syncControllersWithData(midData);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Mid Exams', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: midData.length,
          itemBuilder: (_, index) => _buildSubjectRow(midData[index], isAdmin),
        ),
        if (isAdmin && showAddSubject)
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
                    onSubmitted: (_) => _addSubject(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _addSubject, child: const Text('Add')),
              ],
            ),
          ),
        if (isAdmin)
          ElevatedButton(
            onPressed: () {
              setState(() {
                showAddSubject = !showAddSubject;
              });
            },
            child: Text(showAddSubject ? 'Cancel' : 'Add Subject'),
          ),
        const Divider(thickness: 2),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isAdmin = userRole == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mid Page', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.purpleAccent.shade700,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _loadMidStream(),
        initialData: localData,
        builder: (context, snapshot) {
          final data = snapshot.data ?? localData;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildMidSection(data, isAdmin),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _newSubjectController.dispose();
    _controllers.values.forEach((map) => map.values.forEach((c) => c.dispose()));
    super.dispose();
  }
}
