import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../pages/email_verification_page.dart';

class EmailVerificationDialog {
  static void showVerificationDialog(BuildContext context) {
    final AuthService authService = AuthService();
    
    if (authService.currentUser == null || authService.isEmailVerified()) {
      return; // No need to show dialog if user is verified or not logged in
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Email Verification Required'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.email,
                size: 50,
                color: Colors.blue,
              ),
              SizedBox(height: 16),
              Text(
                'Your email address has not been verified. Please verify your email to access all features.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Later'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EmailVerificationPage()),
                );
              },
              child: const Text('Verify Now'),
            ),
          ],
        );
      },
    );
  }
}
