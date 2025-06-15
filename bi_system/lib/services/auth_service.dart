import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Check if email is verified
      if (result.user != null && !result.user!.emailVerified) {
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message: 'Please verify your email before signing in.',
        );
      }
      
      return result;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update user profile with name
      await result.user?.updateDisplayName(name);

      // Send email verification
      await result.user?.sendEmailVerification();

      // Create user document in Firestore
      await _createUserDocument(result.user!, name);

      return result;
    } on FirebaseAuthException {
      rethrow;
    }
  }
  
  // Check if email is verified
  bool isEmailVerified() {
    User? user = _auth.currentUser;
    return user != null && user.emailVerified;
  }
  
  // Reload user to check if email has been verified
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }
  
  // Resend verification email
  Future<void> sendVerificationEmail() async {
    User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(User user, String name) async {
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'name': name,
      'email': user.email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
  
  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // Get user data from Firestore
  Future<DocumentSnapshot> getUserData(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }
  
  // Stream user data for real-time updates
  Stream<DocumentSnapshot> streamUserData(String uid) {
    return _firestore.collection('users').doc(uid).snapshots();
  }
  
  // Update user profile data
  Future<void> updateUserProfile(Map<String, dynamic> userData) async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Update display name if provided
      if (userData.containsKey('name')) {
        await user.updateDisplayName(userData['name']);
      }
      
      // Update Firestore user document
      await _firestore.collection('users').doc(user.uid).update({
        ...userData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      throw Exception('No authenticated user found');
    }
  }
  
  // Get user role (admin, coach, player, etc.)
  Future<String> getUserRole() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      return data?['role'] ?? 'user';
    }
    return 'guest';
  }
  
  // Check if user has specific permission
  Future<bool> hasPermission(String permission) async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      List<dynamic> permissions = data?['permissions'] ?? [];
      return permissions.contains(permission);
    }
    return false;
  }
  
  // Link user to a team
  Future<void> linkUserToTeam(String teamId, String role) async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Add team to user's teams
      await _firestore.collection('users').doc(user.uid).update({
        'teams': FieldValue.arrayUnion([
          {
            'teamId': teamId,
            'role': role,
            'joinedAt': FieldValue.serverTimestamp(),
          }
        ]),
      });
      
      // Add user to team's members
      await _firestore.collection('teams').doc(teamId).update({
        'members': FieldValue.arrayUnion([
          {
            'userId': user.uid,
            'role': role,
            'joinedAt': FieldValue.serverTimestamp(),
          }
        ]),
      });
    } else {
      throw Exception('No authenticated user found');
    }
  }
  
  // Get teams associated with current user
  Future<List<Map<String, dynamic>>> getUserTeams() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      List<dynamic> teams = data?['teams'] ?? [];
      
      List<Map<String, dynamic>> result = [];
      for (var team in teams) {
        DocumentSnapshot teamDoc = await _firestore.collection('teams').doc(team['teamId']).get();
        Map<String, dynamic>? teamData = teamDoc.data() as Map<String, dynamic>?;
        if (teamData != null) {
          result.add({
            ...teamData,
            'userRole': team['role'],
            'id': team['teamId'],
          });
        }
      }
      
      return result;
    }
    return [];
  }
}
