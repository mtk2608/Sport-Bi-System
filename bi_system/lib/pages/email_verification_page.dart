import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'homepage.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final AuthService _authService = AuthService();
  bool _isEmailVerified = false;
  bool _canResendEmail = true;
  bool _isLoading = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    
    // Check if email is already verified
    _isEmailVerified = _authService.isEmailVerified();
    
    if (!_isEmailVerified) {
      // Start timer to check verification status
      _timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => _checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkEmailVerified() async {
    // Reload user to get latest status
    await _authService.reloadUser();
    
    setState(() {
      _isEmailVerified = _authService.isEmailVerified();
    });

    if (_isEmailVerified) {
      _timer?.cancel();
      // Navigate to homepage if email is verified
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.sendVerificationEmail();
      
      setState(() {
        _canResendEmail = false;
      });
      
      // Reset resend button after 60 seconds
      Future.delayed(const Duration(seconds: 60), () {
        if (mounted) {
          setState(() {
            _canResendEmail = true;
          });
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification email has been sent!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending verification email: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isEmailVerified) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Verification'),
        actions: [
          TextButton(
            onPressed: _signOut,
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.email,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 32),
            const Text(
              'Verify your email',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'We\'ve sent a verification email to your inbox. Please click the link in the email to verify your account.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'If you don\'t see the email, check your spam folder.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: _canResendEmail ? 
                (_isLoading ? null : _resendVerificationEmail) : 
                null,
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(_canResendEmail ? 'Resend Email' : 'Wait to resend'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => _checkEmailVerified(),
              child: const Text('I already verified my email'),
            ),
          ],
        ),
      ),
    );
  }
}
