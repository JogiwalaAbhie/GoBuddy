import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../const.dart';
import 'booked_trip_details.dart';

class UserBookedTripsPage extends StatefulWidget {
  @override
  _UserBookedTripsPageState createState() => _UserBookedTripsPageState();
}

class _UserBookedTripsPageState extends State<UserBookedTripsPage> {
  List<Map<String, dynamic>> groupedBookings = [];
  bool isLoading = true;
  String? userId;


  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  /// Get the currently logged-in user
  Future<void> getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() => userId = user.uid);
      fetchUserBookedTrips(user.uid);
    } else {
      setState(() => isLoading = false);
    }
  }

  /// Fetch booked trips for the current user
  Future<void> fetchUserBookedTrips(String userId) async {
    try {
      List<Map<String, dynamic>> bookingsList = [];

      var userBookingsRef = FirebaseFirestore.instance
          .collection('booked_trip')
          .doc(userId)
          .collection('bookings');

      var bookingsSnapshot = await userBookingsRef.get();

      if (bookingsSnapshot.docs.isEmpty) {
        setState(() => isLoading = false);
        return;
      }

      for (var bookingDoc in bookingsSnapshot.docs) {
        Map<String, dynamic> bookingData = bookingDoc.data();

        // 🛠 Fetch totalFee from bookings collection
        double totalFee = (bookingData["totalFee"] is int)
            ? (bookingData["totalFee"] as int).toDouble()
            : (bookingData["totalFee"] ?? 0).toDouble();

        var tripsSnapshot = await bookingDoc.reference.collection('trips').get();

        List<Map<String, dynamic>> trips = [];

        for (var tripDoc in tripsSnapshot.docs) {
          Map<String, dynamic> tripData = tripDoc.data();

          trips.add({
            "tripId": tripDoc.id,
            "title": tripData["title"] ?? "No Title",
            "destination": tripData["destination"] ?? "Unknown",
            "person": tripData["person"] ?? 1,
          });
        }

        bookingsList.add({
          "bookingId": bookingDoc.id,
          "totalFee": totalFee, // ✅ Assign totalFee
          "trips": trips, // ✅ Store all trips inside a list
        });
      }

      setState(() {
        groupedBookings = bookingsList;
        isLoading = false;
      });

    } catch (e) {
      print("❌ Error fetching booked trips: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text("Your Booked Trips"),
        backgroundColor: Color(0xFF134277),
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black26,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : groupedBookings.isEmpty
          ? Center(
        child: Text(
          "You haven't booked any trips yet!",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
        ),
      )
          : ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: groupedBookings.length,
        itemBuilder: (context, index) {
          var booking = groupedBookings[index];
          var trips = booking["trips"];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              shadowColor: Colors.black26,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Booking ID: ${booking["bookingId"]}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.currency_rupee, color: Color(0xFF134277)),
                            Text(
                              "${booking["totalFee"].toStringAsFixed(2)}", // ✅ Display total fee for all trips
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF134277)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Divider(thickness: 1, height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: trips.map<Widget>((trip) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Icon(Icons.airplanemode_active, color: Color(0xFF134277)),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => BookedTripDetailsPage(tripId: trip["tripId"]), // ✅ Pass tripId correctly
                                          ),
                                        );
                                      },
                                      child: Text(
                                        trip["title"],
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF134277),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on, color: Colors.redAccent, size: 16),
                                        SizedBox(width: 5),
                                        Expanded(
                                          child: Text(
                                            trip["destination"],
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.people, color: Colors.orange, size: 16),
                                        SizedBox(width: 5),
                                        Text(
                                          "${trip["person"]} Person",
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
