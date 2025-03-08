import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../const.dart';
import 'booking_confirm.dart';



class AddToCartPage extends StatefulWidget {
  @override
  _AddToCartPageState createState() => _AddToCartPageState();
}

class _AddToCartPageState extends State<AddToCartPage> {

  final String userId = FirebaseAuth.instance.currentUser!.uid;
  double totalAmount = 0.0;

  bool isLoading = false;

  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }


  void _calculateTotalPrice() async {
    double newTotal = 0.0;

    QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
        .collection('cart')
        .doc(userId)
        .collection('cartItems')
        .get();

    for (var doc in cartSnapshot.docs) {
      newTotal += (doc['totalPrice'] ?? 0.0) as double;
    }

    setState(() {
      totalAmount = newTotal; // Update totalAmount inside setState()
    });
  }


  void updatePersons(String tripId, double tripFee, bool increase) async {
    DocumentReference tripRef = FirebaseFirestore.instance
        .collection('cart')
        .doc(userId)
        .collection('cartItems')
        .doc(tripId);

    DocumentSnapshot tripSnapshot = await tripRef.get();

    if (tripSnapshot.exists) {
      int currentPersons = (tripSnapshot['persons'] ?? 1) as int;
      int newPersons = increase ? currentPersons + 1 : currentPersons - 1;

       tripRef.update({
          'persons': newPersons,
          'totalPrice': newPersons * tripFee,
        });
      _calculateTotalPrice(); // Call this after updating Firestore
    }
  }


  void removeFromCart(String tripId) async {
    await FirebaseFirestore.instance
        .collection('cart')
        .doc(userId)
        .collection('cartItems')
        .doc(tripId)
        .delete();

    _calculateTotalPrice(); // Update total price after removal
  }

  //razorpay
  void openRazorpay(double amount) {
    setState(() {
      isLoading = true; // Show loading before opening Razorpay
    });

    var options = {
      'key': 'rzp_test_9W0xsGjR3cnBpw',  // ⚠️ Replace with your actual Razorpay API Key
      'amount': (amount * 100).toInt(),  // Convert amount to paisa
      'currency': 'INR',
      'name': 'GoBuddy Travel',
      'description': 'Trip Payment',
      'prefill': {
        'contact': '7201821370',  // ⚠️ Replace with actual user contact
        'email': 'gobuddy@example.com',  // ⚠️ Replace with actual user email
      },
      'theme': {'color': '#134277'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print('Error opening Razorpay: $e');
      setState(() {
        isLoading = false; // Hide loading on error
      });
    }
  }


  String generateBookingId(Set<String> existingIds) {
    String newId;
    do {
      int randomNum = Random().nextInt(90000) + 10000; // Generate a 5-digit number (10000-99999)
      newId = "#GB$randomNum"; // Add #GB prefix
    } while (existingIds.contains(newId)); // Ensure uniqueness

    return newId;
  }

  Future<void> storePaidTrips(BuildContext context) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference cartRef = FirebaseFirestore.instance
        .collection('cart')
        .doc(userId)
        .collection('cartItems');

    try {
      QuerySnapshot pendingTrips =
      await cartRef.where('status', isEqualTo: 'Pending').get();

      if (pendingTrips.docs.isEmpty) {
        print("No pending trips found.");
        return;
      }

      double totalFee = 0;
      List<Map<String, dynamic>> tripDetails = [];

      // Fetch existing booking IDs to ensure uniqueness
      QuerySnapshot existingBookings = await FirebaseFirestore.instance
          .collection('booked_trip')
          .doc(userId)
          .collection('bookings')
          .get();

      Set<String> existingIds = existingBookings.docs.map((doc) => doc.id).toSet();

      String bookingId = generateBookingId(existingIds);

      for (var doc in pendingTrips.docs) {
        Map<String, dynamic> tripData = doc.data() as Map<String, dynamic>;
        await cartRef.doc(doc.id).update({'status': 'Paid'});

        totalFee += tripData['totalPrice'];

        tripDetails.add({
          'tripId': doc.id,
          'title': tripData['title'],
          'destination': tripData['destination'],
          'tripFee': tripData['tripFee'],
          'person': tripData['persons'],
          'totalPrice': tripData['totalPrice'],
          'firstImage': tripData['imageUrl'],
          'status': 'Paid',
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      DocumentReference bookingDoc = FirebaseFirestore.instance
          .collection('booked_trip')
          .doc(userId)
          .collection('bookings')
          .doc(bookingId);

      await bookingDoc.set({
        'bookingId': bookingId,
        'userId': userId,
        'totalFee': totalFee,
        'paymentStatus': 'Paid',
        'bookingDate': FieldValue.serverTimestamp(),
      });

      CollectionReference tripsCollection = bookingDoc.collection('trips');

      for (var trip in tripDetails) {
        await tripsCollection.doc(trip['tripId']).set(trip);
      }

      print("Trips stored with bookingId: $bookingId");

      // Navigate to confirmation screen
      Navigator.push(context, MaterialPageRoute(builder: (context) => BookingConfirmationScreen()));

      // Clear cart after storing booked trips
      for (var doc in pendingTrips.docs) {
        await cartRef.doc(doc.id).delete();
      }
    } catch (e) {
      print("Error storing booked trips: $e");
    }
  }


  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() {
      isLoading = true; // Show loading while processing payment
    });

    try {
      await storePaidTrips(context); // Store paid trips in booked_trip collection

      setState(() {
        isLoading = false; // Hide loading after completing process
      });

      // Navigate to the Booking Confirmation Page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BookingConfirmationScreen()),
      );
    } catch (e) {
      setState(() {
        isLoading = false; // Hide loading on error
      });
      print("Error processing payment: $e");
    }
  }


  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(msg: "Payment Failed: ${response.message}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: "External Wallet Selected: ${response.walletName}");
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text("Your Cart", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF134277),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('cart')
            .doc(userId)
            .collection('cartItems')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("Your cart is empty.",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey)),
                ],
              ),
            );
          }

          var cartItems = snapshot.data!.docs.map((doc) => doc.data()).toList();
          double totalAmount = cartItems.fold(0, (sum, item) => sum + (item['totalPrice'] ?? 0));

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final cart = cartItems[index];

                    return Card(
                      color: Colors.white,
                      elevation: 2,
                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: cart['imageUrl'] != null && cart['imageUrl'].isNotEmpty
                                  ? Image.network(
                                cart['imageUrl'],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              )
                                  : Icon(Icons.image, size: 80, color: Colors.grey),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(cart['title'] ?? "No Title", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                                  SizedBox(height: 5),
                                  Text(cart['destination'] ?? "Unknown Location", style: TextStyle(color: Colors.grey[600])),
                                  SizedBox(height: 5),
                                  Text('₹${cart['tripFee']?.toStringAsFixed(2) ?? '0.00'}/person',
                                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: cart['tripId'] != null ? () => removeFromCart(cart['tripId']) : null,
                                    ),
                                  ],
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.2),  // Background color
                                    borderRadius: BorderRadius.circular(15), // Rounded corners
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.remove, color: Colors.red),
                                        onPressed: cart['tripId'] != null
                                            ? () => updatePersons(cart['tripId'], cart['tripFee'], false)
                                            : null,
                                      ),
                                      Text(cart['persons']?.toString() ?? '0',
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
                                      IconButton(
                                        icon: Icon(Icons.add, color: Colors.blue),
                                        onPressed: cart['tripId'] != null
                                            ? () => updatePersons(cart['tripId'], cart['tripFee'], true)
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),

                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.all(8),
                width: MediaQuery.of(context).size.width,
                child: Card(
                  color: Colors.white,
                  margin: EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Price', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                            Text('₹ ${totalAmount.toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 24, color: Colors.blueAccent, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        SizedBox(height: 20,),
                        isLoading
                            ? Center(child: CircularProgressIndicator())
                            : Container(
                              height: 60,
                              width: MediaQuery.of(context).size.width*0.90,
                              child: ElevatedButton(
                              onPressed: () {
                                openRazorpay(totalAmount);  // Pass the total amount
                              },
                              child: Text('Proceed to Payment', style: TextStyle(fontSize: 18, color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF134277),
                              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),

                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),

    );
  }
}
