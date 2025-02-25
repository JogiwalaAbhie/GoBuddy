import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Admin/edit_trip.dart';

Random random = Random();

class TravelDestination {
  final int id, price, review;
  final List<String>? image;
  final String name, description, category, location;
  final double rate;

  TravelDestination({
    required this.name,
    required this.price,
    required this.id,
    required this.category,
    required this.description,
    required this.review,
    required this.image,
    required this.rate,
    required this.location,
  });
}

List<TravelDestination> myDestination = [
  TravelDestination(
    id: 2,
    name: "Mt.Everest",
    category: 'popular',
    image: [
      "https://cdn.britannica.com/17/83817-050-67C814CD/Mount-Everest.jpg",
      "https://plus.unsplash.com/premium_photo-1688645554172-d3aef5f837ce?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8bW91bnQlMjBldmVyZXN0fGVufDB8fDB8fHww",
      "https://media.breezeadventure.com/uploads/media/blog-photos/mt.everest-location%281%29.jpg",
      "https://nationalparks-15bc7.kxcdn.com/images/parks/sagarmatha/Sagarmatha%20National%20Park.jpg",
    ],
    location: "Sagarmatha,Nepal",
    review: random.nextInt(300) + 25,
    price: 999,
    description: description,
    rate: 4.9,
  ),
  TravelDestination(
    id: 7,
    price: 100,
    name: "Pashupatinath Temple",
    image: [
      "https://photographylife.com/wp-content/uploads/2015/08/DSC0026-2.jpg",
      "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1f/Pashupatinath_Temple-2020.jpg/1200px-Pashupatinath_Temple-2020.jpg",
      "https://miro.medium.com/v2/resize:fit:982/1*P7It43hWVB-UWxl2WuT26w.jpeg",
      "https://holidaystonepal.in/media/files/Blogs/Pashupatinath-Temple-Photos/pashupatinath-viewpoint.png",
    ],
    review: random.nextInt(300) + 25,
    category: "popular",
    location: "Kathmandu, Nepal",
    description: description,
    rate: 4.8,
  ),
  TravelDestination(
    id: 3,
    name: "Lubini Temple",
    review: random.nextInt(300) + 25,
    price: 599,
    category: 'recomend',
    image: [
      "https://myrepublica.nagariknetwork.com/uploads/media/2019/May/eve%20of%20buddha%20jayanti%20in%20lumbini%2004.jpg",
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQFF40BKievkEY2Kd1wP-MEcK1ITOdvf_DzhA&s",
      "https://upload.wikimedia.org/wikipedia/commons/1/18/BRP_Lumbini_Mayadevi_temple.jpg",
      "https://blogger.googleusercontent.com/img/a/AVvXsEgJLGz7rSD1euAgJjZipKghOwfNYcXHYzAKNPIak9V6sfHj5QI1fSMkQQa3LbYstY0JsPQ4Uad6Z4aoqEeJfSXtyhojJHog73SCPmqLE-CyNrqGpjKDFQhNcMJ3Hg46F7qF75XzYLz9W7qqckJQHY4dGbpquC0NiGjDnGhh0OQvM7tH_v5FKmyDTv_mC4g",
    ],
    location: "Lumbini,Nepal",
    description: description,
    rate: 4.9,
  ),
  TravelDestination(
    id: 8,
    name: "Rara Lake",
    review: random.nextInt(300) + 25,
    price: 777,
    category: "popular",
    image: [
      "https://www.himkalaadventure.com/uploads/gallery/Rara-Lake---51.jpg",
      "https://facts.net/wp-content/uploads/2023/09/16-unbelievable-facts-about-rara-lake-1694520647.jpg",
      "https://www.insidehimalayas.com/wp-content/uploads/2018/08/42089507610_036a78545e_k.jpg",
    ],
    location: "Mugu, Nepal",
    description: description,
    rate: 4.5,
  ),
  TravelDestination(
    id: 1,
    name: "Mustang",
    review: random.nextInt(300) + 25,
    price: 920,
    category: 'recomend',
    image: [
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRFhSLRmhTZKkOHiWO6qAP-1Ihk7UgSKf2xPQ&s",
      "https://upload.wikimedia.org/wikipedia/commons/2/27/Kali_Gandaki_Valley%2C_Road%2C_Mustang%2C_Nepal%2C_Himalaya.jpg",
      "https://static.toiimg.com/photo/54323153.cms",
      "https://www.nepalguideinfo.com/new/wp-content/uploads/2024/01/upper_mustang_mansoon-1024x517-1.jpg"
    ],
    location: "Mustang,Nepal",
    description: description,
    rate: 4.6,
  ),
  TravelDestination(
    id: 9,
    name: "Karnali River",
    review: random.nextInt(300) + 25,
    category: "popular",
    price: 199,
    image: [
      "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f6/Karnali_river_in_Kailali.jpg/1200px-Karnali_river_in_Kailali.jpg",
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSNn9DYI6MivBwG2NDgZf7R8A6RHxzSHJTVfA&s",
      "https://superdesk-pro-c.s3.amazonaws.com/sd-nepalitimes/20221108101132/636a22729c7e80680e04178cjpeg.jpg",
      "https://highlightstourism.com/wp-content/uploads/2023/01/SA_Surkhet_0939.jpg",
    ],
    location: "Kailali, Nepal",
    description: description,
    rate: 4.7,
  ),
  TravelDestination(
    id: 12,
    name: "Mountain Range",
    category: "recomend",
    review: random.nextInt(300) + 25,
    price: 499,
    image: [
      "https://upload.wikimedia.org/wikipedia/commons/b/b2/Annapurna_Massif_Aerial_View.jpg",
      "https://www.travelandleisure.com/thmb/kfcKH88gBt_d1ZJPFg_rUcyMekU=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/TAL-grand-teton-USMNTNSIPOG0823-2538d183b9094e3fb59dd5e54bbe791c.jpg",
      "https://assets.iflscience.com/assets/articleNo/73209/aImg/74597/longest-ocean-range-meta.jpg",
      "https://www.brit.co/media-library/image.jpg?id=20912072&width=600&height=600&quality=90&coordinates=0%2C0%2C0%2C0",
    ],
    location: "Pokhara,Nepal",
    description: description,
    rate: 4.8,
  ),
  TravelDestination(
    id: 14,
    name: "Kathmandu Durbar ",
    review: random.nextInt(300) + 25,
    category: "recomend",
    price: 99,
    image: [
      "https://lp-cms-production.imgix.net/2023-06/iStock-1399673095.jpg?fit=crop&ar=1%3A1&w=1200&auto=format&q=75",
      "https://mountainroutes.com/wp-content/uploads/2022/07/KTM-Durbar-Square.jpg",
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTGdbXCAE475wXv2GuDOEyRTwj2Lomg5KGZMxR8GMEupL2e4KAx1fiqvnbeUBXW2HpFgfU&usqp=CAU",
    ],
    location: "Kathmandu, Nepal",
    description: description,
    rate: 4.7,
  ),
];
const description =
    'Travel places offer a wide array of experiences, each with its own unique charm and appeal. From stunning natural landscapes to historic landmarks, there is something for every traveler. Coastal TravelDestinations like tropical beaches invite relaxation with crystal-clear waters, while mountainous regions offer adventurous hiking trails and breathtaking views.';



