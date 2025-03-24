import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../const.dart';
import '../models/travel_model.dart';

// class EditTripScreen extends StatefulWidget {
//   @override
//   _EditTripScreenState createState() => _EditTripScreenState();
// }
//
// class _EditTripScreenState extends State<EditTripScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   // Define controllers
//   final TextEditingController _tripTitleController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   final TextEditingController _meetingPointController = TextEditingController();
//   final TextEditingController _accommodationController = TextEditingController();
//   final TextEditingController _includedServicesController = TextEditingController();
//   final TextEditingController _contactInfoController = TextEditingController();
//   final TextEditingController _tripFeeController = TextEditingController();
//   final TextEditingController _maxParticipantsController = TextEditingController();
//
//   String? _selectedCategory, _destination, selectedTransport;
//   DateTime? _startDate, _endDate;
//   TimeOfDay? _startTime, _endTime;
//
//   List<String> _destinations = [
//     // 🌊 Beach Destinations
//     "Goa, India",
//     "Pondicherry, India",
//     "Marina Beach, Tamil Nadu",
//     "Dhanushkodi, Tamil Nadu",
//     "Kanyakumari, Tamil Nadu",
//     "Gokarna, Karnataka",
//     "Kovalam, Kerala",
//     "Varkala, Kerala",
//     "Havelock Island, Andaman",
//     "Neil Island, Andaman",
//
//     // 🏔️ Hill Stations
//     "Manali, Himachal Pradesh",
//     "Shimla, Himachal Pradesh",
//     "Kasol, Himachal Pradesh",
//     "Dharamshala, Himachal Pradesh",
//     "Dalhousie, Himachal Pradesh",
//     "Munnar, Kerala",
//     "Ooty, Tamil Nadu",
//     "Kodaikanal, Tamil Nadu",
//     "Coorg, Karnataka",
//     "Lonavala, Maharashtra",
//     "Mahabaleshwar, Maharashtra",
//     "Saputara, Gujarat",
//     "Mount Abu, Rajasthan",
//     "Chopta, Uttarakhand",
//     "Nainital, Uttarakhand",
//     "Mussoorie, Uttarakhand",
//     "Shillong, Meghalaya",
//     "Gangtok, Sikkim",
//     "Tawang, Arunachal Pradesh",
//
//     // 🏜️ Desert & Cultural Trips
//     "Jaisalmer, Rajasthan",
//     "Jaipur, Rajasthan",
//     "Udaipur, Rajasthan",
//     "Bikaner, Rajasthan",
//     "Rann of Kutch, Gujarat",
//     "Pushkar, Rajasthan",
//     "Jodhpur, Rajasthan",
//
//     // 🏞️ Nature & Wildlife
//     "Jim Corbett National Park, Uttarakhand",
//     "Kaziranga National Park, Assam",
//     "Sundarbans, West Bengal",
//     "Gir National Park, Gujarat",
//     "Bandipur National Park, Karnataka",
//     "Ranthambore National Park, Rajasthan",
//     "Periyar Wildlife Sanctuary, Kerala",
//
//     // 🚣 Adventure & Trekking
//     "Rishikesh, Uttarakhand",
//     "Triund Trek, Himachal Pradesh",
//     "Leh, Ladakh",
//     "Spiti Valley, Himachal Pradesh",
//     "Chandrashila Trek, Uttarakhand",
//     "Roopkund Trek, Uttarakhand",
//     "Zanskar Valley, Ladakh",
//     "Sandakphu, West Bengal",
//     "Valley of Flowers, Uttarakhand",
//
//     // 🏛️ Heritage & Spiritual Destinations
//     "Varanasi, Uttar Pradesh",
//     "Rameswaram, Tamil Nadu",
//     "Bodh Gaya, Bihar",
//     "Ajanta & Ellora Caves, Maharashtra",
//     "Konark Sun Temple, Odisha",
//     "Amritsar, Punjab",
//     "Golden Temple, Punjab",
//     "Dwarka, Gujarat",
//     "Somnath, Gujarat",
//     "Madurai, Tamil Nadu",
//     "Tirupati, Andhra Pradesh",
//     "Shirdi, Maharashtra",
//     "Vaishno Devi, Jammu & Kashmir",
//
//     // 🌆 Metro City Trips
//     "Mumbai, Maharashtra",
//     "Bangalore, Karnataka",
//     "Delhi, India",
//     "Chennai, Tamil Nadu",
//     "Hyderabad, Telangana",
//     "Kolkata, West Bengal",
//     "Ahmedabad, Gujarat",
//     "Pune, Maharashtra",
//
//     // 🎭 Unique & Hidden Gems
//     "Cherrapunji, Meghalaya",
//     "Ziro Valley, Arunachal Pradesh",
//     "Majuli Island, Assam",
//     "Mawlynnong, Meghalaya",
//     "Loktak Lake, Manipur",
//     "Lepchajagat, West Bengal",
//     "Hampi, Karnataka",
//     "Gandikota, Andhra Pradesh",
//     "Bhedaghat, Madhya Pradesh",
//     "Pachmarhi, Madhya Pradesh",
//     "Tawang, Arunachal Pradesh",
//   ];
//   List<String> tripCategories = [
//     "Adventure Trips",
//     "Beach Vacations",
//     "Cultural & Historical Tours",
//     "Road Trips",
//     "Volunteer & Humanitarian Trips",
//     "Wellness Trips"];
//   List<String> transportOptions = ["Car", "Bus", "Train", "Flight", "Bike"];
//
//   @override
//   void initState() {
//     super.initState();
//     fetchTripData();
//   }
//
//   Future<void> fetchTripData() async {
//     // Get tripId from widget
//     String tripId = widget.tripId;
//
//     try {
//       DocumentSnapshot tripDoc = await _firestore.collection('trips').doc(tripId).get();
//
//       if (tripDoc.exists) {
//         Map<String, dynamic> data = tripDoc.data() as Map<String, dynamic>;
//
//         setState(() {
//           _tripTitleController.text = data['tripTitle'] ?? '';
//           _descriptionController.text = data['description'] ?? '';
//           _meetingPointController.text = data['meetingPoint'] ?? '';
//           _accommodationController.text = data['accommodation'] ?? '';
//           _includedServicesController.text = data['includedServices'] ?? '';
//           _contactInfoController.text = data['contactInfo'] ?? '';
//           _tripFeeController.text = data['tripFee']?.toString() ?? '';
//           _maxParticipantsController.text = data['maxParticipants']?.toString() ?? '';
//
//           _destination = data['destination'];
//           _selectedCategory = data['category'];
//           selectedTransport = data['transportation'];
//
//           _startDate = (data['startDate'] != null) ? (data['startDate'] as Timestamp).toDate() : null;
//           _endDate = (data['endDate'] != null) ? (data['endDate'] as Timestamp).toDate() : null;
//
//           _startTime = (data['startTime'] != null) ? TimeOfDay.fromDateTime((data['startTime'] as Timestamp).toDate()) : null;
//           _endTime = (data['endTime'] != null) ? TimeOfDay.fromDateTime((data['endTime'] as Timestamp).toDate()) : null;
//         });
//       }
//     } catch (e) {
//       print("Error fetching trip data: $e");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Edit Trip")),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               _buildTextField("Trip Title", _tripTitleController, true),
//               _buildDestinationField(),
//               _buildDropdownField("Trip Category", tripCategories, _selectedCategory, (value) => setState(() => _selectedCategory = value)),
//               _buildDateField("Start Date", _startDate, (date) => setState(() => _startDate = date)),
//               _buildDateField("End Date", _endDate, (date) => setState(() => _endDate = date)),
//               _buildTimeField("Start Time", _startTime, (time) => setState(() => _startTime = time)),
//               _buildTimeField("End Time", _endTime, (time) => setState(() => _endTime = time)),
//               _buildTextField("Description", _descriptionController, true, maxLines: 3),
//               _buildTextField("Meeting Point", _meetingPointController, true),
//               _buildDropdownField("Transportation", transportOptions, selectedTransport, (value) => setState(() => selectedTransport = value)),
//               _buildTextField("Accommodation", _accommodationController, true),
//               _buildNumericField("Maximum Participants", _maxParticipantsController),
//               _buildNumericField("Trip Fee (per person)", _tripFeeController),
//               _buildTextField("Included Services", _includedServicesController, true),
//               _buildTextField("Contact Information", _contactInfoController, true),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   if (_formKey.currentState!.validate()) {
//                     _updateTrip();
//                   }
//                 },
//                 child: Text("Save Changes"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future<void> _updateTrip() async {
//     String tripId = widget.tripId;
//
//     try {
//       await _firestore.collection('trips').doc(tripId).update({
//         'tripTitle': _tripTitleController.text,
//         'description': _descriptionController.text,
//         'meetingPoint': _meetingPointController.text,
//         'accommodation': _accommodationController.text,
//         'includedServices': _includedServicesController.text,
//         'contactInfo': _contactInfoController.text,
//         'tripFee': double.tryParse(_tripFeeController.text),
//         'maxParticipants': int.tryParse(_maxParticipantsController.text),
//         'destination': _destination,
//         'category': _selectedCategory,
//         'transportation': selectedTransport,
//         'startDate': _startDate,
//         'endDate': _endDate,
//         'startTime': _startTime != null ? Timestamp.fromDate(DateTime(0, 0, 0, _startTime!.hour, _startTime!.minute)) : null,
//         'endTime': _endTime != null ? Timestamp.fromDate(DateTime(0, 0, 0, _endTime!.hour, _endTime!.minute)) : null,
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Trip Updated Successfully!")));
//       Navigator.pop(context);
//     } catch (e) {
//       print("Error updating trip: $e");
//     }
//   }
//
//   Widget _buildDestinationField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text("Destination", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
//         SizedBox(height: 5),
//         TextFormField(
//           controller: _destinationController,
//           decoration: InputDecoration(
//             hintText: "Enter Destination",
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//             contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
//           ),
//           validator: (value) {
//             if (value == null || value.trim().isEmpty) {
//               return "Please enter a destination";
//             }
//             return null;
//           },
//         ),
//         SizedBox(height: 10),
//       ],
//     );
//   }
//
//
//   Widget _buildTimeField(String label, TimeOfDay? selectedTime, Function(TimeOfDay) onTimePicked) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
//         SizedBox(height: 5),
//         GestureDetector(
//           onTap: () async {
//             TimeOfDay? pickedTime = await showTimePicker(
//               context: context,
//               initialTime: selectedTime ?? TimeOfDay.now(),
//             );
//             if (pickedTime != null) {
//               onTimePicked(pickedTime);
//             }
//           },
//           child: Container(
//             padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Text(
//               selectedTime != null
//                   ? "${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}"
//                   : "Select Time",
//               style: TextStyle(fontSize: 16),
//             ),
//           ),
//         ),
//         SizedBox(height: 10),
//       ],
//     );
//   }
//
//
//   Widget _buildDateField(String label, DateTime? selectedDate, Function(DateTime) onDatePicked) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
//         SizedBox(height: 5),
//         GestureDetector(
//           onTap: () async {
//             DateTime? pickedDate = await showDatePicker(
//               context: context,
//               initialDate: selectedDate ?? DateTime.now(),
//               firstDate: DateTime(2000),
//               lastDate: DateTime(2100),
//             );
//             if (pickedDate != null) {
//               onDatePicked(pickedDate);
//             }
//           },
//           child: Container(
//             padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Text(
//               selectedDate != null
//                   ? "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"
//                   : "Select Date",
//               style: TextStyle(fontSize: 16),
//             ),
//           ),
//         ),
//         SizedBox(height: 10),
//       ],
//     );
//   }
//
//
//   Widget _buildTextField(String label, TextEditingController controller, bool isRequired, {int maxLines = 1}) {
//     return TextFormField(
//       controller: controller,
//       decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
//       maxLines: maxLines,
//       validator: (value) => isRequired && (value == null || value.isEmpty) ? 'Please enter $label' : null,
//     );
//   }
//
//   Widget _buildNumericField(String label, TextEditingController controller) {
//     return TextFormField(
//       controller: controller,
//       decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
//       keyboardType: TextInputType.number,
//       validator: (value) => (value == null || value.isEmpty || !RegExp(r'^[0-9]+$').hasMatch(value)) ? 'Enter valid $label' : null,
//     );
//   }
//
//   Widget _buildDropdownField(String label, List<String> options, String? selectedValue, Function(String?) onChanged) {
//     return DropdownButtonFormField<String>(
//       decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
//       value: selectedValue,
//       items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
//       onChanged: onChanged,
//     );
//   }
// }
//


