import 'package:flutter/material.dart';
import 'screens/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove the debug banner
      title: 'Circle App',
      theme: ThemeData(
        primaryColor: const Color(0xFF567F60), // Primary color
        fontFamily: 'Varela', //will change
      ),
      home: const LoginPage(), // login page as the home screen
    );
  }
}
