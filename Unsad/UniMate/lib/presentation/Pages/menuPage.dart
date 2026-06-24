import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unimate/domain/wrapper.dart';
import 'package:unimate/presentation/Pages/homePage.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  bool _isDatesExpanded = false;

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Rapper()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD1C4E9), // Light purple
      appBar: AppBar(
        title: const Text('Menu'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(Icons.settings, color: Colors.black),
                    title: const Text('Settings'),
                    onTap: () {
                      Navigator.pushNamed(context, '/settings');
                    },
                  ),
                  ExpansionTile(
                    title: const Text('Dates'),
                    leading: const Icon(Icons.calendar_today, color: Colors.black),
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16.0),
                    childrenPadding: const EdgeInsets.only(left: 32.0),
                    onExpansionChanged: (bool expanded) {
                      setState(() {
                        _isDatesExpanded = expanded;
                      });
                    },
                    children: [
                      ListTile(
                        title: const Text('Quiz'),
                        onTap: () {
                          Navigator.pushNamed(context, '/quiz');
                        },
                      ),
                      ListTile(
                        title: const Text('Mid'),
                        onTap: () {
                          Navigator.pushNamed(context, '/mid');
                        },
                      ),
                      ListTile(
                        title: const Text('Final'),
                        onTap: () {
                          Navigator.pushNamed(context, '/final');
                        },
                      ),
                    ],
                  ),
                  ListTile(
                    leading: const Icon(Icons.grade, color: Colors.black),
                    title: const Text('Marks'),
                    onTap: () {
                      Navigator.pushNamed(context, '/marks');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person, color: Colors.black),
                    title: const Text('Faculty'),
                    onTap: () {
                      Navigator.pushNamed(context, '/faculty');
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.info, color: Colors.black),
                    title: const Text('About'),
                    onTap: () {
                      Navigator.pushNamed(context, '/about');
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.black),
                    title: const Text('Logout'),
                    onTap: _confirmLogout, // call confirmation dialog
                  ),
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
