import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'background.dart';
import 'dailyRoutinePage.dart';
import 'detailsPage.dart';
import 'documentsPage.dart';
import 'menuPage.dart';
import 'theoryPage.dart';
import 'driveLinkPage.dart'; // <-- Import your DriveLinkPage



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> theories = [];
  String userSemester = '2.1';
  Map<String, List<bool>> localProgress = {};
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadUserSemester();
    _loadSemesterAndTheories();
    _loadUserRole();
  }

  Future<void> _loadUserSemester() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        setState(() {
          userSemester = doc.data()?['semester'] ?? '2.1';
        });
      }
    } catch (e) {
      print('Error fetching user semester: $e');
    }
  }

  Future<void> _loadUserRole() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        setState(() {
          final role = doc.data()?['role'] ?? 'user';
          isAdmin = role.toString().toLowerCase() == 'admin';
        });
      }
    } catch (e) {
      print('Error fetching user role: $e');
    }
  }

  Future<void> _loadSemesterAndTheories() async {
    final prefs = await SharedPreferences.getInstance();
    userSemester = prefs.getString('userSemester') ?? userSemester;

    String? storedTheories = prefs.getString("theories");
    if (storedTheories != null) {
      theories = List<Map<String, dynamic>>.from(jsonDecode(storedTheories));
    } else {
      theories = [];
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MenuPage()),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          const BackgroundDecoration(),
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TheoryPage()),
                    );
                    await _loadSemesterAndTheories();
                  },
                  child: Center(
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB39DDB),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey,
                          width: 9,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          userSemester,
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Fall-2024",
                  style: TextStyle(
                    fontSize: 22,
                    fontFamily: 'Times New Roman',
                    fontWeight: FontWeight.w600,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 40),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RoutinePage()),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB39DDB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        "Daily Routine",
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 80),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          const Text(
                            "Documents",
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 15),
                          _circleButton(context, Icons.folder, "Theory"),
                          const SizedBox(height: 20),
                          _circleButton(context, Icons.folder, "Lab"),
                        ],
                      ),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DriveLinkPage(
                                    semesterId: userSemester,
                                    isAdmin: isAdmin,
                                  ),
                                ),
                              );
                            },
                            child: const CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.purple,
                              child: Icon(Icons.link, color: Colors.white, size: 28),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Drive Link",
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _circleButton(BuildContext context, IconData icon, String text) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailPage(title: text)),
        );
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.purple,
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
