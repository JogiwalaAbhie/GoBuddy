import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gobuddy/const.dart';
import 'package:gobuddy/pages/onboard_travel.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  bool _isNotificationEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationSetting();
    _checkAndUpdateNotification(); // Ensure sync with system settings
  }

  // Load stored notification setting from SharedPreferences
  Future<void> _loadNotificationSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isEnabled = prefs.getBool('notifications_enabled') ?? false;
    setState(() {
      _isNotificationEnabled = isEnabled;
    });
  }

  // Save notification setting to SharedPreferences
  Future<void> _saveNotificationSetting(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() {
      _isNotificationEnabled = value;
    });
  }

  // Check permission status and update the toggle
  Future<void> _checkAndUpdateNotification() async {
    var status = await Permission.notification.status;
    bool isGranted = status.isGranted;

    setState(() {
      _isNotificationEnabled = isGranted;
    });

    await _saveNotificationSetting(isGranted); // Save updated status
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kBackgroundColor,
        title: Text('Delete Account'),
        content: Text('Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await _deleteUserAccount();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUserAccount() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
        await user.delete();
        await FirebaseAuth.instance.signOut();
        Navigator.push(context, MaterialPageRoute(builder: (context) => TravelOnBoardingScreen()));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account delete Succesfully..')),
        );
      }
    } catch (e) {
      print('Error deleting account: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete account. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text("Settings",
          style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF134277),
      ),
      body: ListView(
        children: [
          // Account Settings
          _buildSectionTitle('Account Settings'),
          _buildSettingsTile(Icons.person, 'Edit Profile', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfilePage()));
          }),
          _buildSettingsTile(Icons.lock, 'Change Password', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePasswordScreen()));
          }),
          _buildSettingsTile(Icons.delete, 'Delete Account', () {
            _confirmDeleteAccount(context);
          }),

          Divider(),

          // Notification Settings
          _buildSectionTitle('Notifications'),
          SwitchListTile(
            title: Text("Enable Notifications"),
            value: _isNotificationEnabled,
            onChanged: (bool value) async {
              if (value) {
                var status = await Permission.notification.request();
                if (status.isGranted) {
                  _saveNotificationSetting(true);
                } else {
                  _saveNotificationSetting(false);
                }
              } else {
                _saveNotificationSetting(false);
              }
              _checkAndUpdateNotification(); // Re-check and update toggle
            },
          ),

          Divider(),

          // Privacy & Security
          _buildSectionTitle('Privacy & Security'),
          _buildSettingsTile(Icons.visibility, 'Profile Visibility', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileVisibilityPage()));
          }),
          _buildSettingsTile(Icons.lock_outline, 'Who Can See My Trips?', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => WhoCanSeeMyTripsPage()));
          }),

          Divider(),

          // Help & Support
          _buildSectionTitle('Help & Support'),
          _buildSettingsTile(Icons.help, 'Help Center', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => HelpCenterPage()));
          }),
          _buildSettingsTile(Icons.support_agent, 'Contact Support', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ContactSupportPage()));
          }),
          _buildSettingsTile(Icons.report_problem, 'Report a Problem', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ReportProblemPage()));
          }),

          Divider(),

          // Legal & About
          _buildSectionTitle('Legal & About'),
          _buildSettingsTile(Icons.description, 'Terms & Conditions', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => TermsConditionsPage()));
          }),
          _buildSettingsTile(Icons.privacy_tip, 'Privacy Policy', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => PrivacyPolicyPage()));
          }),
          _buildSettingsTile(Icons.info, 'App Version 1.0.0', null, showArrow: false),
          Divider(),
          Text('© 2025 GoBuddy. All rights reserved.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
          SizedBox(height: 15,)
        ],
      ),
    );
  }

  // Section Title
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Color(0xFF134277)),
      ),
    );
  }

  // Regular List Tile
  Widget _buildSettingsTile(IconData icon, String title, VoidCallback? onTap, {bool showArrow = true}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: showArrow ? Icon(Icons.arrow_forward_ios, size: 16) : null,
      onTap: onTap,
    );
  }

  // Switch Tile
  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }
}

