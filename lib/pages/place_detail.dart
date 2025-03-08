import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../const.dart';
import '../models/travel_model.dart';
import 'add_to_cart.dart';

class PlaceDetailScreen extends StatefulWidget {
  final Trip trip;

  PlaceDetailScreen({required this.trip});

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {

  PageController pageController = PageController();
  int pageView = 0;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? userId = FirebaseAuth.instance.currentUser?.uid;

  bool isSaved = false;

  Trip? trip;

  double _rating = 0;
  TextEditingController _reviewController = TextEditingController();
  double avgTripRating = 0; // Holds updated average rating
  int reviewCount = 0;

  Map<String, dynamic>? hostData;

  bool isExpanded = false;

  Future<void> openWhatsApp() async {

    final Uri whatsappUrl = Uri.parse("https://wa.me/${widget.trip.whatsappInfo}"); // Web-based method

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        throw Exception("Could not launch WhatsApp");
      }
    } catch (e) {
      debugPrint("Error launching WhatsApp: $e");
    }
  }

  void shareTrip() {

    String tripDetails = '''
📍 *${widget.trip.name}*
📌 Destination: ${widget.trip.location}
🗓 Start Date: ${widget.trip.startDate != null ? widget.trip.startDate!.toLocal().toString().split(' ')[0] : "Not provided"}
🏁 End Date: ${widget.trip.endDate != null ? widget.trip.endDate!.toLocal().toString().split(' ')[0] : "Not provided"}
🕒 Duration: ${widget.trip.daysOfTrip} days
💰 Price: \Rs. ${widget.trip.price}
🚗 Transportation: ${widget.trip.transportation}
🏨 Accommodation: ${widget.trip.accommodation}
🎒 Included Services: ${widget.trip.includedServices}
📷 Trip Image:
${widget.trip.image.isNotEmpty ? widget.trip.image.first : "No image available"}

''';

    Share.share(tripDetails);
  }

  void _reportTrip() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => ReportTripCard(trip: widget.trip,),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchTripAndState();
    _fetchHostDetails();
    _fetchTripRatings();
  }


  Future<void> _fetchHostDetails() async {
    try {
      DocumentSnapshot hostSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.trip.hostId) // Fetch host using hostId
          .get();

      if (hostSnapshot.exists) {
        setState(() {
          hostData = hostSnapshot.data() as Map<String, dynamic>;
        });
      }
    } catch (e) {
      print("Error fetching host details: $e");
    }
  }

  // Fetch trip ID and check if it's saved
  Future<void> _fetchTripAndState() async {
    String userId = _auth.currentUser!.uid;

    QuerySnapshot tripSnapshot = await _firestore
        .collection("trips")
        .where("hostId", isEqualTo: userId) // Example: Fetch user's trip
        .limit(1)
        .get();

    if (tripSnapshot.docs.isNotEmpty) {
      String? tripId = tripSnapshot.docs.first.id;
      DocumentSnapshot userTripDoc = await _firestore
          .collection("users")
          .doc(userId)
          .collection("trip")
          .doc(tripId)
          .get();

      setState(() {
        isSaved = userTripDoc.exists; // If exists, trip is saved
      });
    }
  }

  Future<void> _toggleSaveTrip(bool isSaved) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference tripRef = FirebaseFirestore.instance.collection('trips').doc(widget.trip.id);

    if (isSaved) {
      // ✅ Remove user from `savedBy` list
      await tripRef.update({
        'savedBy': FieldValue.arrayRemove([userId]),
      });
    } else {
      // ✅ Add user to `savedBy` list
      await tripRef.update({
        'savedBy': FieldValue.arrayUnion([userId]),
      });
    }
  }

  void _fetchTripRatings() async {
    DocumentSnapshot tripDoc = await FirebaseFirestore.instance.collection('trips').doc(widget.trip.id).get();

    if (tripDoc.exists) {
      setState(() {
        avgTripRating  = (tripDoc['rating'] as num?)?.toDouble() ?? 0.0;
        reviewCount = (tripDoc['reviews'] as num?)?.toInt() ?? 0;
      });
    }
  }

  Future<void> _submitReview() async {
    if (_rating == 0 || _reviewController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add a rating and review")),
      );
      return;
    }

    String userId = FirebaseAuth.instance.currentUser!.uid;

    // ✅ Get user document safely
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

    String username = userData != null && userData.containsKey('username')
        ? userData['username']
        : "Anonymous";

    String? profilePic = userData != null && userData.containsKey('profilePic')
        ? userData['profilePic']
        : null; // ✅ If missing, set to null

    // ✅ Store new review in Firestore (profilePic is null if missing)
    await FirebaseFirestore.instance.collection('trips')
        .doc(widget.trip.id)
        .collection('reviews')
        .add({
      'userId': userId,
      'username': username,
      'profilePic': profilePic, // ❌ Don't store default image
      'rating': _rating,
      'review': _reviewController.text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // ✅ Fetch latest reviews to calculate new rating
    QuerySnapshot reviewsSnapshot = await FirebaseFirestore.instance
        .collection('trips')
        .doc(widget.trip.id)
        .collection('reviews')
        .get();

    int totalReviews = reviewsSnapshot.docs.length;
    double totalRating = 0;

    for (var doc in reviewsSnapshot.docs) {
      totalRating += (doc['rating'] as num).toDouble();
    }

    double avgRating = totalReviews > 0 ? totalRating / totalReviews : 0;

    // ✅ Update trip's rating & reviews count in Firestore
    await FirebaseFirestore.instance.collection('trips').doc(widget.trip.id).update({
      'rating': avgRating,
      'reviews': totalReviews,
    });

    // ✅ Update UI with new values & clear rating input
    setState(() {
      _rating = 0; // Reset rating stars
      _reviewController.clear(); // Clear review text
      avgTripRating = avgRating; // ✅ Update displayed rating
      reviewCount = totalReviews; // ✅ Update displayed review count
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Review Submitted Successfully!")),
    );
  }

  Future<void> addToCart(Trip trip, BuildContext context) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference cartRef = FirebaseFirestore.instance
        .collection('cart')
        .doc(userId)
        .collection('cartItems');

    DocumentSnapshot tripSnapshot = await cartRef.doc(trip.id).get();

    if (tripSnapshot.exists) {
      // Trip already in cart, update person count and total price
      int existingPersons = tripSnapshot['persons'];
      int newPersons = existingPersons + 1;
      double newTotalPrice = newPersons * trip.price;

      await cartRef.doc(trip.id).update({
        'persons': newPersons,
        'totalPrice': newTotalPrice,
      });
    } else {
      // Add trip to cart for the first time
      await cartRef.doc(trip.id).set({
        'tripId':trip.id,
        'userId':userId,
        'title': trip.name,
        'destination': trip.location,
        'tripFee': trip.price,
        'imageUrl': trip.image.isNotEmpty ? trip.image[0] : null, // First image
        'persons': 1, // Default is 1 person
        'totalPrice': trip.price,
        "status": "Pending",// 1 * tripFee
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    // Navigate to AddToCartPage after adding the trip
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddToCartPage()),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Color(0xFF134277),
        leadingWidth: 64,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: const Icon(
              Icons.arrow_back_ios_new,
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          "Detail Page",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Saved Button
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('trips')
                  .doc(widget.trip.id)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.hasError) {
                  return IconButton(
                    icon: const Icon(Icons.favorite_border, color: Colors.grey),
                    onPressed: null, // Disable button if data is not ready
                  );
                }

                // ✅ Ensure `savedBy` exists before accessing it
                Map<String, dynamic>? data = snapshot.data?.data() as Map<String, dynamic>?;

                List<dynamic> savedByList = data != null && data.containsKey('savedBy')
                    ? List<dynamic>.from(data['savedBy'])
                    : [];

                bool isSaved = savedByList.contains(userId);

                return IconButton(
                  icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border, color: Colors.white),
                  onPressed: () => _toggleSaveTrip(isSaved), // ✅ Fixed toggle function
                );
              },
            ),


          ),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'share') {
              shareTrip();
            } else if (value == 'report') {
              _reportTrip();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share, color: Colors.black54),
                  SizedBox(width: 8),
                  Text("Share"),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'report',
              child: Row(
                children: [
                  Icon(Icons.report, color: Colors.redAccent),
                  SizedBox(width: 8),
                  Text("Report a Trip"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: MediaQuery.of(context).size.height*0.5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 5),
                      blurRadius: 7,
                      spreadRadius: 1,
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Stack(
                    children: [
                      PageView(
                        controller: pageController,
                        onPageChanged: (value) {
                          setState(() {
                            pageView = value;
                          });
                        },
                        children: List.generate(
                          widget.trip.image.length,
                          (index) => Image.network(
                            fit: BoxFit.cover,
                            widget.trip.image[index],
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Spacer(),
                          GestureDetector(
                            child: Container(
                              height: 100,
                              width: 100,
                              margin: const EdgeInsets.only(
                                  right: 10, bottom: 10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 2,
                                  color: Colors.white,
                                ),
                                borderRadius: BorderRadius.circular(15),
                                image: DecorationImage(
                                  image:
                                  widget.trip.image.length - 1 != pageView
                                      ? NetworkImage(
                                    widget.trip.image[pageView + 1],
                                  )
                                      : NetworkImage(
                                    widget.trip.image[0],
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.black.withOpacity(0.8),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: List.generate(
                                      widget.trip.image.length,
                                          (index) => GestureDetector(
                                        onTap: () {
                                          if (pageController.hasClients) {
                                            pageController.animateToPage(
                                              index,
                                              duration: const Duration(
                                                milliseconds: 500,
                                              ),
                                              curve: Curves.easeInOut,
                                            );
                                          }
                                        },
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                              milliseconds: 500),
                                          height: 5,
                                          width: 20,
                                          margin:
                                          const EdgeInsets.only(right: 5),
                                          decoration: BoxDecoration(
                                            color: pageView == index
                                                ? Colors.white
                                                : Colors.white
                                                .withOpacity(0.4),
                                            borderRadius:
                                            BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.trip.name,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                            children: [
                                              const Icon(
                                                Icons.location_on,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                widget.trip.location,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                       Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.star_rounded,
                                                    color: Colors.amber[800],
                                                    size: 25,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    avgTripRating.toStringAsFixed(2), // Show rating with 1 decimal
                                                    style: const TextStyle(
                                                      fontSize: 17,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                '($reviewCount reviews)', // Fetch total reviews
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                       ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      "Overview : ",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                      ),
                    ),
                    SizedBox(height: 10),

                    // Description
                    Text(
                      widget.trip.des,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                    //additional info
                    SizedBox(height: 10),
                    ExpansionTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Additional Info",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      tilePadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      childrenPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      collapsedBackgroundColor: Colors.white,
                      children: [
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.start,
                          children: [
                            Text(
                              "Trip Category : ",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                            ),
                            Expanded(
                              child: Text(
                                widget.trip.tripCategory,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 15,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 7,),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.start,
                          children: [
                            Text(
                              "Meeting Point : ",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                            ),
                            Expanded(
                              child: Text(
                                widget.trip.meetingPoint,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 15,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 7,),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.start,
                          children: [
                            Text(
                              "Transportation : ",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                            ),
                            Expanded(
                              child: Text(
                                widget.trip.transportation,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 15,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 7,),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.start,
                          children: [
                            Text(
                              "Maximum Participants : ",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                            ),
                            Expanded(
                              child: Text(
                                widget.trip.maxpart.toString(),
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 15,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 7,),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.start,
                          children: [
                            Text(
                              "Trip Days : ",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                            ),
                            Expanded(
                              child: Text(
                                widget.trip.daysOfTrip.toString(),
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 15,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.start,
                          children: [
                            Text(
                              "Trip Start Date ",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                            ),
                            Expanded(
                              child: Text(
                                widget.trip.startDate!.toLocal().toString().split(' ')[0],
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 15,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.start,
                          children: [
                            Text(
                              "Trip Start Time : ",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                            ),
                            Expanded(
                              child: Text(
                                widget.trip.startTime.toString(),
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 15,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.start,
                          children: [
                            Text(
                              "Trip End Date ",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                            ),
                            Expanded(
                              child: Text(
                                widget.trip.endDate!.toLocal().toString().split(' ')[0],
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 15,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.start,
                          children: [
                            Text(
                              "Trip End Time : ",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                            ),
                            Expanded(
                              child: Text(
                                widget.trip.endTime.toString(),
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 15,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                    //accommadation
                    SizedBox(height: 10),
                    ExpansionTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Accommodation Details",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      tilePadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      childrenPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      collapsedBackgroundColor: Colors.white,
                      children: [
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                widget.trip.accommodation,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 15,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                    //included service
                    SizedBox(height: 10),
                    ExpansionTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Included Service",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      tilePadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      childrenPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      collapsedBackgroundColor: Colors.white,
                      children: [
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                widget.trip.includedServices,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 15,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                    //Itms to bring
                    SizedBox(height: 10),
                    ExpansionTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Items to Bring",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      tilePadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      childrenPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      collapsedBackgroundColor: Colors.white,
                      children: [
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                widget.trip.itemsToBring,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 15,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                    //Guidlines and rule
                    SizedBox(height: 10),
                    ExpansionTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Guidlines And Rules",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      tilePadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      childrenPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      collapsedBackgroundColor: Colors.white,
                      children: [
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                widget.trip.guidelines,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 15,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                    //cancellation policy
                    SizedBox(height: 10),
                    ExpansionTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Cancellation Policy",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      tilePadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      childrenPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      collapsedBackgroundColor: Colors.white,
                      children: [
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                widget.trip.cancellationPolicy,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 15,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                    //contect
                    SizedBox(height: 10),
                    ExpansionTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Host Info",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      tilePadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      childrenPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      collapsedBackgroundColor: Colors.white,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: hostData?['profilePic'] != null
                                  ? NetworkImage(hostData!['profilePic'])
                                  : null,
                              child:hostData?['profilePic'] == null
                                  ? Icon(Icons.person, color: Colors.grey[700], )
                                  : null,
                            ),
                            SizedBox(width: 12),
                            // Host Name
                            Column(
                              children: [
                                Text(
                                  hostData?['username'] ?? "Loading...",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  "The Host",
                                  style: TextStyle(fontSize: 15)
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 7,),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.start,
                          children: [
                            Text(
                              "Mobile Number : ",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                            ),
                            Expanded(
                              child: Text(
                                widget.trip.contactInfo,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 15,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 7,),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.start,
                          children: [
                            Text(
                              "Whatsapp Number : ",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                            ),
                            Text(
                              widget.trip.whatsappInfo,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 15,
                                height: 1.5,
                              ),
                            ),
                            SizedBox(width: 10,),
                            GestureDetector(
                              onTap: openWhatsApp,
                              child: Container(
                                width: 35, // Square container
                                height: 35,
                                decoration: BoxDecoration(
                                  color: Colors.white70, // WhatsApp theme color
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],// Square with rounded corners
                                ),
                                child: Center(
                                  child: Image.asset(
                                    'assets/image/wp.png', // Replace with your Google icon
                                    height: 30,
                                    width: 30,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                    SizedBox(height: 15),

                    Text("Rate & Review :", style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                    ),),
                    SizedBox(height: 8),
                    RatingBar.builder(
                      initialRating: _rating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
                      onRatingUpdate: (rating) {
                        setState(() { _rating = rating; });
                      },
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _reviewController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Write your review...",
                        suffixIcon: IconButton(onPressed: _submitReview, icon: Icon(Icons.send,color: Colors.blue,)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF8BA7E8), width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF134277), width: 2),
                        ),
                      ),
                      maxLines: 3,
                    ),

                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 5,),
                        Text("Reviews : ",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          ),),
                      ],
                    ),
                    SizedBox(height: 5,),


                    // Fetch and Show Reviews (Expandable)
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('trips')
                          .doc(widget.trip.id)
                          .collection('reviews')
                          .orderBy('timestamp', descending: true) // Latest first
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }

                        var reviews = snapshot.data!.docs;
                        if (reviews.isEmpty) {
                          return Text("No reviews yet.");
                        }

                        return Card(
                          color: Colors.white,
                          shadowColor: Colors.grey,
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                            child: Column(
                              children: [

                                // Display One Review
                                _buildReviewTile(reviews.first),

                                // Expand/Collapse Logic
                                if (isExpanded)
                                  Column(
                                    children: reviews
                                        .skip(1) // Show remaining reviews
                                        .map((review) => _buildReviewTile(review))
                                        .toList(),
                                  ),

                                // Expand/Collapse Button
                                if (reviews.length > 1)
                                  TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        isExpanded = !isExpanded;
                                      });
                                    },
                                    icon: Icon(
                                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                      size: 25,
                                    ),
                                    label: Text(isExpanded ? "Show Less" : "Show More",style: TextStyle(color: Color(0xFF134277),),),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 110,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Price",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '\₹${widget.trip.price}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: blueTextColor,
                          ),
                        ),
                        TextSpan(
                          text: ' /Person',
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.6),
                            fontSize: 14,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),

            TextButton(
              onPressed: () {
                addToCart(widget.trip, context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Color(0xFF134277)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.confirmation_number_outlined,
                      color: Colors.white,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Add to Cart",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewTile(DocumentSnapshot reviewDoc) {
    Map<String, dynamic> review = reviewDoc.data() as Map<String, dynamic>;

    Timestamp? timestamp = review['timestamp'];
    String formattedDate = timestamp != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(timestamp.toDate())
        : "Unknown Date";

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align content to the left
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ✅ Profile Picture or Default Icon
              CircleAvatar(
                radius: 24,
                backgroundImage: review['profilePic'] != null && review['profilePic'].isNotEmpty
                    ? NetworkImage(review['profilePic'])
                    : null,
                child: review['profilePic'] == null || review['profilePic'].isEmpty
                    ? Icon(Icons.person, color: Colors.white, size: 24)
                    : null,
                backgroundColor: Colors.blueGrey[200],
              ),

              SizedBox(width: 10),

              // ✅ Username and Rating (in Column)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
                children: [
                  // ✅ Username after Profile Picture
                  Text(
                    review['username'] ?? "Anonymous",
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                  ),

                  SizedBox(height: 5),

                  Row(
                    children: [
                      Text(
                        formattedDate,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),

            ],
          ),

          SizedBox(height: 10),

          Row(
            children: [
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < (review['rating'] ?? 0) ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 18,
                  );
                }),
              ),
              SizedBox(width: 8),
              Text(
                "${(review['rating'] ?? 0).toStringAsFixed(2)}",
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
          SizedBox(height: 3),
          // ✅ Review Text
          Text(
            review['review'] ?? "",
            style: TextStyle(fontSize: 14),
          ),

          SizedBox(height: 3),
          // ✅ Divider for separation
          Divider(thickness: 1, color: Colors.grey[300]),

        ],
      ),
    );

  }

}


class ReportTripCard extends StatefulWidget {

  final Trip trip;

  ReportTripCard({required this.trip});

  @override
  _ReportTripCardState createState() => _ReportTripCardState();
}

class _ReportTripCardState extends State<ReportTripCard> {
  String? _selectedReason; // Stores selected reason
  final TextEditingController _otherReasonController = TextEditingController();
  final List<String> _reportReasons = [
    "Inappropriate content",
    "Misleading information",
    "Scam or fraud",
    "Other issues",
  ];

  void _submitReport() async {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a reason to report.")),
      );
      return;
    }

    if (_selectedReason == "Other issues" && _otherReasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please provide details for 'Other issues'.")),
      );
      return;
    }

    String finalReason = _selectedReason == "Other issues"
        ? _otherReasonController.text
        : _selectedReason!;

    String reason = _selectedReason!;


    // Get the current user ID
    String userId = FirebaseAuth.instance.currentUser!.uid;

    // Generate a new report document ID
    String reportId = FirebaseFirestore.instance.collection('trips')
        .doc(widget.trip.id)
        .collection('reports')
        .doc()
        .id;

    try {
      // Store report in Firestore under trips -> tripId -> reports collection
      await FirebaseFirestore.instance.collection('trips')
          .doc(widget.trip.id)
          .collection('reports')
          .doc(reportId)
          .set({
        'reportId': reportId,
        'tripId': widget.trip.id,
        'userId': userId,
        'reason': reason,
        'finalReason': finalReason,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Report submitted successfully!")),
      );

      Navigator.pop(context); // Close the bottom sheet

    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit report. Please try again.")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Report a Trip",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            "Please select a reason for reporting this trip:",
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          SizedBox(height: 10),

          // List of selectable reasons
          Column(
            children: _reportReasons.map((reason) {
              return RadioListTile<String>(
                title: Text(reason),
                value: reason,
                groupValue: _selectedReason,
                onChanged: (value) {
                  setState(() {
                    _selectedReason = value;
                  });
                },
                activeColor: Color(0xFF134277),
              );
            }).toList(),
          ),

          // Show TextField if "Other issues" is selected
          if (_selectedReason == "Other issues") ...[
            SizedBox(height: 10),
            TextField(
              controller: _otherReasonController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: "Enter details...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],

          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF134277),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text("Submit",style: TextStyle(color: Colors.white),),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
