import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gobuddy/Admin/admin_navigation.dart';
import 'package:gobuddy/Admin/admin_profile.dart';
import 'package:gobuddy/Admin/admin_trips.dart';
import 'package:gobuddy/Admin/user_trip_reports.dart';
import 'package:gobuddy/Admin/user_trips.dart';
import 'package:iconsax/iconsax.dart';

import '../const.dart';
import '../models/travel_model.dart';
import '../pages/onboard_travel.dart';
import '../pages/place_detail.dart';
import '../pages/setting.dart';
import '../widgets/adminside_populartrip.dart';
import '../widgets/adminside_recomtrip.dart';
import '../widgets/popular_place.dart';
import '../widgets/recomendate.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {

  List<Trip> trips = [];

  @override
  void initState() {
    super.initState();
    fetchTrips(); // Load trips when the page opens
  }


  Future<void> fetchTrips() async {
    Stream<List<Trip>> fetchedTrips = TripService().fetchTrips(); // Fetch trips stream

    fetchedTrips.listen((tripList) {
      setState(() {
        trips = tripList; // Update the UI when new data arrives
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "GoBuddy Admin",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF134277),
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        backgroundColor: kBackgroundColor,
        elevation: 16,
        child: ListView(
          padding: EdgeInsets.all(0),
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * 0.28,
              child: DrawerHeader(
                decoration: BoxDecoration(color: Color(0xFF134277)),
                child: FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser?.uid)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(); // Loading indicator while fetching data.
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error loading data.'));
                    } else if (snapshot.hasData && !snapshot.data!.exists) {
                      return Center(child: Text('No user data found.'));
                    } else if (snapshot.hasData) {
                      final data =
                          snapshot.data!.data() as Map<String, dynamic>;
                      final username = data['username'] ?? 'No username';
                      final profileImageBase64 = data['profilePic'];

                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          AdminProfilePage()));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(0.3), // Shadow color
                                    blurRadius: 10, // How soft the shadow looks
                                    spreadRadius: 2, // Size of shadow
                                    offset:
                                        Offset(4, 4), // Shadow position (X, Y)
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.all(3),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey.shade300,
                                backgroundImage: profileImageBase64 != null &&
                                        profileImageBase64!.isNotEmpty
                                    ? NetworkImage(profileImageBase64!)
                                    : null,
                                child: profileImageBase64 == null ||
                                        profileImageBase64!.isEmpty
                                    ? Icon(Icons.person,
                                        size: 50, color: Colors.grey[700])
                                    : null,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            username,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: kBackgroundColor,
                            ),
                          ),
                        ],
                      );
                    }
                    return Center(child: Text('No data found.'));
                  },
                ),
              ),
            ),
            ListTile(
              leading: Icon(Iconsax.home),
              title: Text("Home"),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AdminNavigationPage()));
              },
            ),
            ListTile(
              leading: Icon(Iconsax.map),
              title: Text("Admin Trips"),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AdminTripsPage()));
              },
            ),
            ListTile(
              leading: Icon(Iconsax.map),
              title: Text("Users Trips"),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UserTripPage()));
              },
            ),
            ListTile(
              leading: Icon(Iconsax.receipt_item),
              title: Text("Users Reports"),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UserTripReportsPage()));
              },
            ),
            ListTile(
              leading: Icon(Iconsax.information),
              title: Text("About Us"),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AboutUsPage()));
              },
            ),
            ListTile(
              leading: Icon(Iconsax.logout),
              title: Text("LogOut"),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext) {
                      return AlertDialog(
                        backgroundColor: kBackgroundColor,
                        title: Text('Confirm Logout'),
                        content: Text('Are you sure you want to Log Out ?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          TravelOnBoardingScreen()));
                            },
                            child: Text('Log Out'),
                          ),
                        ],
                      );
                    });
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        // Wrap everything in a scrollable view
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Popular place",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "See all",
                      style: TextStyle(
                        fontSize: 14,
                        color: blueTextColor,
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 12),
              //admin trips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: StreamBuilder<List<Trip>>(
                  // Use correct type
                  stream: PopularTripService().fetchPopularTrips(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child:
                              CircularProgressIndicator()); // Show loading indicator
                    }

                    if (snapshot.hasError) {
                      return Center(
                          child:
                              Text("Error: ${snapshot.error}")); // Handle error
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text("No trips found.")); // Handle empty data
                    }

                    final adminTrips = snapshot.data!; // Get trip list

                    return Row(
                      children: adminTrips.map((trip) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PlaceDetailScreen(
                                    trip: trip, // Pass selected trip to the detail screen
                                  ),
                                ),
                              );
                            },
                            child: AdminSidePopularTripManage(
                              trip: trip, // Pass the trip to the widget
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              const SizedBox(height: 5),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Recommendation for you",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "See all",
                      style: TextStyle(
                        fontSize: 14,
                        color: blueTextColor,
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 12),
              //user trips
              StreamBuilder<List<Trip>>(
                stream: RecommendationTripService().fetchRecommendationTrips(), // Fetch trips in real-time
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator()); // Show loading indicator
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text("Error loading trips: ${snapshot.error}"));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("No trips found.")); // Handle empty data
                  }

                  final trips = snapshot.data!; // Get the trip data

                  return SingleChildScrollView(  // Fix overflow issue
                    child: Column(
                      children: List.generate(
                        trips.length,
                            (index) {
                          final trip = trips[index]; // Get trip at this index
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PlaceDetailScreen(trip: trip),
                                  ),
                                );
                              },
                              child: AdminSideRecomTripManage(
                                trip: trip,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },

              ),
            ]
          ),
        ),
      ),
    );
  }
}