//About Us Page
class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text("About Us",
          style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF134277),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('Welcome to GoBuddy!',
              style: TextStyle(color: Color(0xFF134277),fontWeight: FontWeight.w500,fontSize: 22),),
            Divider(),
            _buildSection(
              title: 'What is GoBuddy?',
              content:
              'GoBuddy is your ultimate travel companion, designed to connect like-minded travelers, host trips, and help you discover new adventures. Whether you\'re a solo traveler or love exploring with friends, GoBuddy provides a platform for planning, joining, and sharing unforgettable travel experiences.',
            ),
            Divider(),
            _buildSection(
              title: 'Our Mission',
              content:
              'At GoBuddy, our mission is to make travel easy, enjoyable, and social. We aim to create a seamless experience where travelers can organize trips, share exciting destinations, and connect with others who share the same passion for exploring the world.',
            ),
            Divider(),
            _buildSection(
              title: 'Features of GoBuddy',
              content:
              '- Host Trips: Plan and host trips for your friends or others.\n'
                  '- Join Trips: Discover trips hosted by others and join them.\n'
                  '- Chat with Fellow Travelers: Use our in-app chat feature to connect with fellow travelers.\n'
                  '- Trip Planning: Organize trip details like dates, destinations, and activities all in one place.\n'
                  '- Ratings & Reviews: Rate and review trips and hosts to help others make informed decisions.\n'
                  '- Support: Get help and support whenever you need it with our dedicated customer service.',
            ),
            Divider(),
            _buildSection(
              title: 'Why Choose GoBuddy?',
              content:
              'GoBuddy is not just another travel app; it\'s a community of passionate travelers. With our easy-to-use interface, collaborative trip planning features, and focus on socializing, GoBuddy provides a unique platform that makes traveling fun and easy.',
            ),
            Divider(),
            _buildSection(
              title: 'Our Values',
              content:
              '- Community: We believe in the power of connecting with like-minded individuals who share the same travel passion.\n'
                  '- Safety: We prioritize the safety of our users by offering secure trip planning and communication features.\n'
                  '- Sustainability: We encourage responsible travel by promoting eco-friendly trips and supporting local communities.\n'
                  '- Adventure: We inspire users to step out of their comfort zones and explore the world, embracing new cultures and experiences.',
            ),
            Divider(),
            _buildSection(
              title: 'Security & Privacy',
              content:
              'Your security and privacy are important to us. GoBuddy takes all necessary measures to protect your personal data, including using encryption and adhering to strict data privacy policies. We will never share your personal details with third parties without your consent, and you have full control over your account settings and data.',
            ),
            Divider(),
            _buildSection(
              title: 'How We Keep Your Data Safe',
              content:
              '- Encrypted Data Storage: All sensitive data, including passwords and personal information, is securely encrypted.\n'
                  '- Two-Factor Authentication: We offer two-factor authentication (2FA) for an added layer of security.\n'
                  '- Regular Security Audits: We conduct regular audits to ensure our app is up-to-date with the latest security practices.',
            ),
            Divider(),
            _buildSection(
              title: 'Contact Us',
              content:
              'We would love to hear from you! If you have any questions, feedback, or suggestions, feel free to contact us at:\n\n'
                  'Email: support@gobuddy.com\n'
                  'Phone: +91 7201821370\n',
            ),
            Divider(),
            _buildSection(
              title: 'Feedback & Suggestions',
              content:
              'Your feedback helps us improve the GoBuddy experience! If you have any suggestions for new features, or if you have encountered an issue while using the app, please let us know by contacting us at support@gobuddy.com. We appreciate your input and strive to make GoBuddy the best travel companion for everyone.',
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to display a section with title and content
  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500,color: Colors.black),
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(color: Colors.black45,fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Helper function for the title at the top of the page
  Widget _buildTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }
}


