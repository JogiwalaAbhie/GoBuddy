import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:in_app_review/in_app_review.dart';

class HelpSupportPage extends StatelessWidget {
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
              subtitle: Text('Learn how to create a new trip and invite others to join.'),
              onTap: () {
                // Navigate to FAQ page or show the answer
              },
            ),
            ListTile(
              title: Text('How do I join a trip?'),
              subtitle: Text('Step-by-step guide on how to join trips hosted by others.'),
              onTap: () {
                // Navigate to FAQ page or show the answer
              },
            ),
            ListTile(
              title: Text('Can I cancel my trip?'),
              subtitle: Text('Here’s how you can cancel a trip you’ve created.'),
              onTap: () {
                // Navigate to FAQ page or show the answer
              },
            ),
            Divider(),

            _buildSectionTitle('Contact Support'),
            ListTile(
              title: Text('Email Support'),
              subtitle: Text('Contact us via email for any issues or questions.'),
              onTap: () {
                _launchEmailClient();
              },
            ),
            ListTile(
              title: Text('Live Chat'),
              subtitle: Text('Chat with a support representative in real-time.'),
              onTap: () {
                // Navigate to live chat or contact page
              },
            ),
            Divider(),

            _buildSectionTitle('Give Feedback'),
            ListTile(
              title: Text('Rate the App'),
              subtitle: Text('Tell us how we are doing by rating the app.'),
              onTap: () {
                _rateApp();
              },
            ),
            ListTile(
              title: Text('Submit Feedback'),
              subtitle: Text('We value your feedback to improve GoBuddy.'),
              onTap: () {
                // Navigate to a form for feedback
              },
            ),
            Divider(),

            _buildSectionTitle('Terms & Conditions'),
            ListTile(
              title: Text('Read our Terms of Service'),
              subtitle: Text('View the terms and conditions of using GoBuddy.'),
              onTap: () {
                // _openTermsPage();
              },
            ),
            ListTile(
              title: Text('Privacy Policy'),
              subtitle: Text('Understand how we handle your data and privacy.'),
              onTap: () {

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
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500,color: Color(0xFF134277)),
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

  // Function to rate the app (using in_app_review package)
  void _rateApp() async {
    final InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    } else {
      print('In-app review is not available');
    }
  }
 }




