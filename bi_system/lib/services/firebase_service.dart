import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';

/// A service class to manage Firebase initialization and error handling
class FirebaseService {
  // Singleton instance
  static final FirebaseService _instance = FirebaseService._internal();
  
  // Factory constructor
  factory FirebaseService() => _instance;
  
  // Private constructor
  FirebaseService._internal();
  
  // Flag to track if Firebase is initialized
  bool _initialized = false;
  bool get isInitialized => _initialized;
  
  // Error info
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  /// Initialize Firebase with error handling
  Future<bool> initializeFirebase() async {
    if (_initialized) {
      return true;
    }
    
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      _initialized = true;
      _errorMessage = null;
      
      if (kDebugMode) {
        print('✅ Firebase initialized successfully');
      }
      
      return true;
    } on FirebaseException catch (e) {
      _errorMessage = 'Failed to initialize Firebase: ${e.code} - ${e.message}';
      if (kDebugMode) {
        print('❌ $_errorMessage');
      }
      return false;
    } catch (e) {
      _errorMessage = 'Unexpected error initializing Firebase: $e';
      if (kDebugMode) {
        print('❌ $_errorMessage');
      }
      return false;
    }
  }
  
  /// Reset error state
  void clearError() {
    _errorMessage = null;
  }
}
