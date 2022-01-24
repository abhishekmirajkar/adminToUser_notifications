import 'package:admin_college_project/screens/home_screen.dart';
import 'package:admin_college_project/screens/login_screen.dart';
import 'package:admin_college_project/screens/splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAuth.instance;

  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const MaterialColor kPrimaryColor = const MaterialColor(
      0xFF12469B,
      const <int, Color>{
        50: const Color(0xFF12469B),
        100: const Color(0xFF12469B),
        200: const Color(0xFF12469B),
        300: const Color(0xFF12469B),
        400: const Color(0xFF12469B),
        500: const Color(0xFF12469B),
        600: const Color(0xFF12469B),
        700: const Color(0xFF12469B),
        800: const Color(0xFF12469B),
        900: const Color(0xFF12469B),
      },
    );
    return MaterialApp(
      title: 'Student Connect',
      theme: ThemeData(
        primarySwatch: kPrimaryColor,
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
