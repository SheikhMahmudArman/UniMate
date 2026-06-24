import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unimate/presentation/Pages/homePage.dart';
import 'package:unimate/presentation/Pages/loginPage.dart';



class Rapper extends StatefulWidget {
  const Rapper({super.key});

  @override
  State<Rapper> createState() => _RapperState();
}

class _RapperState extends State<Rapper> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData) {
              return HomePage();
            } else {
              return LoginPage();
            }
          }
      ),
    );
  }
}
