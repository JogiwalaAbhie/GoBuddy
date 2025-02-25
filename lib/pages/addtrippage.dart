import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gobuddy/Admin/admin_navigation.dart';

import 'package:gobuddy/const.dart';
import 'package:gobuddy/pages/navigation_page.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddTripPage extends StatefulWidget {
  @override
  _AddTripPageState createState() => _AddTripPageState();
}

class _AddTripPageState extends State<AddTripPage> {
  final _formKey = GlobalKey<FormState>();
  String? userId = FirebaseAuth.instance.currentUser?.uid;

  String? _tripTitle;
  String? _hostusername;
  String? _destination;
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;
  String? _description;
  String? _meetingPoint;
  String? _accommodation;
  int? _maxParticipants;
  double? _tripFee;
  String? _includedServices;
  String? _contactInfo;
  String? _wacontactinfo;
  String itemsToBring = "Valid ID proof\nComfortable clothing\nWater bottle\nPersonal medications";
  String guidelinesAndRules = "No littering in the area\nRespect local culture\nFollow the guide’s instructions\nNo smoking in restricted areas\nPets are not allowed";
  String cancellationPolicy = "Full refund if canceled 48 hours before\n50% refund if canceled 24 hours before\nNo refund for cancellations within 24 hours";

  bool _isLoading = false;

  String? _selectedCategory = "";
  final List<String> tripcat = [
   "Adventure Trips",
    "Beach Vacations",
    "Cultural & Historical Tours",
    "Road Trips",
    "Volunteer & Humanitarian Trips",
    "Wellness Trips"
  ];

  String? selectedTransport;
  List<String> transport = ["Car", "Bus", "Train", "Flight", "Bike"];

  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = [];

  final List<String> _destinations = [
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
    _fetchUsername();
  }

  int _calculateDaysOfTrip() {
    if (_startDate != null && _endDate != null) {
      return _endDate!.difference(_startDate!).inDays;
    }
    return 0; // Default to 0 if dates are not selected
  }

