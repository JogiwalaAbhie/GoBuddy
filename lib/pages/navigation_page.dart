import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gobuddy/pages/search_page.dart';
import 'package:gobuddy/pages/travel_home_screen.dart';
import 'package:gobuddy/pages/user_profile.dart';
import 'package:gobuddy/pages/user_trips.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:iconsax/iconsax.dart';
import 'addtrippage.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {

  int _selectedIndex = 0;
  final List<Widget> _pages = [
    TravelHomeScreen(),
    UserTripsPage(),
    AddTripPage(),
    UserProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text("Exit App"),
        content: Text("Are you sure you want to exit?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Stay on page
            child: Text("Cancel",style: TextStyle(color: Color(0xFF134277)),),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Exit page
            child: Text("Exit",style: TextStyle(color: Color(0xFF134277)),),
          ),
        ],
      ),
    ) ??
        false; // If the dialog is dismissed, return false
  }



  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevents immediate exit without confirmation
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return; // If already popped, do nothing

        bool shouldExit = await _showExitConfirmationDialog(context);
        if (shouldExit) {
          SystemNavigator.pop(); // Exit the app
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: Container(
          color: Color(0xFF134277),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
            child: GNav(
              backgroundColor: Color(0xFF134277),
              haptic: true,
              tabBorderRadius: 20,
              tabBorder: Border.all(color: Color(0xFF134277), width: 1),
              color: Colors.white,
              activeColor: Colors.white,
              tabBackgroundColor: Color(0xFF4C6D99),
              gap: 10,
              padding: EdgeInsets.all(16),
              selectedIndex: _selectedIndex,
              onTabChange: _onItemTapped,
              tabs: [
                GButton(icon: Iconsax.home, text: 'Home'),
                GButton(icon: Iconsax.map_1, text: 'UserTrip'),
                GButton(icon: Iconsax.add_square, text: 'Add Trip'),
                GButton(icon: Iconsax.profile_circle, text: 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}