//Edit Profile Page
class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _addressController = TextEditingController();
  final _dobController = TextEditingController();
  DateTime _dob = DateTime.now();

  String _currentUsername = '';
  String _currentPhone = '';
  String _currentBio = '';
  String _currentAddress = '';
  String _currentDob = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch the current user's data from Firestore
  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          // Safely access fields using the `data()` method
          var userData = userDoc.data() as Map<String, dynamic>;

          // Check if the 'bio' field is missing, and if so, set a default value
          if (userData['bio'] == null) {
            await _firestore.collection('users').doc(user.uid).update({
              'bio': '', // Set a default value for 'bio'
            });
            print("Bio field was missing and is now created with a default value.");
          }

          // Use safe null checking for other fields
          setState(() {
            _currentUsername = userData['username'] ?? ''; // Default if not found
            _currentPhone = userData['phone'] ?? ''; // Default if not found
            _currentBio = userData['bio'] ?? ''; // Default if not found
            _currentAddress = userData['address'] ?? ''; // Default if not found
            _currentDob = userData['dob'] ?? ''; // Default if not found

            // Assign to the controllers
            _usernameController.text = _currentUsername;
            _phoneController.text = _currentPhone;
            _bioController.text = _currentBio;
            _addressController.text = _currentAddress;
            _dobController.text = _currentDob;
          });
        } else {
          print("User document does not exist.");
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  // Save the updated profile information
  Future<void> _saveProfile() async {
    User? user = _auth.currentUser;
    if (formKey.currentState!.validate() ?? false) {
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'username': _usernameController.text,
          'phone': _phoneController.text,
          'bio': _bioController.text,
          'address': _addressController.text,
          'dob': DateFormat('MM/dd/yyyy').format(_dob),
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Profile updated successfully!"),
          backgroundColor: Colors.green,
        ));
        Navigator.pop(context);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _dob, // current date
      firstDate: DateTime(1900), // earliest possible date
      lastDate: DateTime(2100), // latest possible date
    );

    if (selectedDate != null && selectedDate != _dob) {
      setState(() {
        _dob = selectedDate;
        _dobController.text = DateFormat('MM/dd/yyyy').format(_dob); // Format the selected date
      });
    }
  }

  String? _validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date of Birth is required!';
    }

    // Check if the selected date is not the default date (today)
    if (_dob.isBefore(DateTime(1900)) || _dob.isAfter(DateTime.now())) {
      return 'Please select a valid date!';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text("Edit Profile",
          style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF134277),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 30),
                Text(
                  textAlign: TextAlign.center,
                  'Edit Your Profile',
                  style: TextStyle(color: Colors.black,fontSize: 24, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 30),
                
                // Username field
                TextFormField(
                  controller: _usernameController,
                  style: const TextStyle(fontSize: 15),
                  autocorrect: true,
                  enableSuggestions: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    final usernameRegExp = RegExp(r'^[a-zA-Z][a-zA-Z0-9_]{2,14}$');
                    if (!usernameRegExp.hasMatch(value)) {
                      return 'Invalid username (3-15 chars, letters, numbers, _)';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Username",
                    hintStyle: const TextStyle(color: Color(0xFF3D5F8C)),
                    prefixIcon: const Icon(Iconsax.user, color: Colors.black),
                    filled: true,
                    fillColor: const Color(0xFFBFCFF3),
                    border: InputBorder.none,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFBFCFF3), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFBFCFF3), width: 2),
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
                
                // Phone number field
                TextFormField(
                  controller: _phoneController,
                  style: const TextStyle(fontSize: 15),
                  autocorrect: true,
                  keyboardType: TextInputType.phone,
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
                    hintText: "Phone number",
                    hintStyle: const TextStyle(color: Color(0xFF3D5F8C)),
                    prefixIcon: const Icon(Iconsax.call, color: Colors.black),
                    filled: true,
                    fillColor: const Color(0xFFBFCFF3),
                    border: InputBorder.none,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFBFCFF3), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFBFCFF3), width: 2),
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
                
                // Bio field (Additional Info)
                TextFormField(
                  controller: _bioController,
                  style: const TextStyle(fontSize: 15),
                  autocorrect: true,
                  enableSuggestions: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Bio';
                    }
                    if (value.length < 10) {
                      return 'Bio must be at least 10 characters long';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText : "Bio",
                    hintStyle: const TextStyle(color: Color(0xFF3D5F8C)),
                    prefixIcon: const Icon(Icons.info_outline, color: Colors.black),
                    filled: true,
                    fillColor: const Color(0xFFBFCFF3),
                    border: InputBorder.none,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFBFCFF3), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFBFCFF3), width: 2),
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
                
                // Address field
                TextFormField(
                  controller: _addressController,
                  style: const TextStyle(fontSize: 15),
                  autocorrect: true,
                  enableSuggestions: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Address';
                    }
                    if (value.length < 10) {
                      return 'Address must be at least 10 characters long';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Address",
                    hintStyle: const TextStyle(color: Color(0xFF3D5F8C)),
                    prefixIcon: const Icon(Icons.location_on_outlined, color: Colors.black),
                    filled: true,
                    fillColor: const Color(0xFFBFCFF3),
                    border: InputBorder.none,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFBFCFF3), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFBFCFF3), width: 2),
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
                
                // Date of Birth field
                TextFormField(
                  controller: _dobController,
                  validator: _validateDate,
                  style: const TextStyle(fontSize: 15),
                  decoration: InputDecoration(
                    hintText: "Date of birth",
                    suffixIcon: Icon(Icons.calendar_today),
                    hintStyle: const TextStyle(color: Color(0xFF3D5F8C)),
                    prefixIcon: const Icon(Icons.date_range, color: Colors.black),
                    filled: true,
                    fillColor: const Color(0xFFBFCFF3),
                    border: InputBorder.none,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFBFCFF3), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFBFCFF3), width: 2),
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
                  onTap: () {
                    _selectDate(context); // Open the Date Picker
                  },
                  readOnly: true, // Prevent typing, just for selecting date
                ),
                SizedBox(height: 20),
                SizedBox(height: 20),
                
                // Save button
                Container(
                  width: MediaQuery.of(context).size.width*0.8,
                  height: 60,
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    child: Text("Save Changes",
                      style: const TextStyle(
                        color: Color(0xFFF2F5F1),
                        fontWeight: FontWeight.w500,
                        fontSize: 20),),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      shadowColor: Colors.black,
                      backgroundColor: const Color(0xFF134277),
                      elevation: 10, // Elevation
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                  ),
                ),
                ),
                const SizedBox(height: 20.0),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Go back to login screen
                  },
                  child: const Text(
                    'Back',
                    style: TextStyle(fontSize: 16, color: Color(0xFF134277),),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



//Profile visibility page code
class ProfileVisibilityPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text("Profile Visibility",
          style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF134277),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile Visibility',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 10),
              Text(
                'Choose who can see your profile on the app. You can select between public, only friends, or private visibility.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              ListTile(
                title: Text("Public"),
                subtitle: Text("Your profile will be visible to everyone."),
                leading: Radio<String>(
                  value: "public",
                  groupValue: "private", // This should be a variable that holds the selected option
                  onChanged: (String? value) {
                    // Save selected value in Firebase or SharedPreferences
                  },
                ),
              ),
              ListTile(
                title: Text("Only Friends"),
                subtitle: Text("Only your friends can see your profile."),
                leading: Radio<String>(
                  value: "friends",
                  groupValue: "private", // This should be a variable that holds the selected option
                  onChanged: (String? value) {
                    // Save selected value in Firebase or SharedPreferences
                  },
                ),
              ),
              ListTile(
                title: Text("Private"),
                subtitle: Text("Only you can see your profile."),
                leading: Radio<String>(
                  value: "private",
                  groupValue: "private", // This should be a variable that holds the selected option
                  onChanged: (String? value) {
                    // Save selected value in Firebase or SharedPreferences
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



//who can see my trips code page
class WhoCanSeeMyTripsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text("Who can see My trips ?",
          style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF134277),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Who Can See My Trips?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 10),
              Text(
                'Select who can see your trips on the app. You can choose between public, only friends, or just you.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              ListTile(
                title: Text("Public"),
                subtitle: Text("Everyone can see your trips."),
                leading: Radio<String>(
                  value: "public",
                  groupValue: "public", // This should be a variable that holds the selected option
                  onChanged: (String? value) {
                    // Save selected value in Firebase or SharedPreferences
                  },
                ),
              ),
              ListTile(
                title: Text("Only Friends"),
                subtitle: Text("Only your friends can see your trips."),
                leading: Radio<String>(
                  value: "friends",
                  groupValue: "public", // This should be a variable that holds the selected option
                  onChanged: (String? value) {
                    // Save selected value in Firebase or SharedPreferences
                  },
                ),
              ),
              ListTile(
                title: Text("Private"),
                subtitle: Text("Only you can see your trips."),
                leading: Radio<String>(
                  value: "private",
                  groupValue: "public", // This should be a variable that holds the selected option
                  onChanged: (String? value) {
                    // Save selected value in Firebase or SharedPreferences
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



//Terms and Conditions Page code
class TermsConditionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text("Terms & Conditions",
          style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF134277),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1. Introduction\n\n'
                  'Welcome to GoBuddy. These Terms & Conditions ("Terms") govern your use of our mobile application, website, and services (the "Services"). By accessing or using the Services, you agree to comply with and be bound by these Terms. If you do not agree with any part of these Terms, you must discontinue use of our Services.\n\n'
                  '2. User Accounts\n\n'
                  'To access certain features of the Services, you may be required to create an account. You are responsible for maintaining the confidentiality of your account credentials. You agree to notify us immediately if you suspect any unauthorized use of your account.\n\n'
                  '3. User Responsibilities\n\n'
                  'You agree to use the Services in a lawful manner and in compliance with all applicable laws and regulations. You may not use the Services to transmit harmful or unlawful content. GoBuddy reserves the right to suspend or terminate your access if you violate any of these terms.\n\n'
                  '4. Prohibited Uses\n\n'
                  'You may not use the Services to:\n'
                  '• Engage in any activity that violates the rights of others;\n'
                  '• Transmit any viruses, malware, or other harmful components;\n'
                  '• Engage in data scraping, mining, or any automated access of our Services.\n\n'
                  '5. Limitation of Liability\n\n'
                  'GoBuddy is not liable for any damages or losses that may occur as a result of using our Services, including but not limited to loss of data or business interruption. You use the Services at your own risk.\n\n'
                  '6. Indemnification\n\n'
                  'You agree to indemnify and hold harmless GoBuddy and its affiliates, officers, and employees from any claims, damages, or expenses arising from your use of the Services or any violation of these Terms.\n\n'
                  '7. Modifications\n\n'
                  'GoBuddy reserves the right to modify or terminate the Services, or any part of them, at any time without notice. We may update these Terms from time to time, and it is your responsibility to review them periodically.\n\n'
                  '8. Privacy and Data Protection\n\n'
                  'Your use of the Services is also governed by our Privacy Policy, which outlines how we collect, use, and protect your personal information. Please review the Privacy Policy for more details.\n\n'
                  '9. Governing Law and Dispute Resolution\n\n'
                  'These Terms are governed by the laws of the jurisdiction in which GoBuddy operates. Any disputes arising from these Terms shall be resolved through binding arbitration, rather than in court.\n\n'
                  '10. Contact Us\n\n'
                  'If you have any questions regarding these Terms, please contact us at support@gobuddy.com.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 15,)
          ],
        ),
      ),
    );
  }
}



