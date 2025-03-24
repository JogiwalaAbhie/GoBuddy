import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gobuddy/widgets/userside_usertripedit.dart';
import 'package:intl/intl.dart';

import '../models/notification_model.dart';
import '../models/travel_model.dart';
import '../pages/user_trips_details.dart';

class AdminApproveTrips extends StatefulWidget {
  @override
  _AdminApproveTripsState createState() => _AdminApproveTripsState();
}

class _AdminApproveTripsState extends State<AdminApproveTrips> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = "";

  // // Function to approve trip
  // Future<void> approveTrip(String tripId) async {
  //   await _firestore.collection('trips').doc(tripId).update({'isApproved': true});
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text('Trip Approved ✅')),
  //   );
  // }
  //
  // // Function to reject trip
  // Future<void> rejectTrip(String tripId) async {
  //   await _firestore.collection('trips').doc(tripId).delete();
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text('Trip Rejected ❌')),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF134277),
        foregroundColor: Colors.white,
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Search by destination...",
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          onChanged: (query) {
            setState(() {
              _searchQuery = query;
            });
          },
        )
            : Text('Approve Trips'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                _searchQuery = "";
                _searchController.clear();
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('trips').where('isApproved', isEqualTo: false).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No pending trips to approve'));
          }

          var trips = snapshot.data!.docs;

          // Filter trips based on search query
          var filteredTrips = trips.where((trip) {
            String destination = trip['destination'].toLowerCase();
            return _searchQuery.isEmpty || destination.contains(_searchQuery.toLowerCase());
          }).toList();

          if (filteredTrips.isEmpty) {
            return Center(child: Text('No trips found for "$_searchQuery"'));
          }

          return ListView.builder(
            itemCount: filteredTrips.length,
            itemBuilder: (context, index) {
              var tripDoc = filteredTrips[index]; // QueryDocumentSnapshot
              Trip? trip;

              try {
                trip = Trip.fromFirestore(tripDoc);
              } catch (e) {
                print('Error parsing trip: $e');
                return SizedBox(); // Skip rendering if error occurs
              }

              if (trip == null) return SizedBox(); // Avoid null issues

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserTripsDetails(trip: trip!), // Pass Trip object
                    ),
                  );
                },
                child: Card(
                  color: Colors.white,
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                        child: Image.network(
                          (trip.image.isNotEmpty) ? trip.image.first : 'https://via.placeholder.com/150',
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset('assets/images/default.png', height: 180, width: double.infinity, fit: BoxFit.cover);
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trip.location ?? 'Unknown Location',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Date: ${trip.startDate != null ? DateFormat('dd MMM yyyy').format(trip.startDate!) : 'N/A'} to '
                                  '${trip.endDate != null ? DateFormat('dd MMM yyyy').format(trip.endDate!) : 'N/A'}',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Cost Level : ${trip.costLevel}",
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(

                                  onPressed: () {
                                    FirebaseService().approveTrip(trip!.id, trip.hostId);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Trip Approved! Notification sent.")),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  icon: Icon(Icons.check, color: Colors.white),
                                  label: Text('Approve', style: TextStyle(color: Colors.white)),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    FirebaseService().rejectTrip(trip!.id, trip.hostId);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Trip Rejected! Notification sent.")),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  icon: Icon(Icons.close, color: Colors.white),
                                  label: Text('Reject', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
