import 'package:flutter/material.dart';

import '../models/travel_model.dart';
import '../pages/place_detail.dart';
import '../widgets/popular_place.dart';

class AdminTripsPage extends StatefulWidget {

  const AdminTripsPage({super.key});

  @override
  State<AdminTripsPage> createState() => _AdminTripsPageState();
}

class _AdminTripsPageState extends State<AdminTripsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: const Text(
      "Admin Trips",
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: const Color(0xFF134277),
      foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              StreamBuilder<List<Trip>>(
                // Use correct type
                stream: AdminTripService().fetchTrips(),
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

                  return Column(
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
                          child: AdminTripsWidget2(
                            trip: trip, // Pass the trip to the widget
                          ),
                        ),
                      );
                    }).toList(),
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
