import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gobuddy/Admin/admin_navigation.dart';
import 'package:gobuddy/const.dart';
import 'package:gobuddy/pages/place_detail.dart';
import 'package:gobuddy/pages/user_trips_details.dart';
import 'package:gobuddy/widgets/userside_usertripedit.dart';

import '../models/travel_model.dart';
import 'navigation_page.dart';

class UserTripsPage extends StatefulWidget {
  const UserTripsPage({super.key});

  @override
  State<UserTripsPage> createState() => _UserTripsPageState();
}


class _UserTripsPageState extends State<UserTripsPage> {
  TextEditingController _searchController = TextEditingController();
  List<Trip> _allTrips = []; // Store all trips
  List<Trip> _filteredTrips = []; // Store filtered trips
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _fetchTrips(); // Load trips when page opens
  }

  void _fetchTrips() {
    UserTripService().fetchTrips().listen((trips) {
      setState(() {
        _allTrips = trips;
        _filteredTrips = trips; // Initially, show all trips
      });
    });
  }

  void _filterTrips(String query) {
    setState(() {
      _filteredTrips = _allTrips.where((trip) {
        final nameMatch = trip.location.toLowerCase().contains(query.toLowerCase());
        return nameMatch;
      }).toList();
    });
  }

  void _openFilterDialog() {
    TextEditingController dateController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? selectedCategory;
        DateTime? selectedDate;
        int? selectedDays;

        final List<String> tripcat = [
          "Adventure",
          "Beach Vacations",
          "Historical Tours",
          "Road Trips",
          "Volunteer & Humanitarian",
          "Wellness"
        ];

        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Filter Trips",
            style: TextStyle(fontSize: 22,fontWeight: FontWeight.w500),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Category Dropdown
              DropdownButtonFormField<String>(
                dropdownColor: kBackgroundColor,
                decoration: InputDecoration(labelText: "Category",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFBFCFF3), width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF134277), width: 2),
                  ),),
                value: selectedCategory,
                items: tripcat.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedCategory = value;
                },
              ),
              SizedBox(height: 10),

              // Date Picker for Date Selection
              TextFormField(
                controller: dateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Select Date",
                  suffixIcon: Icon(Icons.calendar_today,color: Color(0xFF134277),),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFBFCFF3), width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF134277), width: 2),
                  ),
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(), // Disable past dates
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null) {
                    selectedDate = pickedDate;
                    dateController.text = "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}"; // ✅ Show selected date
                  }
                },
              ),
              SizedBox(height: 10),

              // Days Filter
              TextField(
                decoration: InputDecoration(labelText: "Days",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFBFCFF3), width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF134277), width: 2),
                  ),),
                keyboardType: TextInputType.number,
                onChanged: (value) => selectedDays = int.tryParse(value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel",style: TextStyle(color: Color(0xFF134277),),),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _filteredTrips = _allTrips.where((trip) {
                    final categoryMatch = selectedCategory == null || trip.tripCategory == selectedCategory;

                    // ✅ Corrected Date Comparison
                    final dateMatch = selectedDate == null || (trip.startDate != null &&
                        trip.startDate!.year == selectedDate!.year &&
                        trip.startDate!.month == selectedDate!.month &&
                        trip.startDate!.day == selectedDate!.day);

                    final daysMatch = selectedDays == null || trip.daysOfTrip == selectedDays;
                    return categoryMatch && dateMatch && daysMatch;
                  }).toList();
                });
                Navigator.pop(context);
              },
              child: Text("Apply"),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                shadowColor: Colors.black,
                backgroundColor: const Color(0xFF134277),
                elevation: 10, // Elevation
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Search trips...",
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey)
          ),
          style: TextStyle(color: Colors.white),
          onChanged: _filterTrips,
        )
            : Text("User Trips", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: Color(0xFF134277),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            // Assuming you have a user ID and a 'role' field in your Firestore user document
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              // Fetch the user's role from Firestore (assuming the role is stored in Firestore)
              DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
              String userRole = userDoc['role'];  // Assuming 'role' field stores 'admin' or other roles

              // Navigate based on role
              if (userRole == 'admin') {
                // Navigate to admin screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AdminNavigationPage()),
                );
              } else {
                // Navigate to the regular screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => NavigationPage()),
                );
              }
            }
          },
        ),

        actions: [
          // Search Icon
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _filteredTrips = _allTrips; // Reset list when search is closed
                }
              });
            },
          ),
          // Filter Icon
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _openFilterDialog,
          ),
        ],
      ),
      body: _filteredTrips.isEmpty
          ? Center(child: Text("No matching trips found.", style: TextStyle(fontSize: 18)))
          : ListView.builder(
        padding: EdgeInsets.all(14.0),
        itemCount: _filteredTrips.length,
        itemBuilder: (context, index) {
          final trip = _filteredTrips[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserTripsDetails(trip: trip),
                  ),
                );
              },
              child: UserTripWidget(trip: trip),
            ),
          );
        },
      ),
    );
  }
}


