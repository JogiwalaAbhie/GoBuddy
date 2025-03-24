import 'package:flutter/material.dart';
import 'package:gobuddy/pages/place_detail.dart';
import 'package:gobuddy/pages/user_trips_details.dart';

import '../models/travel_model.dart';
import '../widgets/recomendate.dart';
import '../widgets/userside_usertripedit.dart';

import 'package:flutter/material.dart';

class SavedTripPage extends StatefulWidget {
  const SavedTripPage({super.key});

  @override
  State<SavedTripPage> createState() => _SavedTripPageState();
}

class _SavedTripPageState extends State<SavedTripPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        backgroundColor: const Color(0xFF134277),
        foregroundColor: Colors.white,
        title: const Text(
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
          padding: const EdgeInsets.all(14.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              StreamBuilder<List<Trip>>(
                stream: SavedTripService().fetchSavedTrips(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        "It looks like you haven't saved any trips yet..",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                      ),
                    );
                  }

                  final savedTrips = snapshot.data!;

                  return Column(
                    children: List.generate(
                      savedTrips.length,
                          (index) {
                        final trip = savedTrips[index]; // Get trip at this index
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: GestureDetector(
                            onTap: () {
                              if (trip.role == 'admin') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PlaceDetailScreen(trip: trip),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => UserTripsDetails(trip: trip),
                                  ),
                                );
                              }
                            },
                            child: trip.role == 'admin'
                                ? RecomTripWidget(trip: trip) // Show Admin widget
                                : UserTripWidget(trip: trip), // Show User widget
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
