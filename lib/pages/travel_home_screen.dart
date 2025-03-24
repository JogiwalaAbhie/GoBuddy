import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gobuddy/models/travel_model.dart';
import 'package:gobuddy/pages/help_and_supprt.dart';
import 'package:gobuddy/pages/my_trip.dart';
import 'package:gobuddy/pages/onboard_travel.dart';
import 'package:gobuddy/pages/place_detail.dart';
import 'package:gobuddy/pages/saved_trip.dart';
import 'package:gobuddy/pages/search_page.dart';
import 'package:gobuddy/pages/setting.dart';
import 'package:gobuddy/pages/user_booked_trip.dart';
import 'package:gobuddy/pages/user_profile.dart';
import 'package:iconsax/iconsax.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../const.dart';
import '../models/internet_service.dart';
import '../models/notification_model.dart';
import '../widgets/popular_place.dart';
import '../widgets/recomendate.dart';
import 'navigation_page.dart'; // add this package first for icon

class TravelHomeScreen extends StatefulWidget {
  const TravelHomeScreen({super.key});

  @override
  State<TravelHomeScreen> createState() => _TravelHomeScreenState();
}

class _TravelHomeScreenState extends State<TravelHomeScreen> {


  @override
  void initState() {
    super.initState();
    checkAndDeleteExpiredTrips();
    _checkInternetBeforeLoading();
    _checkNotificationPermission();
    scheduleBackgroundTask();
  }

  // Check if notification permission is not granted
  Future<void> _checkNotificationPermission() async {
    var status = await Permission.notification.status;

    if (!status.isGranted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showPermissionDialog();
      });
    }
  }

  // Show alert dialog to request permission
  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Enable Notifications",style: TextStyle(fontWeight: FontWeight.w500),),
          content: Text("This app requires notification permissions to send important alerts."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel",style: TextStyle(color: Color(0xFF134277)),),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                await _requestNotificationPermission();
              },
              child: Text("Allow",style: TextStyle(color: Color(0xFF134277)),),
            ),
          ],
        );
      },
    );
  }
  // Request notification permission & navigate to settings if denied
  Future<void> _requestNotificationPermission() async {
    var status = await Permission.notification.request();

    if (status.isDenied || status.isPermanentlyDenied) {
      openAppSettings(); // Navigate to system settings
    }
  }

  void _checkInternetBeforeLoading() async {
    bool isConnected = await hasInternetConnection(context);
    if (!isConnected) return; // Stop further execution if no internet

  }

  void checkAndDeleteExpiredTrips() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    Timestamp now = Timestamp.now();

    QuerySnapshot snapshot = await firestore
        .collection("trips")
        .where("tripRole", isEqualTo: "admin")
        .where("tripDone", isEqualTo: false)
        .get(); // Fetch all trips

    for (var doc in snapshot.docs) {
      String endDateTimeString = doc["endDateTime"]; // Stored as a string
      DateTime? endDateTime = parseTimestamp(endDateTimeString);

      if (endDateTime != null) {
        DateTime deleteTime = endDateTime.add(Duration(hours: 24)); // 24 hours after endDateTime
        if (now.toDate().isAfter(deleteTime)) {
          await firestore.collection("trips").doc(doc.id).delete();
          print("Deleted expired trip with ID: ${doc.id}");
        }
      }
    }
  }

// Function to parse the string timestamp to DateTime
  DateTime? parseTimestamp(String timestamp) {
    try {
      return DateTime.parse(timestamp); // Assuming it's in 'yyyy-MM-dd HH:mm:ss' format
    } catch (e) {
      print("Error parsing timestamp: $e");
      return null;
    }
  }


  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: kBackgroundColor,
      appBar: headerParts(),
      drawer: Drawer(
        backgroundColor: kBackgroundColor,
        elevation: 16,
        child: ListView(
          padding: EdgeInsets.all(0),
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height*0.28,
              child: DrawerHeader(
                decoration: BoxDecoration(
                    color: Color(0xFF134277)
                  ),
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser?.uid)
                      .snapshots(), // Real-time updates from Firestore
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(); // Show loading indicator
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error loading data.'));
                    } else if (!snapshot.hasData || !snapshot.data!.exists) {
                      return Center(child: Text('No user data found.'));
                    }

                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    final username = data['username'] ?? 'No username';
                    final profileImage = data['profilePic'];

                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfilePage()));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                  offset: Offset(4, 4),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(3),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey.shade300,
                              backgroundImage: profileImage != null && profileImage.isNotEmpty
                                  ? NetworkImage(profileImage)
                                  : null,
                              child: profileImage == null || profileImage.isEmpty
                                  ? Icon(Icons.person, size: 50, color: Colors.grey[700])
                                  : null,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
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
                  },
                ),

              ),
            ),
            ListTile(
              leading: Icon(Iconsax.home),
              title: Text("Home"),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationPage()));
              },
            ),
            ListTile(
              leading: Icon(Iconsax.map),
              title: Text("My Trip"),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => MyTrip()));
              },
            ),
            ListTile(
              leading: Icon(Iconsax.bag_tick),
              title: Text("Booked Trip"),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => UserBookedTripsPage()));
              },
            ),
            ListTile(
              leading: Icon(Iconsax.save_2),
              title: Text("Saved"),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => SavedTripPage()));
              },
            ),
            ListTile(
              leading: Icon(Iconsax.setting),
              title: Text("Settings"),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
              },
            ),
            ListTile(
              leading: Icon(Iconsax.support),
              title: Text("Help & Support"),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => HelpSupportPage()));
              },
            ),
            ListTile(
              leading: Icon(Iconsax.information),
              title: Text("About Us"),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => AboutUsPage()));
              },
            ),
            ListTile(
              leading: Icon(Iconsax.logout),
              title: Text("LogOut"),
              onTap: (){
                showDialog(
                    context: context,
                    builder: (BuildContext){
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
                              Navigator.push(context, MaterialPageRoute(builder: (context) => TravelOnBoardingScreen()));
                            },
                            child: Text('Log Out'),
                          ),
                        ],
                      );
                    }
                );
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
                              child: PopularTripWidget(
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
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                //user trips
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: StreamBuilder<List<Trip>>(
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
                                  child: RecomTripWidget(
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
                ),
              ]
          ),
        ),
      ),
    );
  }

  AppBar headerParts() {

    return AppBar(
      elevation: 5,
      backgroundColor: Color(0xFF134277),
      title:const Text(
        "Go Buddy",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 22,
          color: Colors.white,
        ),
      ),
      leading: IconButton(
          onPressed: () {
            scaffoldKey.currentState?.openDrawer();
          },
          icon: Icon(Iconsax.menu_1),
        color: Colors.white,
      ),
      actions: [
        Container(
          height: MediaQuery.of(context).size.height*0.05,
          width: 45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.white60,
            ),
          ),
          padding: const EdgeInsets.all(0),
          child: Stack(
            children: [
              IconButton(
                icon: const Icon(Iconsax.search_normal ,color: Colors.white,), // Cart  icon
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SearchTripPage()),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }
}
