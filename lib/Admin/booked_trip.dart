// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:iconsax/iconsax.dart';
//
// class BookedTripsAdminScreen extends StatefulWidget {
//   @override
//   _BookedTripsAdminScreenState createState() => _BookedTripsAdminScreenState();
// }
//
// class _BookedTripsAdminScreenState extends State<BookedTripsAdminScreen> {
//   List<Map<String, dynamic>> allBookings = [];
//   List<Map<String, dynamic>> filteredBookings = [];
//   TextEditingController searchController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     fetchAllBookings();
//   }
//
//   Future<void> fetchAllBookings() async {
//     List<Map<String, dynamic>> bookings = [];
//
//     try {
//       QuerySnapshot userDocs =
//       await FirebaseFirestore.instance.collection('booked_trip').get();
//
//       if (userDocs.docs.isEmpty) {
//         print("DEBUG: No booked_trip found in Firestore.");
//         return;
//       }
//
//       for (var userDoc in userDocs.docs) {
//         String userId = userDoc.id;
//         QuerySnapshot bookingDocs = await FirebaseFirestore.instance
//             .collection('booked_trip')
//             .doc(userId)
//             .collection('bookings')
//             .get();
//
//         for (var bookingDoc in bookingDocs.docs) {
//           String bookingId = bookingDoc.id;
//
//           QuerySnapshot tripDocs = await FirebaseFirestore.instance
//               .collection('booked_trip')
//               .doc(userId)
//               .collection('bookings')
//               .doc(bookingId)
//               .collection('trips')
//               .get();
//
//           List<Map<String, dynamic>> tripList = [];
//
//           for (var tripDoc in tripDocs.docs) {
//             Map<String, dynamic>? tripData = tripDoc.data() as Map<String, dynamic>?;
//
//             if (tripData == null) {
//               print("DEBUG: Skipping trip with null data (Booking ID: $bookingId)");
//               continue;
//             }
//
//             tripList.add({
//               'title': tripData['title'] ?? 'Unknown Title',
//               'destination': tripData['destination'] ?? 'Unknown Destination',
//               'tripFee': tripData['tripFee'] ?? 0,
//               'person': tripData['person'] ?? 1,
//               'totalPrice': tripData['totalPrice'] ?? 0,
//               'firstImage': tripData['firstImage'] ??
//                   'https://via.placeholder.com/150', // Default image
//             });
//           }
//
//           if (tripList.isNotEmpty) {
//             bookings.add({
//               'bookingId': bookingId,
//               'trips': tripList,
//             });
//           }
//         }
//       }
//     } catch (e) {
//       print("Error fetching booked trips: $e");
//     }
//
//     setState(() {
//       allBookings = bookings;
//       filteredBookings = bookings;
//     });
//   }
//
//   void searchBooking(String query) {
//     if (query.isEmpty) {
//       setState(() {
//         filteredBookings = allBookings;
//       });
//       return;
//     }
//
//     List<Map<String, dynamic>> searchResults = allBookings
//         .where((booking) => booking['bookingId'].contains(query))
//         .toList();
//
//     setState(() {
//       filteredBookings = searchResults;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Booked Trips - Admin"),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.search),
//             onPressed: () {
//               showSearchDialog();
//             },
//           ),
//         ],
//       ),
//       body: filteredBookings.isEmpty
//           ? Center(
//         child: Text(
//           "No trips found.",
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
//         ),
//       )
//           : ListView.builder(
//         itemCount: filteredBookings.length,
//         itemBuilder: (context, index) {
//           var booking = filteredBookings[index];
//           List<Map<String, dynamic>> trips = booking['trips'];
//
//           return Card(
//             margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(10),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "Booking ID: ${booking['bookingId']}",
//                     style:
//                     TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                   ),
//                   SizedBox(height: 8),
//                   Column(
//                     children: trips.map((trip) {
//                       return Container(
//                         margin: EdgeInsets.symmetric(vertical: 5),
//                         child: ListTile(
//                           leading: ClipRRect(
//                             borderRadius: BorderRadius.circular(8),
//                             child: Image.network(
//                               trip['firstImage'],
//                               width: 60,
//                               height: 60,
//                               fit: BoxFit.cover,
//                               errorBuilder: (context, error, stackTrace) =>
//                                   Icon(Icons.image,
//                                       size: 50, color: Colors.grey),
//                             ),
//                           ),
//                           title: Text(
//                             "${trip['title']} - ${trip['destination']}",
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           subtitle: Text(
//                             "Persons: ${trip['person']} | Total Fee: ₹${trip['totalPrice']}",
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   void showSearchDialog() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: Colors.white,
//           title: Text("Search Booked Trip"),
//           content: TextField(
//             controller: searchController,
//             decoration: InputDecoration(
//               hintText: "Enter Booking ID",
//               border: OutlineInputBorder(),
//               prefixIcon: Icon(Iconsax.search_favorite),
//             ),
//             onChanged: searchBooking,
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 searchController.clear();
//                 searchBooking('');
//                 Navigator.pop(context);
//               },
//               child: Text("Clear"),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: Text("Close"),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminBookedTripsPage extends StatefulWidget {
  @override
  _AdminBookedTripsPageState createState() => _AdminBookedTripsPageState();
}

