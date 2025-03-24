import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gobuddy/pages/setting.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:in_app_review/in_app_review.dart';


class HelpSupportPage extends StatelessWidget {

  void _showAnswer(BuildContext context, String question, String answer) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(question),
          content: Text(answer),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text("Help & Support",
          style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF134277),),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSectionTitle('FAQ'),
            ListTile(
              title: Text('How do I create a trip?'),
              subtitle: Text(
                  'Learn how to create a new trip and invite others to join.'),
              onTap: () {
                _showAnswer(
                  context,
                  'How do I create a trip?',
                  'To create a trip, go to the "Add Trip" page, enter the trip details, and confirm. You can also invite others to join by sharing the trip through Whatsapp and Other',
                );
              },
            ),
            ListTile(
              title: Text('How do I join a trip?'),
              subtitle: Text(
                  'Step-by-step guide on how to join trips hosted by others.'),
              onTap: () {
                _showAnswer(
                  context,
                  'How do I join a trip?',
                  'You can join a trip by searching for available trips or receiving an invite. Click "Add To cart" and Confirm the Payment to confirm your participation.',
                );
              },
            ),
            ListTile(
              title: Text('Can I cancel my trip?'),
              subtitle: Text(
                  'Here’s how you can cancel a trip you’ve created.'),
              onTap: () {
                _showAnswer(
                  context,
                  'Can I cancel my trip?',
                  'Yes, you can cancel your trip from the "Booked Trips" section. Select the trip you want to cancel and click on "Cancel Trip".',
                );
              },
            ),
            Divider(),

            _buildSectionTitle('Contact Support'),
            ListTile(
              title: Text('Email Support'),
              subtitle: Text(
                  'Contact us via email for any issues or questions.'),
              onTap: () {
                _launchEmailClient();
              },
            ),
            Divider(),

            _buildSectionTitle('Give Feedback'),
            ListTile(
              title: Text('Submit Feedback'),
              subtitle: Text('We value your feedback to improve GoBuddy.'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => FeedbackDialog(),
                );
              },
            ),
            Divider(),

            _buildSectionTitle('Terms & Conditions'),
            ListTile(
              title: Text('Read our Terms of Service'),
              subtitle: Text('View the terms and conditions of using GoBuddy.'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => TermsConditionsPage()));
              },
            ),
            ListTile(
              title: Text('Privacy Policy'),
              subtitle: Text('Understand how we handle your data and privacy.'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => PrivacyPolicyPage()));
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to display section titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Color(0xFF134277)),
      ),
    );
  }

  // Function to launch the email client with predefined email address
  void _launchEmailClient() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@gobuddy.com',
      queryParameters: {
        'subject': 'Support Request',
      },
    );

    if (await canLaunch(emailUri.toString())) {
      await launch(emailUri.toString());
    } else {
      print('Could not launch email client');
    }
  }

}

class FeedbackDialog extends StatefulWidget {
  @override
  _FeedbackDialogState createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  int _selectedRating = 0; // Default rating (0 means no rating selected)
  TextEditingController _reviewController = TextEditingController();

  void _submitFeedback() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null && _selectedRating > 0) {
      String userId = user.uid;
      String username = user.displayName ?? "Anonymous";

      await FirebaseFirestore.instance.collection('feedback').add({
        'userId': userId,
        'username': username,
        'rating': _selectedRating,
        'review': _reviewController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Thank you for your feedback!'))
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a rating before submitting.'))
      );
    }
  }

  Widget _buildStarRating(BuildContext context) {
    double starSize = MediaQuery.of(context).size.width * 0.12; // Dynamic size

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedRating = index + 1; // Update rating
            });
          },
          child: Icon(
            index < _selectedRating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: starSize,
          ),
        );
      }),
    );
  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text('Submit Feedback'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Rate your experience:'),
          SizedBox(height: 20),
          _buildStarRating(context), // ⭐ Star Rating System
          SizedBox(height: 10),
          TextField(
            controller: _reviewController,
            decoration: InputDecoration(
              hintText: "Write your review",
              hintStyle: const TextStyle(color: Color(0xFF3D5F8C)),
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
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel',style: TextStyle(color: Color(0xFF134277),),),
        ),
        ElevatedButton(
          onPressed: _submitFeedback,
          child: Text('Submit'),
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
      ],
    );
  }
}



