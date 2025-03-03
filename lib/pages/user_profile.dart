import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gobuddy/pages/help_and_supprt.dart';
import 'package:gobuddy/pages/my_trip.dart';
import 'package:gobuddy/pages/saved_trip.dart';
import 'package:gobuddy/pages/setting.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import '../const.dart';
import 'navigation_page.dart';
import 'package:http/http.dart' as http;
import 'onboard_travel.dart';


class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // String profilePhotoURL='';

  bool _isEditing = false;  // To control edit mode
  String _username = '';
  String _email = '';
  String _phoneNumber = '';
  final _formKey = GlobalKey<FormState>();

  String? profileImageUrl;
  bool _isUploading = false;

  final String cloudName = "dz0shhr6k";  // Your Cloudinary cloud name
  final String uploadPreset = "gobuddy-images";  // Your Cloudinary upload preset

  Future<void> fetchProfileImageUrl() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
    if (userId.isEmpty) return;

    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (doc.exists && doc['profilePic'] != null) {
      setState(() {
        profileImageUrl = doc['profilePic'];
      });
    }
  }

  // Function to edit the profile photo
  Future<void> editProfilePhoto() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() => _isUploading = true);

    // Get the current image URL from Firestore to delete it
    String? currentImageUrl = profileImageUrl;

    // Delete the current image if it exists
    if (currentImageUrl != null && currentImageUrl.isNotEmpty) {
      await deleteImageFromCloudinary(currentImageUrl);
    }

    // Upload the new image to Cloudinary
    File imageFile = File(pickedFile.path);
    String? newImageUrl = await uploadImageToCloudinary(imageFile);

    if (newImageUrl != null) {
      await updateProfileImageUrl(newImageUrl);
    }

    setState(() => _isUploading = false);
  }

  // Function to upload image to Cloudinary
  Future<String?> uploadImageToCloudinary(File imageFile) async {
    final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
    var request = http.MultipartRequest("POST", url);
    request.fields["upload_preset"] = uploadPreset;
    request.files.add(await http.MultipartFile.fromPath("file", imageFile.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(await response.stream.bytesToString());
      return jsonResponse["secure_url"];
    } else {
      print("Cloudinary upload failed: ${response.reasonPhrase}");
      return null;
    }
  }

  // Function to update the Firestore profile image URL
  Future<void> updateProfileImageUrl(String imageUrl) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'profilePic': imageUrl,  // Update Firestore with new image URL
    });

    setState(() {
      profileImageUrl = imageUrl;
    });
  }

  Future<void> deleteProfilePhoto() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
    if (userId.isEmpty) return;

    // Fetch current user data
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (!doc.exists || doc['profilePic'] == null) {
      print("No profile image to delete.");
      return;
    }

    String profileImageUrl = doc['profilePic'];

    // Extract public_id from Cloudinary URL
    String? publicId = extractPublicId(profileImageUrl);
    if (publicId != null) {
      // Delete image from Cloudinary
      await deleteImageFromCloudinary(publicId);
    }

    // Remove profile image URL from Firestore
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'profilePic': FieldValue.delete(),  // This removes the profilePic field
    });

    print("Profile photo deleted successfully.");
  }

  Future<void> deleteImageFromCloudinary(String publicId) async {
    final String cloudName = 'dz0shhr6k'; // Your Cloudinary cloud name
    final String apiKey = '763225618255152'; // Your Cloudinary API Key
    final String apiSecret = 'DFCYPhLVFLb8pdNwwopUAPM_i8w'; // Your Cloudinary API Secret

    // Generate timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Prepare the string to sign
    final signatureString = 'public_id=$publicId&timestamp=$timestamp$apiSecret';

    // Generate the signature using SHA-1
    final signature = generateSignature(signatureString);

    // Build the URL and body for the API request
    final uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/destroy");

    final response = await http.post(
      uri,
      body: {
        "public_id": publicId,
        "api_key": apiKey,
        "signature": signature,
        "timestamp": timestamp.toString(),
      },
    );

    if (response.statusCode == 200) {
      print("Image deleted from Cloudinary");
    } else {
      print("Failed to delete image from Cloudinary: ${response.body}");
    }
  }

