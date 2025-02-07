import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../const.dart';
import '../models/travel_model.dart';

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

  bool isSaved = false;
  String? tripId;

  @override
  void initState() {
    super.initState();
    _fetchTripAndState();
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
      tripId = tripSnapshot.docs.first.id;
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

  // Toggle save state in Firestore
  Future<void> _toggleSave() async {
    if (tripId == null) return;
    String userId = _auth.currentUser!.uid;
    DocumentReference userTripRef = _firestore
        .collection("users")
        .doc(userId)
        .collection("trip")
        .doc(tripId);
    DocumentReference tripRef = _firestore.collection("trips").doc(tripId);

    setState(() => isSaved = !isSaved);

    WriteBatch batch = _firestore.batch();

    if (isSaved) {
      batch.set(userTripRef, {"saved": true});
      batch.update(tripRef, {
        "savedBy": FieldValue.arrayUnion([userId])
      });
    } else {
      batch.delete(userTripRef);
      batch.update(tripRef, {
        "savedBy": FieldValue.arrayRemove([userId])
      });
    }

    await batch.commit();
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
            child: Container(
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
              ),
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
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: _toggleSave,
              icon: Icon(
                isSaved ? Icons.bookmark : Icons.bookmark_outline,
                color: isSaved ? Colors.white : Colors.white,
                size: 25,
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Container(
            height: 1500,
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.58,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black38,
                        offset: Offset(0, 5),
                        blurRadius: 7,
                        spreadRadius: 1,
                      ),
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
                                                fontWeight: FontWeight.bold,
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
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
                                                  widget.trip.rate.toString(),
                                                  style: const TextStyle(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              '(${widget.trip.review} reviews)',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.54,
                          child: const TabBar(
                            labelColor: blueTextColor,
                            labelStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            unselectedLabelColor: Colors.black,
                            indicatorColor: blueTextColor,
                            dividerColor: Colors.transparent,
                            tabs: [
                              Tab(text: 'Overview'),
                              Tab(text: 'Review'),
                            ],
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            widget.trip.des,
                                            maxLines: 3,
                                            style: const TextStyle(
                                              color: Colors.black54,
                                              fontSize: 14,
                                              height: 1.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 7,),
                                    Container(
                                        width: double.infinity,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Trip Category : ",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                            ),
                                            Expanded(
                                              child: Text(
                                                widget.trip.tripCategory,
                                                maxLines: 3,
                                                style: const TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 14,
                                                  height: 1.5,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )),
                                    SizedBox(height: 7,),
                                    Divider(),
                                    SizedBox(height: 7,),
                                    Container(
                                      width: double.infinity,
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Transportation : ",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          ),
                                          Expanded(
                                            child: Text(
                                              widget.trip.transportation,
                                              maxLines: 3,
                                              style: const TextStyle(
                                                color: Colors.black54,
                                                fontSize: 14,
                                                height: 1.5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ),
                                    SizedBox(height: 7,),
                                    Container(
                                        width: double.infinity,
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Accommodation : ",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                            ),
                                            Expanded(
                                              child: Text(
                                                widget.trip.accommodation,
                                                maxLines: 3,
                                                style: const TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 14,
                                                  height: 1.5,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                    ),
                                    SizedBox(height: 7,),
                                    Container(
                                        width: double.infinity,
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Included Service : ",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                            ),
                                            Expanded(
                                              child: Text(
                                                widget.trip.includedServices,
                                                maxLines: 3,
                                                style: const TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 14,
                                                  height: 1.5,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                    ),
                                    SizedBox(height: 7,),
                                    Container(
                                        width: double.infinity,
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Meeting Point : ",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                            ),
                                            Expanded(
                                              child: Text(
                                                widget.trip.meetingPoint,
                                                maxLines: 3,
                                                style: const TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 14,
                                                  height: 1.5,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                    ),
                                    Divider(),
                                    // Container(
                                    //     width: double.infinity,
                                    //     child: Row(
                                    //       mainAxisAlignment:
                                    //       MainAxisAlignment.start,
                                    //       children: [
                                    //         Text(
                                    //           "Mobile Number : ",
                                    //           style: TextStyle(
                                    //               fontWeight: FontWeight.bold,
                                    //               color: Colors.black),
                                    //         ),
                                    //         Expanded(
                                    //           child: Text(
                                    //             widget.trip.contactInfo,
                                    //             maxLines: 3,
                                    //             style: const TextStyle(
                                    //               color: Colors.black54,
                                    //               fontSize: 14,
                                    //               height: 1.5,
                                    //             ),
                                    //           ),
                                    //         ),
                                    //       ],
                                    //     )
                                    // ),
                                    // SizedBox(height: 7,),
                                    // Container(
                                    //     width: double.infinity,
                                    //     child: Row(
                                    //       mainAxisAlignment:
                                    //       MainAxisAlignment.start,
                                    //       children: [
                                    //         Text(
                                    //           "Whatsapp Number : ",
                                    //           style: TextStyle(
                                    //               fontWeight: FontWeight.bold,
                                    //               color: Colors.black),
                                    //         ),
                                    //         Expanded(
                                    //           child: Text(
                                    //             widget.trip.whatsappInfo,
                                    //             maxLines: 3,
                                    //             style: const TextStyle(
                                    //               color: Colors.black54,
                                    //               fontSize: 14,
                                    //               height: 1.5,
                                    //             ),
                                    //           ),
                                    //         ),
                                    //       ],
                                    //     )
                                    // ),
                                    //Divider(),
                                    // Container(
                                    //     width: double.infinity,
                                    //     child: Row(
                                    //       mainAxisAlignment:
                                    //       MainAxisAlignment.start,
                                    //       children: [
                                    //         Text(
                                    //           "Items to Brings : ",
                                    //           style: TextStyle(
                                    //               fontWeight: FontWeight.bold,
                                    //               color: Colors.black),
                                    //         ),
                                    //         Expanded(
                                    //           child: Text(
                                    //             widget.trip.itemsToBring,
                                    //             maxLines: 3,
                                    //             style: const TextStyle(
                                    //               color: Colors.black54,
                                    //               fontSize: 14,
                                    //               height: 1.5,
                                    //             ),
                                    //           ),
                                    //         ),
                                    //       ],
                                    //     )
                                    // ),
                                    // SizedBox(height: 7,),
                                    // Container(
                                    //     width: double.infinity,
                                    //     child: Row(
                                    //       mainAxisAlignment:
                                    //       MainAxisAlignment.start,
                                    //       children: [
                                    //         Text(
                                    //           "Guidlines : ",
                                    //           style: TextStyle(
                                    //               fontWeight: FontWeight.bold,
                                    //               color: Colors.black),
                                    //         ),
                                    //         Expanded(
                                    //           child: Text(
                                    //             widget.trip.guidelines,
                                    //             maxLines: 3,
                                    //             style: const TextStyle(
                                    //               color: Colors.black54,
                                    //               fontSize: 14,
                                    //               height: 1.5,
                                    //             ),
                                    //           ),
                                    //         ),
                                    //       ],
                                    //     )
                                    // ),
                                    // SizedBox(height: 7,),
                                    // Container(
                                    //     width: double.infinity,
                                    //     child: Row(
                                    //       mainAxisAlignment:
                                    //       MainAxisAlignment.start,
                                    //       children: [
                                    //         Text(
                                    //           "Cancellation Policy : ",
                                    //           style: TextStyle(
                                    //               fontWeight: FontWeight.bold,
                                    //               color: Colors.black),
                                    //         ),
                                    //         Expanded(
                                    //           child: Text(
                                    //             widget.trip.cancellationPolicy,
                                    //             maxLines: 3,
                                    //             style: const TextStyle(
                                    //               color: Colors.black54,
                                    //               fontSize: 14,
                                    //               height: 1.5,
                                    //             ),
                                    //           ),
                                    //         ),
                                    //       ],
                                    //     )
                                    // ),
                                  ],
                                ),
                              ),
                              const Center(
                                child: Text('No Review yet'),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
                            fontSize: 23,
                            fontWeight: FontWeight.w600,
                            color: blueTextColor,
                          ),
                        ),
                        TextSpan(
                          text: ' /Person',
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.6),
                            fontSize: 16,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Color(0xFF134277)),
                child: const Row(
                  children: [
                    Icon(
                      Icons.confirmation_number_outlined,
                      color: Colors.white,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Add to Cart",
                      style: TextStyle(
                        fontSize: 20,
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
}
