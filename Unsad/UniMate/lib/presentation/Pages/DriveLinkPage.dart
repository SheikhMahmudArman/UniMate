import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class DriveLinkPage extends StatefulWidget {
  final String semesterId;
  final bool isAdmin;

  const DriveLinkPage({
    super.key,
    required this.semesterId,
    required this.isAdmin,
  });

  @override
  State<DriveLinkPage> createState() => _DriveLinkPageState();
}

class _DriveLinkPageState extends State<DriveLinkPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _semesterController = TextEditingController();

  bool _isLoading = true;
  List<String> _semesters = [];
  Map<String, String> _links = {};

  @override
  void initState() {
    super.initState();
    _loadSemestersAndLinks();
  }

  // Load semesters and cached links
  Future<void> _loadSemestersAndLinks() async {
    setState(() => _isLoading = true);

    try {
      final snapshot = await _firestore.collection('semesters').get();
      _semesters = snapshot.docs.map((e) => e.id).toList();

      for (var sem in _semesters) {
        final doc = await _firestore
            .collection('semesters')
            .doc(sem)
            .collection('links')
            .doc('drive')
            .get();
        if (doc.exists && doc.data()?['url'] != null) {
          _links[sem] = doc['url'];
          await _saveToCache(sem, doc['url']);
        }
      }

      // Load from cache if offline
      final prefs = await SharedPreferences.getInstance();
      for (var sem in _semesters) {
        if (!_links.containsKey(sem)) {
          final cached = prefs.getString('drive_link_$sem');
          if (cached != null) _links[sem] = cached;
        }
      }
    } catch (e) {
      print('Error loading semesters: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveToCache(String semester, String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('drive_link_$semester', url);
  }

  Future<void> _saveLink(String semester, String url) async {
    await _firestore
        .collection('semesters')
        .doc(semester)
        .collection('links')
        .doc('drive')
        .set({'url': url});
    await _saveToCache(semester, url);
    setState(() => _links[semester] = url);
    _linkController.clear();
  }

  Future<void> _deleteLink(String semester) async {
    await _firestore
        .collection('semesters')
        .doc(semester)
        .collection('links')
        .doc('drive')
        .delete();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('drive_link_$semester');
    setState(() => _links.remove(semester));
  }

  Future<void> _addSemester() async {
    if (_semesterController.text.trim().isEmpty) return;
    final newSem = _semesterController.text.trim();
    await _firestore.collection('semesters').doc(newSem).set({});
    setState(() {
      _semesters.add(newSem);
      _semesterController.clear();
    });
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Could not open link')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Drive Links')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ..._semesters.map((sem) {
              final url = _links[sem];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Semester: $sem',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      if (url != null)
                        InkWell(
                          onTap: () => _openLink(url),
                          child: Text(
                            url,
                            style: const TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline),
                          ),
                        )
                      else
                        const Text('No link added yet.'),
                      if (widget.isAdmin) ...[
                        const SizedBox(height: 12),
                        TextField(
                          controller: _linkController,
                          decoration: InputDecoration(
                            labelText: 'Add / Update Link',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: () {
                                if (_linkController.text.trim().isNotEmpty) {
                                  _saveLink(sem, _linkController.text.trim());
                                }
                              },
                            ),
                          ),
                        ),
                        if (url != null)
                          TextButton.icon(
                            onPressed: () => _deleteLink(sem),
                            icon: const Icon(Icons.delete, color: Colors.red),
                            label: const Text(
                              'Delete Link',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 30),

            // Admin: Add Semester section at bottom
            if (widget.isAdmin) ...[
              const Divider(),
              const SizedBox(height: 12),
              TextField(
                controller: _semesterController,
                decoration: InputDecoration(
                  labelText: 'Add New Semester',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addSemester,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _linkController.dispose();
    _semesterController.dispose();
    super.dispose();
  }
}
