import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class Trip {
  final String id;
  final String location;
  final String from;
  final String to;
  final double rate;
  final int review;
  final int approxCost;
  final double price;
  final String des;
  final String tripoverview;
  final String tripCategory;
  final String transportation;
  final String accommodation;
  final int maxpart;
  final int daysOfTrip;
  List<String> includedServices;
  DateTime? startDateTime;
  DateTime? endDateTime;
  final DateTime? startDate;
  final DateTime? endDate;
  final String meetingPoint;
  final String whatsappInfo;
  final String itemsToBring;
  final String guidelines;
  final String cancellationPolicy;
  final String hostId;
  final String hostName;
  final String costLevel;
  final List<String>? savedBy;
  final List<String> image;
  final bool popular;
  int persons;
  final List<String> itinerary;
  final String role;

  Trip({
    required this.id,
    required this.location,
    required this.from,
    required this.to,
    required this.rate,
    required this.review,
    required this.approxCost,
    required this.price,
    required this.des,
    required this.tripoverview,
    required this.tripCategory,
    required this.maxpart,
    required this.daysOfTrip,
    required this.transportation,
    required this.accommodation,
    required this.includedServices,
    this.startDateTime,
    this.endDateTime,
    required this.startDate,
    required this.endDate,
    required this.meetingPoint,
    required this.whatsappInfo,
    required this.itemsToBring,
    required this.guidelines,
    required this.cancellationPolicy,
    required this.hostId,
    required this.hostName,
    required this.costLevel,
    this.savedBy,
    this.persons = 1,
    required this.image,
    required this.popular,
    required this.itinerary,
    required this.role,
  });

  // Convert Firestore document to Trip object
  factory Trip.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Trip(
      id: doc.id,
      location: data['destination'] ?? '',
      rate: (data['rating'] ?? 0).toDouble(),
      review: data['reviews'] ?? 0,
      des: data['description'] ?? '',
      from: data["from"] ?? '',
      to: data["to"] ?? '',
      tripoverview: data['tripOverview'] ?? '',
      tripCategory: data['tripCategory'] ?? '',
      maxpart: data['maxParticipants'] ?? 0,
      daysOfTrip: data['daysOfTrip'] ?? 0,
      transportation: data['transportation'] ?? '',
      accommodation: data['accommodation'] ?? '',
      includedServices: List<String>.from(data["includedServices"] ?? []),
      startDateTime: data["startDateTime"] != null ? DateTime.parse(data["startDateTime"]) : null,
      endDateTime: data["endDateTime"] != null ? DateTime.parse(data["endDateTime"]) : null,
      startDate: data['startDate'] != null ? DateTime.parse(data['startDate']) : null,
      endDate: data['endDate'] != null ? DateTime.parse(data['endDate']) : null,
      meetingPoint: data['meetingPoint'] ?? '',
      whatsappInfo: data['whatsappInfo'] ?? '',
      itemsToBring: data['itemsToBring'] ?? '',
      guidelines: data['guidelines'] ?? '',
      cancellationPolicy: data['cancellationPolicy'] ?? '',
      approxCost: data['approxCost']?? 0,
      price: (data['tripFee'] ?? 0).toDouble(),
      hostId: data['hostId'] ?? '',
      costLevel: data["costLevel"] ?? '',
      hostName: data['hostUsername'] ?? '',
      savedBy: List<String>.from(data['savedBy'] ?? []),
      image: List<String>.from(data['photos'] ?? []),
      popular: data['popular'] ?? false,
      itinerary: List<String>.from(data['itinerary'] ?? []),
      role: data['tripRole'],
    );

  }

}

class MyTripService{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? userId = FirebaseAuth.instance.currentUser?.uid;

  Stream<List<Trip>> fetchTrips() {
    try {
      return _firestore
          .collection('trips')
          .where('hostId', isEqualTo: userId)
          .snapshots() // 👈 Use snapshots() for real-time updates
          .map((snapshot) =>
          snapshot.docs.map((doc) => Trip.fromFirestore(doc)).toList());
    } catch (e) {
      print('Error fetching trips: $e');
      return Stream.value([]); // Return an empty list in case of an error
    }
  }

}

class TripSearchService {
  Stream<List<Trip>> fetchSearchedTrips(String query, String? category, String? transport) {
    Query queryRef = FirebaseFirestore.instance
        .collection('trips')
        .where('tripDone', isEqualTo: false)
        .where("tripRole", isEqualTo: "admin");

    // Apply category filter
    if (category != null && category.isNotEmpty) {
      queryRef = queryRef.where("category", isEqualTo: category);
    }

    // Apply transport filter
    if (transport != null && transport.isNotEmpty) {
      queryRef = queryRef.where("transportation", isEqualTo: transport);
    }

    return queryRef.snapshots().map((snapshot) {
      List<Trip> allTrips = snapshot.docs.map((doc) => Trip.fromFirestore(doc)).toList();

      // Filter trips by search query matching from, to, or destination
      return allTrips.where((trip) {
        final queryLower = query.toLowerCase();

        final fromMatch = trip.from.toLowerCase().contains(queryLower);
        final toMatch = trip.to.toLowerCase().contains(queryLower);
        final destinationMatch = trip.location.toLowerCase().contains(queryLower);

        return fromMatch || toMatch || destinationMatch;
      }).toList();
    });
  }
}

class SavedTripService {

  String? userId = FirebaseAuth.instance.currentUser?.uid;

  Stream<List<Trip>> fetchSavedTrips() {
    if (userId == null) {
      return Stream.value([]); // Return an empty stream if userId is null
    }

    return FirebaseFirestore.instance
        .collection('trips')
        .where('savedBy', arrayContains: userId)
        .where('tripDone', isEqualTo: false)// 🔥 Listen to real-time updates
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Trip.fromFirestore(doc)).toList());
  }

}

