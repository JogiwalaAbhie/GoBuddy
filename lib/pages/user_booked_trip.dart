import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:workmanager/workmanager.dart';

import '../const.dart';
import '../models/notification_model.dart';
import '../models/work_manager_model.dart';
import 'user_booked_trip_details.dart';

class UserBookedTripsPage extends StatefulWidget {
  @override
  _UserBookedTripsPageState createState() => _UserBookedTripsPageState();
}

class _UserBookedTripsPageState extends State<UserBookedTripsPage> {
  List<Map<String, dynamic>> groupedBookings = [];
  bool isLoading = true;
  String? userId;
  String? tripid;


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

  Future<void> fetchUserBookedTrips(String userId) async {
    try {
      setState(() => isLoading = true); // Start loading

      List<Map<String, dynamic>> bookingsList = [];

      // Fetch only the current user's booked trips
      var bookingsSnapshot = await FirebaseFirestore.instance
          .collection('booked_trip')
          .where('userId', isEqualTo: userId)
          .get();

      if (bookingsSnapshot.docs.isEmpty) {
        setState(() {
          groupedBookings = [];
          isLoading = false;
        });
        return;
      }

      for (var bookingDoc in bookingsSnapshot.docs) {
        Map<String, dynamic> bookingData = bookingDoc.data();

        // Directly fetch trip details from the booking document
        String tripId = bookingData["tripId"];
        String destination = bookingData["destination"] ?? "Unknown";
        String from = bookingData["from"] ?? "Unknown";
        String to = bookingData["to"] ?? "Unknown";
        int adults = bookingData["adults"] ?? 1;
        int children = bookingData["children"] ?? 1;
        int totalPerson = adults + children;
        double totalAmount = bookingData["totalAmount"] ?? 0.0;

        // Initialize bookingDateTimestamp with a default value
        Timestamp bookingDateTimestamp = Timestamp.now();  // Default value

        // Handling the timestamp conversion
        dynamic bookingDate = bookingData["timestamp"];
        if (bookingDate is Timestamp) {
          bookingDateTimestamp = bookingDate;
        } else if (bookingDate is String) {
          try {
            // If the bookingDate is a string, try parsing it as a DateTime
            DateTime parsedDate = DateTime.parse(bookingDate);
            bookingDateTimestamp = Timestamp.fromDate(parsedDate);
          } catch (e) {
            print("❌ Error parsing timestamp string: $e");
          }
        } else if (bookingDate is DateTime) {
          // If the timestamp is already a DateTime object
          bookingDateTimestamp = Timestamp.fromDate(bookingDate);
        }

        // Fetch participants data from the array in the booking document
        List<dynamic> participantsList = bookingData["participants"] ?? [];

        // Map participants data to a list of participant details
        List<Map<String, dynamic>> participants = participantsList.map((participant) {
          return {
            "name": participant["name"] ?? "Unknown",
            "age": participant["age"] ?? 0,
            "phone": participant["phone"] ?? "Unknown",
            "gender": participant["gender"] ?? "Unknown",
          };
        }).toList();

        bookingsList.add({
          "bookingId": bookingDoc.id,
          "tripId": tripId,
          "from": from,
          "to": to,
          "destination": destination,
          "person": totalPerson,
          "adults": adults,
          "children": children,
          "totalAmount": totalAmount,
          "bookingDate": bookingDateTimestamp,
          "participants": participants, // Include participants in the result
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

  String formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return "No Date Available";

    try {
      if (timestamp is Timestamp) {
        DateTime dateTime = timestamp.toDate();
        return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
        // Example: 12 Mar 2025, 10:30 AM
      } else if (timestamp is String) {
        DateTime dateTime = DateTime.parse(timestamp);
        return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
      } else if (timestamp is int) {
        DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
      }
    } catch (e) {
      print("❌ Error formatting date & time: $e");
    }

    return "Invalid Date";
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

          // Fetch the necessary data from the booking
          var tripId = booking["tripId"];
          var destination = booking["destination"];
          var from = booking["from"];
          var to = booking["to"];
          var adults = booking["adults"];
          var children = booking["children"];
          var totalPerson = booking["person"];
          var totalAmount = booking["totalAmount"];
          var bookingDateTimestamp = booking["bookingDate"];
          var participants = booking["participants"];

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
                child: GestureDetector(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookedTripDetailsPage(
                          tripId: tripId,
                        ), // Pass tripId correctly
                      ),
                    );
                  },
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
                                "${totalAmount.toStringAsFixed(2)}", // Display total fee for all trips
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF134277),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Divider(thickness: 1, height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.airplanemode_active, color: Color(0xFF134277)),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        destination,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF134277),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.location_on, color: Colors.redAccent, size: 16),
                                          SizedBox(width: 5),
                                          Expanded(
                                            child: Text(
                                              "$from to $to",
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
                                            "$totalPerson Person ($adults Adults & $children Children)",
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Booking Date: ${formatTimestamp(bookingDateTimestamp)}",
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 10),
                      Divider(thickness: 1, height: 20),
                      SizedBox(height: 10),
                      Text(
                        "Participants:",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 10),
                      Column(
                        children: participants.map<Widget>((participant) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 5.0),
                            child: Row(
                              children: [
                                Icon(Icons.person, color: Colors.blueAccent),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Name: ${participant["name"]}",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        "Age: ${participant["age"]}",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        "Phone: ${participant["phone"]}",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        "Gender: ${participant["gender"]}",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      SizedBox(height: 10),
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
            ),
          );
        },
      ),
    );
  }
}