class AdminTripEditScreen extends StatefulWidget {
  final Trip trip;

  const AdminTripEditScreen({Key? key, required this.trip}) : super(key: key);

  @override
  _EditTripScreenState createState() => _EditTripScreenState();
}

class _EditTripScreenState extends State<AdminTripEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;

  // Define controllers
  late TextEditingController _descriptionController;
  late TextEditingController _meetingPointController;
  late TextEditingController _accommodationController;
  late TextEditingController _whatsappInfoController;
  late TextEditingController _tripFeeController;
  late TextEditingController _maxParticipantsController;
  late TextEditingController _destinationController;
  late TextEditingController _fromLocationController;
  late TextEditingController _toLocationController;

  String? _selectedCategory, _destination, selectedTransport;
  DateTime? _startDateTime;
  DateTime? _endDateTime ;
  //String? _startTime, _endTime;

  final List<String> _destinationsList = [
    // 🌊 Beach Destinations
    "Goa, India",
    "Pondicherry, India",
    "Marina Beach, Tamil Nadu",
    "Dhanushkodi, Tamil Nadu",
    "Kanyakumari, Tamil Nadu",
    "Gokarna, Karnataka",
    "Kovalam, Kerala",
    "Varkala, Kerala",
    "Havelock Island, Andaman",
    "Neil Island, Andaman",

    // 🏔️ Hill Stations
    "Manali, Himachal Pradesh",
    "Shimla, Himachal Pradesh",
    "Kasol, Himachal Pradesh",
    "Dharamshala, Himachal Pradesh",
    "Dalhousie, Himachal Pradesh",
    "Munnar, Kerala",
    "Ooty, Tamil Nadu",
    "Kodaikanal, Tamil Nadu",
    "Coorg, Karnataka",
    "Lonavala, Maharashtra",
    "Mahabaleshwar, Maharashtra",
    "Saputara, Gujarat",
    "Mount Abu, Rajasthan",
    "Chopta, Uttarakhand",
    "Nainital, Uttarakhand",
    "Mussoorie, Uttarakhand",
    "Shillong, Meghalaya",
    "Gangtok, Sikkim",
    "Tawang, Arunachal Pradesh",

    // 🏜️ Desert & Cultural Trips
    "Jaisalmer, Rajasthan",
    "Jaipur, Rajasthan",
    "Udaipur, Rajasthan",
    "Bikaner, Rajasthan",
    "Rann of Kutch, Gujarat",
    "Pushkar, Rajasthan",
    "Jodhpur, Rajasthan",

    // 🏞️ Nature & Wildlife
    "Jim Corbett National Park, Uttarakhand",
    "Kaziranga National Park, Assam",
    "Sundarbans, West Bengal",
    "Gir National Park, Gujarat",
    "Bandipur National Park, Karnataka",
    "Ranthambore National Park, Rajasthan",
    "Periyar Wildlife Sanctuary, Kerala",

    // 🚣 Adventure & Trekking
    "Rishikesh, Uttarakhand",
    "Triund Trek, Himachal Pradesh",
    "Leh, Ladakh",
    "Spiti Valley, Himachal Pradesh",
    "Chandrashila Trek, Uttarakhand",
    "Roopkund Trek, Uttarakhand",
    "Zanskar Valley, Ladakh",
    "Sandakphu, West Bengal",
    "Valley of Flowers, Uttarakhand",

    // 🏛️ Heritage & Spiritual Destinations
    "Varanasi, Uttar Pradesh",
    "Rameswaram, Tamil Nadu",
    "Bodh Gaya, Bihar",
    "Ajanta & Ellora Caves, Maharashtra",
    "Konark Sun Temple, Odisha",
    "Amritsar, Punjab",
    "Golden Temple, Punjab",
    "Dwarka, Gujarat",
    "Somnath, Gujarat",
    "Madurai, Tamil Nadu",
    "Tirupati, Andhra Pradesh",
    "Shirdi, Maharashtra",
    "Vaishno Devi, Jammu & Kashmir",

    // 🌆 Metro City Trips
    "Mumbai, Maharashtra",
    "Bangalore, Karnataka",
    "Delhi, India",
    "Chennai, Tamil Nadu",
    "Hyderabad, Telangana",
    "Kolkata, West Bengal",
    "Ahmedabad, Gujarat",
    "Pune, Maharashtra",

    // 🎭 Unique & Hidden Gems
    "Cherrapunji, Meghalaya",
    "Ziro Valley, Arunachal Pradesh",
    "Majuli Island, Assam",
    "Mawlynnong, Meghalaya",
    "Loktak Lake, Manipur",
    "Lepchajagat, West Bengal",
    "Hampi, Karnataka",
    "Gandikota, Andhra Pradesh",
    "Bhedaghat, Madhya Pradesh",
    "Pachmarhi, Madhya Pradesh",
    "Tawang, Arunachal Pradesh",
  ];

  List<String> imageUrls = []; // List to store image URLs
  File? _selectedImage;
  final picker = ImagePicker();

  final List<String> tripcat = [
    "Adventure",
    "Beach Vacations",
    "Historical Tours",
    "Road Trips",
    "Volunteer & Humanitarian",
    "Wellness"
  ];

  List<String> transport = ["Car", "Bus", "Train", "Flight"];

  List<String> allServices = [
    "Transport", "Food & Drinks", "Tour Guide",
    "Emergency Help", "Luggage Support",
    "WiFi & Entertainment", "Photography"
  ];
  List<String> _includedServices = [];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with trip data
    imageUrls = List<String>.from(widget.trip.image ?? []);
    _descriptionController = TextEditingController(text: widget.trip.des);
    _meetingPointController = TextEditingController(text: widget.trip.meetingPoint);
    _accommodationController = TextEditingController(text: widget.trip.accommodation);
    _whatsappInfoController = TextEditingController(text: widget.trip.whatsappInfo);
    _tripFeeController = TextEditingController(text: widget.trip.price.toString());
    _maxParticipantsController = TextEditingController(text: widget.trip.maxpart.toString());
    _includedServices = List<String>.from(widget.trip.includedServices);
    _destinationController = TextEditingController(text: widget.trip.location);
    _fromLocationController = TextEditingController(text: widget.trip.from);
    _toLocationController = TextEditingController(text: widget.trip.to);
    _destination = widget.trip.location;
    _selectedCategory = widget.trip.tripCategory;
    selectedTransport = widget.trip.transportation;
    _startDateTime = DateTime.parse(widget.trip.startDateTime.toString());
    _endDateTime = DateTime.parse(widget.trip.endDateTime.toString());

  }


  @override
  void dispose() {
    _descriptionController.dispose();
    _meetingPointController.dispose();
    _accommodationController.dispose();
    _whatsappInfoController.dispose();
    _tripFeeController.dispose();
    _maxParticipantsController.dispose();
    _destinationController.dispose();
    super.dispose();
  }


  Future<void> _updateTrip() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true; // Start loading
      });

      try {
        // Reference to the trip document in Firestore
        DocumentReference tripDocRef = _firestore.collection('trips').doc(widget.trip.id);

        int? dayOfTrip;
        if (_startDateTime != null && _endDateTime != null) {
          dayOfTrip = _endDateTime!.difference(_startDateTime!).inDays;
        }

        if (_selectedImage != null) {
          await _updateImage();
        }

        // Data to update
        Map<String, dynamic> updatedData = {
          'meetingPoint': _meetingPointController.text.trim(),
          'accommodation': _accommodationController.text.trim(),
          'from':_fromLocationController.text.trim(),
          'to':_toLocationController.text.trim(),
          'includedServices': _includedServices,
          'whatsappInfo': _whatsappInfoController.text.trim(),
          'tripFee': double.tryParse(_tripFeeController.text.trim()) ?? 0.0,
          'maxParticipants': int.tryParse(_maxParticipantsController.text.trim()) ?? 0,
          'destination': _destinationController.text, // Fixed destination field
          'category': _selectedCategory,
          'transportation': selectedTransport,
          'startDateTime': _startDateTime!.toIso8601String(), // Convert DateTime to String
          'endDateTime': _endDateTime!.toIso8601String(),
          'daysOfTrip': dayOfTrip,
          'photos': imageUrls,
        };

        // Update the main trip document in the "trips" collection
        await tripDocRef.update(updatedData);

        // Also update the trip in the user's subcollection (if it exists)
        if (widget.trip.hostId != null) {
          DocumentReference userTripRef = _firestore
              .collection('users')
              .doc(widget.trip.hostId)
              .collection('trip')
              .doc(widget.trip.id);
          await userTripRef.update({
            ...updatedData,
            'photos': imageUrls, // Ensure photos update in user subcollection
          });
        }

        // Check if the trip exists in the "admin" collection before updating
        DocumentReference adminTripRef = _firestore.collection('admin').doc(widget.trip.id);
        DocumentSnapshot adminTripSnapshot = await adminTripRef.get();

        if (adminTripSnapshot.exists) {
          await adminTripRef.update({
            ...updatedData,
            'photos': imageUrls, // Ensure photos update in user subcollection
          });
        }

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Trip Updated Successfully!")),
        );

        // Close the edit page and send "true" to refresh trips in the home page
        Navigator.pop(context, true);
      } catch (e) {
        print("Error updating trip: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update trip. Please try again.")),
        );
      }
      setState(() {
        _isLoading = false; // Stop loading after process completes
      });
    }
  }

  // Pick an image from gallery
  Future<void> _pickImage() async {
    final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return; // No image selected

    File imageFile = File(image.path);

    // Upload to Cloudinary and get the URL
    String? imageUrl = await _uploadToCloudinary(imageFile);

    if (imageUrl != null) {
      setState(() {
        imageUrls.add(imageUrl); // Update UI immediately
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image Upload Failed")),
      );
    }
  }


  // Extract public ID from Cloudinary URL
  String? _extractPublicId(String? url) {
    if (url == null) return null;
    Uri uri = Uri.parse(url);
    List<String> segments = uri.pathSegments;

    if (segments.length > 1) {
      String filename = segments.last;
      return filename.split('.').first; // Remove file extension
    }
    return null;
  }

  // Delete image from Cloudinary
  Future<void> _deleteFromCloudinary(String? imageUrl) async {
    if (imageUrl == null) return;

    String? publicId = _extractPublicId(imageUrl);
    if (publicId == null) {
      print("Failed to extract public ID.");
      return;
    }

    final String cloudName = 'dz0shhr6k'; // Your Cloudinary cloud name
    final String apiKey = '763225618255152'; // Your Cloudinary API Key
    final String apiSecret = 'DFCYPhLVFLb8pdNwwopUAPM_i8w';

    int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    String stringToSign = "public_id=$publicId&timestamp=$timestamp$apiSecret";
    String signature = sha1.convert(utf8.encode(stringToSign)).toString();

    final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/destroy");

    final response = await http.post(
      url,
      body: {
        "public_id": publicId,
        "api_key": apiKey,
        "timestamp": timestamp.toString(),
        "signature": signature,
      },
    );

    if (response.statusCode == 200) {
      print("✅ Image deleted successfully from Cloudinary.");
    } else {
      print("❌ Failed to delete image: ${response.body}");
    }
  }


  // Upload new image to Cloudinary
  Future<String?> _uploadToCloudinary(File imageFile) async {
    final cloudinaryUrl =
        "https://api.cloudinary.com/v1_1/dz0shhr6k/image/upload";
    final uploadPreset = "gobuddy-images";

    var request = http.MultipartRequest("POST", Uri.parse(cloudinaryUrl));
    request.fields['upload_preset'] = uploadPreset;
    request.files.add(await http.MultipartFile.fromPath("file", imageFile.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = jsonDecode(await response.stream.bytesToString());
      return responseData["secure_url"];
    } else {
      return null;
    }
  }

  // Add new image to Firestore
  Future<void> _updateImage() async {
    if (_selectedImage == null) return;

    // Upload the new image
    String? uploadedImageUrl = await _uploadToCloudinary(_selectedImage!);

    if (uploadedImageUrl != null) {
      setState(() {
        imageUrls.add(uploadedImageUrl); // Add to local list
      });

      await FirebaseFirestore.instance
          .collection('trips')
          .doc(widget.trip.id)
          .update({'photos': imageUrls}); // Update Firestore array

      setState(() {
        _selectedImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image Added Successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image Upload Failed")),
      );
    }
  }


  // Delete a specific image
  Future<void> _deleteImage(int index) async {
    String imageUrlToDelete = imageUrls[index];

    // Delete image from Cloudinary
    await _deleteFromCloudinary(imageUrlToDelete);

    // Remove from Firestore
    imageUrls.removeAt(index);
    await FirebaseFirestore.instance
        .collection('trips')
        .doc(widget.trip.id)
        .update({'photos': imageUrls});

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Image Deleted Successfully")),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(title: Text('Edit Trip'),
        backgroundColor: Color(0xFF134277),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: Icon(Icons.add_a_photo, color: Colors.black),
                    label: Text("Pick Image"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF8BA7E8),
                      foregroundColor: Colors.black,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: imageUrls.isNotEmpty
                        ? Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: imageUrls.asMap().entries.map((entry) {
                        int index = entry.key;
                        String photoUrl = entry.value;

                        return Stack(
                          children: [
                            Image.network(photoUrl, width: 100, height: 100, fit: BoxFit.cover),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () => _deleteImage(index),
                                child: Icon(Icons.cancel, color: Colors.red),
                              ),
                            )
                          ],
                        );
                      }).toList(),
                    )
                        : Text("No photos added yet"),
                  ),
                ],
              ),
              //DEstination
              _buildAutoCompleteTextField(
                controller: _destinationController,
                labelText: "Destination",
                hintText: "Enter Your Destination",
                options: _destinationsList,
                keyboardType: TextInputType.text,
                maxLines: 1,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a destination";
                  }
                  return null;
                },
              ),
              //From To
              SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _fromLocationController, // Controller for "From"
                      decoration: InputDecoration(
                        labelText: "From",
                        hintText: "Enter starting location",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Trip location';
                        }
                        final locationRegExp = RegExp(r'^[a-zA-Z\s]+$');
                        if (!locationRegExp.hasMatch(value)) {
                          return 'Invalid Trip location';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 10), // Space between fields
                  Expanded(
                    child: TextFormField(
                      controller: _toLocationController, // Controller for "To"
                      decoration: InputDecoration(
                        labelText: "To",
                        hintText: "Enter destination",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Trip destination';
                        }
                        final locationRegExp = RegExp(r'^[a-zA-Z\s]+$');
                        if (!locationRegExp.hasMatch(value)) {
                          return 'Invalid Trip destination';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              //Trip Categgory
              Text("Trip Category : ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              SizedBox(height: 6),
              Wrap(
                spacing: 8, // Space between chips
                children: tripcat.map((category) {
                  return ChoiceChip(
                    label: Text(category),
                    selected: _selectedCategory == category, // Default selection
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? category : _selectedCategory; // Change category only if selected
                      });
                    },
                    showCheckmark: false,
                    selectedColor: Color(0xFF134277), // Selected chip color
                    backgroundColor: Colors.grey[100], // Default chip color
                    labelStyle: TextStyle(
                      color: _selectedCategory == category ? Colors.white : Colors.black87,
                    ),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1.5, color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              //Date and Time
              Row(
                children: [
                  Expanded(
                    child: _buildDateTimeSelector(
                      label: "Start Date & Time",
                      dateTime: _startDateTime,
                      onTap: () async {
                        DateTime? selected = await _pickDateTime(context, initialDateTime: _startDateTime);
                        if (selected != null) {
                          setState(() {
                            _startDateTime = selected;
                            // Ensure end date is not before start date
                            if (_endDateTime != null && _endDateTime!.isBefore(_startDateTime!)) {
                              _endDateTime = null;
                            }
                          });
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildDateTimeSelector(
                      label: "End Date & Time",
                      dateTime: _endDateTime,
                      onTap: () async {
                        DateTime? selected = await _pickDateTime(
                          context,
                          initialDateTime: _endDateTime,
                          firstDate: _startDateTime ?? DateTime.now(), // Prevent selecting past start date
                        );
                        if (selected != null) {
                          setState(() {
                            _endDateTime = selected;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              //Meeting Point
              _buildTextField(
                controller: _meetingPointController,
                labelText: "Meeting Point",
                hintText: "Enter your Meeting Point",
                keyboardType: TextInputType.name,
                maxLines: 1,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Meeting Point';
                  }
                  final usernameRegExp = RegExp(r'^[a-zA-Z]');
                  if (!usernameRegExp.hasMatch(value)) {
                    return 'Invalid Meeting Point';
                  }
                  return null;
                },
              ),
             //Transportation
              Text("Transportation : ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: transport.map((category) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTransport = category; // Update selected transport
                      });
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.215, // Responsive width
                      padding: EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: selectedTransport == category
                            ? LinearGradient(colors: [Color(0xFF134277), Color(0xFF134277)])
                            : LinearGradient(colors: [Colors.grey[200]!, Colors.grey[200]!]),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selectedTransport == category ? Color(0xFF134277) : Colors.grey[400]!,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          category,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: selectedTransport == category ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 10),
              // Accommodation
              _buildTextField(
                controller: _accommodationController,
                labelText: "Accommodation",
                hintText: "Enter your Accommodation",
                keyboardType: TextInputType.name,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Accommodation';
                  }
                  return null;
                },
              ),

              //Max Participants
              _buildTextField(
                controller: _maxParticipantsController,
                labelText: "Max Participants",
                hintText: "Enter your Max Participants",
                keyboardType: TextInputType.number,
                maxLines: 1,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Maximum Participants';
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Enter valid Maximum Participants(must be digits)';
                  }
                  return null;
                },
              ),

              //Trip Fee
              _buildTextField(
                controller: _tripFeeController,
                labelText: "Trip Fee",
                hintText: "Enter your Trip Fee",
                keyboardType: TextInputType.number,
                maxLines: 1,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Trip Fee (per person)';
                  }
                  if (!RegExp(r'^[0-9.]+$').hasMatch(value)) {
                    return 'Invalid Trip Fee(must be digits)';
                  }
                  return null;
                },
              ),

              SizedBox(height: 10),
              Text(
                "Included Services:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: allServices.map((service) {
                  return ChoiceChip(
                    showCheckmark: false,
                    label: Text(service),
                    selected: _includedServices.contains(service), // Highlight selected services
                    onSelected: (selected) {
                      setState(() {
                        selected
                            ? _includedServices.add(service)
                            : _includedServices.remove(service);
                      });
                    },
                    selectedColor: Color(0xFF134277), // Highlighted color
                    backgroundColor: Colors.grey[200], // Default chip color
                    labelStyle: TextStyle(
                      color: _includedServices.contains(service) ? Colors.white : Colors.black87,
                    ),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1.5, color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 6),

              //Contact Info
              _buildTextField(
                controller: _whatsappInfoController,
                labelText: "WhatsApp Contact Info",
                hintText: "Enter your WhatsApp Contact Info",
                keyboardType: TextInputType.phone,
                maxLines: 1,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter WhatsApp contact';
                  }
                  final phoneRegExp = RegExp(r'^[0-9]{10}$');
                  if (!phoneRegExp.hasMatch(value)) {
                    return 'Invalid WhatsApp contact details (must be 10 digits)';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width*0.8,
                  height: 60,
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(90)),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      shadowColor: Colors.black,
                      backgroundColor: const Color(0xFF134277),
                      elevation: 10,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    onPressed: _isLoading ? null : _updateTrip,
                    child:_isLoading
                        ? CircularProgressIndicator()
                        : Text("Update Trip", style: TextStyle(fontSize: 18,color: Colors.white)),
                  ),
                ),
              ),



            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeSelector({
    required String label,
    required DateTime? dateTime,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            SizedBox(height: 6),
            Text(
              dateTime != null
                  ? DateFormat("yyyy-MM-dd HH:mm").format(dateTime)
                  : "Select Date & Time",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Future<DateTime?> _pickDateTime(
      BuildContext context, {
        DateTime? initialDateTime,
        DateTime? firstDate,
      }) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDateTime ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) return null;

    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDateTime ?? DateTime.now()),
    );

    if (selectedTime == null) return null;

    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
  }


  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator ?? (value) {
          if (value == null || value.isEmpty) {
            return "Please enter $labelText";
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: Color(0xFF134277),
          ),
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey,
          ),
          border: InputBorder.none,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF8BA7E8), width: 2),
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
        ),
      ),
    );
  }

  Widget _buildAutoCompleteTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required List<String> options,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) return [];
              return options.where((String option) {
                return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
              });
            },
            onSelected: (String selection) {
              controller.text = selection;
            },
            fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
              textEditingController.text = controller.text;
              return TextFormField(
                controller: textEditingController,
                focusNode: focusNode,
                keyboardType: keyboardType,
                maxLines: maxLines,
                validator: validator ?? (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter $labelText";
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: hintText,
                  labelStyle: TextStyle(
                    color: Color(0xFF134277),
                  ),
                  hintText: hintText,
                  hintStyle: TextStyle(
                    color: Colors.grey,
                  ),
                  border: InputBorder.none,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF8BA7E8), width: 2),
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
                ),
                onChanged: (value) {
                  controller.text = value;
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownButtonFormField({
    required String labelText,
    required List<String> options,
    required String? selectedValue,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            dropdownColor: kBackgroundColor,
            value: selectedValue,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: EdgeInsets.symmetric(horizontal: 10,vertical: 15),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF8BA7E8), width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF134277), width: 2),
              ),
            ),
            items: options.map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker({
    required String labelText,
    required DateTime? selectedDate,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            decoration: InputDecoration(
              labelText: labelText,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF8BA7E8), width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF134277), width: 2),
              ),
            ),
            readOnly: true,
            controller: TextEditingController(
              text: selectedDate != null ? DateFormat("yyyy-MM-dd").format(selectedDate) : "",
            ),
            onTap: onTap,
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker({
    required String labelText,
    required String selectedTime,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            decoration: InputDecoration(
              labelText: labelText,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF8BA7E8), width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF134277), width: 2),
              ),
            ),
            readOnly: true,
            controller: TextEditingController(
              text: selectedTime.isNotEmpty ? selectedTime : "",
            ),
            onTap: onTap,
          ),
        ],
      ),
    );
  }

}
