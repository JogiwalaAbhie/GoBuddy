import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:gobuddy/Admin/admin_navigation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../const.dart';
import '../models/api_service.dart';

class AdminAddTripPage extends StatefulWidget {
  const AdminAddTripPage({super.key});

  @override
  State<AdminAddTripPage> createState() => _AdminAddTripPageState();
}

class _AdminAddTripPageState extends State<AdminAddTripPage> {

  // Itinerary? _itinerary;
  final String apiKey = 'AIzaSyC_Fdxg404-NJbwkj5BPECWmuMmPDLKLZQ';

  static const String ajapiKey = "AIzaSyC7yH2LhTEKXkBGeEuCIX-p5LOdASycP5Q";

  late GeminiApi _api;

  final _formKey = GlobalKey<FormState>();
  String? userId = FirebaseAuth.instance.currentUser?.uid;

  String? _tripTitle;
  String? _hostusername;
  String? _destination;
  String? _meetingPoint;
  String? _accommodation;
  int? _maxParticipants;
  double? _tripFee;
  String? _wacontactinfo;
  String fromLocation = "";
  String toLocation = "";

  DateTime? _startDateTime;
  DateTime? _endDateTime;

  String itemsToBring = "Valid ID proof\nComfortable clothing\nWater bottle\nPersonal medications";
  String guidelinesAndRules = "No littering in the area\nRespect local culture\nFollow the guide’s instructions\nNo smoking in restricted areas\nPets are not allowed";
  String cancellationPolicy = "Full refund if canceled 48 hours before\n50% refund if canceled 24 hours before\nNo refund for cancellations within 24 hours";

  bool _isLoading = false;

  String? _selectedCategory = "";
  final List<String> tripcat = [
    "Adventure",
    "Beach Vacations",
    "Historical Tours",
    "Road Trips",
    "Volunteer & Humanitarian",
    "Wellness"
  ];

  String? selectedTransport;
  List<String> transport = ["Car", "Bus", "Train", "Flight"];

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

  List<String> allServices = [
    "Transport", "Food & Drinks", "Tour Guide",
    "Emergency Help", "Luggage Support",
    "WiFi & Entertainment", "Photography"
  ];
  List<String> _includedServices = [];

