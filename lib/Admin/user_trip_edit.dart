import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

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


class UserTripEditScreen extends StatefulWidget {
  final Trip trip;

  const UserTripEditScreen({Key? key, required this.trip}) : super(key: key);

  @override
  _EditTripScreenState createState() => _EditTripScreenState();
}

class _EditTripScreenState extends State<UserTripEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;

  // Define controllers
  late TextEditingController _tripTitleController;
  late TextEditingController _descriptionController;
  late TextEditingController _meetingPointController;
  late TextEditingController _accommodationController;
  late TextEditingController _includedServicesController;
  late TextEditingController _contactInfoController;
  late TextEditingController _whatsappInfoController;
  late TextEditingController _tripFeeController;
  late TextEditingController _maxParticipantsController;
  late TextEditingController _destinationController;

  String? _selectedCategory, _destination, selectedTransport;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _startTime, _endTime;

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

  @override
  void initState() {
    super.initState();
    // Initialize controllers with trip data
    _tripTitleController = TextEditingController(text: widget.trip.name);
    _descriptionController = TextEditingController(text: widget.trip.des);
    _meetingPointController = TextEditingController(text: widget.trip.meetingPoint);
    _accommodationController = TextEditingController(text: widget.trip.accommodation);
    _includedServicesController = TextEditingController(text: widget.trip.includedServices);
    _contactInfoController = TextEditingController(text: widget.trip.contactInfo);
    _whatsappInfoController = TextEditingController(text: widget.trip.whatsappInfo);
    _tripFeeController = TextEditingController(text: widget.trip.price.toString());
    _maxParticipantsController = TextEditingController(text: widget.trip.maxpart.toString());

    _destinationController = TextEditingController(text: widget.trip.location);

    _destination = widget.trip.location;
    _selectedCategory = widget.trip.tripCategory;
    selectedTransport = widget.trip.transportation;
    _startDate = widget.trip.startDate;
    _endDate = widget.trip.endDate;
    _startTime = widget.trip.startTime;
    _endTime = widget.trip.endTime;
  }

  // DateTime? _parseDateString(String? dateString) {
  //   if (dateString == null || dateString.isEmpty) return null;
  //
  //   try {
  //     return DateTime.parse(dateString); // Convert string to DateTime
  //   } catch (e) {
  //     print("Error parsing date: $e");
  //     return null;
  //   }
  // }



  @override
  void dispose() {
    _tripTitleController.dispose();
    _descriptionController.dispose();
    _meetingPointController.dispose();
    _accommodationController.dispose();
    _includedServicesController.dispose();
    _contactInfoController.dispose();
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
        DocumentReference tripDocRef = _firestore.collection('trips').doc(
            widget.trip.id);

        int? dayOfTrip;
        if (_startDate != null && _endDate != null) {
          dayOfTrip = _endDate!.difference(_startDate!).inDays;
        }

        // Data to update
        Map<String, dynamic> updatedData = {
          'tripTitle': _tripTitleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'meetingPoint': _meetingPointController.text.trim(),
          'accommodation': _accommodationController.text.trim(),
          'includedServices': _includedServicesController.text.trim(),
          'contactInfo': _contactInfoController.text.trim(),
          'whatsappInfo': _whatsappInfoController.text.trim(),
          'tripFee': double.tryParse(_tripFeeController.text.trim()) ?? 0.0,
          'maxParticipants': int.tryParse(
              _maxParticipantsController.text.trim()) ?? 0,
          'destination': _destinationController.text,
          // Fixed destination field
          'category': _selectedCategory,
          'transportation': selectedTransport,
          'startDate': _startDate?.toIso8601String(),
          // Convert DateTime to String
          'endDate': _endDate?.toIso8601String(),
          'startTime': _startTime,
          'endTime': _endTime,
          'daysOfTrip': dayOfTrip
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

          await userTripRef.update(updatedData);
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

  Future<void> _pickStartDate() async {
    DateTime today = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate != null && _startDate!.isAfter(today)
          ? _startDate!
          : today, // Ensures initialDate is valid
      firstDate: today, // Prevent past dates
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _startDate = pickedDate;

        // Ensure end date is after start date
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = null; // Reset invalid end date
        }
      });
    }
  }

  // ✅ Pick End Date (Must be After Start Date)
  Future<void> _pickEndDate() async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a start date first.")),
      );
      return;
    }

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate!,
      firstDate: _startDate!, // End date must be after start date
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _endDate = pickedDate;
      });
    }
  }

  // Convert "HH:mm AM/PM" string to TimeOfDay
  TimeOfDay _parseTime(String timeString) {
    final format = DateFormat.jm(); // Format: "08:30 AM"
    try {
      final DateTime dateTime = format.parse(timeString);
      return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
    } catch (e) {
      return TimeOfDay(hour: 0, minute: 0);
    }
  }

  // Convert TimeOfDay to "HH:mm AM/PM" string
  String _formatTime(TimeOfDay time) {
    final DateTime now = DateTime.now();
    final DateTime dateTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm().format(dateTime); // Example: "08:30 AM"
  }

  // Show Time Picker
  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _parseTime(_startTime!) : _parseTime(_endTime!),
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = _formatTime(picked);
        } else {
          if (_parseTime(_startTime!).hour > picked.hour ||
              (_parseTime(_startTime!).hour == picked.hour && _parseTime(_startTime!).minute > picked.minute)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("End time must be after start time!")),
            );
          } else {
            _endTime = _formatTime(picked);
          }
        }
      });
    }
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
              _buildTextField(
                controller: _tripTitleController,
                labelText: "Trip Title",
                hintText: "Enter your Trip Title",
                keyboardType: TextInputType.name,
                maxLines: 1,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Trip Title';
                  }
                  final usernameRegExp = RegExp(r'^[a-zA-Z]');
                  if (!usernameRegExp.hasMatch(value)) {
                    return 'Invalid Trip Title';
                  }
                  return null;
                },
              ),
              // Destination Field with Autocomplete
              // Text("Destination", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              // SizedBox(height: 8),
              // Autocomplete<String>(
              //   optionsBuilder: (TextEditingValue textEditingValue) {
              //     if (textEditingValue.text.isEmpty) return [];
              //     return _destinationsList.where((String option) {
              //       return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
              //     });
              //   },
              //   onSelected: (String selection) {
              //     setState(() {
              //       _destinationController.text = selection;
              //     });
              //   },
              //   fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
              //     controller.text = _destinationController.text;
              //     return TextField(
              //       controller: controller,
              //       focusNode: focusNode,
              //       decoration: InputDecoration(
              //         labelText: "Enter Destination",
              //         border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              //       ),
              //       onChanged: (value) {
              //         setState(() {
              //           _destinationController.text = value;
              //         });
              //       },
              //     );
              //   },
              // ),
              //destination
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
              // Text("Trip Category", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              // SizedBox(height: 8),
              // DropdownButtonFormField<String>(
              //   value: _selectedCategory,
              //   decoration: InputDecoration(
              //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              //     contentPadding: EdgeInsets.symmetric(horizontal: 10),
              //   ),
              //   items: [
              //     "Adventure Trips",
              //     "Beach Vacations",
              //     "Cultural & Historical Tours",
              //     "Road Trips",
              //     "Volunteer & Humanitarian Trips",
              //     "Wellness Trips"
              //   ].map((String category) {
              //     return DropdownMenuItem<String>(
              //       value: category,
              //       child: Text(category),
              //     );
              //   }).toList(),
              //   onChanged: (value) {
              //     setState(() {
              //       _selectedCategory = value;
              //     });
              //   },
              // ),
              //trip category
              _buildDropdownButtonFormField(
                labelText: "Trip Category",
                options: [
                  "Adventure Trips",
                  "Beach Vacations",
                  "Cultural & Historical Tours",
                  "Road Trips",
                  "Volunteer & Humanitarian Trips",
                  "Wellness Trips"
                ],
                selectedValue: _selectedCategory,
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              //StartDate
              // SizedBox(height: 20),
              // Text("Start Date", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              // SizedBox(height: 8),
              // GestureDetector(
              //   onTap: _pickStartDate,
              //   child: Container(
              //     padding: EdgeInsets.all(12),
              //     decoration: BoxDecoration(
              //       border: Border.all(color: Colors.grey),
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //     child: Text(
              //       _startDate != null ? DateFormat("yyyy-MM-dd").format(_startDate!) : "Select Start Date",
              //       style: TextStyle(fontSize: 16),
              //     ),
              //   ),
              // ),
              // SizedBox(height: 20),
              _buildDatePicker(
                labelText: "Start Date",
                selectedDate: _startDate,
                onTap: _pickStartDate,
              ),
              //Text("Start Time", style: TextStyle(fontWeight: FontWeight.bold)),
              // InkWell(
              //   onTap: () => _selectTime(context, true),
              //   child: Container(
              //     padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              //     decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(10)),
              //     child: Text(_startTime!),
              //   ),
              // ),
              _buildTimePicker(
                labelText: "Start Time",
                selectedTime: _startTime!,
                onTap: () => _selectTime(context, true),
              ),
              // 🗓 End Date Field
              // Text("End Date", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              // SizedBox(height: 8),
              // GestureDetector(
              //   onTap: _pickEndDate,
              //   child: Container(
              //     padding: EdgeInsets.all(12),
              //     decoration: BoxDecoration(
              //       border: Border.all(color: Colors.grey),
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //     child: Text(
              //       _endDate != null ? DateFormat("yyyy-MM-dd").format(_endDate!) : "Select End Date",
              //       style: TextStyle(fontSize: 16),
              //     ),
              //   ),
              // ),
              // SizedBox(height: 10),
              _buildDatePicker(
                labelText: "End Date",
                selectedDate: _endDate,
                onTap: _pickEndDate,
              ),
              // End Time Picker
              // Text("End Time", style: TextStyle(fontWeight: FontWeight.bold)),
              // InkWell(
              //   onTap: () => _selectTime(context, false),
              //   child: Container(
              //     padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              //     decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(10)),
              //     child: Text(_endTime!),
              //   ),
              // ),
              _buildTimePicker(
                labelText: "End Time",
                selectedTime: _endTime!,
                onTap: () => _selectTime(context, false),
              ),

              //description
              _buildTextField(
                controller: _descriptionController,
                labelText: "Description",
                hintText: "Enter your Description",
                keyboardType: TextInputType.name,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Description';
                  }
                  final usernameRegExp = RegExp(r'^[a-zA-Z]');
                  if (!usernameRegExp.hasMatch(value)) {
                    return 'Invalid Description';
                  }
                  return null;
                },
              ),
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
              // Transportation Dropdown
              // Text("Transportation", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              // SizedBox(height: 8),
              // DropdownButtonFormField<String>(
              //   value: selectedTransport,
              //   decoration: InputDecoration(
              //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              //     contentPadding: EdgeInsets.symmetric(horizontal: 10),
              //   ),
              //   items: [
              //     'Car',
              //     'Bus',
              //     'Train',
              //     'Flight',
              //     'Bike',
              //     'Boat'
              //   ].map((String transport) {
              //     return DropdownMenuItem<String>(
              //       value: transport,
              //       child: Text(transport),
              //     );
              //   }).toList(),
              //   onChanged: (value) {
              //     setState(() {
              //       selectedTransport = value;
              //     });
              //   },
              // ),
              _buildDropdownButtonFormField(
                labelText: "Transportation",
                options: [
                      'Car',
                      'Bus',
                      'Train',
                      'Flight',
                      'Bike',
                      'Boat'
                ],
                selectedValue: selectedTransport,
                onChanged: (value) {
                  setState(() {
                    selectedTransport = value;
                  });
                },
              ),
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
                  final usernameRegExp = RegExp(r'^[a-zA-Z]');
                  if (!usernameRegExp.hasMatch(value)) {
                    return 'Invalid Accommodation';
                  }
                  return null;
                },
              ),
              //Included Services
              _buildTextField(
                controller: _includedServicesController,
                labelText: "Included Services",
                hintText: "Enter your Included Services",
                keyboardType: TextInputType.name,
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Included Services';
                  }
                  final usernameRegExp = RegExp(r'^[a-zA-Z]');
                  if (!usernameRegExp.hasMatch(value)) {
                    return 'Invalid Included Services';
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
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Invalid Trip Fee(must be digits)';
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
              //Contact Info
              _buildTextField(
                controller: _contactInfoController,
                labelText: "Contact Info",
                hintText: "Enter your Contact Info",
                keyboardType: TextInputType.phone,
                maxLines: 1,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Contact Information';
                  }
                  final phoneRegExp = RegExp(r'^[0-9]{10}$');
                  if (!phoneRegExp.hasMatch(value)) {
                    return 'Invalid contact details (must be 10 digits)';
                  }
                  return null;
                },
              ),
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
