import 'package:flutter/material.dart';
import 'package:gobuddy/pages/place_detail.dart';
import 'package:gobuddy/pages/user_trips_details.dart';
import 'package:gobuddy/widgets/userside_usertripedit.dart';
import '../models/travel_model.dart';

class MyTrip extends StatefulWidget {
  const MyTrip({super.key});

  @override
  State<MyTrip> createState() => _MyTripState();
}

class _MyTripState extends State<MyTrip> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        backgroundColor: Color(0xFF134277),
        foregroundColor: Colors.white,
        title:const Text(
          "My Trip",
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
              StreamBuilder<List<Trip>>(
                stream: MyTripService().fetchTrips(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        "It looks like you haven't added any trips yet..",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                      ),
                    );
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
                                  builder: (_) => UserTripsDetails(
                                    trip: trip,  // Pass selected trip to the detail screen
                                  ),
                                ),
                              );
                            },
                            child: UserTripEditWidget(
                              trip: trip,  // Pass the trip to the widget
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