  // Function to pick a date & time
  Future<DateTime?> _pickDateTime(BuildContext context, {DateTime? firstDate}) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: firstDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return null; // User canceled

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) return null; // User canceled

    return DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchhostUsername();
    _api = GeminiApi(apiKey);
  }

  Future<void> _fetchhostUsername() async {
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

  int _calculateDaysOfTrip() {
    if (_startDateTime != null && _endDateTime != null) {
      return _endDateTime!.difference(_startDateTime!).inDays;
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

  // 🌍 Fetch Trip Overview
  Future<String> getTripOverview(String destination) async {
    final String apiUrl =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$ajapiKey";

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text": "Provide a 70-word detailed overview about $destination as a travel destination. "
                    "Mention key attractions, culture, food, and unique experiences."
              }
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["candidates"][0]["content"]["parts"][0]["text"] ??
          "Discover the beauty of $destination!";
    } else {
      print("Error fetching trip overview: ${response.body}");
      return "Unable to fetch trip details.";
    }
  }

  Future<List<String>?> _generateItinerary() async {
    if (!mounted) return null; // Check if the widget is still mounted

    final destination = _destination;
    final days = _calculateDaysOfTrip();
    final from = fromLocation;
    final to = toLocation;

    if (destination!.isEmpty || days <= 0) {
      return null;
    }

    final itiPrompt =
        "Create a $destination itinerary for $days days based on $from to $to ,Each day in 50 words. Format it as: \n"
        "\n"
        "Day 2: [plan]\n"
        "Day 3: [plan]...\n"
        "Do not use '*' or bullet points.";

    try {
      final itinerary = await _api.generateItinerary(itiPrompt);

      // Extract text from API response
      final itineraryText = itinerary?.candidates[0].content.parts[0].text;

      // Split itinerary into separate days
      List<String> itineraryDays = itineraryText!.split(RegExp(r'\nDay \d+: '))
          .where((element) => element.isNotEmpty)
          .toList();

      return itineraryDays;
    } catch (e) {
      print("Error in _generateItinerary: $e");
      return null;
    }
  }

  Future<void> _saveTrip() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("You need to be logged in to host a Trip."),
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
      String destination = _destination ?? ""; // Safe fallback for _destination
      // 📝 Get Trip Overview
      String tripOverview = await getTripOverview(destination);

      List<String>? itineraryText = await _generateItinerary();

      // ✅ Generate a unique trip ID
      String tripId = FirebaseFirestore.instance.collection('trips').doc().id;

      final tripData = {
        "tripId": tripId,
        "hostId": userId,
        "hostUsername": _hostusername,
        "tripTitle": _tripTitle,
        "destination": _destination,
        "from":fromLocation,
        "to":toLocation,
        "tripCategory": _selectedCategory,
        "startDateTime": _startDateTime!.toIso8601String(),
        "endDateTime": _endDateTime!.toIso8601String(),
        "daysOfTrip": daysOfTrip,
        "description": tripOverview,
        "itinerary": itineraryText,
        "meetingPoint": _meetingPoint,
        "transportation": selectedTransport,
        "accommodation": _accommodation,
        "maxParticipants": _maxParticipants,
        "tripFee": _tripFee,
        "includedServices": _includedServices,
        "whatsappInfo": _wacontactinfo,
        "tripRole": "admin",
        "popular":false,
        "tripDone":false,
        "itemsToBring": itemsToBring,
        "guidelines": guidelinesAndRules,
        "cancellationPolicy": cancellationPolicy,
        "photos": uploadedImageUrls,
        "createdAt": DateTime.now().toIso8601String(),
      };

      // ✅ Firestore references
      final tripsRef = FirebaseFirestore.instance.collection('trips').doc(tripId);
      final adminRef = FirebaseFirestore.instance.collection('admin').doc(tripId);
      final userTripRef = FirebaseFirestore.instance.collection('users').doc(userId).collection('trip').doc(tripId);

      try {
        WriteBatch batch = FirebaseFirestore.instance.batch();

        // ✅ Store trip in general trips collection (`trips/{tripId}`)
        batch.set(tripsRef, tripData);

        // ✅ Store trip in admin collection (`admin/{tripId}`)
        batch.set(adminRef, tripData);

        // ✅ Store trip in user's trip subcollection (`users/{userId}/trip/{tripId}`)
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
            Navigator.push(context, MaterialPageRoute(builder: (context) => AdminNavigationPage()));
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
                                    color: kBackgroundColor, // Default item background
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
              SizedBox(height: 10),
              //From To
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: "From",
                      hint: "Enter starting location",
                      onSaved: (value) => fromLocation = value!,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Trip location';
                        }
                        final usernameRegExp = RegExp(r'^[a-zA-Z]');
                        if (!usernameRegExp.hasMatch(value)) {
                          return 'Invalid Trip location';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 10), // Space between fields
                  Expanded(
                    child: _buildTextField(
                      label: "To",
                      hint: "Enter destination",
                      onSaved: (value) => toLocation = value!,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Trip destination';
                        }
                        final usernameRegExp = RegExp(r'^[a-zA-Z]');
                        if (!usernameRegExp.hasMatch(value)) {
                          return 'Invalid Trip destination';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              //Trip Category
              Text("Trip Category : ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              SizedBox(height: 6),
              Wrap(
                spacing: 8, // Space between chips
                children: tripcat.map((category) {
                  return ChoiceChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? category : ''; // Toggle selection
                      });
                    },
                    showCheckmark: false,
                    selectedColor: Color(0xFF134277), // Color when selected
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

              //Date Time
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildDateTimeSelector(
                      label: "Start Date & Time",
                      dateTime: _startDateTime,
                      onTap: () async {
                        DateTime? selected = await _pickDateTime(context);
                        if (selected != null) {
                          setState(() {
                            _startDateTime = selected;
                            _endDateTime = null; // Reset end date when start changes
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
                          firstDate: _startDateTime ?? DateTime.now(),
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
              Text("Transportation : ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: transport.map((category) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTransport = category;
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
              SizedBox(height: 8),
              Text("Included Services:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: allServices.map((service) {
                  return ChoiceChip(
                    showCheckmark: false,
                    label: Text(service),
                    selected: _includedServices.contains(service),
                    onSelected: (selected) {
                      setState(() {
                        selected
                            ? _includedServices.add(service)
                            : _includedServices.remove(service);
                      });
                    },
                    selectedColor: Color(0xFF134277), // Selected color
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
              _buildTextField(
                label: "WhatsApp contact",
                hint: "Enter WhatsApp contact details",
                keyboardType: TextInputType.phone,
                onSaved: (value) => _wacontactinfo = value,
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
                    onPressed: _isLoading ? null : _saveTrip,
                    child:_isLoading
                        ? CircularProgressIndicator()
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

  Widget _buildDateTimeSelector({required String label, required DateTime? dateTime, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xFF8BA7E8), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            dateTime == null ? label : DateFormat('dd/MM/yyyy, hh:mm a').format(dateTime),
            style: TextStyle(fontWeight: FontWeight.w400, color: Color(0xFF134277),),
          ),
        ),
      ),
    );
  }
}

