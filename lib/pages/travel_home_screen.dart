import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gobuddy/models/travel_model.dart';
import 'package:gobuddy/pages/addtrippage.dart';
import 'package:gobuddy/pages/help_and_supprt.dart';
import 'package:gobuddy/pages/onboard_travel.dart';
import 'package:gobuddy/pages/place_detail.dart';
import 'package:gobuddy/pages/searchpage.dart';
import 'package:gobuddy/pages/setting.dart';
import 'package:gobuddy/pages/user_profile.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:iconsax/iconsax.dart';
import '../const.dart';
import '../models/travel_model.dart';
import '../screen/login.dart';
import '../widgets/popular_place.dart';
import '../widgets/recomendate.dart';
import 'navigation_page.dart'; // add this package first for icon

class TravelHomeScreen extends StatefulWidget {
  const TravelHomeScreen({super.key});

  @override
  State<TravelHomeScreen> createState() => _TravelHomeScreenState();
}

class _TravelHomeScreenState extends State<TravelHomeScreen> {

  // for popular ites(filter the popular items only from model)
  // this means only display those data whose category is popular
  List<TravelDestination> popular =
  myDestination.where((element) => element.category == "popular").toList();
  // this means only display those data whose category is recomend
  List<TravelDestination> recomendate =
  myDestination.where((element) => element.category == "recomend").toList();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  Future<List<Trip>> trips = Future.value([]);

  @override
  void initState() {
    super.initState();
    trips = _fetchTrips();
  }

  Future<List<Trip>> _fetchTrips() async {
    return await TripService().fetchTrips();
  }


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
              height: MediaQuery.of(context).size.height*0.25,
              child: DrawerHeader(
                decoration: BoxDecoration(
                    color: Color(0xFF134277)
                  ),
                child: FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(); // Loading indicator while fetching data.
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error loading data.'));
                    } else if (snapshot.hasData && !snapshot.data!.exists) {
                      return Center(child: Text('No user data found.'));
                    } else if (snapshot.hasData) {
                      final data = snapshot.data!.data() as Map<String, dynamic>;
                      final username = data['username'] ?? 'No username';
                      final profileImageBase64 = data['profilePic'];

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
                                    color: Colors.black.withOpacity(0.3), // Shadow color
                                    blurRadius: 10, // How soft the shadow looks
                                    spreadRadius: 2, // Size of shadow
                                    offset: Offset(4, 4), // Shadow position (X, Y)
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.all(3),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey.shade300,
                                backgroundImage: profileImageBase64 != null && profileImageBase64!.isNotEmpty
                                    ? NetworkImage(profileImageBase64!)
                                    : null,
                                child: profileImageBase64 == null || profileImageBase64!.isEmpty
                                    ? Icon(Icons.person, size: 50, color: Colors.grey[700])
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            username,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
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
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationPage()));
              },
            ),
            ListTile(
              leading: Icon(Iconsax.map),
              title: Text("My Trip"),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => TravelHomeScreen()));
              },
            ),
            ListTile(
              leading: Icon(Iconsax.save_2),
              title: Text("Saved"),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => TravelHomeScreen()));
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
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // const SizedBox(height: 20),
                // const Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 15),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Text(
                //         "Popular place",
                //         style: TextStyle(
                //           fontSize: 20,
                //           fontWeight: FontWeight.w600,
                //           color: Colors.black,
                //         ),
                //       ),
                //       Text(
                //         "See all",
                //         style: TextStyle(
                //           fontSize: 14,
                //           color: blueTextColor,
                //         ),
                //       )
                //     ],
                //   ),
                // ),
                // const SizedBox(height: 15),
                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   padding: const EdgeInsets.only(bottom: 20),
                //   child: Row(
                    // children: List.generate(
                    //   popular.length,
                    //       (index) => Padding(
                    //         padding: const EdgeInsets.all(8.0),
                    //         child: GestureDetector(
                    //           onTap: () {
                    //             Navigator.push(
                    //               context,
                    //               MaterialPageRoute(
                    //                 builder: (_) => PlaceDetailScreen(
                    //                   trip: popular[index],
                    //                 ),
                    //               ),
                    //             );
                    //           },
                    //           child: PopularPlace(
                    //             destination: popular[index],
                    //           ),
                    //         ),
                    //       ),
                    // ),
                //   ),
                // ),
                // const Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 15),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Text(
                //         "Recomendation for you",
                //         style: TextStyle(
                //           fontSize: 20,
                //           fontWeight: FontWeight.w600,
                //           color: Colors.black,
                //         ),
                //       ),
                //       Text(
                //         "See all",
                //         style: TextStyle(
                //           fontSize: 14,
                //           color: blueTextColor,
                //         ),
                //       )
                //     ],
                //   ),
                // ),
                // const SizedBox(height: 20),
                FutureBuilder<List<Trip>>(
                  future: trips,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text("No trips found."));
                    }

                    final recomendate  = snapshot.data!;

                    return Expanded(
                      child: recomendate.isNotEmpty
                          ? Column(
                        children: List.generate(
                          recomendate.length,
                              (index) {
                            final trip = recomendate[index]; // Get the trip at this index
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PlaceDetailScreen(
                                        trip: trip, // Pass the selected Trip object
                                      ),
                                    ),
                                  );
                                },
                                child: TripWidget(
                                  destination: trip, // Pass the Trip object to TripWidget
                                ),
                              ),
                            );
                          },
                        ),
                      )
                          : Center(child: CircularProgressIndicator()), // Show a loading indicator if data is null or empty
                    );
                  },
                ),
              ],
            ),
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
          icon: Icon(Icons.menu),
        color: Colors.white,
      ),
      actions: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.white60,
            ),
          ),
          padding: const EdgeInsets.all(7),
          child: const Stack(
            children: [
              Icon(
                Iconsax.notification,
                color: Colors.white,
                size: 25,
              ),
            ],
          ),
        ),
        const SizedBox(width: 15),
      ],
    );
  }
}


// class TripDetailsPage extends StatefulWidget {
//   final Trip trip;
//
//   const TripDetailsPage({Key? key, required this.trip}) : super(key: key);
//
//   @override
//   _TripDetailsPageState createState() => _TripDetailsPageState();
// }
//
// class _TripDetailsPageState extends State<TripDetailsPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.trip.name)),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Destination: ${widget.trip.location}', style: const TextStyle(fontSize: 18)),
//             const SizedBox(height: 8),
//             Text('Trip Fee: ₹${widget.trip.price}'),
//             const SizedBox(height: 8),
//             Text('Description: ${widget.trip.des}'),
//             const SizedBox(height: 8),
//             Text('Meeting Point: ${widget.trip.meetingPoint}'),
//             const SizedBox(height: 16),
//             const Text('Photos:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             widget.trip.image.isNotEmpty
//                 ? SizedBox(
//               height: 150,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: widget.trip.image.length,
//                 itemBuilder: (context, index) {
//                   return Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Image.network(widget.trip.image[index],
//                         width: 150, height: 100, fit: BoxFit.cover),
//                   );
//                 },
//               ),
//             )
//                 : const Text('No photos available'),
//           ],
//         ),
//       ),
//     );
//   }
// }