//Privacy Policy Page code
class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text("Privacy Policy",
          style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF134277),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1. Introduction\n\n'
                  'At GoBuddy, we value your privacy. This Privacy Policy explains how we collect, use, and protect your personal information when you use our mobile app, website, or other services (the "Services"). By using our Services, you consent to the practices described in this policy.\n\n'
                  '2. Information We Collect\n\n'
                  'We collect several types of information when you use our Services:\n'
                  '• Personal Information: When you register for an account, we collect your name, email address, phone number, and other information you provide.\n'
                  '• Usage Data: We collect information on how you use the Services, including IP addresses, device type, and pages visited.\n'
                  '• Location Data: If enabled, we collect your location to provide location-based services.\n\n'
                  '3. How We Use Your Information\n\n'
                  'We use the information we collect for various purposes, including:\n'
                  '• To provide and maintain our Services;\n'
                  '• To personalize your experience;\n'
                  '• To send you updates and notifications;\n'
                  '• To improve our Services and resolve issues;\n'
                  '• To comply with legal obligations.\n\n'
                  '4. Data Sharing\n\n'
                  'We do not sell, rent, or lease your personal information to third parties. However, we may share your data with:\n'
                  '• Trusted third-party service providers who assist us in operating our Services;\n'
                  '• Law enforcement or other governmental authorities when required by law;\n'
                  '• Our business partners if you request services from them through our platform.\n\n'
                  '5. Data Security\n\n'
                  'We implement reasonable security measures to protect your personal information from unauthorized access, alteration, or destruction. However, no method of transmission over the internet is 100% secure, so we cannot guarantee the absolute security of your data.\n\n'
                  '6. Data Retention\n\n'
                  'We retain your personal information for as long as necessary to fulfill the purposes outlined in this Privacy Policy or as required by law. You may request the deletion of your account and personal data at any time by contacting us.\n\n'
                  '7. Cookies and Tracking Technologies\n\n'
                  'We use cookies and similar tracking technologies to enhance your experience on our Services. Cookies allow us to store preferences, improve performance, and gather analytics data.\n\n'
                  '8. Your Rights\n\n'
                  'You have the right to access, update, or delete your personal information. You can also object to the processing of your data in certain circumstances. For more information on how to exercise these rights, please contact us.\n\n'
                  '9. Children’s Privacy\n\n'
                  'Our Services are not intended for children under the age of 13, and we do not knowingly collect personal information from children. If we learn that we have collected data from a child under 13, we will take steps to delete it.\n\n'
                  '10. Changes to this Privacy Policy\n\n'
                  'We may update this Privacy Policy from time to time. Any changes will be posted on this page with an updated date. Please review this page periodically for updates.\n\n'
                  '11. Contact Us\n\n'
                  'If you have any questions or concerns about this Privacy Policy, please contact us at support@gobuddy.com.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 15,)
          ],
        ),
      ),
    );
  }
}