class AdminTripService {
  Stream<List<Trip>> fetchFilteredTrips(String searchQuery, String? category, String? transport) {
    Query query = FirebaseFirestore.instance
        .collection('trips')
        .where('tripRole', isEqualTo: 'admin');

    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }
    if (transport != null && transport.isNotEmpty) {
      query = query.where('transportation', isEqualTo: transport);
    }

    return query.snapshots().map((snapshot) {
      List<Trip> allTrips = snapshot.docs.map((doc) => Trip.fromFirestore(doc)).toList();

      if (searchQuery.isEmpty) {
        return allTrips;
      }

      String queryLower = searchQuery.toLowerCase();

      return allTrips.where((trip) {
        return (trip.from.toLowerCase().contains(queryLower) ?? false) ||
            (trip.to.toLowerCase().contains(queryLower) ?? false) ||
            (trip.location.toLowerCase().contains(queryLower) ?? false);
      }).toList();
    });
  }
}

class UserTripSearchService {
  Stream<List<Trip>> fetchFilteredTrips(String searchQuery, String? category, String? costLevel) {
    Query query = FirebaseFirestore.instance
        .collection('trips')
        .where('isApproved', isEqualTo: true)
        .where('tripRole', isEqualTo: 'user');

    if (category != null && category.isNotEmpty) {
      query = query.where('tripCategory', isEqualTo: category);
    }
    if (costLevel != null && costLevel.isNotEmpty) {
      query = query.where('costLevel', isEqualTo: costLevel);
    }

    return query.snapshots().map((snapshot) {
      List<Trip> allTrips = snapshot.docs.map((doc) => Trip.fromFirestore(doc)).toList();

      if (searchQuery.isEmpty) {
        return allTrips;
      }

      String queryLower = searchQuery.toLowerCase();

      return allTrips.where((trip) {
        return (trip.from.toLowerCase().contains(queryLower) ?? false) ||
            (trip.to.toLowerCase().contains(queryLower) ?? false) ||
            (trip.location.toLowerCase().contains(queryLower) ?? false);
      }).toList();
    });
  }
}

class UserTripService{
  Stream<List<Trip>> fetchTrips() {
    return FirebaseFirestore.instance
        .collection('trips')
        .where('tripRole', isEqualTo: 'user')
        .where('isApproved', isEqualTo: true)
        .where('tripDone', isEqualTo: false)
        .snapshots() // 👈 Listen for real-time updates
        .map((snapshot) =>
        snapshot.docs.map((doc) => Trip.fromFirestore(doc)).toList());
  }
}

class DeleteTripService{
  void deleteUserTrip(BuildContext context, Trip trip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this trip?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              try {
                // Reference to Firestore
                FirebaseFirestore firestore = FirebaseFirestore.instance;

                // Delete from main trips collection
                await firestore.collection("trips").doc(trip.id).delete();

                // Fetch all users who might have this trip in their subcollection
                QuerySnapshot usersSnapshot = await firestore.collection("users").get();

                // Batch delete trip from each user's subcollection
                WriteBatch batch = firestore.batch();
                for (var userDoc in usersSnapshot.docs) {
                  DocumentReference userTripRef = firestore
                      .collection("users")
                      .doc(userDoc.id)
                      .collection("trip")
                      .doc(trip.id);

                  batch.delete(userTripRef);
                }

                await batch.commit(); // Execute batch delete

                Navigator.pop(context); // Close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Trip deleted successfully")),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error deleting trip: $e")),
                );
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void deleteAdminTrip(BuildContext context, Trip trip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this trip?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              try {
                // Reference to Firestore
                FirebaseFirestore firestore = FirebaseFirestore.instance;

                // Create a batch for efficient deletion
                WriteBatch batch = firestore.batch();

                // Delete from main trips collection
                batch.delete(firestore.collection("trips").doc(trip.id));

                // Fetch all users who might have this trip in their subcollection
                QuerySnapshot usersSnapshot = await firestore.collection("users").get();

                // Batch delete trip from each user's subcollection
                for (var userDoc in usersSnapshot.docs) {
                  DocumentReference userTripRef = firestore
                      .collection("users")
                      .doc(userDoc.id)
                      .collection("trip")
                      .doc(trip.id);
                  batch.delete(userTripRef);
                }

                // Delete trip from admin collection
                batch.delete(firestore.collection("admin").doc(trip.id));

                // Commit batch deletion
                await batch.commit();

                Navigator.pop(context); // Close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Trip deleted successfully")),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error deleting trip: $e")),
                );
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class PopularTripService{
  void togglePopularStatus(BuildContext context, Trip trip) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      await firestore.collection("trips").doc(trip.id).update({
        "popular": !trip.popular, // Toggle true/false
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(trip.popular ? "Trip marked as unpopular!" : "Trip marked as popular!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating trip status: $e")),
      );
    }
  }

  Stream<List<Trip>> fetchPopularTrips() {
    return FirebaseFirestore.instance
        .collection("trips")
        .where("tripRole", isEqualTo: "admin")
        .where("popular", isEqualTo: true)
        .where('tripDone', isEqualTo: false)// ✅ Fetch only popular trips
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Trip.fromFirestore(doc)).toList());
  }

}

class RecommendationTripService{
  Stream<List<Trip>> fetchRecommendationTrips() {
    return FirebaseFirestore.instance
        .collection("trips")
        .where("tripRole", isEqualTo: "admin")
        .where("popular", isEqualTo: false)
        .where('tripDone', isEqualTo: false)// ✅ Fetch only popular trips
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Trip.fromFirestore(doc)).toList());
  }
}