// Function to generate SHA-1 signature
  String generateSignature(String stringToSign) {
    final bytes = utf8.encode(stringToSign);
    final digest = sha1.convert(bytes);
    return digest.toString();
  }


// Helper function to extract public_id from Cloudinary URL
  String? extractPublicId(String imageUrl) {
    Uri uri = Uri.parse(imageUrl);
    List<String> segments = uri.pathSegments;
    if (segments.length > 1) {
      String filename = segments.last.split('.').first;
      return filename;
    }
    return null;
  }

  // Function to show options for editing or removing profile photo
  void showEditOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.edit),
              title: Text("Edit Photo"),
              onTap: () {
                Navigator.pop(context);
                editProfilePhoto();  // Trigger edit photo function
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text("Remove Photo"),
              onTap: () {
                Navigator.pop(context);
                deleteProfilePhoto();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  void initState() {
    super.initState();
    _loadUserData();
    fetchProfileImageUrl();
  }


  Future<void> _loadUserData() async {
    final User? user = _auth.currentUser;

    if (user != null) {
      try {
        // Set placeholders for immediate feedback
        setState(() {
          _email = user.email ?? 'No Email';
          _username = 'Loading...';
          _phoneNumber = 'Loading...';
          // profilePhotoURL = ''; // Placeholder for the image
        });

        // Fetch Firestore data
        final userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          final data = userDoc.data();

          // Update text fields first
          if (mounted) {
            setState(() {
              _email = data?['email'] ?? '';
              _username = data?['username'] ?? 'Unknown';
              _phoneNumber = data?['phone'] ?? 'N/A';
            });
          }
        }
      } catch (e) {
        print("Error loading user data: $e");
        // Handle errors gracefully
        if (mounted) {
          setState(() {
            _username = 'Error';
            _phoneNumber = 'Error';
            // profilePhotoURL = '';
          });
        }
      }
    } else {
      print("User not signed in.");
    }
  }

  void _editProfile() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveProfile() async {
    final User? user = _auth.currentUser;

    if (_formKey.currentState!.validate()) {
      if (user != null) {
        try {
          await _firestore.collection('users').doc(user.uid).update({
            'username': _username,
            'phone': _phoneNumber,
          });
        } catch (e) {
          // Show an error message if the update fails
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving profile: $e')),
          );
        }
        _editProfile(); // Close the edit mode if successful
      }
    } else {
      // Show an error message if validation fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields correctly.')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
        appBar: AppBar(
        title: const Text("User Profile",
        style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xFF134277),
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationPage()));
            },
          ),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(vertical: 20),
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: showEditOptions,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF134277),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF134277).withOpacity(0.3), // Shadow color
                          blurRadius: 10, // How soft the shadow looks
                          spreadRadius: 2, // Size of shadow
                          offset: Offset(4, 4), // Shadow position (X, Y)
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(3),
                    child: CircleAvatar(
                      radius: 75,
                      backgroundColor: Colors.grey[300], // Light grey background
                      backgroundImage: profileImageUrl != null && profileImageUrl!.isNotEmpty
                          ? NetworkImage(profileImageUrl!)
                          : null,
                      child: profileImageUrl == null || profileImageUrl!.isEmpty
                          ? Icon(Icons.person, size: 50, color: Colors.grey[700]) // Default icon if no image
                          : null,
                    ),
                  ),
                ),
              ),
              Card(
                color: Colors.white,
                shadowColor: Color(0xFF134277),
                elevation: 7,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: Text(
                                    'Name :',
                                    style: TextStyle(
                                        fontSize: 18)
                                )
                            ),
                            _isEditing
                                ? Expanded(
                              child: TextFormField(
                                controller: TextEditingController(text: _username),
                                onChanged: (value) => _username = value,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your username';
                                  }
                                  else if (!RegExp(r'^[a-zA-Z0-9 ]+$').hasMatch(value)) {
                                    return 'Only letters, numbers, and spaces are allowed';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: 'Enter Name',
                                  filled: true,
                                  fillColor: const Color(0xFFBFCFF3),
                                  hintStyle: const TextStyle(color: Color(0xFF3D5F8C)),
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
                                ),
                              ),
                            )
                                : Expanded(child: Text(_username, style: TextStyle(fontSize: 18))),
                          ],
                        ),
                        SizedBox(height: 10),
                        Divider(),
                        Row(
                          children: [
                            Expanded(child: Text('Email :', style: TextStyle(fontSize: 18))),
                            Expanded(child: Text(_email, style: TextStyle(fontSize: 18))),
                          ],
                        ),
                        SizedBox(height: 10),
                        Divider(),
                        Row(
                          children: [
                            Expanded(child: Text('Phone :', style: TextStyle(fontSize: 18))),
                            _isEditing
                                ? Expanded(
                              child: TextFormField(
                                controller: TextEditingController(text: _phoneNumber),
                                onChanged: (value) => _phoneNumber = value,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your Phone Number';
                                  }
                                  final phoneRegExp = RegExp(r'^[0-9]{10}$');
                                  if (!phoneRegExp.hasMatch(value)) {
                                    return 'Invalid phone number (must be 10 digits)';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: 'Enter Phone',
                                  filled: true,
                                  fillColor: const Color(0xFFBFCFF3),
                                  hintStyle: const TextStyle(color: Color(0xFF3D5F8C)),
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
                                ),
                              ),
                            )
                                : Expanded(child: Text(_phoneNumber, style: TextStyle(fontSize: 18))),
                          ],
                        ),
                        SizedBox(height: 20,),
                        Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: Center(
                            child: ElevatedButton(
                              onPressed: _isEditing ? _saveProfile : _editProfile,
                              child: Text(_isEditing ? 'Save' : 'Edit'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                shadowColor: Colors.black,
                                backgroundColor: const Color(0xFF134277),
                                elevation: 10, // Elevation
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding:
                                EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Divider(),
              Card(
                color: Colors.white,
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  leading: Icon(Iconsax.edit),
                  title: Text('Edit Profile'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfilePage()));
                  },
                ),
              ),
              SizedBox(height: 7,),
              Card(
                color: Colors.white,
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  leading: Icon(Iconsax.map),
                  title: Text('My Trips'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => MyTrip()));
                  },
                ),
              ),
              SizedBox(height: 7,),
              Card(
                color: Colors.white,
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  leading: Icon(Iconsax.save_2),
                  title: Text('Saved Trips'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => savedTripPage()));
                  },
                ),
              ),
              SizedBox(height: 7,),
              Card(
                color: Colors.white,
                elevation:2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  leading: Icon(Iconsax.setting),
                  title: Text('Settings'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
                  },
                ),
              ),
              SizedBox(height: 7,),
              Card(
                color: Colors.white,
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  leading: Icon(Iconsax.information),
                  title: Text('About GoBuddy'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AboutUsPage()));
                  },
                ),
              ),
              SizedBox(height: 7,),
              Card(
                color: Colors.white,
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  leading: Icon(Iconsax.support),
                  title: Text('Help & Support'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => HelpSupportPage()));
                  },
                ),
              ),
              SizedBox(height: 7,),
              Card(
                color: Colors.white,
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  leading: Icon(Iconsax.logout),
                  title: Text('Logout'),
                  onTap: (){
                    showDialog(
                        context: context,
                        builder: (BuildContext){
                          return AlertDialog(
                            backgroundColor: kBackgroundColor,
                            title: Text('Confirm Logout'),
                            content: Text('Are you sure you want to Log Out ?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // Close the dialog
                                },
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await FirebaseAuth.instance.signOut();
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => TravelOnBoardingScreen()));
                                },
                                child: Text('Log Out'),
                              ),
                            ],
                          );
                        }
                    );
                  },
                ),
              ),
            ],
          ),
        ),
    );
  }
}



