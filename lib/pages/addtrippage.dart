import 'dart:async';
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
import 'package:lottie/lottie.dart';

import '../models/api_service.dart';
import '../models/itinerary_model.dart';
import '../models/notification_model.dart';

class AddTripPage extends StatefulWidget {
  @override
  _AddTripPageState createState() => _AddTripPageState();
}

class _AddTripPageState extends State<AddTripPage> {
  final _formKey = GlobalKey<FormState>();
  String? userId = FirebaseAuth.instance.currentUser?.uid;

  String? _hostusername;
  String? _destination;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _wacontactinfo;

  // Itinerary? _itinerary;
  final String apiKey = 'AIzaSyC_Fdxg404-NJbwkj5BPECWmuMmPDLKLZQ';

  static const String ajapiKey = "AIzaSyC7yH2LhTEKXkBGeEuCIX-p5LOdASycP5Q";

  late GeminiApi _api;

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


  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = [];

  // final List<String> _destinations = [
  //   // 🌊 Beach Destinations
  //   "Goa, India",
  //   "Pondicherry, India",
  //   "Marina Beach, Tamil Nadu",
  //   "Dhanushkodi, Tamil Nadu",
  //   "Kanyakumari, Tamil Nadu",
  //   "Gokarna, Karnataka",
  //   "Kovalam, Kerala",
  //   "Varkala, Kerala",
  //   "Havelock Island, Andaman",
  //   "Neil Island, Andaman",
  //
  //   // 🏔️ Hill Stations
  //   "Manali, Himachal Pradesh",
  //   "Shimla, Himachal Pradesh",
  //   "Kasol, Himachal Pradesh",
  //   "Dharamshala, Himachal Pradesh",
  //   "Dalhousie, Himachal Pradesh",
  //   "Munnar, Kerala",
  //   "Ooty, Tamil Nadu",
  //   "Kodaikanal, Tamil Nadu",
  //   "Coorg, Karnataka",
  //   "Lonavala, Maharashtra",
  //   "Mahabaleshwar, Maharashtra",
  //   "Saputara, Gujarat",
  //   "Mount Abu, Rajasthan",
  //   "Chopta, Uttarakhand",
  //   "Nainital, Uttarakhand",
  //   "Mussoorie, Uttarakhand",
  //   "Shillong, Meghalaya",
  //   "Gangtok, Sikkim",
  //   "Tawang, Arunachal Pradesh",
  //
  //   // 🏜️ Desert & Cultural Trips
  //   "Jaisalmer, Rajasthan",
  //   "Jaipur, Rajasthan",
  //   "Udaipur, Rajasthan",
  //   "Bikaner, Rajasthan",
  //   "Rann of Kutch, Gujarat",
  //   "Pushkar, Rajasthan",
  //   "Jodhpur, Rajasthan",
  //
  //   // 🏞️ Nature & Wildlife
  //   "Jim Corbett National Park, Uttarakhand",
  //   "Kaziranga National Park, Assam",
  //   "Sundarbans, West Bengal",
  //   "Gir National Park, Gujarat",
  //   "Bandipur National Park, Karnataka",
  //   "Ranthambore National Park, Rajasthan",
  //   "Periyar Wildlife Sanctuary, Kerala",
  //
  //   // 🚣 Adventure & Trekking
  //   "Rishikesh, Uttarakhand",
  //   "Triund Trek, Himachal Pradesh",
  //   "Leh, Ladakh",
  //   "Spiti Valley, Himachal Pradesh",
  //   "Chandrashila Trek, Uttarakhand",
  //   "Roopkund Trek, Uttarakhand",
  //   "Zanskar Valley, Ladakh",
  //   "Sandakphu, West Bengal",
  //   "Valley of Flowers, Uttarakhand",
  //
  //   // 🏛️ Heritage & Spiritual Destinations
  //   "Varanasi, Uttar Pradesh",
  //   "Rameswaram, Tamil Nadu",
  //   "Bodh Gaya, Bihar",
  //   "Ajanta & Ellora Caves, Maharashtra",
  //   "Konark Sun Temple, Odisha",
  //   "Amritsar, Punjab",
  //   "Golden Temple, Punjab",
  //   "Dwarka, Gujarat",
  //   "Somnath, Gujarat",
  //   "Madurai, Tamil Nadu",
  //   "Tirupati, Andhra Pradesh",
  //   "Shirdi, Maharashtra",
  //   "Vaishno Devi, Jammu & Kashmir",
  //
  //   // 🌆 Metro City Trips
  //   "Mumbai, Maharashtra",
  //   "Bangalore, Karnataka",
  //   "Delhi, India",
  //   "Chennai, Tamil Nadu",
  //   "Hyderabad, Telangana",
  //   "Kolkata, West Bengal",
  //   "Ahmedabad, Gujarat",
  //   "Pune, Maharashtra",
  //
  //   // 🎭 Unique & Hidden Gems
  //   "Cherrapunji, Meghalaya",
  //   "Ziro Valley, Arunachal Pradesh",
  //   "Majuli Island, Assam",
  //   "Mawlynnong, Meghalaya",
  //   "Loktak Lake, Manipur",
  //   "Lepchajagat, West Bengal",
  //   "Hampi, Karnataka",
  //   "Gandikota, Andhra Pradesh",
  //   "Bhedaghat, Madhya Pradesh",
  //   "Pachmarhi, Madhya Pradesh",
  //   "Tawang, Arunachal Pradesh",
  // ];

