import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gobuddy/Admin/admin_navigation.dart';
import 'package:gobuddy/pages/help_and_supprt.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminBookedTripDetailsPage extends StatefulWidget {
  final String tripId;

  const AdminBookedTripDetailsPage({Key? key, required this.tripId}) : super(key: key);
  @override
  _AdminBookedTripDetailsPageState createState() => _AdminBookedTripDetailsPageState();
}

class _AdminBookedTripDetailsPageState extends State<AdminBookedTripDetailsPage> {
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
  String tripid="";


  @override
  void initState() {
    super.initState();
    fetchBookedTripDetails();
    fetchTripDetails(widget.tripId); // Call function with tripId
  }



  String formatTimestamp(DateTime timestamp) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(timestamp);
  }

  Future<void> fetchBookedTripDetails() async {
    try {
      QuerySnapshot bookingsSnapshot = await FirebaseFirestore.instance
          .collection('booked_trip')
          .get();

      for (var bookingDoc in bookingsSnapshot.docs) {
        Map<String, dynamic> bookingData = bookingDoc.data() as Map<String, dynamic>;

        List<dynamic> trips = bookingData["trips"] ?? []; // Fetch trips array

        for (var trip in trips) {
          if (trip["tripId"] == widget.tripId) {
            setState(() {
              bookingId = bookingDoc.id;
              tripDetails = trip;
              isLoading = false;
              tripDetails!["bookingDate"] = bookingData["bookingDate"];
            });
            return;
          }
        }
      }

      setState(() => isLoading = false);
    } catch (e) {
      print("❌ Error fetching trip details: $e");
      setState(() => isLoading = false);
    }
  }

  void fetchTripDetails(String tripId) async {
    print("📌 Fetching details for tripId: $tripId"); // Debugging

    try {
      DocumentSnapshot tripSnapshot =
      await FirebaseFirestore.instance.collection('trips').doc(widget.tripId).get();

      if (!tripSnapshot.exists) {
        print("❌ No trip found for tripId: $tripId");
        setState(() {
          tripDescription = "Trip details not found";
          isLoading = false;
        });
        return;
      }

      DateFormat format = DateFormat('dd MMM yyyy');

      // ✅ Handle Firestore timestamp conversion
      DateTime? parsedStartDate = tripSnapshot["startDate"] is Timestamp
          ? (tripSnapshot["startDate"] as Timestamp).toDate()
          : DateTime.tryParse(tripSnapshot["startDate"] ?? "");

      DateTime? parsedEndDate = tripSnapshot["endDate"] is Timestamp
          ? (tripSnapshot["endDate"] as Timestamp).toDate()
          : DateTime.tryParse(tripSnapshot["endDate"] ?? "");

      setState(() {
        tripDescription = tripSnapshot["description"] ?? "No Description Available";
        daysOfTrip = tripSnapshot["daysOfTrip"]?.toString() ?? "N/A";
        startDate = parsedStartDate != null ? format.format(parsedStartDate) : "Unknown";
        endDate = parsedEndDate != null ? format.format(parsedEndDate) : "Unknown";
        startTime = tripSnapshot["startTime"] ?? "N/A";
        endTime = tripSnapshot["endTime"] ?? "N/A";
        tripid = tripSnapshot["tripId"];
      });

      print("✅ Trip details loaded successfully for tripId: $tripId");

    } catch (e) {
      setState(() {
        tripDescription = "Error loading Data";
        isLoading = false;
      });
      print("❌ Error fetching trip details: $e");
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
          ? Center(child: CircularProgressIndicator()) // Show loader while fetching data
          : tripDetails == null
          ? Center(
        child: Text(
          "Trip details not found!",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
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
                              ? (tripDetails!["firstImage"] as List).isNotEmpty
                              ? (tripDetails!["firstImage"] as List).first
                              : ""
                              : tripDetails!["firstImage"].toString(),
                        ),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: tripDetails!["firstImage"] == null ||
                        tripDetails!["firstImage"].toString().isEmpty
                        ? Text("No photos available",
                        style: TextStyle(color: Colors.black54, fontSize: 16))
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
                      Text(tripDetails!["destination"] ?? "Unknown",
                          style: TextStyle(fontSize: 16)),
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
                      Text("Persons: ${tripDetails!["person"] ?? 1}",
                          style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text("Trip Description",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  SizedBox(height: 5),
                  Text(tripDescription,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                  SizedBox(height: 5),
                  Divider(),
                  Row(
                    children: [
                      Icon(Icons.confirmation_number, color: Colors.deepOrange),
                      SizedBox(width: 5),
                      Text("Trip Days: $daysOfTrip",
                          style: TextStyle(color: Colors.black)),
                    ],
                  ),
                  SizedBox(height: 5),
                  Text("Trip Start: $startDate at $startTime",
                      style: TextStyle(color: Colors.black)),
                  SizedBox(height: 5),
                  Text("Trip End: $endDate at $endTime",
                      style: TextStyle(color: Colors.black)),
                  SizedBox(height: 5),
                  Divider(),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.date_range, color: Colors.purple),
                      SizedBox(width: 5),
                      Text(
                        "Booking Date: ${tripDetails!["bookingDate"] != null ? formatTimestamp(tripDetails!["bookingDate"].toDate()) : "N/A"}",
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: helpSupportButton(context)),
                    SizedBox(width: 10),
                    Expanded(child: cancelTripButton(context, bookingId!),),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: googleMapsButton(context)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget cancelTripButton(BuildContext context, String bookingId) {
    return Container(
      height: 60,
      child: ElevatedButton.icon(
        onPressed: () => showCancelOptions(context, bookingId),
        icon: Icon(Icons.cancel, color: Colors.red),
        label: Text("Cancel Trip", style: TextStyle(fontSize: 16, color: Colors.red)),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, elevation: 2),
      ),
    );
  }

  void showCancelOptions(BuildContext context, String bookingId) {
    TextEditingController customReasonController = TextEditingController();
    String? selectedReason;
    List<String> reasons = [
      "Health Issues",
      "Unexpected Work",
      "Weather Conditions",
      "Personal Reasons",
      "Other"
    ];

    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10,),
              Text("Select a reason for cancellation", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              SizedBox(height: 10,),
              Divider(),
              SizedBox(height: 10,),
              ...reasons.map((reason) => RadioListTile<String>(
                title: Text(reason),
                value: reason,
                groupValue: selectedReason,
                onChanged: (value) {
                  selectedReason = value;
                  if (value != "Other") {
                    customReasonController.clear();
                  }
                  (context as Element).markNeedsBuild(); // Rebuild widget
                },
              )),
              if (selectedReason == "Other")
                TextFormField(
                  controller: customReasonController,
                  decoration: InputDecoration(
                    hintText: "Reason",
                    hintStyle: const TextStyle(color: Color(0xFF3D5F8C)),
                    filled: true,
                    fillColor: const Color(0xFFBFCFF3),
                    border: InputBorder.none,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFBFCFF3), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF134277), width: 2),
                    ),
                  ),
                  autocorrect: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Reason';
                    } else if (value.length < 3) {
                      return 'Username must be at least 3 characters long';
                    } else if (!RegExp(r'^[a-zA-Z0-9 ]+$').hasMatch(value)) {
                      return 'Only letters, numbers, and spaces are allowed';
                    }
                    return null; // Valid username
                  },
                ),
              SizedBox(height: 20),
              Container(
                width: MediaQuery.of(context).size.width*0.8,
                height: 60,
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                decoration:
                BoxDecoration(borderRadius: BorderRadius.circular(90)),
                child: ElevatedButton(
                  onPressed: () async {
                    String finalReason = selectedReason == "Other" ? customReasonController.text : selectedReason!;

                    if (finalReason.isNotEmpty) {
                      removeCancelledTrip(bookingId, tripid);
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> AdminNavigationPage()));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Trip cancelled successfully!")),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please provide a cancellation reason.")),
                      );
                    }
                  },

                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    shadowColor: Colors.black,
                    backgroundColor: const Color(0xFF134277),
                    elevation: 10, // Elevation
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding:
                    EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: Text("Confirm Cancellation"),
                ),
              ),
              SizedBox(height: 10,),
            ],
          ),
        );
      },
    );
  }

  void removeCancelledTrip(String bookingId, String tripId) async {
    DocumentReference bookingRef = FirebaseFirestore.instance.collection("booked_trip").doc(bookingId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(bookingRef);

      if (!snapshot.exists) {
        throw Exception("Booking not found");
      }

      List<dynamic> trips = List.from(snapshot["trips"]); // Convert to modifiable list

      // Remove the trip with the matching tripId
      trips.removeWhere((trip) => trip["tripId"] == tripId);

      if (trips.isEmpty) {
        // If no trips remain, delete the entire booking document
        transaction.delete(bookingRef);
      } else {
        // Otherwise, update the trips array in Firestore
        transaction.update(bookingRef, {"trips": trips});
      }
    });

    print("Trip $tripId removed. Booking deleted if no trips remain.");
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
