import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../models/travel_model.dart';
import 'booking_confirm.dart';
import 'package:http/http.dart' as http;

class PlaceDetailsScreen2 extends StatefulWidget {
  final Trip trip;
  PlaceDetailsScreen2({required this.trip});

  @override
  _PlaceDetailsScreen2State createState() => _PlaceDetailsScreen2State();
}

class _PlaceDetailsScreen2State extends State<PlaceDetailsScreen2> {
  int _adults = 0;
  int _children = 0;
  late Razorpay _razorpay;

  String? bookingId;

  bool _isLoading = false;

  String? errmsg;

  List<Map<String, String>> _participants = [];


  // Function to automatically create participant forms
  List<Widget> _buildParticipantForms() {
    List<Widget> forms = [];
    int totalParticipants = _adults + _children;

    // Ensure the _participants list has enough elements
    while (_participants.length < totalParticipants) {
      _participants.add({});
    }

    for (int i = 0; i < totalParticipants; i++) {
      forms.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Card(
            color: Colors.white,
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Participant ${i + 1}", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18)),
                  SizedBox(height: 15),
                  // Name Field
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: "Name : ",
                      border: InputBorder.none,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFBFCFF3), width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF134277), width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red, width: 1),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    ),
                    onChanged: (value) {
                      _participants[i]['name'] = value;
                    },
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter the name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  // Age Field
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: "Age : ",
                      border: InputBorder.none,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFBFCFF3), width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF134277), width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red, width: 1),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _participants[i]['age'] = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the age';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Age must be a number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  // Phone Number Field
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: "Phone Number : ",
                      border: InputBorder.none,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFBFCFF3), width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF134277), width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red, width: 1),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    ),
                    keyboardType: TextInputType.phone,
                    onChanged: (value) {
                      _participants[i]['phone'] = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the phone number';
                      }
                      if (value.length != 10) {
                        return 'Phone number must be 10 digits';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  // Gender Selection
                  Text("Gender", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _participants[i]['gender'] = 'Male';
                          });
                        },
                        child: Row(
                          children: [
                            Radio(
                              value: 'Male',
                              groupValue: _participants[i]['gender'],
                              onChanged: (value) {
                                setState(() {
                                  _participants[i]['gender'] = value!;
                                });
                              },
                            ),
                            Text("Male"),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _participants[i]['gender'] = 'Female';
                          });
                        },
                        child: Row(
                          children: [
                            Radio(
                              value: 'Female',
                              groupValue: _participants[i]['gender'],
                              onChanged: (value) {
                                setState(() {
                                  _participants[i]['gender'] = value!;
                                });
                              },
                            ),
                            Text("Female"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return forms;
  }


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

  Future<void> sendInvoiceEmail(String bookingId) async {
    try {
      print("📧 Sending invoice email for booking: $bookingId");
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Fetch User Details
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection("users").doc(userId).get();
      if (!userSnapshot.exists) return;

      String userEmail = userSnapshot["email"];
      String userName = userSnapshot["username"];
      String userPhone = userSnapshot["phone"];

      // Fetch Booking Details
      DocumentSnapshot bookingSnapshot = await FirebaseFirestore.instance
          .collection("booked_trip")
          .doc(bookingId)
          .get();
      if (!bookingSnapshot.exists) return;

      String destination = bookingSnapshot["destination"];
      String from = bookingSnapshot["from"];
      String to = bookingSnapshot["to"];
      int adults = bookingSnapshot["adults"];
      int children = bookingSnapshot["children"];
      double totalAmount = bookingSnapshot["totalAmount"];

      // Fixing Timestamp conversion
      DateTime bookingTime;
      if (bookingSnapshot["timestamp"] is Timestamp) {
        bookingTime = (bookingSnapshot["timestamp"] as Timestamp).toDate();
      } else {
        bookingTime = DateTime.parse(bookingSnapshot["timestamp"]);
      }

      // Fetch Participants
      List<dynamic> participants = bookingSnapshot["participants"] ?? [];

      // Fetch Trip ID from Booking
      String tripId = bookingSnapshot["tripId"];

      // Fetch Trip Details using tripId
      DocumentSnapshot tripSnapshot = await FirebaseFirestore.instance
          .collection("trips")
          .doc(tripId)
          .get();
      if (!tripSnapshot.exists) return;

      DateTime startDateTime;
      if (tripSnapshot["startDateTime"] is Timestamp) {
        startDateTime = (tripSnapshot["startDateTime"] as Timestamp).toDate();
      } else {
        startDateTime = DateTime.parse(tripSnapshot["startDateTime"]);
      }

      DateTime endDateTime;
      if (tripSnapshot["endDateTime"] is Timestamp) {
        endDateTime = (tripSnapshot["endDateTime"] as Timestamp).toDate();
      } else {
        endDateTime = DateTime.parse(tripSnapshot["endDateTime"]);
      }

      int daysOfTrip = endDateTime.difference(startDateTime).inDays + 1;

      String meetingPoint = tripSnapshot["meetingPoint"];
      String transportation = tripSnapshot["transportation"];
      String accommodation = tripSnapshot["accommodation"];
      String cancellationPolicy = tripSnapshot["cancellationPolicy"];
      String guidelines = tripSnapshot["guidelines"];
      List includedServices = tripSnapshot["includedServices"];

      // Generate PDF Invoice
      File pdfFile = await generateInvoicePDF(
        bookingId,
        userName,
        userEmail,
        userPhone,
        adults,
        children,
        totalAmount,
        bookingTime,
        destination,
        from,
        to,
        startDateTime,
        endDateTime,
        daysOfTrip,
        meetingPoint,
        transportation,
        accommodation,
        includedServices,
        cancellationPolicy,
        guidelines,
        participants, // Add participants list here
      );

      print("📎 PDF generated: ${pdfFile.path}");

      // Send Email with PDF
      await sendEmailWithAttachment(userEmail, bookingId, pdfFile);
    } catch (e) {
      print("❌ Error: $e");
    }
  }


  Future<File> generateInvoicePDF(
      String bookingId,
      String userName,
      String userEmail,
      String userPhone,
      int adults,
      int children,
      double totalAmount,
      DateTime bookingTime,
      String destination,
      String from,
      String to,
      DateTime startDateTime,
      DateTime endDateTime,
      int daysOfTrip,
      String meetingPoint,
      String transportation,
      String accommodation,
      List<dynamic> includedServices,
      String cancellationPolicy,
      String guidelines,
      List<dynamic> participants, // Add participants parameter
      ) async {
    final pdf = pw.Document();

    final customFont = pw.Font.ttf(await rootBundle.load("assets/fonts/Rubik-Medium.ttf"));
    final emojiFont = pw.Font.ttf(await rootBundle.load("assets/fonts/NotoColorEmoji-Regular.ttf"));

    final formattedBookingTime = DateFormat('dd-MM-yyyy • hh:mm a').format(bookingTime);
    final formattedStartDate = DateFormat('dd-MM-yyyy • hh:mm a').format(startDateTime);
    final formattedEndDate = DateFormat('dd-MM-yyyy • hh:mm a').format(endDateTime);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 2)),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Container(
                  padding: pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(color: PdfColors.blue900),
                  child: pw.Text(
                    "GoBuddy - Trip Invoice",
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                      font: customFont,
                      fontFallback: [emojiFont],
                    ),
                  ),
                ),
                pw.SizedBox(height: 10),

                // Booking & User Details
                pw.Text(" •  Booking ID: $bookingId", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, font: customFont, fontFallback: [emojiFont])),
                pw.Text(" •  Booking Time: $formattedBookingTime", style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.normal, font: customFont, fontFallback: [emojiFont])),
                pw.Divider(),
                pw.SizedBox(height: 10),
                pw.Text("Name: $userName", style: pw.TextStyle(fontSize: 12, font: customFont, fontFallback: [emojiFont])),
                pw.Text("Email: $userEmail", style: pw.TextStyle(fontSize: 12, font: customFont, fontFallback: [emojiFont])),
                pw.Text("Phone: $userPhone", style: pw.TextStyle(fontSize: 12, font: customFont, fontFallback: [emojiFont])),

                pw.SizedBox(height: 20),

                // Trip Details
                pw.Text("• Trip Details:", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.green800, font: customFont, fontFallback: [emojiFont])),
                pw.SizedBox(height: 5),
                pw.Text(" Destination: $destination", style: pw.TextStyle(fontSize: 12, font: customFont, fontFallback: [emojiFont])),
                pw.Text(" From: $from", style: pw.TextStyle(fontSize: 12, font: customFont, fontFallback: [emojiFont])),
                pw.Text(" To: $to", style: pw.TextStyle(fontSize: 12, font: customFont, fontFallback: [emojiFont])),
                pw.Text(" Start Date: $formattedStartDate", style: pw.TextStyle(fontSize: 12, font: customFont, fontFallback: [emojiFont])),
                pw.Text(" End Date: $formattedEndDate", style: pw.TextStyle(fontSize: 12, font: customFont, fontFallback: [emojiFont])),
                pw.Text(" Days of Trip: $daysOfTrip", style: pw.TextStyle(fontSize: 12, font: customFont, fontFallback: [emojiFont])),
                pw.Text(" Meeting Point: $meetingPoint", style: pw.TextStyle(fontSize: 12, font: customFont, fontFallback: [emojiFont])),
                pw.Text(" Transportation: $transportation", style: pw.TextStyle(fontSize: 12, font: customFont, fontFallback: [emojiFont])),
                pw.Text(" Accommodation: $accommodation", style: pw.TextStyle(fontSize: 12, font: customFont, fontFallback: [emojiFont])),
                pw.SizedBox(height: 10),

                // **Participants**
                pw.Text("• Participants:", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800, font: customFont, fontFallback: [emojiFont])),
                pw.SizedBox(height: 5),
                for (var participant in participants)
                  pw.Text("Name: ${participant['name']}, Age: ${participant['age']}, Phone: ${participant['phone']}", style: pw.TextStyle(fontSize: 10, font: customFont, fontFallback: [emojiFont])),

                pw.SizedBox(height: 10),

                // Total Price
                pw.Container(
                  padding: pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(color: PdfColors.orange900),
                  child: pw.Text(
                    "Total Price: ₹ ${totalAmount.toStringAsFixed(2)}",
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.white, font: customFont, fontFallback: [emojiFont]),
                  ),
                ),
                pw.SizedBox(height: 10),

                // Services
                pw.Text(" • Included Services:", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, font: customFont, fontFallback: [emojiFont])),
                pw.SizedBox(height: 5),
                pw.Text(includedServices.join(", "), style: pw.TextStyle(fontSize: 10, font: customFont, fontFallback: [emojiFont])),
                pw.SizedBox(height: 10),

                // Cancellation Policy and Guidelines
                pw.Text(" • Cancellation Policy:", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, font: customFont, fontFallback: [emojiFont])),
                pw.SizedBox(height: 5),
                pw.Text(cancellationPolicy, style: pw.TextStyle(fontSize: 10, font: customFont, fontFallback: [emojiFont])),
                pw.SizedBox(height: 10),

                pw.Text(" • Guidelines:", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, font: customFont, fontFallback: [emojiFont])),
                pw.SizedBox(height: 5),
                pw.Text(guidelines, style: pw.TextStyle(fontSize: 10, font: customFont, fontFallback: [emojiFont])),

                pw.SizedBox(height: 10),

                // Payment Success
                pw.Text(
                  "✅ Payment Successful via Razorpay",
                  style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.green800, font: customFont, fontFallback: [emojiFont]),
                ),
              ],
            ),
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/invoice_$bookingId.pdf");
    await file.writeAsBytes(await pdf.save());
    return file;
  }




  Future<void> sendEmailWithAttachment(String recipientEmail, String bookingId, File pdfFile) async {
    final String senderEmail = "abhie.jogiwala.1435@gmail.com"; // Your Gmail
    final String appPassword = "psiv vtva vaui thlv"; // Use Google App Password

    final smtpServer = gmail(senderEmail, appPassword);

    final message = Message()
      ..from = Address(senderEmail, "GoBuddy")
      ..recipients.add(recipientEmail)
      ..subject = "Your Trip Invoice - Booking ID: $bookingId"
      ..text = """
Dear Traveler,

Thank you for booking your trip with GoBuddy! 🌍✈️  
We are excited to be part of your adventure and ensure you have a smooth and enjoyable journey.

📌 Booking Details:  
- Booking ID: $bookingId  
- Invoice: Please find your trip invoice attached to this email.  

🔹 What’s Next?  
- Trip Confirmation: Your booking is confirmed. Please keep this email for reference.  
- Meeting Point & Timing: Make sure to arrive at the designated meeting point on time.  
- Packing Tips: Carry essential items based on your destination's weather and activities.  

🤝 Need Assistance?  
If you have any questions or require support, feel free to reach out to us. Our support team is always available to assist you.  

📧 Email: support@gobuddy.com  
📞 Contact: +91 7201821370  

Thank you for choosing GoBuddy! We wish you a fantastic journey filled with beautiful experiences and memories.  

🚀 Safe Travels & Happy Exploring!  

Best Regards,  
GoBuddy Team  
""";

    // Attach the PDF Invoice
    message.attachments.add(FileAttachment(pdfFile));

    try {
      await send(message, smtpServer);
      print("✅ Invoice email sent successfully to $recipientEmail");
    } catch (e) {
      print("❌ Error sending email: $e");
    }
  }


  double getTotalPrice() {
    return (_adults + _children) * widget.trip.price;
  }

  void _proceedToPayment() {
    double totalPrice = getTotalPrice();
    if (totalPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select at least one person to proceed!")),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Start loading
    });

    var options = {
      'key': 'rzp_test_9W0xsGjR3cnBpw',
      'amount': (totalPrice * 100).toInt(), // Razorpay needs amount in paise
      'currency': 'INR',
      'name': "GoBuddy",
      'description': "Trip Booking for ${widget.trip.location}",
      'prefill': {
        'email': FirebaseAuth.instance.currentUser?.email ?? '',
        'contact': FirebaseAuth.instance.currentUser?.phoneNumber ?? '' // Replace with user phone number if available
      },
      'theme': {'color': "#134277"},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() {
        _isLoading = false; // Stop loading after Razorpay is triggered
      });
    }
  }
  // Add this in your class

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (_isLoading) return; // Prevent multiple clicks
    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? "";

      // 1️⃣ Get User Info
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection("users").doc(userId).get();
      if (!userDoc.exists || !(userDoc["notificationsEnabled"] ?? false)) return;

      String username = userDoc["username"];

      // ✅ Generate a unique booking ID (e.g., #GB12345)
      String bookingId = await _generateUniqueBookingId();

      // ✅ Add userId to the 'joinedBy' array in the 'trips' collection
      DocumentReference tripRef =
      FirebaseFirestore.instance.collection('trips').doc(widget.trip.id);

      await tripRef.update({
        'joinedBy': FieldValue.arrayUnion([userId]),
      });

      // ✅ Store trip details in 'booked_trip' collection with the unique booking ID
      DocumentReference bookingRef =
      FirebaseFirestore.instance.collection('booked_trip').doc(bookingId);

      await bookingRef.set({
        'bookingId': bookingId,
        'userId': userId,
        'tripId': widget.trip.id,
        'destination': widget.trip.location,
        'to': widget.trip.to,
        'from': widget.trip.from,
        'tripFee': widget.trip.price,
        'allImages': widget.trip.image, // Store all photos
        'adults': _adults,
        'children': _children,
        'participants': _participants,
        'totalAmount': getTotalPrice(),
        'startDateTime': widget.trip.startDateTime,
        'endDateTime': widget.trip.endDateTime,
        'timestamp': FieldValue.serverTimestamp(),
      });
      String tripDestination =  widget.trip.location;


      // ✅ Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment Successful! Booking ID: $bookingId")),
      );

      // ✅ Navigate to the Booking Confirmation Screen after a small delay
      await Future.delayed(Duration(seconds: 1));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BookingConfirmationScreen()),
      );

      // ✅ Print & send invoice email
      print("Generated Booking ID: $bookingId");
      await sendInvoiceEmail(bookingId);
      // 3️⃣ Get Admin Token
      QuerySnapshot adminSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .where("role", isEqualTo: "admin")
          .get();

      if (adminSnapshot.docs.isNotEmpty) {
        String? adminToken = adminSnapshot.docs.first["fcmToken"];

        if (adminToken != null) {
          await sendNotificationToAdmin(adminToken, username, tripDestination);
        }
      }
    } catch (e) {
      // Handle errors
      print("Error processing payment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment failed. Please try again.")),
      );
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

