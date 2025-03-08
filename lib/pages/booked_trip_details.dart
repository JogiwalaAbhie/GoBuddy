import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gobuddy/pages/help_and_supprt.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class BookedTripDetailsPage extends StatefulWidget {
  final String tripId;

  const BookedTripDetailsPage({Key? key, required this.tripId}) : super(key: key);
  @override
  _BookedTripDetailsPageState createState() => _BookedTripDetailsPageState();
}

class _BookedTripDetailsPageState extends State<BookedTripDetailsPage> {
  String? userId;
  String? bookingId;
  Map<String, dynamic>? tripDetails;
  bool isLoading = true;

  String tripDescription="";
  String daysOfTrip="";
  String startDate="";
  String endDate="";
  String startTime="";
  String endTime="";


  @override
  void initState() {
    super.initState();
    fetchUserId();
    fetchTripDescription();
  }

  /// Fetch the User ID from FirebaseAuth
  void fetchUserId() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
      fetchTripDetails();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Fetch Trip Details using tripId
  Future<void> fetchTripDetails() async {
    if (userId == null || widget.tripId.isEmpty) return;

    try {
      QuerySnapshot bookingsSnapshot = await FirebaseFirestore.instance
          .collection('booked_trip')
          .doc(userId)
          .collection('bookings')
          .get();

      for (var bookingDoc in bookingsSnapshot.docs) {
        DocumentSnapshot tripDoc = await FirebaseFirestore.instance
            .collection('booked_trip')
            .doc(userId)
            .collection('bookings')
            .doc(bookingDoc.id)
            .collection('trips')
            .doc(widget.tripId)
            .get();

        if (tripDoc.exists) {
          setState(() {
            bookingId = bookingDoc.id;
            tripDetails = tripDoc.data() as Map<String, dynamic>;
            isLoading = false;
          });
          return;
        }
      }
      setState(() => isLoading = false);
    } catch (e) {
      print("❌ Error fetching trip details: $e");
      setState(() => isLoading = false);
    }
  }


// Function to format Firestore Timestamp
  String formatTimestamp(dynamic timestamp) {
  if (timestamp == null) return "N/A";

  DateTime date;
  if (timestamp is Timestamp) {
  date = timestamp.toDate(); // Convert Firestore Timestamp to DateTime
  } else if (timestamp is String) {
  date = DateTime.tryParse(timestamp) ?? DateTime.now();
  } else if (timestamp is int) {
  date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  } else {
  return "Invalid Date";
  }

  return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  // Example Output: 07 Mar 2025, 10:30 AM
  }

  void fetchTripDescription() async {
    try {
      DocumentSnapshot tripSnapshot =
      await FirebaseFirestore.instance.collection('trips').doc(widget.tripId).get();

      DateFormat format = DateFormat('dd MMM yyyy');

      if (tripSnapshot.exists) {
        setState(() {
          tripDescription = tripSnapshot["description"];
          daysOfTrip = tripSnapshot["daysOfTrip"]?.toString() ?? "N/A";
          startDate = format.format(DateTime.parse(tripSnapshot["startDate"]));
          endDate = format.format(DateTime.parse(tripSnapshot["endDate"]));
          startTime = tripSnapshot["startTime"];
          endTime = tripSnapshot["endTime"];
        });
      }
    } catch (e) {
      setState(() {
        tripDescription = "Error loading description";
      });
      print("Error fetching trip description: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Booked Trip Details"),
        backgroundColor: Color(0xFF134277),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : tripDetails == null
          ? Center(
        child: Text(
          "Trip details not found!",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      )
          : Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[300],
                      image: tripDetails!["firstImage"] != null &&
                          tripDetails!["firstImage"].toString().isNotEmpty
                          ? DecorationImage(
                        image: NetworkImage(
                          tripDetails!["firstImage"] is List
                              ? (tripDetails!["firstImage"] as List).first
                              : tripDetails!["firstImage"],
                        ),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: (tripDetails!["firstImage"] == null ||
                        tripDetails!["firstImage"].toString().isEmpty)
                        ? Text("No photos available", style: TextStyle(color: Colors.black54))
                        : null,
                  ),
                  SizedBox(height: 20),
                  Text(tripDetails!["title"] ?? "No Title",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.red),
                      SizedBox(width: 5),
                      Text(tripDetails!["destination"] ?? "Unknown", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.money, color: Colors.green),
                      SizedBox(width: 5),
                      Text("Total Fee: ₹${tripDetails!["totalPrice"] ?? 0}",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.people, color: Colors.blue),
                      SizedBox(width: 5),
                      Text("Persons: ${tripDetails!["person"] ?? 1}", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text("Trip Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  SizedBox(height: 5),
                  Text(tripDescription, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                  SizedBox(height: 5),
                  Divider(),
                  Row(
                    children: [
                      Icon(Icons.confirmation_number, color: Colors.deepOrange),
                      SizedBox(width: 5),
                      Text("Trip Days : $daysOfTrip", style: TextStyle(color: Colors.black)),
                    ],
                  ),
                  SizedBox(height: 5),
                  Text("Trip Start : $startDate at $startTime", style: TextStyle(color: Colors.black)),
                  SizedBox(height: 5),
                  Text("Trip End : $endDate at $endTime", style: TextStyle(color: Colors.black)),
                  SizedBox(height: 5),
                  Divider(),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.date_range, color: Colors.purple),
                      SizedBox(width: 5),
                      Text(
                        "Booking Date: ${formatTimestamp(tripDetails!["timestamp"])}",
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Buttons Section at the Bottom
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: helpSupportButton(context),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: cancelTripButton(context),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: googleMapsButton(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget cancelTripButton(BuildContext context) {
    return Container(
      height: 60,
      child: ElevatedButton.icon(
        onPressed: () => confirmCancellation(context),
        icon: Icon(Icons.cancel, color: Colors.red),
        label: Text("Cancel Trip", style: TextStyle(fontSize:16,color: Colors.red)),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, elevation: 2),
      ),
    );
  }

  Widget helpSupportButton(BuildContext context) {
    return Container(
      height: 60,
      child: ElevatedButton.icon(
        onPressed: () {
          // Navigate to Help & Support Page
          Navigator.push(context, MaterialPageRoute(builder: (context) => HelpSupportPage()));
        },
        icon: Icon(Icons.help_outline, color: Color(0xFF134277)),
        label: Text("Help & Support", style: TextStyle(fontSize:16,color: Color(0xFF134277))),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, elevation: 2),
      ),
    );
  }

  Widget googleMapsButton(BuildContext context) {
    return Container(
      height: 60,
      child: ElevatedButton.icon(
        onPressed: () {
          openGoogleMaps(tripDetails?["destination"]);
        },
        icon: Icon(Icons.map, color: Colors.white),
        label: Text("View in Google Map", style: TextStyle(fontSize:16,color: Colors.white)),
        style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF134277), elevation: 2),
      ),
    );
  }

  void confirmCancellation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Cancel Trip?"),
        content: Text("Are you sure you want to cancel this trip? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("No"),
          ),
          TextButton(
            onPressed: () async {
              if (userId!.isNotEmpty && bookingId!.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('booked_trip')
                    .doc(userId)
                    .collection('bookings')
                    .doc(bookingId)
                    .delete();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Trip cancelled successfully!")),
                );
              }
            },
            child: Text("Yes, Cancel", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void openGoogleMaps(String? destination) async {
    if (destination != null && destination.isNotEmpty) {
      final url = "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(destination)}";
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        print("Could not open Google Maps");
      }
    }
  }
}