//Help Center Page code
class HelpCenterPage extends StatelessWidget {
  final List<Map<String, String>> faqs = [
    {
      'question': 'How do I create a trip?',
      'answer': 'To create a trip, go to the "Add Trip" page from the home screen. Enter the required details like destination, travel dates, budget, and a description. Once done, tap the "Post Trip" button. Your trip will be visible to others in the community.'
    },
    {
      'question': 'Can I edit my trip after posting?',
      'answer': 'Yes, you can edit or delete your trip at any time. Navigate to "My Trips" in your profile, select the trip you want to edit, make changes, and save them. If you wish to delete the trip, simply tap on the delete button.'
    },
    {
      'question': 'How do I join a trip?',
      'answer': 'Browse available trips in the "Explore" section. If you find a trip that interests you, tap on it to see details and click the "Join Trip" button. The trip host will receive a request and can approve or reject your request.'
    },
    {
      'question': 'How do I leave a trip I joined?',
      'answer': 'If you have already joined a trip but want to leave, go to "My Trips", find the trip under "Joined Trips", and click "Leave Trip". You will be removed from the group, and the host will be notified.'
    },
    {
      'question': 'Can I chat with other travelers?',
      'answer': 'Yes! Once you join a trip, you can use the in-app chat feature to communicate with other travelers. You will find the chat option in the trip details page.'
    },
    {
      'question': 'Is my personal data safe in GoBuddy?',
      'answer': 'GoBuddy takes privacy seriously. Your data is securely stored and not shared with third parties. You can manage your privacy settings from the "Settings" page.'
    },
    {
      'question': 'How do I delete my account?',
      'answer': 'If you wish to delete your account, go to "Settings" > "Delete Account". This action is permanent and will remove all your data from our platform.'
    },
    {
      'question': 'What happens if I report a user?',
      'answer': 'If you report a user for inappropriate behavior, our moderation team will review the complaint and take necessary action, including warnings, temporary suspension, or permanent removal from the platform.'
    },
    {
      'question': 'How can I reset my password?',
      'answer': 'If you forgot your password, go to the login page and click "Forgot Password?". Enter your registered email, and we will send you a password reset link.'
    },
    {
      'question': 'How do I contact customer support?',
      'answer': 'You can reach out to us through the "Contact Support" option in Settings. You can also email us at support@gobuddy.com for assistance.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help Center',style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xFF134277),
        foregroundColor: Colors.white,),
      body: ListView(
        children: faqs.map((faq) => ExpansionTile(
          title: Text(faq['question']!, style: TextStyle(fontWeight: FontWeight.w500,color: Colors.black,)),
          children: [Padding(padding: EdgeInsets.all(16.0), child: Text(faq['answer']!))],
        )).toList(),
      ),
    );
  }
}



