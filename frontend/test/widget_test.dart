import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:autoshare/Login&Signup/login_page.dart';
import 'package:autoshare/Customer/customer_home_page.dart';
import 'package:autoshare/Driver/driver_home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoShare',
      theme: ThemeData(
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(), // Start with splash
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    // Simulate loading time (e.g., logo animation)
    await Future.delayed(const Duration(seconds: 3));

    // Load login state from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String? userType = prefs.getString('userType');

    if (isLoggedIn) {
      if (userType == "customer") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CustomerHomePage()),
        );
      } else if (userType == "driver") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DriverHomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white, // Background color
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.local_taxi, size: 80, color: Colors.green),
              SizedBox(height: 20),
              Text(
                "Autorickshaw App",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 40),
              CircularProgressIndicator(), // Loading spinner
            ],
          ),
        ),
      ),
    );
  }
}
