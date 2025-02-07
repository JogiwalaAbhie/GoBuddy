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
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Color(0xFF134277)),
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
            style: TextStyle(color: Color(0xFF134277),fontWeight: FontWeight.bold,fontSize: 22),),
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
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold,color: Colors.black),
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