// Function to send FCM notification
  Future<void> sendNotificationToAdmin(String adminToken, String destination, String userName) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Fetch admin settings
    DocumentSnapshot adminDoc = await firestore.collection('users').doc(adminToken).get();
    bool isNotificationEnabled = adminDoc['notifications'] ?? true;

    if (!isNotificationEnabled) {
      print("Admin disabled notifications.");
      return;
    }

    String serverKey = 'YOUR_FIREBASE_SERVER_KEY'; // Replace with your actual server key

    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
      body: jsonEncode({
        'to': adminToken,
        'notification': {
          'title': 'New Trip Booking',
          'body': '$userName booked a trip to $destination',
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        },
        'data': {
          'type': 'trip_booking',
          'destination': destination,
          'userName': userName,
        },
      }),
    );

    print("Notification Sent: ${response.body}");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed! Try Again.")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("External Wallet Used: ${response.walletName}")),
    );
  }


  Future<String> _generateUniqueBookingId() async {
    String newBookingId = "";
    bool isUnique = false;
    Random random = Random();

    while (!isUnique) {
      // ✅ Generate a random 5-digit number
      int randomNum = 10000 + random.nextInt(90000); // Generates a number between 10000-99999
      newBookingId = "#GB$randomNum";

      // ✅ Check if this ID exists in Firestore
      DocumentSnapshot bookingSnapshot = await FirebaseFirestore.instance
          .collection('booked_trip')
          .doc(newBookingId)
          .get();

      if (!bookingSnapshot.exists) {
        isUnique = true; // ✅ Found a unique ID
      }
    }

    return newBookingId;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        title: Text("Trip Book Details", style: TextStyle(color: Colors.white)),
    backgroundColor: Color(0xFF134277),
    foregroundColor: Colors.white,
    ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trip Image & Details Card
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.trip.image.isNotEmpty ? widget.trip.image[0] : 'https://via.placeholder.com/150',
                        width: 120,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.trip.location, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                          SizedBox(height: 5,),
                          Text("From: ${widget.trip.from} → To: ${widget.trip.to}", style: TextStyle(fontSize: 14, color: Colors.grey)),
                          SizedBox(height: 5,),
                          Text("Price: \₹ ${widget.trip.price.toStringAsFixed(2)}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.green)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            // Adults & Children Counters
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                children: [
                  Expanded(child: _buildCounter("Children", _children, (value) => setState(() => _children = value))),
                  SizedBox(width: 12),
                  Expanded(child: _buildCounter("Adults", _adults, (value) => setState(() => _adults = value))),

                ],
              ),
            ),
            SizedBox(height: 10),
            // Display the forms after the children and adults counter
            if (_adults + _children > 0) ...[
              ..._buildParticipantForms(),
            ],
            // Trip Details
            Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Additional Details : ",style: TextStyle(fontWeight: FontWeight.w600,color: Colors.black,fontSize: 20),),
                    SizedBox(height: 5,),
                    Divider(),
                    SizedBox(height: 5,),
                    _buildDetailRow(Iconsax.calendar, "Days of Trip", widget.trip.daysOfTrip.toString()),
                    Divider(),
                    _buildDetailRow(Iconsax.location, "Meeting Point", widget.trip.meetingPoint),
                    Divider(),
                    _buildDetailRow(Iconsax.bus, "Transportation", widget.trip.transportation),
                    Divider(),
                    _buildDetailRow(Iconsax.buildings_2, "Accommodation", widget.trip.accommodation),
                    Divider(),
                    _buildDetailRow(Iconsax.tick_circle, "Included Services", widget.trip.includedServices.join(", ")),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: Card(
        color: Colors.white,
        margin: EdgeInsets.all(14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCalculationRow("Adults x $_adults", _adults * widget.trip.price),
              _buildCalculationRow("Children x $_children", _children * widget.trip.price),
              Divider(thickness: 1),
              _buildCalculationRow("Total", getTotalPrice(), isBold: true),
              SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    setState(() {
                      _isLoading = true; // Start loading
                    });

                    try {
                      // Fetch the trip's maxParticipants
                      DocumentSnapshot tripSnapshot = await FirebaseFirestore.instance
                          .collection("trips")
                          .doc(widget.trip.id)  // Make sure tripId is available
                          .get();

                      if (!tripSnapshot.exists) {
                        setState(() => _isLoading = false);
                        return;
                      }

                      int maxParticipants = tripSnapshot["maxParticipants"];

                      // Fetch the current bookings for this trip
                      QuerySnapshot bookingSnapshot = await FirebaseFirestore.instance
                          .collection("booked_trip")
                          .where("tripId", isEqualTo: widget.trip.id)
                          .get();

                      // Calculate the total number of participants
                      int totalParticipants = 0;
                      for (var booking in bookingSnapshot.docs) {
                        var participants = booking["participants"];
                        if (participants != null) {
                          totalParticipants += (participants.length as int);
                        }
                      }
                      bool isMaxParticipantsReached = totalParticipants >= maxParticipants;

                      // Validate participant details
                      bool isNameValid = _participants.every((participant) {
                        return participant.containsKey('name') && participant['name']!.isNotEmpty;
                      });

                      bool isAgeValid = _participants.every((participant) {
                        return participant.containsKey('age') && participant['age']!.isNotEmpty;
                      });

                      bool isGenderValid = _participants.every((participant) {
                        return participant.containsKey('gender') &&
                            (participant['gender'] == 'Male' || participant['gender'] == 'Female');
                      });

                      bool isPhoneValid = _participants.every((participant) {
                        return participant.containsKey('phone') &&
                            participant['phone']!.isNotEmpty &&
                            participant['phone']!.length == 10;
                      });

                      bool allDetailsFilled = _participants.length == _adults + _children &&
                          isNameValid && isAgeValid && isGenderValid && isPhoneValid;

                      if (isMaxParticipantsReached) {
                        // Show message if maximum participants are reached
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Maximum participants reached for this trip")),
                        );
                        return;
                      }

                      if (!isNameValid) {
                        // Show message if name is not filled in correctly
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Please fill in the participant names")),
                        );
                        return;
                      }

                      if (!isAgeValid) {
                        // Show message if age is not filled in correctly
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Please fill in the participant ages")),
                        );
                        return;
                      }

                      if (!isGenderValid) {
                        // Show message if gender is not filled in correctly
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Please select valid genders (Male or Female)")),
                        );
                        return;
                      }

                      if (!isPhoneValid) {
                        // Show message if phone number is not filled in correctly
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Please enter valid phone numbers (10 digits)")),
                        );
                        return;
                      }

                      if (allDetailsFilled) {
                        // Proceed to payment if all details are filled and max participants not reached
                        _proceedToPayment();
                      } else {
                        // Show message if any participant details are missing
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Please fill in all participant details")),
                        );
                      }
                    } catch (e) {
                      print("Error: $e");
                    } finally {
                      setState(() {
                        _isLoading = false; // Stop loading
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF134277),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isLoading
                      ? SizedBox(
                    width: 24, height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2,
                    ),
                  )
                      : Text(
                    "Proceed to Payment",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF134277), size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "$title: $value",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildCounter(String label, int count, Function(int) onChanged) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1), // Light grey background
        borderRadius: BorderRadius.circular(15), // Rounded corners
        border: Border.all(color: Colors.grey.shade400, width: 1), // Border
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.remove, color: Colors.red),
                onPressed: count > 0 ? () => onChanged(count - 1) : null,
                splashRadius: 24,
              ),
              Text(count.toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              IconButton(
                icon: Icon(Icons.add, color: Colors.blue),
                onPressed: () => onChanged(count + 1),
                splashRadius: 24,
              ),
            ],
          ),
        ],
      ),
    );
  }


  // Calculation Row
  Widget _buildCalculationRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 18, fontWeight: isBold ? FontWeight.w600 : FontWeight.normal)),
          Text("\₹ ${amount.toStringAsFixed(2)}", style: TextStyle(fontSize: 20, fontWeight: isBold ? FontWeight.w700 : FontWeight.normal, color: Color(0xFF134277),)),
        ],
      ),
    );
  }
}