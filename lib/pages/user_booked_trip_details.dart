import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gobuddy/pages/help_and_supprt.dart';
import 'package:gobuddy/pages/navigation_page.dart';
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
  String startDateTime="";
  String endDateTime="";
  String tripid="";


  @override
  void initState() {
    super.initState();
    fetchUserId();
    fetchBookedTripDetails();
  }

  /// Fetch the User ID from FirebaseAuth
  void fetchUserId() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
      fetchBookedTripDetails();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchBookedTripDetails() async {
    if (userId == null || widget.tripId.isEmpty) return;

    try {
      // Fetch details directly from the 'booked_trip' collection for the current user
      QuerySnapshot bookingsSnapshot = await FirebaseFirestore.instance
          .collection('booked_trip')
          .where('userId', isEqualTo: userId)
          .get();

      if (bookingsSnapshot.docs.isEmpty) {
        print("❌ No bookings found for this user.");
        setState(() => isLoading = false);
        return;
      }

      for (var bookingDoc in bookingsSnapshot.docs) {
        Map<String, dynamic> bookingData = bookingDoc.data() as Map<String, dynamic>;

        // Fetch details of the booking
        String bookingId = bookingDoc.id;
        String destination = bookingData["destination"] ?? "Unknown";
        String from = bookingData["from"] ?? "Unknown";
        String to = bookingData["to"] ?? "Unknown";
        int adults = bookingData["adults"] ?? 1;
        int children = bookingData["children"] ?? 1;
        int totalPerson = adults + children;
        double totalAmount = bookingData["totalAmount"] ?? 0.0;

        // Handle bookingDate timestamp or string conversion
        dynamic bookingDate = bookingData["bookingDate"];
        Timestamp bookingDateTimestamp = Timestamp.now();  // Default value

        if (bookingDate is Timestamp) {
          bookingDateTimestamp = bookingDate;
        } else if (bookingDate is String) {
          try {
            DateTime parsedDate = DateTime.parse(bookingDate);
            bookingDateTimestamp = Timestamp.fromDate(parsedDate);
          } catch (e) {
            print("❌ Error parsing bookingDate string: $e");
          }
        }

        // Fetch startDateTime and endDateTime
        dynamic startDateTime = bookingData["startDateTime"];
        dynamic endDateTime = bookingData["endDateTime"];
        Timestamp startDateTimeTimestamp = Timestamp.now();  // Default value
        Timestamp endDateTimeTimestamp = Timestamp.now();  // Default value

        // Handle startDateTime and endDateTime conversion
        if (startDateTime is Timestamp) {
          startDateTimeTimestamp = startDateTime;
        } else if (startDateTime is String) {
          try {
            DateTime parsedStartDate = DateTime.parse(startDateTime);
            startDateTimeTimestamp = Timestamp.fromDate(parsedStartDate);
          } catch (e) {
            print("❌ Error parsing startDateTime string: $e");
          }
        }

        if (endDateTime is Timestamp) {
          endDateTimeTimestamp = endDateTime;
        } else if (endDateTime is String) {
          try {
            DateTime parsedEndDate = DateTime.parse(endDateTime);
            endDateTimeTimestamp = Timestamp.fromDate(parsedEndDate);
          } catch (e) {
            print("❌ Error parsing endDateTime string: $e");
          }
        }

        // Fetch images from the photos array
        List<dynamic> photos = bookingData["allImages"] ?? [];
        String firstImage = photos.isNotEmpty ? photos[0] : ""; // Get the first image from the array

        // Update the trip details with fetched data
        if (widget.tripId == bookingData["tripId"]) {
          setState(() {
            tripDetails = {
              "bookingId": bookingId,
              "tripId": bookingData["tripId"],
              "destination": destination,
              "from": from,
              "to": to,
              "adults": adults,
              "children": children,
              "totalPerson": totalPerson,
              "totalAmount": totalAmount,
              "bookingDate": bookingDateTimestamp,
              "startDateTime": startDateTimeTimestamp,
              "endDateTime": endDateTimeTimestamp,
              "firstImage": firstImage,  // Add first image to tripDetails
            };
            isLoading = false;
          });
          return;  // Exit once we've found the matching tripId
        }
      }

      setState(() => isLoading = false);
    } catch (e) {
      print("❌ Error fetching trip details: $e");
      setState(() => isLoading = false);
    }
  }



