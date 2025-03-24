import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gobuddy/Admin/admin_navigation.dart';
import 'package:gobuddy/pages/navigation_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:gobuddy/const.dart';
import 'package:gobuddy/pages/onboard_travel.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(Duration(seconds: 3)); // Show splash for 3 seconds

    User? user = FirebaseAuth.instance.currentUser;
    Widget nextScreen;

    if (user == null) {
      nextScreen = TravelOnBoardingScreen(); // Guest user
    } else {
      String role = await _fetchUserRole(user.uid);
      nextScreen = (role == "admin") ? AdminNavigationPage() : NavigationPage();
    }

    if (!mounted) return; // Prevents navigation errors if widget is disposed

    // Navigate to next screen and remove splash from stack
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextScreen),
    );
  }

  Future<String> _fetchUserRole(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .get();
      return userDoc.get("role") ?? "user"; // Default to "user"
    } catch (e) {
      debugPrint("Error fetching user role: $e");
      return "user"; // Fallback role
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Center(
        child: Lottie.asset("assets/animation/splash.json"), // Lottie animation
      ),
    );
  }
}