//Contact Support page problem
class ContactSupportPage extends StatefulWidget {
  @override
  _ContactSupportPageState createState() => _ContactSupportPageState();
}

class _ContactSupportPageState extends State<ContactSupportPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  Future<void> _submitSupportRequest() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String message = _messageController.text.trim();
    String? userId = FirebaseAuth.instance.currentUser?.uid; // Get current user ID

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("You need to be logged in to submit a support request."),
        backgroundColor: Colors.red,
      ));
      return;
    }

    if (formKey.currentState!.validate()) {
      try {
        // Store in Global Collection
        await FirebaseFirestore.instance.collection("support_requests").add({
          "userId": userId,
          "name": name,
          "email": email,
          "message": message,
          "timestamp": FieldValue.serverTimestamp(),
        });

        // Store inside the user's collection
        await FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .collection("support_requests")
            .add({
          "name": name,
          "email": email,
          "message": message,
          "timestamp": FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Your request has been submitted successfully!"),
          backgroundColor: Colors.green,
        ));

        Navigator.pop(context);

        _nameController.clear();
        _emailController.clear();
        _messageController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to submit request. Try again."),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Support',style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xFF134277),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "We're here to help!",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 10),
                Text(
                  "If you have any issues or questions, fill out the form below and our support team will get back to you.",
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(fontSize: 15),
                  autocorrect: true,
                  enableSuggestions: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Name';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      hintText: "Your Name",
                    hintStyle: const TextStyle(color: Color(0xFF3D5F8C)),
                    prefixIcon: const Icon(Icons.person, color: Colors.black),
                    filled: true,
                    fillColor: const Color(0xFFBFCFF3),
                    border: InputBorder.none,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFBFCFF3), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFBFCFF3), width: 2),
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
                TextFormField(
                  controller: _emailController,
                  style: const TextStyle(fontSize: 15),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: true,
                  enableSuggestions: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    final emailRegex =
                    RegExp(r'^[^@]+@[^@]+\.[^@]+'); // Basic email validation
                    if (!emailRegex.hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      hintText: "Your Email",
                    hintStyle: const TextStyle(color: Color(0xFF3D5F8C)),
                    prefixIcon: const Icon(Icons.email, color: Colors.black),
                    filled: true,
                    fillColor: const Color(0xFFBFCFF3),
                    border: InputBorder.none,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFBFCFF3), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFBFCFF3), width: 2),
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
                TextFormField(
                  controller: _messageController,
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Message';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      hintText: "Your Message",
                    hintStyle: const TextStyle(color: Color(0xFF3D5F8C),),
                    prefixIcon: const Icon(Icons.message, color: Colors.black),
                    filled: true,
                    fillColor: const Color(0xFFBFCFF3),
                    border: InputBorder.none,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFBFCFF3), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFBFCFF3), width: 2),
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
                Container(
                  width: MediaQuery.of(context).size.width*0.8,
                  height: 60,
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(90)),
                  child: ElevatedButton(
                    onPressed: _submitSupportRequest,
                    child: Text("Submit Request",
                      style: const TextStyle(
                          color: Color(0xFFF2F5F1),
                          fontWeight: FontWeight.w500,
                          fontSize: 20),),
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
                SizedBox(height: 20),
                Divider(),
                SizedBox(height: 10),
                Text("📧 Email: support@gobuddy.com",style: TextStyle(fontSize: 15),),
                SizedBox(height: 5),
                Text("📞 Phone: +91 7201821370",style: TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



// Report a Problem page code
class ReportProblemPage extends StatefulWidget {
  @override
  _ReportProblemPageState createState() => _ReportProblemPageState();
}

class _ReportProblemPageState extends State<ReportProblemPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _problemController = TextEditingController();
  String _selectedCategory = "App Bug";

  final formKey = GlobalKey<FormState>();

  final List<String> _categories = [
    "App Bug",
    "Payment Issue",
    "Trip-Related Problem",
    "Inappropriate Content",
    "User Misbehavior",
    "Other"
  ];

  Future<void> _submitReport() async {
    String email = _emailController.text.trim();
    String problem = _problemController.text.trim();

    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("You need to be logged in to submit a Report."),
        backgroundColor: Colors.red,
      ));
      return;
    }

    if (formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection("problem_reports").add({
          "userId": userId,
          "email": email,
          "problem": problem,
          "category": _selectedCategory, // Assuming you have a category dropdown
          "timestamp": FieldValue.serverTimestamp(),
        });

        await FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .collection("problem_reports")
            .add({
          "email": email,
          "problem": problem,
          "category": _selectedCategory,
          "timestamp": FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Your problem has been reported successfully!"),
          backgroundColor: Colors.green,
        ));

        Navigator.pop(context);

        _emailController.clear();
        _problemController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to report problem. Try again."),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report a Problem',style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xFF134277),
        foregroundColor: Colors.white,),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Report an issue",
                  style: TextStyle(color:Color(0xFF134277),fontSize: 20, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 10),
                Text(
                  "Let us know what problem you're facing so we can improve your experience.",
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                SizedBox(height: 20),
                Text("Problem Category", style: TextStyle(fontWeight: FontWeight.w500)),
                SizedBox(height: 5),
                DropdownButtonFormField(
                  value: _selectedCategory,
                  items: _categories.map((category) {
                    return DropdownMenuItem(value: category, child: Text(category));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value.toString();
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFBFCFF3),
                    border: InputBorder.none,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFBFCFF3), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFBFCFF3), width: 2),
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
                TextFormField(
                  controller: _emailController,
                  style: const TextStyle(fontSize: 15),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: true,
                  enableSuggestions: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    final emailRegex =
                    RegExp(r'^[^@]+@[^@]+\.[^@]+'); // Basic email validation
                    if (!emailRegex.hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      hintText: "Your Email",
                    filled: true,
                    fillColor: const Color(0xFFBFCFF3),
                    border: InputBorder.none,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFBFCFF3), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFBFCFF3), width: 2),
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
                TextFormField(
                  controller: _problemController,
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      hintText: "Describe the problem",
                    filled: true,
                    fillColor: const Color(0xFFBFCFF3),
                    border: InputBorder.none,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFBFCFF3), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFBFCFF3), width: 2),
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
                Container(
                  width: MediaQuery.of(context).size.width*0.8,
                  height: 60,
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: ElevatedButton(
                    onPressed: _submitReport,
                    child: Text("Submit Report",
                      style: const TextStyle(
                        color: Color(0xFFF2F5F1),
                      fontWeight: FontWeight.w500,
                      fontSize: 20),
                      ),
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
                SizedBox(height: 20),
                Divider(),
                SizedBox(height: 10),
                Text(
                  textAlign: TextAlign.center,
                  "Note: Our team will review your report and take appropriate action. If it's urgent, please contact support.",
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



//Change Password Screen Code
class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  // Function to handle password change
  Future<void> _changePassword() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get the current user
      User? user = _auth.currentUser;

      if (user == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = "User not found. Please log in first.";
        });
        return;
      }

      // Verify the old password by re-authenticating the user
      String oldPassword = _oldPasswordController.text.trim();

      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );

      // Re-authenticate the user with the old password
      await user.reauthenticateWithCredential(credential);

      // Check if the new passwords match
      String newPassword = _newPasswordController.text.trim();
      String confirmPassword = _confirmPasswordController.text.trim();

      if (newPassword != confirmPassword) {
        setState(() {
          _isLoading = false;
          _errorMessage = "New passwords do not match.";
        });
        return;
      }

      // Update the password
      await user.updatePassword(newPassword);

      setState(() {
        _isLoading = false;
        _errorMessage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password changed successfully!")),
      );

      // Optionally, navigate to a different page
      // Navigator.pop(context);

    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password',style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xFF134277),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              color: Colors.white,
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      textAlign: TextAlign.center,
                      'Change Your Password',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF134277),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    const Text(
                      'Enter your old Password to Change Password.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    SizedBox(height: 32.0),
                    // Old Password TextField
                    TextField(
                      controller: _oldPasswordController,
                      obscureText: true,
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: "Old Password",
                        errorText: _errorMessage != null ? "Invalid old password" : null,
                        hintStyle: const TextStyle(color: Color(0xFF3D5F8C)),
                        prefixIcon: const Icon(Icons.password_outlined, color: Color(0xFF134277)),
                        filled: true,
                        fillColor: const Color(0xFFBFCFF3),
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
                      ),
                    ),
                    SizedBox(height: 20),

                    // New Password TextField
                    TextField(
                      controller: _newPasswordController,
                      obscureText: true,
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        errorText: _errorMessage != null ? "Password Does not Match" : null,
                        hintText: "New Password",
                        hintStyle: const TextStyle(color: Color(0xFF3D5F8C)),
                        prefixIcon: const Icon(Icons.password_outlined, color: Color(0xFF134277)),
                        filled: true,
                        fillColor: const Color(0xFFBFCFF3),
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
                      ),
                    ),
                    SizedBox(height: 20),

                    // Confirm New Password TextField
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: "Confirm New Password",
                        errorText: _errorMessage != null ? "Password Does not Match" : null,
                        hintStyle: const TextStyle(color: Color(0xFF3D5F8C)),
                        prefixIcon: const Icon(Icons.password_outlined, color: Color(0xFF134277)),
                        filled: true,
                        fillColor: const Color(0xFFBFCFF3),
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
                      ),
                    ),
                    SizedBox(height: 35),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                      onPressed: _changePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF134277),
                        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                      child: const Text(
                        'Change Password',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}