  Future<void> _pickImages() async {
    final List<XFile> selectedImages = await _picker.pickMultiImage();
    if (selectedImages.length >= 2) {
      setState(() {
        _selectedImages = selectedImages.map((file) => File(file.path)).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Select at least 2 images")),
      );
    }
  }

  Future<String?> _uploadToCloudinary(File imageFile) async {
    const cloudinaryUrl = "https://api.cloudinary.com/v1_1/dz0shhr6k/image/upload";
    const uploadPreset = "gobuddy-images";
    const folderName = "GoBuddyTrips";

    var request = http.MultipartRequest("POST", Uri.parse(cloudinaryUrl))
      ..fields["upload_preset"] = uploadPreset
      ..fields["folder"] = folderName  // Store in specific folder
      ..files.add(await http.MultipartFile.fromPath("file", imageFile.path));

    try {
      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      // Debugging: Print response to check if it's HTML instead of JSON
      print("Cloudinary Response: $responseData");

      final jsonResponse = json.decode(responseData);

      if (response.statusCode == 200 && jsonResponse["secure_url"] != null) {
        return jsonResponse["secure_url"];
      } else {
        print("Cloudinary Error: ${jsonResponse.toString()}");
        return null;
      }
    } catch (error) {
      print("Upload Error: $error");
      return null;
    }
  }

  Future<List<String>> _uploadAllImages() async {
    List<String> uploadedUrls = [];
    for (var image in _selectedImages) {
      String? imageUrl = await _uploadToCloudinary(image);
      if (imageUrl != null) {
        uploadedUrls.add(imageUrl);
      }
    }
    return uploadedUrls;
  }

  // Function to fetch username from Firestore
  Future<void> _fetchUsername() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final userDoc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();

      setState(() {
        _hostusername = userDoc['username']; // Assuming username is a field
      });
    } catch (e) {
      print('Error fetching username: $e');
      setState(() {
        _hostusername = 'Unknown User';
      });
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        _endDate = null; // Reset end date when start date changes
      });
    }
  }

  // Function to select the Trip End Date
  Future<void> _selectEndDate(BuildContext context) async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select the Trip Start Date first'))
      );
      return;
    }

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate!.add(Duration(days: 1)), // Default to next day
      firstDate: _startDate!.add(Duration(days: 1)), // End date must be after start date
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  String? validateStartDate() {
    if (_startDate == null) return "Please select a start date";
    return null;
  }
  // Validation for End Date
  String? validateEndDate() {
    if (_endDate == null) {
      return "End Date is required";
    } else if (_startDate != null && _endDate!.isBefore(_startDate!)) {
      return "End Date must be after Start Date";
    }
    return null;
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }


  Future<void> _saveTrip() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("You need to be logged in to submit a Report."),
          backgroundColor: Colors.red,
        ));
        return;
      }

      setState(() {
        _isLoading = true; // Start loading
      });

      if (_selectedImages.length < 2) {
        setState(() {
          _isLoading = false; // Stop loading on failure
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("You must upload at least 2 images."),
          backgroundColor: Colors.red,
        ));
        return;
      }

      List<String> uploadedImageUrls = await _uploadAllImages();

      if (uploadedImageUrls.isEmpty) {
        setState(() {
          _isLoading = false; // Stop loading on failure
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to upload images. Please try again."),
          backgroundColor: Colors.red,
        ));
        return;
      }
      int daysOfTrip = _calculateDaysOfTrip();

      // ✅ Generate a unique trip ID
      String tripId = FirebaseFirestore.instance.collection('trips').doc().id;

      final tripData = {
        "tripId": tripId, // ✅ Store the trip ID explicitly
        "hostId": userId,
        "hostUsername": _hostusername,
        "tripTitle": _tripTitle,
        "destination": _destination,
        "tripCategory": _selectedCategory,
        "startDate": _startDate?.toIso8601String(),
        "startTime": _startTime?.format(context),
        "endDate": _endDate?.toIso8601String(),
        "endTime": _endTime?.format(context),
        "daysOfTrip": daysOfTrip,
        "description": _description,
        "meetingPoint": _meetingPoint,
        "transportation": selectedTransport,
        "accommodation": _accommodation,
        "maxParticipants": _maxParticipants,
        "tripFee": _tripFee,
        "includedServices": _includedServices,
        "contactInfo": _contactInfo,
        "whatsappInfo": _wacontactinfo,
        "tripRole":"user",
        "itemsToBring": itemsToBring,
        "guidelines": guidelinesAndRules,
        "cancellationPolicy": cancellationPolicy,
        "photos": uploadedImageUrls, // Save uploaded images in Firestore
        "createdAt": DateTime.now().toIso8601String(),
      };

      // Get Firestore references
      final tripsCollection = FirebaseFirestore.instance.collection('trips').doc(tripId);
      final userTripRef = FirebaseFirestore.instance.collection('users').doc(userId).collection('trip').doc(tripId);

      try {
        WriteBatch batch = FirebaseFirestore.instance.batch();

        // ✅ Add trip data to 'trips' collection using a fixed tripId
        batch.set(tripsCollection, tripData);

        // ✅ Store the same trip in the user's collection
        batch.set(userTripRef, tripData);

        await batch.commit();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Trip successfully hosted!')),
        );

        Navigator.push(context, MaterialPageRoute(builder: (context) => AdminNavigationPage()));
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving trip: $error')),
        );
      }

      setState(() {
        _isLoading = false; // Stop loading after process completes
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text("Host a Trip",
        style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF134277),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationPage()));
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImages,
                    icon: Icon(Icons.add_a_photo,color: Colors.black,),
                    label: Text("Add Photos"),
                    style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF8BA7E8),foregroundColor: Colors.black),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _selectedImages.isNotEmpty
                        ? Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _selectedImages.map((photo) {
                        return Stack(
                          children: [
                            Image.file(
                              File(photo.path),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedImages.remove(photo);
                                  });
                                },
                                child: Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                ),
                              ),
                            )
                          ],
                        );
                      }).toList(),
                    )
                        : Text("No photos added yet"),
                  )
                ],
              ),
              SizedBox(height: 20),
              _buildTextField(
                label: "Trip Title",
                hint: "Enter the trip title",
                onSaved: (value) => _tripTitle = value,
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
              SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.all(0.0),
                child: Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<String>.empty();
                    }
                    return _destinations.where((destination) =>
                        destination.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                  },
                  onSelected: (String selection) {
                    print('User selected: $selection');
                  },
                  fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                    return TextFormField( // ✅ Corrected: Now returning TextFormField
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: "Destination",
                        labelStyle: TextStyle(
                          color: Color(0xFF134277),
                        ),
                        hintText: "Enter the destination",
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter Destination";
                        }
                        return null;
                      },
                      onSaved: (value) => _destination = value,
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        color: Colors.white, // Background color of the suggestion box
                        elevation: 4, // Adds shadow effect
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.925, // Adjust width
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white, width: 2), // Border color
                          ),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: options.length,
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              final String option = options.elementAt(index);
                              return GestureDetector(
                                onTap: () => onSelected(option),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white, // Default item background
                                    border: Border(
                                      bottom: BorderSide(color: Colors.grey.shade300), // Border between items
                                    ),
                                  ),
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      color: Colors.black, // Custom text color
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                dropdownColor: kBackgroundColor,
                value: _selectedCategory!.isNotEmpty ? _selectedCategory : null,
                hint: Text("Select trip Category",style: TextStyle(color: Color(0xFF134277),),),
                items: tripcat.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value ?? '';  // Ensure it's not null
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select Trip Category';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintStyle: TextStyle(
                    color: Color(0xFF134277), // Hint text color
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
              SizedBox(height: 10),
              _buildDateField(
                context,
                label: "Start Date",
                date: _startDate,
                onTap: () => _selectStartDate(context),
                validator: validateStartDate,
              ),
              _buildTimeField(
                context,
                label: "Start Time",
                time: _startTime,
                onTap: () => _selectTime(context, true),
              ),
              _buildDateField(
                context,
                label: "Trip End Date",
                date: _endDate,
                onTap: () => _selectEndDate(context),
                validator: validateEndDate,
              ),
              _buildTimeField(
                context,
                label: "End Time",
                time: _endTime,
                onTap: () => _selectTime(context, false),
              ),
              _buildTextField(
                label: "Description",
                hint: "Enter trip description",
                onSaved: (value) => _description = value,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Description';
                  }
                  return null;
                },
              ),
              _buildTextField(
                label: "Meeting Point",
                hint: "Enter the meeting point",
                onSaved: (value) => _meetingPoint = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Meeting Point';
                  }
                  return null;
                },
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                dropdownColor: kBackgroundColor,
                value: transport.contains(selectedTransport) ? selectedTransport : null,
                hint: Text("Select Transportation",style: TextStyle(color: Color(0xFF134277),),),
                items: transport.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedTransport = value ?? '';  // Ensure it's not null
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select Transportation';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintStyle: TextStyle(
                    color: Color(0xFF134277), // Hint text color
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
              SizedBox(height: 8,),
              _buildTextField(
                label: "Accommodation Details",
                hint: "Enter accommodation details",
                onSaved: (value) => _accommodation = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Accommodation Details';
                  }
                  return null;
                },
              ),
              _buildTextField(
                label: "Maximum Participants",
                hint: "Enter the number of participants",
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  if (value != null && value.isNotEmpty) {
                    _maxParticipants = int.tryParse(value); // Convert String to int safely
                  }
                },
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
              _buildTextField(
                label: "Trip Fee (per person)",
                hint: "Enter the fee",
                keyboardType: TextInputType.number,
                onSaved: (value) => _tripFee = double.tryParse(value ?? ''),
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
              _buildTextField(
                label: "Included Services",
                hint: "Enter included services",
                onSaved: (value) => _includedServices = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Included Services';
                  }
                  return null;
                },
              ),
              _buildTextField(
                label: "Contact Information",
                hint: "Enter contact details",
                keyboardType: TextInputType.number,
                onSaved: (value) => _contactInfo = value,
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
              _buildTextField(
                label: "WhatsaApp contact",
                hint: "Enter WhatsaApp contact details",
                keyboardType: TextInputType.phone,
                onSaved: (value) => _wacontactinfo = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter WhatsaApp contact';
                  }
                  final phoneRegExp = RegExp(r'^[0-9]{10}$');
                  if (!phoneRegExp.hasMatch(value)) {
                    return 'Invalid WhatsApp contact details (must be 10 digits)';
                  }
                  return null;
                },
              ),
              // _buildTextField(
              //   label: "Items to Bring",
              //   hint: "Enter Items to Bring",
              //   onSaved: (value) => _itemsToBring = value,
              //   maxLines: 2,
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Please enter Items to Bring';
              //     }
              //     return null;
              //   },
              // ),
              // _buildTextField(
              //   label: "Guidelines and Rules",
              //   hint: "Enter guidelines",
              //   onSaved: (value) => _guidelines = value,
              //   maxLines: 2,
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Please enter Guidelines and Rules';
              //     }
              //     return null;
              //   },
              // ),
              // _buildTextField(
              //   label: "Cancellation Policy",
              //   hint: "Enter cancellation policy",
              //   onSaved: (value) => _cancellationPolicy = value!,
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Please enter Cancellation Policy';
              //     }
              //     return null;
              //   },
              // ),
              SizedBox(height: 7,),
              //USERNAME FIELD
              TextFormField(
                readOnly: true,
                initialValue: _hostusername,
                decoration: InputDecoration(
                  //hintText: _hostusername!.isEmpty ? 'Loading...' : _hostusername,
                  hintText: _hostusername,
                  prefixIcon: Icon(Icons.person),
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
                    onPressed: _isLoading ? null : _saveTrip,
                    child:_isLoading
                      ? CircularProgressIndicator(color: Colors.white,backgroundColor:Color(0xFF134277) ,)
                      : Text("Host Trip", style: TextStyle(fontSize: 18,color: Colors.white)),
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
    required String label,
    required String hint,
    required FormFieldSetter<String> onSaved,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,  // Optional custom validator
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Color(0xFF134277), // Hint text color// Italic style// Font size
          ),
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey, // Hint text color
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
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator ??
                (value) {
              if (value == null || value.isEmpty) {
                return "Please enter $label";
              }
              return null;
            },
        onSaved: onSaved,
      ),
    );
  }

  Widget _buildDateField(BuildContext context, {
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    required String? Function()? validator,
  }) {
    String? errorText = validator?.call(); // Call validator to check errors

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                date == null ? "Select Date" : DateFormat('yyyy-MM-dd').format(date),
                style: TextStyle(
                  fontSize: 16,
                  color: date == null ? Colors.grey : Colors.black,
                ),
              ),
              if (errorText != null) // Display validation message if there's an error
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  // child: Text(
                  //   errorText,
                  //   style: TextStyle(color: Colors.red, fontSize: 12),
                  // ),
                ),
            ],
          ),
        ),
      ),
    );
  }


  // Time Field Widget
  Widget _buildTimeField(BuildContext context, {
    required String label,
    required TimeOfDay? time,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                time != null ? time.format(context) : "Select $label",
                style: TextStyle(
                  color: time != null ? Colors.black : Color(0xFF134277),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

