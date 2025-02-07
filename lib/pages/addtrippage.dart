import 'dart:convert';

import 'package:flutter/material.dart';
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
  int? _days;
  int? _nights;
  String? _description;
  String? _meetingPoint;
  String? _accommodation;
  int? _maxParticipants;
  double? _tripFee;
  String? _includedServices;
  String? _contactInfo;
  String? _wacontactinfo;
  String? _itemsToBring;
  String? _guidelines;
  String? _cancellationPolicy;
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

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  Future<void> _pickImages() async {
    final List<XFile> selectedImages = await _picker.pickMultiImage();
    if (selectedImages.length >= 5) {
      setState(() {
        _selectedImages = selectedImages.map((file) => File(file.path)).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Select at least 5 images")),
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

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
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
        "days": _days,
        "nights": _nights,
        "description": _description,
        "meetingPoint": _meetingPoint,
        "transportation": selectedTransport,
        "accommodation": _accommodation,
        "maxParticipants": _maxParticipants,
        "tripFee": _tripFee,
        "includedServices": _includedServices,
        "contactInfo": _contactInfo,
        "whatsappInfo": _wacontactinfo,
        "itemsToBring": _itemsToBring,
        "guidelines": _guidelines,
        "cancellationPolicy": _cancellationPolicy,
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

        Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationPage()));
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
                  return null;
                },
              ),
              _buildTextField(
                label: "Destination",
                hint: "Enter the destination",
                onSaved: (value) => _destination = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Destination';
                  }
                  return null;
                },
              ),
              SizedBox(height: 5),
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
                onTap: () => _selectDate(context, true),
              ),
              _buildTimeField(
                context,
                label: "Start Time",
                time: _startTime,
                onTap: () => _selectTime(context, true),
              ),
              _buildDateField(
                context,
                label: "End Date",
                date: _endDate,
                onTap: () => _selectDate(context, false),
              ),
              _buildTimeField(
                context,
                label: "End Time",
                time: _endTime,
                onTap: () => _selectTime(context, false),
              ),
              _buildTextField(
                label: "Number of Days",
                hint: "Enter number of days",
                keyboardType: TextInputType.number,
                onSaved: (value) => _days = int.tryParse(value ?? ''),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Trip Fee (per person)';
                  }
                  return null;
                },
              ),
              _buildTextField(
                label: "Number of Nights",
                hint: "Enter number of nights",
                keyboardType: TextInputType.number,
                onSaved: (value) => _nights = int.tryParse(value ?? ''),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Number of Nights';
                  }
                  return null;
                },
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
                onSaved: (value) => _maxParticipants = int.tryParse(value ?? ''),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Maximum Participants';
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
                  if (value.length != 10) {
                    return 'Contact Information must be in 10 digit';
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
                  if (value.length != 10) {
                    return 'WhatsaApp contact must be in 10 digit';
                  }
                  return null;
                },
              ),
              _buildTextField(
                label: "Items to Bring",
                hint: "Enter Items to Bring",
                onSaved: (value) => _itemsToBring = value,
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Items to Bring';
                  }
                  return null;
                },
              ),
              _buildTextField(
                label: "Guidelines and Rules",
                hint: "Enter guidelines",
                onSaved: (value) => _guidelines = value,
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Guidelines and Rules';
                  }
                  return null;
                },
              ),
              _buildTextField(
                label: "Cancellation Policy",
                hint: "Enter cancellation policy",
                onSaved: (value) => _cancellationPolicy = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Cancellation Policy';
                  }
                  return null;
                },
              ),
              SizedBox(height: 7,),
              //USERNAME FIELD
              TextFormField(
                readOnly: true,
                initialValue: _hostusername,
                decoration: InputDecoration(
                  hintText: _hostusername!.isEmpty ? 'Loading...' : _hostusername,
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
                date != null ? DateFormat.yMMMd().format(date) : "Select $label",
                style: TextStyle(
                  color: date != null ? Colors.black : Color(0xFF134277),
                ),
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




//
// class DisplayImages extends StatelessWidget {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Uploaded Trip Photos")),
//       body: StreamBuilder(
//         stream: _firestore.collection("trips").snapshots(),
//         builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
//
//           final trips = snapshot.data!.docs;
//
//           return ListView.builder(
//             itemCount: trips.length,
//             itemBuilder: (context, index) {
//               List<String> imageUrls = List<String>.from(trips[index]["imageUrls"]);
//
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text("Trip ${index + 1}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   SizedBox(height: 10),
//                   Wrap(
//                     spacing: 8,
//                     children: imageUrls.map((url) => Image.network(url, width: 80, height: 80)).toList(),
//                   ),
//                   Divider(),
//                 ],
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
