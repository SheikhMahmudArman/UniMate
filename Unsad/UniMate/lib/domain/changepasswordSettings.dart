import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showNewPasswordFields = false;
  bool _oldPasswordVerified = false;
  bool _isSuperAdmin = false;
  bool _loading = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _checkSuperAdmin();
  }

  Future<void> _checkSuperAdmin() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() {
        _isSuperAdmin = false;
        _loading = false;
      });
      return;
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final role = doc.data()?['role'] ?? '';
      setState(() {
        _isSuperAdmin = role == 'super_admin';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _isSuperAdmin = false;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _verifyOldPassword() async {
    try {
      final credential = EmailAuthProvider.credential(
        email: _emailController.text.trim(),
        password: _oldPasswordController.text,
      );

      // temporarily sign in the target user to verify old password
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _oldPasswordController.text,
      );

      setState(() {
        _oldPasswordVerified = true;
        _showNewPasswordFields = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Old password verified ✅')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification failed: $e')),
      );
    }
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = _auth.currentUser;
        if (user != null) {
          await user.updatePassword(_newPasswordController.text);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password changed successfully 🎉')),
          );

          setState(() {
            _oldPasswordVerified = false;
            _showNewPasswordFields = false;
            _emailController.clear();
            _oldPasswordController.clear();
            _newPasswordController.clear();
            _confirmPasswordController.clear();
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_isSuperAdmin) {
      return const Center(
        child: Text(
          'Access Denied\nOnly Super Admin can change passwords',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.red),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'Change User Password (Admin Only)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'User Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter user email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _oldPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Old Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter old password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _verifyOldPassword,
                  child: const Text('Verify Old Password'),
                ),
                if (_showNewPasswordFields && _oldPasswordVerified) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _newPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'New Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter new password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Confirm New Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Confirm new password';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _changePassword,
                    child: const Text('Change Password'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