  final List<String> _costLevels = ["Easy", "Medium", "Premium"];
  String? _selectedCostLevel;


  @override
  void initState() {
    super.initState();
    _api = GeminiApi(apiKey);
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
                "text": "Provide a 100-word detailed overview about $destination as a travel destination. "
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

  // 💰 Fetch Estimated Trip Cost
  Future<int> getApproxCost(String destination, int days, String costLevel) async {
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
                "text": "Estimate the approximate cost in Indian Rupees for a trip to $destination for $days days at a $costLevel budget level. "
                    "Provide only the numeric value (without symbols or text)."
              }
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String costString = data["candidates"][0]["content"]["parts"][0]["text"].toString();
      String numericCost = costString.replaceAll(RegExp(r'[^0-9]'), ''); // Extract only numbers

      return int.tryParse(numericCost) ?? 1000; // Default fallback
    } else {
      print("Error fetching cost: ${response.body}");
      return 1000; // Default fallback
    }
  }


  Future<List<String>?> _generateItinerary() async {
    if (!mounted) return null; // Check if the widget is still mounted

    final destination = _destination;
    final days = _endDate!.difference(_startDate!).inDays;

    if (destination!.isEmpty || days <= 0) {
      return null;
    }

    final itiPrompt =
        "Create a $destination itinerary for $days days in 100 words. Format it as: \n"
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

      // Validate required fields
      if (_selectedImages.length < 2 ||
          _startDate == null || _endDate == null ||
          _selectedCategory == null ||
          _selectedCostLevel == null) {  // Added _destination null check

        String errorMessage =
        _selectedImages.length < 2 ? "You must upload at least 2 images." :
        _startDate == null || _endDate == null ? "Please select both start and end dates." :
        _selectedCategory == null ? "Please select a trip category." :
        "Please select a trip cost level.";
           // Added destination validation

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
        return;
      }

      // Start loading
      setState(() {
        _isLoading = true;
      });

      try {
        int daysOfTrip = _calculateDaysOfTrip();
        String destination = _destination ?? ""; // Safe fallback for _destination
        // 📝 Get Trip Overview
        String tripOverview = await getTripOverview(destination);

        // 💰 Get Estimated Cost
        int approxCost = await getApproxCost(destination, daysOfTrip, _selectedCostLevel!);
        List<String>? itineraryText = await _generateItinerary();

        // Upload images
        List<String> uploadedImageUrls = await _uploadAllImages();
        if (uploadedImageUrls.isEmpty) {
          throw Exception("Failed to upload images. Please try again.");
        }

        // Generate a unique trip ID
        String tripId = FirebaseFirestore.instance
            .collection('trips')
            .doc()
            .id;

        final tripData = {
          "tripId": tripId,
          "hostId": userId,
          "hostUsername": _hostusername,
          "destination": destination,
          "tripCategory": _selectedCategory,
          "startDate": _startDate?.toIso8601String(),
          "endDate": _endDate?.toIso8601String(),
          "daysOfTrip": daysOfTrip,
          "costLevel": _selectedCostLevel,
          "approxCost": approxCost,
          "tripOverview": tripOverview,
          "itinerary": itineraryText,
          "whatsappInfo": _wacontactinfo,
          "tripRole": "user",
          "tripDone": false,
          "isApproved":false,
          "photos": uploadedImageUrls, // Store uploaded images in Firestore
          "createdAt": DateTime.now().toIso8601String(),
        };

        // Get Firestore references
        final tripsCollection = FirebaseFirestore.instance.collection('trips')
            .doc(tripId);
        final userTripRef = FirebaseFirestore.instance.collection('users').doc(
            userId).collection('trip').doc(tripId);

        // Use Firestore batch for atomic writes
        WriteBatch batch = FirebaseFirestore.instance.batch();
        batch.set(tripsCollection, tripData);
        batch.set(userTripRef, tripData);
        await batch.commit();

        FirebaseService().sendNotificationToAdmin(tripId, userId!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Trip successfully hosted! It will be visible to users after admin approval.'),
          ),
        );

        Navigator.push(
            context, MaterialPageRoute(builder: (context) => NavigationPage()));
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving trip: $error'),
              backgroundColor: Colors.red),
        );
      }

      // Stop loading
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<String> _suggestions = [];


  Future<void> fetchSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    setState(() => _isLoading = true);

    final url = Uri.parse(
        'https://api.geoapify.com/v1/geocode/autocomplete?text=$query&apiKey=281c107a40344c3cb70e824e591654fe'
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        List<String> newSuggestions = (data['features'] as List)
            .map<String>((item) => item['properties']['formatted'].toString())
            .toList();

        setState(() {
          _suggestions = newSuggestions;
          _isLoading = false;
        });

        print("✅ Suggestions: $_suggestions");
      } else {
        print("❌ API Error: ${response.statusCode}");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("❌ Error fetching suggestions: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text("Create Trip",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
              // Destination Input
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) async {
            await fetchSuggestions(textEditingValue.text);
            return _suggestions;
          },
          onSelected: (String selection) {
            setState(() {
              _destination = selection;  // Store the selected destination in _destination
            });
            print('User selected: $_destination');
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: "Destination",
                labelStyle: TextStyle(color: Color(0xFF134277)),
                hintText: "Enter the destination",
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF8BA7E8), width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF134277), width: 2),
                ),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                color: Colors.white,
                elevation: 4,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.925,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: _isLoading
                      ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                      : ListView.builder(
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
                            color: Colors.white,
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: Text(
                            option,
                            style: TextStyle(color: Colors.black),
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

              SizedBox(height: 15),
              // Date Pickers in one row
              Row(
                children: [
                  Expanded(child: _buildDateSelector("Start Date", _startDate, () => _selectStartDate(context),)),
                  SizedBox(width: 12),
                  Expanded(child: _buildDateSelector("End Date", _endDate, () => _selectEndDate(context),)),
                ],
              ),
              SizedBox(height: 15),

              // Trip Category Selection with Chips
              _buildTitle("Trip Category"),
              Wrap(
                spacing: 10,
                children: tripcat.map((category) {
                  return ChoiceChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    selectedColor: Color(0xFF134277),
                    backgroundColor: Colors.grey[200],
                    showCheckmark: false,
                    labelStyle: TextStyle(color: _selectedCategory == category ? Colors.white : Colors.black),
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? category : null;
                      });
                    },
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Color(0xFF8BA7E8), width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 10),

              // Trip Cost Level Selection
              _buildTitle("Trip Cost Level"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _costLevels.map((cost) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCostLevel = cost;
                      });
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width*0.29,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: _selectedCostLevel == cost
                            ? LinearGradient(colors: [Color(0xFF134277), Color(0xFF134277)])
                            : LinearGradient(colors: [Colors.grey[200]!, Colors.grey[200]!]),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _selectedCostLevel == cost ? Color(0xFF134277) : Colors.grey[400]!, // Border color
                          width: 2, // Border width
                        ),
                      ),
                      child: Center(
                        child: Text(cost,
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: _selectedCostLevel == cost ? Colors.white : Colors.black)),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 15),

              // WhatsApp Contact Field
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
              SizedBox(height: 15),

              // Submit Button
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
                        : Text("Create Trip", style: TextStyle(fontSize: 18,color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildDateSelector(String label, DateTime? date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: Color(0xFF8BA7E8), // Border color
            width: 2, // Border width
          ),
          borderRadius: BorderRadius.circular(8),
        ),        child: Center(
          child: Text(date == null ? label : DateFormat('dd MMM yyyy').format(date),
              style: TextStyle(fontWeight: FontWeight.w400,color: Colors.black)),
        ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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

