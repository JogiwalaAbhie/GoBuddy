import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gobuddy/pages/booking_confirm.dart';import 'package:gobuddy/pages/place_detail.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../const.dart';
import '../models/map_service.dart';
import '../models/travel_model.dart';

class UserTripsDetails extends StatefulWidget {
  final Trip trip;

  const UserTripsDetails({required this.trip});

  @override
  State<UserTripsDetails> createState() => _UserTripsDetailsState();
}

class _UserTripsDetailsState extends State<UserTripsDetails> {


  PageController pageController = PageController();
  int pageView = 0;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? userId = FirebaseAuth.instance.currentUser?.uid;

  bool isSaved = false;

  bool _isLoading = false; // ✅ Loading state

  Trip? trip;

  Map<String, dynamic>? hostData;

  LatLng? _destinationLocation;

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

  void shareTrip() {

    String tripDetails = '''
📌 Destination: ${widget.trip.location}
🗓  Start Date: ${widget.trip.startDate != null ? widget.trip.startDate!.toLocal().toString().split(' ')[0] : "Not provided"}
🏁 End Date: ${widget.trip.endDate != null ? widget.trip.endDate!.toLocal().toString().split(' ')[0] : "Not provided"}
🕒 Duration: ${widget.trip.daysOfTrip} days
💰 Approx Price: \Rs. ${widget.trip.approxCost}
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

  Future<void> _fetchDestination() async {
    try {
      LatLng? location =
      await MapService.fetchCoordinates("${widget.trip.location}, India");

      if (mounted) {
        if (location != null) {
          setState(() {
            _destinationLocation = location;
          });

          // ✅ Move map to new location
          MapService.mapController.move(location, 7.0);
        } else {
          if (mounted) {
            setState(() {
              print("Location not found.");
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          print("Error in _fetchDestination: $e");
        });
      }
    }
  }

  void _openGoogleMaps() async {
    final googleMapsUrl =
        "https://www.google.com/maps?q=${_destinationLocation!.latitude},${_destinationLocation!.longitude}";

    final Uri uri = Uri.parse(googleMapsUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not open Google Maps.");
    }
  }

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

  @override
  void initState() {
    super.initState();
    //_fetchTripAndState();
    _fetchHostDetails();
    //_fetchTripRatings();
    _fetchDestination();
    //_api = GeminiApi(apiKey);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            color: Colors.white,
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
                    Icon(Icons.share, color: Color(0xFF134277)),
                    SizedBox(width: 8),
                    Text("Share"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.report, color: Color(0xFF134277)),
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
                              (index) => CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl: widget.trip.image[index],
                                placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) => Icon(Icons.error, size: 40, color: Colors.red),
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
                                border: Border.all(width: 2, color: Colors.white),
                                borderRadius: BorderRadius.circular(15),
                                image: DecorationImage(
                                  image: CachedNetworkImageProvider(
                                    widget.trip.image.length - 1 != pageView
                                        ? widget.trip.image[pageView + 1]
                                        : widget.trip.image[0],
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
                                  const SizedBox(height: 10),
                                  Wrap(
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.trip.location,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            widget.trip.tripCategory,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
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
              SizedBox(height: 15,),
              //startdate and enddate
              Container(
                width: MediaQuery.of(context).size.width, // Ensures layout constraints
                child: Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue),
                        ),
                        child: Column(
                          children: [
                            Text("Start Date", style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 5),
                            Text(widget.trip.startDate?.toLocal().toString().split(' ')[0] ?? 'N/A',
                                style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 14), // Space between containers
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Column(
                          children: [
                            Text("End Date", style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 5),
                            Text(widget.trip.endDate?.toLocal().toString().split(' ')[0] ?? 'N/A',
                                style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Trip Overview
                    Text(
                      "Overview : ",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      widget.trip.tripoverview,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 12),
                    Divider(),
                    // Itinerary Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Itinerary:",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                          ),
                        ),
                        SizedBox(height: 12),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: widget.trip.itinerary.length,
                          itemBuilder: (context, index) {
                            return Card(
                              color: Colors.white,
                              elevation: 2, // Soft shadow
                              margin: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                leading: CircleAvatar(
                                  backgroundColor: Color(0xFF134277),
                                  child: Text(
                                    "${index + 1}",
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Text(
                                  "Day ${index + 1}",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                                ),
                                subtitle: Text(
                                  widget.trip.itinerary[index],
                                  style: TextStyle(fontSize: 14, color: Colors.black54),
                                ),
                              ),
                            );
                          },
                        ),

                      ],
                    ),
                    Divider(),
                    // Host Information Card
                    Card(
                      color: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Row(
                              children: [
                                Text(
                                  "Get In Touch : ",
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),

                            // Host Profile Picture & Name
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 35,
                                      backgroundImage: hostData?['profilePic'] != null
                                          ? NetworkImage(hostData!['profilePic'])
                                          : null,
                                      child: hostData?['profilePic'] == null
                                          ? Icon(Icons.person, color: Colors.grey[700], size: 30)
                                          : null,
                                    ),
                                    SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          hostData?['username'] ?? "Loading...",
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          "The Host",
                                          style: TextStyle(fontSize: 15, color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: openWhatsApp,
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.3),
                                              spreadRadius: 2,
                                              blurRadius: 5,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Image.asset('assets/image/wp.png', height: 30, width: 30),
                                        ),
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

                    SizedBox(height: 10),

                    // Map Section with Google Maps Button
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 2,
                                spreadRadius: 2,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: SizedBox(
                              height: 300,
                              child: _destinationLocation != null
                                  ? FlutterMap(
                                options: MapOptions(
                                  initialCenter: _destinationLocation!,
                                  initialZoom: 7.0,
                                  interactionOptions: InteractionOptions(flags: InteractiveFlag.all),
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate: "https://tile.thunderforest.com/outdoors/{z}/{x}/{y}.png?apikey=7d2cbd26e9dd49fa990aa14f7a46e329",
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      if (_destinationLocation != null)
                                        Marker(
                                          width: 60.0,
                                          height: 60.0,
                                          point: _destinationLocation!, // Ensure it's not null before using
                                          child: Icon(Icons.location_pin, color: Colors.red, size: 40),
                                        )
                                    ],
                                  ),
                                ],
                              )
                                  : Center(child: CircularProgressIndicator()),
                            ),
                          ),
                        ),

                        /// **Location Icon Positioned at Top-Right**
                        Positioned(
                          top: 10,
                          right: 10,
                          child: GestureDetector(
                            onTap: () {
                              _openGoogleMaps();
                            },
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.location_on,
                                color: Colors.blue, // Change color as needed
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 90,
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
                vertical: 15,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Approx Cost",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '\₹ ${widget.trip.approxCost}',
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
              onPressed: _isLoading ? null : () => _joinTrip(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: const Color(0xFF134277),
                ),
                child: _isLoading
                    ? SizedBox(
                  width: 120, // Same width as the button content
                  height: 26, // Matches text & icon height
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                ) // ✅ Loader with same button dimensions
                    : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.confirmation_number_outlined,
                      color: Colors.white,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Join Now",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ), // ✅ Show original button when not loading
              ),
            ),

          ],
        ),
      ),
    );
  }

  Future<void> _joinTrip(BuildContext context) async {
    if (_isLoading) return; // Prevent multiple clicks
    setState(() => _isLoading = true); // Start loading

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("You need to log in first!"))
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      // ✅ Fetch user's phone number from Firestore
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      String phoneNumber = userSnapshot.get("phone") ?? "";

      // ✅ Validate and format phone number
      phoneNumber = _formatPhoneNumber(phoneNumber);
      if (phoneNumber.isEmpty) {
        print("❌ Invalid or missing phone number.");
      }

      // ✅ Reference to the trip document
      DocumentReference tripRef = FirebaseFirestore.instance.collection("trips").doc(widget.trip.id);

      // ✅ Add the current user's UID to the "joinedBy" array
      await tripRef.update({
        "joinedBy": FieldValue.arrayUnion([user.uid])
      });

      // ✅ Fetch trip details
      DocumentSnapshot tripSnapshot = await tripRef.get();

      String destination = tripSnapshot.get("destination") ?? "Unknown Destination";
      String startDate = tripSnapshot.get("startDate") ?? "N/A";
      String endDate = tripSnapshot.get("endDate") ?? "N/A";
      int daysOfTrip = tripSnapshot.get("daysOfTrip") ?? 0;
      double approxCost = (tripSnapshot.get("approxCost") as num).toDouble();

      List itineraryList = tripSnapshot.get("itinerary") ?? [];
      String itinerary = itineraryList.isNotEmpty
          ? itineraryList.join("\n- ")  // Format itinerary as a list
          : "Itinerary details will be shared soon.";


      await _sendConfirmationEmail(user.email!, destination, startDate, endDate, daysOfTrip, approxCost, itinerary);


      // ✅ Navigate to Confirmation Page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserTripConfirmationPage(tripId: widget.trip.id),
        ),
      );
    } catch (e) {
      print("❌ Error joining trip: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to join trip. Try again!"))
      );
    }

    setState(() => _isLoading = false); // Stop loading
  }

  // ✅ Function to format phone number correctly
  String _formatPhoneNumber(String phone) {
    if (phone.isEmpty) return "";
    if (!phone.startsWith("+")) {
      phone = "+91$phone"; // Assuming India (+91), modify as needed
    }
    return phone;
  }

  Future<void> _sendConfirmationEmail(String userEmail, String destination, String startDate, String endDate, int daysOfTrip, double approxCost, String itinerary) async {
    String username = "abhie.jogiwala.1435@gmail.com"; // Your Gmail address
    String password = "psiv vtva vaui thlv"; // Use a valid App Password

    final smtpServer = SmtpServer(
      'smtp.gmail.com',
      port: 587, // TLS
      username: username,
      password: password,
      ssl: false,
      allowInsecure: true,
    );

    // ✅ Convert and format dates
    String formattedStartDate = _formatDate(startDate);
    String formattedEndDate = _formatDate(endDate);

    final message = Message()
      ..from = Address(username, "GoBuddy")
      ..recipients.add(userEmail)
      ..subject = "Trip Joined - GoBuddy 🎉"
      ..text = """
Hey! 🎉

You have successfully joined the trip: $destination. Here are the details:

🌍 Destination: $destination  
📅 Start Date: $formattedStartDate  
📅 End Date: $formattedEndDate  
⏳ Days of Trip: $daysOfTrip  
💰 Approximate Cost: ₹$approxCost  

📜 Itinerary:  
- $itinerary  

Best regards,  
GoBuddy Team
""";

    try {
      final sendReport = await send(message, smtpServer);
      print("Email sent successfully: ${sendReport.toString()}");
    } catch (e) {
      print("❌ Failed to send email: $e");
    }
  }

// ✅ Function to Format Dates
  String _formatDate(String dateStr) {
    try {
      DateTime date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date); // Example: 22 Mar 2025
    } catch (e) {
      print("❌ Error formatting date: $e");
      return dateStr; // Return original if parsing fails
    }
  }

}


