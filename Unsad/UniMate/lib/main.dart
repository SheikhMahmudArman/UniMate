import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:unimate/domain/wrapper.dart';
import 'package:unimate/firebase_options.dart';
import 'package:unimate/presentation/Pages/AboutPage.dart';
import 'package:unimate/presentation/Pages/FinalPage.dart';

import 'package:unimate/presentation/Pages/MidPage.dart';
import 'package:unimate/presentation/Pages/facultyPage.dart';

import 'package:unimate/presentation/Pages/homePage.dart';
import 'package:unimate/presentation/Pages/markPage.dart';
import 'package:unimate/presentation/Pages/quizPage.dart';
import 'package:unimate/presentation/Pages/settingPage.dart';
import 'package:unimate/presentation/Pages/splashPage.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
        routes: {
          '/settings': (context) => const SettingsPage(),
          '/quiz': (context) => const QuizPage(),
          '/mid': (context) => const MidPage(),
          '/final': (context) => const FinalPage(),
          '/marks': (context) => const MarksPage(),
          '/faculty': (context) => const FacultyPage(),
          '/about': (context) => const AboutPage(),
        }
    );
  }
}











