import 'package:flutter/material.dart';

import '../const.dart';
import '../models/travel_model.dart';
import '../pages/place_detail.dart';
import '../widgets/adminside_usertrips.dart';
import '../widgets/recomendate.dart';
import 'admin_navigation.dart';

class UserTripPage extends StatefulWidget {
  const UserTripPage({super.key});

  @override
  State<UserTripPage> createState() => _UserTripPageState();
}

class _UserTripPageState extends State<UserTripPage> {

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
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text("User Trips",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF134277),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AdminNavigationPage()));
          },
        ),
      ),
      body: SingleChildScrollView( // Wrap everything in a scrollable view
        child: Padding(
          padding: const EdgeInsets.all(10.0),
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
              StreamBuilder<List<Trip>>(
                stream: TripService().fetchTrips(),  // Fetch trips in real-time
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());  // Show loading indicator
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("No trips found."));  // Handle empty data
                  }

                  final recomendate = snapshot.data!;  // Get the trip data

                  return Column(
                    children: List.generate(
                      recomendate.length,
                          (index) {
                        final trip = recomendate[index];  // Get trip at this index
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PlaceDetailScreen(
                                    trip: trip,  // Pass selected trip to the detail screen
                                  ),
                                ),
                              );
                            },
                            child: AdminSideUserTripManage(
                              trip: trip,
                              // Pass the trip to the widget
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              // You can add more widgets here as needed.
            ],
          ),
        ),
      ),
    );
  }
}