// Function to format Firestore Timestamp
  String formatTimestamp(DateTime timestamp) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(timestamp);
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
                  // Image section
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[300],
                      image: tripDetails!["firstImage"] != null && tripDetails!["firstImage"].isNotEmpty
                          ? DecorationImage(
                        image: NetworkImage(tripDetails!["firstImage"]),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: (tripDetails!["firstImage"] == null || tripDetails!["firstImage"].toString().isEmpty)
                        ? Text("No photos available", style: TextStyle(color: Colors.black54))
                        : null,
                  ),
                  SizedBox(height: 20),
                  Text(
                    tripDetails!["destination"] ?? "No destination",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.red),
                      SizedBox(width: 5),
                      Text(
                        "${tripDetails!["from"]} To ${tripDetails!["to"]}",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.money, color: Colors.green),
                      SizedBox(width: 5),
                      Text(
                        "Total Amount: ₹${tripDetails!["totalAmount"] ?? 0}",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.people, color: Colors.blue),
                      SizedBox(width: 5),
                      Text(
                        "Persons: ${tripDetails!["totalPerson"] ?? 1}",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Divider(),
                  Row(
                    children: [
                      Icon(Icons.confirmation_number, color: Colors.deepOrange),
                      SizedBox(width: 5),
                      Text(
                        "Trip Days : $daysOfTrip",
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Trip Start : ${formatTimestamp(tripDetails!["startDateTime"].toDate())}",
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Trip End : ${formatTimestamp(tripDetails!["endDateTime"].toDate())}",
                    style: TextStyle(color: Colors.black),
                  ),
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
          // Buttons Section at the Bottom
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: helpSupportButton(context),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child:
                          cancelTripButton(context, tripDetails!["bookingId"])
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

  Widget cancelTripButton(BuildContext context, String bookingId) {
    return Container(
      height: 60,
      child: ElevatedButton.icon(
        onPressed: () => showCancelOptions(context, bookingId),
        icon: Icon(Icons.cancel, color: Colors.red),
        label: Text("Cancel", style: TextStyle(fontSize: 16, color: Colors.red)),
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
              SizedBox(height: 10),
              Text("Select a reason for cancellation", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              SizedBox(height: 10),
              Divider(),
              SizedBox(height: 10),
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
                      return 'Reason must be at least 3 characters long';
                    } else if (!RegExp(r'^[a-zA-Z0-9 ]+$').hasMatch(value)) {
                      return 'Only letters, numbers, and spaces are allowed';
                    }
                    return null; // Valid reason
                  },
                ),
              SizedBox(height: 20),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 60,
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
                child: ElevatedButton(
                  onPressed: () async {
                    String finalReason = selectedReason == "Other" ? customReasonController.text : selectedReason!;

                    if (finalReason.isNotEmpty) {
                      // Show confirmation dialog before canceling the trip
                      _showConfirmationDialog(context, bookingId, finalReason);
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
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: Text("Confirm Cancellation"),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }


  void _showConfirmationDialog(BuildContext context, String bookingId, String cancellationReason) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Are you sure?"),
          content: Text("Do you really want to cancel the trip? This action cannot be undone."),
          actions: <Widget>[
            // "No" button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("No"),
            ),
            // "Yes" button
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog

                // Proceed with cancellation
                await cancelTrip(bookingId, cancellationReason);

                // Optionally, navigate to another page or update the UI
                Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationPage()));

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Trip canceled successfully!")),
                );
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }


  Future<void> cancelTrip(String bookingId, String cancellationReason) async {
    try {
      // Fetch the booking document by its ID
      DocumentReference bookingRef = FirebaseFirestore.instance.collection('booked_trip').doc(bookingId);

      // Prepare the cancellation data (you can store the reason in Firestore or log it)
      await bookingRef.update({
        'status': 'canceled', // Mark the trip as canceled
        'cancellationReason': cancellationReason, // Store the reason for cancellation
        'cancellationDate': Timestamp.now(), // Store the date of cancellation
      });

      // Now, delete the booking document from Firestore
      await bookingRef.delete();

      // Show a success message
      print("Trip with bookingId $bookingId has been canceled and deleted successfully.");

      // Optionally, navigate back or perform any other actions
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NavigationPage()), // Navigate to another page if needed
      );

      // Show a success message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Trip deleted successfully.")),
      );

    } catch (e) {
      print("❌ Error canceling and deleting the trip: $e");

      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to cancel and delete the trip. Please try again.")),
      );
    }
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
        label: Text("Help & Support",textAlign: TextAlign.center,style: TextStyle(fontSize:16,color: Color(0xFF134277), )),
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
