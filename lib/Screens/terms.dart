import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({Key? key}) : super(key: key);

  // Function to open email
  void _openEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'Could not launch $email';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Terms and Conditions',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16.0),
            const Text(
              'Welcome to Pet Patrol!',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'These terms and conditions outline the rules and regulations for the use of the Pet Patrol mobile application.',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            const Text(
              '1. Acceptance of Terms',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'By using this app, you agree to be bound by these terms and conditions. If you do not agree with any part of these terms, you must discontinue use of the app.',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            const Text(
              '2. User Responsibilities',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            const Text(
              '- Users are responsible for the accuracy of the information they provide.\n'
              '- Users must not misuse the app for fraudulent activities or purposes.\n'
              '- Users must report any issues with the app or inaccurate animal profiles.',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            const Text(
              '3. Privacy Policy',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'We value your privacy. All location data, personal information, and user activity within the app will be handled in accordance with our privacy policy.',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            const Text(
              '4. Changes to Terms',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Pet Patrol reserves the right to modify these terms and conditions at any time. Any changes will be updated in this section.',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            const Text(
              '5. Limitation of Liability',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Pet Patrol is not responsible for any issues arising from the misuse of the app or the information provided within the app. Use it at your own risk.',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'If you have any questions about these Terms and Conditions, please contact us at:',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 8.0),
            GestureDetector(
              onTap: () => _openEmail('abdullahal-2021311226@cs.du.ac.bd'),
              child: const Text(
                'abdullahal-2021311226@cs.du.ac.bd',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            GestureDetector(
              onTap: () => _openEmail('shahjamal-2020915641@cs.du.ac.bd'),
              child: const Text(
                'shahjamal-2020915641@cs.du.ac.bd',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 32.0),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Button background color
                  foregroundColor: Colors.white, // Button text color
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 16.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
