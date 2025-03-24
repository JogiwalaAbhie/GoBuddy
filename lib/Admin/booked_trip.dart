import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../const.dart';

import '../models/notification_model.dart';
import '../models/work_manager_model.dart';
import '../pages/user_booked_trip_details.dart';
import 'admin_booked_trip_details.dart';

class AdminBookedTripsScreen extends StatefulWidget {
  @override
  _AdminBookedTripsScreenState createState() => _AdminBookedTripsScreenState();
}

class _AdminBookedTripsScreenState extends State<AdminBookedTripsScreen> {
  List<Map<String, dynamic>> groupedBookings = [];
  bool isLoading = true;
  String? userId;

  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";
  bool isSearching = false;
  List<Map<String, dynamic>> filteredTrips = [];


  @override
  void initState() {
    super.initState();
    fetchAllBookedTripsForAdmin();
  }

  /// Fetch booked trips for the current user
  Future<void> fetchAllBookedTripsForAdmin() async {
    try {
      setState(() => isLoading = true); // Start loading

      List<Map<String, dynamic>> bookingsList = [];

      // Fetch all booked trips (all users)
      var bookingsSnapshot = await FirebaseFirestore.instance.collection('booked_trip').get();

      if (bookingsSnapshot.docs.isEmpty) {
        setState(() {
          groupedBookings = [];
          isLoading = false;
        });
        return;
      }

      List<Future<void>> fetchTasks = [];

      for (var bookingDoc in bookingsSnapshot.docs) {
        fetchTasks.add(Future(() async {
          Map<String, dynamic> bookingData = bookingDoc.data();

          String userId = bookingData["userId"] ?? "Unknown";
          String tripId = bookingData["tripId"] ?? "Unknown";
          String destination = bookingData["destination"] ?? "Unknown";
          String from = bookingData["from"] ?? "Unknown";
          String to = bookingData["to"] ?? "Unknown";
          int adults = bookingData["adults"] ?? 1;
          int children = bookingData["children"] ?? 1;
          int totalPerson = adults + children;
          double totalAmount = bookingData["totalAmount"] ?? 0.0;

          Timestamp bookingDateTimestamp = Timestamp.now();
          dynamic bookingDate = bookingData["timestamp"];

          if (bookingDate is Timestamp) {
            bookingDateTimestamp = bookingDate;
          } else if (bookingDate is String) {
            try {
              DateTime parsedDate = DateTime.parse(bookingDate);
              bookingDateTimestamp = Timestamp.fromDate(parsedDate);
            } catch (e) {
              print("❌ Error parsing timestamp string: $e");
            }
          }

          // Fetch user details
          var userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
          String userName = userDoc.exists ? userDoc['username'] ?? "Unknown User" : "Unknown User";
          String userEmail = userDoc.exists ? userDoc['email'] ?? "Unknown Email" : "Unknown Email";

          // Fetch trip details
          var tripDoc = await FirebaseFirestore.instance.collection('trips').doc(tripId).get();
          DateTime? startDateAsDateTime;
          if (tripDoc.exists) {
            dynamic startDate = tripDoc['startDateTime'];
            if (startDate is String) {
              try {
                startDateAsDateTime = DateTime.parse(startDate);
              } catch (e) {
                print("❌ Error parsing startDateTime string: $e");
              }
            } else if (startDate is Timestamp) {
              startDateAsDateTime = startDate.toDate();
            }
          }

          List<dynamic> participantsList = bookingData["participants"] ?? [];
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
            "userId": userId,
            "userName": userName,
            "userEmail": userEmail,
            "tripId": tripId,
            "from": from,
            "to": to,
            "destination": destination,
            "person": totalPerson,
            "adults": adults,
            "children": children,
            "totalAmount": totalAmount,
            "bookingDate": bookingDateTimestamp,
            "participants": participants,
            "startDate": startDateAsDateTime,
          });
        }));
      }

      await Future.wait(fetchTasks);