//
// class Trip {
//   final String id;
//   final String hostId;
//   final String hostUsername;
//   final String tripTitle;
//   final String destination;



//   final String description;
//   final String meetingPoint;

//   final int maxParticipants;
//   final double tripFee;


//   final List<String> photos;
//   final DateTime createdAt;
//
//   Trip({
//     required this.id,
//     required this.hostId,
//     required this.hostUsername,
//     required this.tripTitle,
//     required this.destination,



//     required this.description,
//     required this.meetingPoint,

//     required this.maxParticipants,
//     required this.tripFee,


//     required this.photos,
//     required this.createdAt,
//   });
//
//   // Convert Firestore Document to Trip object
//   factory Trip.fromFirestore(DocumentSnapshot doc) {
//     Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//
//     return Trip(
//       id: doc.id,
//       hostId: data['hostId'] ?? '',
//       hostUsername: data['hostUsername'] ?? '',
//       tripTitle: data['tripTitle'] ?? '',
//       destination: data['destination'] ?? '',



//       description: data['description'] ?? '',
//       meetingPoint: data['meetingPoint'] ?? '',

//       maxParticipants: data['maxParticipants'] ?? 0,
//       tripFee: (data['tripFee'] ?? 0).toDouble(),


//       photos: List<String>.from(data['photos'] ?? []),
//       createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
//     );
//   }
// }


// class TripService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   // Fetch all trips as a list of Trip objects
//   Future<List<Trip>> getTrips() async {
//     try {
//       QuerySnapshot snapshot = await _firestore.collection('trips').get();
//
//       return snapshot.docs.map((doc) => Trip.fromFirestore(doc)).toList();
//     } catch (e) {
//       print('Error fetching trips: $e');
//       return [];
//     }
//   }
// }

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
  final String? startTime;
  final DateTime? endDate;
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
    );

  }

}

class TripService {

  Stream<List<Trip>> fetchTrips() {
    return FirebaseFirestore.instance
        .collection('trips')
        .snapshots() // 👈 Listen for real-time updates
        .map((snapshot) =>
        snapshot.docs.map((doc) => Trip.fromFirestore(doc)).toList());
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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

  // 🔹 Function to delete a trip
  void deleteTrip(BuildContext context, Trip trip) {
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
                      .collection("trips")
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

}

class EditTripService{
  void editTrip(BuildContext context, Trip trip) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTripScreen(),
      ),
    );
  }
}

