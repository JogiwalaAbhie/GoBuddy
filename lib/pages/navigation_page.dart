import 'package:flutter/material.dart';
import 'package:gobuddy/pages/searchpage.dart';
import 'package:gobuddy/pages/travel_home_screen.dart';
import 'package:gobuddy/pages/user_profile.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
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
    SearchTripPage(),
    AddTripPage(),
    UserProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              GButton(icon: Icons.home, text: 'Home'),
              GButton(icon: Icons.search, text: 'Search'),
              GButton(icon: Icons.add, text: 'Add Trip'),
              GButton(icon: Icons.person, text: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}