      setState(() {
        groupedBookings = bookingsList;
        filteredTrips = bookingsList;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error fetching all booked trips: $e");
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

  void searchTrips(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredTrips = groupedBookings.where((trip) {
        final destination = trip["destination"].toString().toLowerCase();
        final from = trip["from"].toString().toLowerCase();
        final to = trip["to"].toString().toLowerCase();
        final bookingId = trip["bookingId"].toString().toLowerCase();

        return destination.contains(searchQuery) ||
            from.contains(searchQuery) ||
            to.contains(searchQuery) ||
            bookingId.contains(searchQuery);
      }).toList();
    });
  }

  void toggleSearch() {
    setState(() {
      isSearching = !isSearching;
      if (!isSearching) {
        _searchController.clear();
        searchTrips(""); // Reset search results
      }
    });
  }

  void applyFilters(String? destination, String? from, String? to, DateTime? bookingDate) {
    setState(() {
      filteredTrips = groupedBookings.where((trip) {
        bool matches = true;

        if (destination != null && destination.isNotEmpty) {
          matches &= trip["destination"].toLowerCase().contains(destination.toLowerCase());
        }
        if (from != null && from.isNotEmpty) {
          matches &= trip["from"].toLowerCase().contains(from.toLowerCase());
        }
        if (to != null && to.isNotEmpty) {
          matches &= trip["to"].toLowerCase().contains(to.toLowerCase());
        }
        if (bookingDate != null) {
          DateTime tripDate = (trip["bookingDate"] as Timestamp).toDate();
          matches &= tripDate.year == bookingDate.year &&
              tripDate.month == bookingDate.month &&
              tripDate.day == bookingDate.day;
        }
        return matches;
      }).toList();
    });
  }

  void showFilterDialog(BuildContext context) {
    String? selectedDestination;
    String? selectedFrom;
    String? selectedTo;
    DateTime? selectedBookingDate;
    TextEditingController dateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Filter Trips",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,),
              ),
              Icon(Icons.filter_alt, color: Color(0xFF134277)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: "Destination",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFBFCFF3), width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF134277), width: 2),
                  ),
                ),
                onChanged: (value) => selectedDestination = value,
              ),
              SizedBox(height: 10),

              TextField(
                decoration: InputDecoration(
                  labelText: "From",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFBFCFF3), width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF134277), width: 2),
                  ),
                ),
                onChanged: (value) => selectedFrom = value,
              ),
              SizedBox(height: 10),

              TextField(
                decoration: InputDecoration(
                  labelText: "To",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFBFCFF3), width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF134277), width: 2),
                  ),
                ),
                onChanged: (value) => selectedTo = value,
              ),
              SizedBox(height: 10),

              TextField(
                controller: dateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Booking Date",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFBFCFF3), width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF134277), width: 2),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.date_range, color:  Color(0xFF134277)),
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (pickedDate != null) {
                        selectedBookingDate = pickedDate;
                        dateController.text =
                        "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Color(0xFF134277),)),
            ),
            ElevatedButton(
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
              onPressed: () {
                applyFilters(selectedDestination, selectedFrom, selectedTo, selectedBookingDate);
                Navigator.pop(context);
              },
              child: Text("Apply", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Search trips...",
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          style: TextStyle(color: Colors.white),
          onChanged: searchTrips,
        )
            : Text("All Booked Trips"),
        backgroundColor: const Color(0xFF134277),
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black26,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: toggleSearch,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showFilterDialog(context);
            },
          ),
        ],
      ),

      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : filteredTrips.isEmpty
          ? Center(
        child: Text(
          "User haven't booked any trips yet!",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
        ),
      )
          : RefreshIndicator(
        onRefresh: fetchAllBookedTripsForAdmin,
            child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: filteredTrips.length,
                    itemBuilder: (context, index) {
            var booking = filteredTrips[index];
            
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
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => BookedTripDetailsPage(
                      //       tripId: tripId,
                      //     ), // Pass tripId correctly
                      //   ),
                      // );
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
          ),
    );
  }
}





