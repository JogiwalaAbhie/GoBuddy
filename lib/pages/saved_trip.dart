import 'package:flutter/material.dart';
import 'package:gobuddy/pages/place_detail.dart';

import '../models/travel_model.dart';
import '../widgets/recomendate.dart';

class savedTripPage extends StatefulWidget {
  const savedTripPage({super.key});

  @override
  State<savedTripPage> createState() => _savedTripPageState();
}

class _savedTripPageState extends State<savedTripPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        backgroundColor: Color(0xFF134277),
        foregroundColor: Colors.white,
        title:const Text(
          "Saved Trip",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
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
                stream: SavedTripService().fetchSavedTrips(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("It looks like you haven't Saved any trips yet.."));
                  }

                  final recomendate  = snapshot.data!;

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
                            child: TripWidget(
                              destination: trip,  // Pass the trip to the widget
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