class _AdminBookedTripsPageState extends State<AdminBookedTripsPage> {
  List<Map<String, dynamic>> bookedTrips = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    clearFirestoreCache();
    fetchBookedTrips();
  }

  /// Clears Firestore cache
  Future<void> clearFirestoreCache() async {
    await FirebaseFirestore.instance.clearPersistence();
    print("✅ Firestore cache cleared!");
  }

  /// Fetch all booked trips from Firestore
  Future<void> fetchBookedTrips() async {
    try {
      List<Map<String, dynamic>> tripsList = [];
      print("🔍 Fetching booked trips...");

      var bookedTripsRef = FirebaseFirestore.instance.collection('booked_trip');
      var snapshot = await bookedTripsRef.get();

      if (snapshot.docs.isEmpty) {
        print("❌ No users found in booked_trip!");
        setState(() => isLoading = false);
        return;
      }

      for (var userDoc in snapshot.docs) {
        print("👤 Found user: ${userDoc.id}");

        var bookingsSnapshot = await userDoc.reference.collection('bookings').get();
        if (bookingsSnapshot.docs.isEmpty) {
          print("❌ No bookings found for user: ${userDoc.id}");
          continue;
        }

        for (var bookingDoc in bookingsSnapshot.docs) {
          print("📦 Found booking ID: ${bookingDoc.id}");

          var tripsSnapshot = await bookingDoc.reference.collection('trips').get();
          if (tripsSnapshot.docs.isEmpty) {
            print("❌ No trips found for booking: ${bookingDoc.id}");
            continue;
          }

          for (var tripDoc in tripsSnapshot.docs) {
            Map<String, dynamic> tripData = tripDoc.data();
            print("🚀 Trip Found: ${tripData}");

            tripsList.add({
              "bookingId": bookingDoc.id,
              "title": tripData["title"] ?? "No Title",
              "destination": tripData["destination"] ?? "Unknown",
              "totalFee": tripData["totalFee"] ?? 0,
              "person": tripData["person"] ?? 1,
            });
          }
        }
      }

      setState(() {
        bookedTrips = tripsList;
        isLoading = false;
      });

      print("✅ Successfully fetched ${bookedTrips.length} booked trips!");

    } catch (e) {
      print("❌ Error fetching booked trips: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin - Booked Trips")),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loader
          : bookedTrips.isEmpty
          ? Center(child: Text("No booked trips found!")) // Show empty message
          : ListView.builder(
        itemCount: bookedTrips.length,
        itemBuilder: (context, index) {
          var trip = bookedTrips[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text(trip["title"], style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Destination: ${trip["destination"]}"),
                  Text("Booking ID: ${trip["bookingId"]}"),
                  Text("Persons: ${trip["person"]}"),
                  Text("Total Fee: \$${trip["totalFee"]}"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
