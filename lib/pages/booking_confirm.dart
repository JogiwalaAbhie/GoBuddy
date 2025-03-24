import 'package:flutter/material.dart';
import 'package:gobuddy/pages/navigation_page.dart';
import 'package:gobuddy/pages/travel_home_screen.dart';
import 'package:lottie/lottie.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:gobuddy/Admin/admin_navigation.dart';
import 'package:gobuddy/pages/navigation_page.dart';
import 'package:gobuddy/pages/travel_home_screen.dart';

class BookingConfirmationScreen extends StatelessWidget {
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

  void _navigateBasedOnRole(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TravelHomeScreen()));
      return;
    }

    String role = await _fetchUserRole(user.uid);

    Widget nextScreen = (role == "admin") ? AdminNavigationPage() : NavigationPage();

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => nextScreen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset('assets/animation/success.json', height: 180, repeat: false),
              SizedBox(height: 20),
              Text(
                "🎉 Trip Booked Successfully! 🎉",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                "Your adventure awaits! Thank you for booking with GoBuddy. Have an amazing journey! ✈️🌍",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => _navigateBasedOnRole(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF134277),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text("Back to Home", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class UserTripConfirmationPage extends StatelessWidget {
  final String tripId;

  const UserTripConfirmationPage({Key? key, required this.tripId}) : super(key: key);

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

  void _navigateBasedOnRole(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => NavigationPage()));
      return;
    }

    String role = await _fetchUserRole(user.uid);

    Widget nextScreen = (role == "admin") ? AdminNavigationPage() : NavigationPage();

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => nextScreen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('assets/animation/success.json', height: 180, repeat: false),
              SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Text(
                      "You have successfully joined the trip! 🎉",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.green[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Get ready to explore new places and create unforgettable memories! 🌍✨",
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Stay connected with your fellow travelers and enjoy the adventure! 🏕️🚗",
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _navigateBasedOnRole(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF134277),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text("Back to Home", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
