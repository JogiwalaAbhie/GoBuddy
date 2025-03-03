import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class Trip {
  final String id;
  final String name;
  final String location;
  final double rate;
  final int review;
  final double price;
  final String des;
  final String tripCategory;
  final String transportation;
  final String accommodation;
  final int maxpart;
  final int daysOfTrip;
  final String includedServices;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? startTime;
  final String? endTime;
  final String meetingPoint;
  final String contactInfo;
  final String whatsappInfo;
  final String itemsToBring;
  final String guidelines;
  final String cancellationPolicy;
  final String hostId;
  final String hostName;
  final List<String>? savedBy;
  final List<String> image;
  final bool popular;

  Trip({
    required this.id,
    required this.name,
    required this.location,
    required this.rate,
    required this.review,
    required this.price,
    required this.des,
    required this.tripCategory,
    required this.maxpart,
    required this.daysOfTrip,
    required this.transportation,
    required this.accommodation,
    required this.includedServices,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
    required this.meetingPoint,
    required this.contactInfo,
    required this.whatsappInfo,
    required this.itemsToBring,
    required this.guidelines,
    required this.cancellationPolicy,
    required this.hostId,
    required this.hostName,
    this.savedBy,
    required this.image,
    required this.popular
  });

  // Convert Firestore document to Trip object
  factory Trip.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Trip(
      id: doc.id,
      name: data['tripTitle'] ?? '',
      location: data['destination'] ?? '',
      rate: (data['rating'] ?? 0).toDouble(),
      review: data['reviews'] ?? 0,
      des: data['description'] ?? '',
      tripCategory: data['tripCategory'] ?? '',
      maxpart: data['maxParticipants'] ?? 0,
      daysOfTrip: data['daysOfTrip'] ?? 0,
      transportation: data['transportation'] ?? '',
      accommodation: data['accommodation'] ?? '',
      includedServices: data['includedServices'] ?? '',
      startDate: data['startDate'] != null ? DateTime.parse(data['startDate']) : null,
      startTime: data['startTime'],
      endDate: data['endDate'] != null ? DateTime.parse(data['endDate']) : null,
      endTime: data['endTime'],
      meetingPoint: data['meetingPoint'] ?? '',
      contactInfo: data['contactInfo'] ?? '',
      whatsappInfo: data['whatsappInfo'] ?? '',
      itemsToBring: data['itemsToBring'] ?? '',
      guidelines: data['guidelines'] ?? '',
      cancellationPolicy: data['cancellationPolicy'] ?? '',
      price: (data['tripFee'] ?? 0).toDouble(),
      hostId: data['hostId'] ?? '',
      hostName: data['hostUsername'] ?? '',
      savedBy: List<String>.from(data['savedBy'] ?? []),
      image: List<String>.from(data['photos'] ?? []),
      popular: data['popular'] ?? false,
    );

  }

}

class TripService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch trips in real-time
  Stream<List<Trip>> fetchTrips() {
    return _firestore.collection('trips').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Trip.fromFirestore(doc);
      }).toList();
    });
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
  Stream<List<Trip>> fetchSearchedTrips(String query) {
    return FirebaseFirestore.instance
        .collection('trips')
        .snapshots() // 🔥 Listen to real-time updates
        .map((snapshot) {
      List<Trip> allTrips = snapshot.docs.map((doc) => Trip.fromFirestore(doc)).toList();

      // Filter trips by title or destination
      return allTrips.where((trip) {
        final titleMatch = trip.name.toLowerCase().contains(query.toLowerCase());
        final destinationMatch = trip.location.toLowerCase().contains(query.toLowerCase());
        return titleMatch || destinationMatch;
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
        .where('savedBy', arrayContains: userId) // 🔥 Listen to real-time updates
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Trip.fromFirestore(doc)).toList());
  }

}

class AdminTripService {
  Stream<List<Trip>> fetchTrips() {
    return FirebaseFirestore.instance
        .collection('trips')
        .where('tripRole', isEqualTo: 'admin')
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
        .where("popular", isEqualTo: true) // ✅ Fetch only popular trips
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Trip.fromFirestore(doc)).toList());
  }

}

class RecommendationTripService{
  Stream<List<Trip>> fetchRecommendationTrips() {
    return FirebaseFirestore.instance
        .collection("trips")
        .where("popular", isEqualTo: false) // ✅ Fetch only popular trips
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Trip.fromFirestore(doc)).toList());
  }
}

