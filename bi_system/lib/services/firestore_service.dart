import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Collection references
  CollectionReference get users => _firestore.collection('users');
  CollectionReference get dashboards => _firestore.collection('dashboards');
  CollectionReference get models => _firestore.collection('models');
  CollectionReference get databases => _firestore.collection('databases');
  CollectionReference get metrics => _firestore.collection('metrics');
  CollectionReference get analytics => _firestore.collection('analytics');
  CollectionReference get personalCollection => _firestore.collection('personal_collection');
  CollectionReference get examples => _firestore.collection('examples');
  CollectionReference get trash => _firestore.collection('trash');
  
  // Current user ID helper
  String? get currentUserId => _auth.currentUser?.uid;
  
  // User operations
  Future<void> createUserProfile(String uid, Map<String, dynamic> userData) async {
    return await users.doc(uid).set(userData);
  }
  
  Future<DocumentSnapshot> getUserProfile(String uid) async {
    return await users.doc(uid).get();
  }
  
  Future<void> updateUserProfile(String uid, Map<String, dynamic> userData) async {
    return await users.doc(uid).update(userData);
  }
  
  // Initialize user data after sign up
  Future<void> initializeUserData(String uid, String email, String displayName) async {
    final userData = {
      'email': email,
      'displayName': displayName,
      'createdAt': DateTime.now().toString(),
      'lastLogin': DateTime.now().toString(),
      'settings': {
        'theme': 'light',
        'notifications': true,
      }
    };
    
    return await createUserProfile(uid, userData);
  }
  
  // Dashboard operations
  Future<DocumentReference> createDashboard(Map<String, dynamic> dashboardData) async {
    // Ensure userId is set if not provided
    if (dashboardData['userId'] == null) {
      dashboardData['userId'] = currentUserId;
    }
    dashboardData['createdAt'] = DateTime.now().toString();
    dashboardData['updatedAt'] = DateTime.now().toString();
    
    return await dashboards.add(dashboardData);
  }
  
  Future<void> updateDashboard(String dashboardId, Map<String, dynamic> dashboardData) async {
    // Add updated timestamp
    dashboardData['updatedAt'] = DateTime.now().toString();
    return await dashboards.doc(dashboardId).update(dashboardData);
  }
  
  Future<void> deleteDashboard(String dashboardId) async {
    // Option 1: Actually delete
    return await dashboards.doc(dashboardId).delete();
    
    // Option 2: Move to trash
    /*
    final doc = await dashboards.doc(dashboardId).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      data['deletedAt'] = DateTime.now().toString();
      data['originalCollection'] = 'dashboards';
      await trash.add(data);
      return await dashboards.doc(dashboardId).delete();
    }
    */
  }
  
  Stream<QuerySnapshot> getUserDashboards(String uid) {
    return dashboards
        .where('userId', isEqualTo: uid)
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }
  
  Future<DocumentSnapshot> getDashboard(String dashboardId) async {
    return await dashboards.doc(dashboardId).get();
  }
  
  // Model operations
  Future<DocumentReference> createModel(Map<String, dynamic> modelData) async {
    if (modelData['userId'] == null) {
      modelData['userId'] = currentUserId;
    }
    modelData['createdAt'] = DateTime.now().toString();
    modelData['updatedAt'] = DateTime.now().toString();
    
    return await models.add(modelData);
  }
  
  Future<void> updateModel(String modelId, Map<String, dynamic> modelData) async {
    modelData['updatedAt'] = DateTime.now().toString();
    return await models.doc(modelId).update(modelData);
  }
  
  Future<void> deleteModel(String modelId) async {
    return await models.doc(modelId).delete();
  }
  
  Stream<QuerySnapshot> getUserModels(String uid) {
    return models
        .where('userId', isEqualTo: uid)
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }
  
  Future<DocumentSnapshot> getModel(String modelId) async {
    return await models.doc(modelId).get();
  }
  
  // Database connection operations
  Future<DocumentReference> createDatabaseConnection(Map<String, dynamic> dbData) async {
    if (dbData['userId'] == null) {
      dbData['userId'] = currentUserId;
    }
    dbData['createdAt'] = DateTime.now().toString();
    dbData['updatedAt'] = DateTime.now().toString();
    
    return await databases.add(dbData);
  }
  
  Future<void> updateDatabaseConnection(String dbId, Map<String, dynamic> dbData) async {
    dbData['updatedAt'] = DateTime.now().toString();
    return await databases.doc(dbId).update(dbData);
  }
  
  Future<void> deleteDatabaseConnection(String dbId) async {
    return await databases.doc(dbId).delete();
  }
  
  Stream<QuerySnapshot> getUserDatabaseConnections(String uid) {
    return databases
        .where('userId', isEqualTo: uid)
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }
  
  Future<DocumentSnapshot> getDatabaseConnection(String dbId) async {
    return await databases.doc(dbId).get();
  }
  
  // Metrics operations
  Future<DocumentReference> createMetric(Map<String, dynamic> metricData) async {
    if (metricData['userId'] == null) {
      metricData['userId'] = currentUserId;
    }
    metricData['createdAt'] = DateTime.now().toString();
    metricData['updatedAt'] = DateTime.now().toString();
    
    return await metrics.add(metricData);
  }
  
  Future<void> updateMetric(String metricId, Map<String, dynamic> metricData) async {
    metricData['updatedAt'] = DateTime.now().toString();
    return await metrics.doc(metricId).update(metricData);
  }
  
  Future<void> deleteMetric(String metricId) async {
    return await metrics.doc(metricId).delete();
  }
  
  Stream<QuerySnapshot> getUserMetrics(String uid) {
    return metrics
        .where('userId', isEqualTo: uid)
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }
  
  Future<DocumentSnapshot> getMetric(String metricId) async {
    return await metrics.doc(metricId).get();
  }
  
  // Analytics operations
  Future<DocumentReference> createAnalytics(Map<String, dynamic> analyticsData) async {
    if (analyticsData['userId'] == null) {
      analyticsData['userId'] = currentUserId;
    }
    analyticsData['createdAt'] ??= DateTime.now().toString();
    analyticsData['updatedAt'] = DateTime.now().toString();
    
    return await analytics.add(analyticsData);
  }
  
  Future<void> updateAnalytics(String analyticsId, Map<String, dynamic> analyticsData) async {
    analyticsData['updatedAt'] = DateTime.now().toString();
    return await analytics.doc(analyticsId).update(analyticsData);
  }
  
  Future<void> deleteAnalytics(String analyticsId) async {
    return await analytics.doc(analyticsId).delete();
  }
  
  Stream<QuerySnapshot> getUserAnalytics(String uid) {
    return analytics
        .where('userId', isEqualTo: uid)
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }
  
  Future<DocumentSnapshot> getAnalytics(String analyticsId) async {
    return await analytics.doc(analyticsId).get();
  }
  
  // Personal Collection operations
  Future<DocumentReference> addToPersonalCollection(Map<String, dynamic> itemData) async {
    if (itemData['userId'] == null) {
      itemData['userId'] = currentUserId;
    }
    itemData['createdAt'] = DateTime.now().toString();
    itemData['updatedAt'] = DateTime.now().toString();
    
    return await personalCollection.add(itemData);
  }
  
  Stream<QuerySnapshot> getUserPersonalCollection(String uid) {
    return personalCollection
        .where('userId', isEqualTo: uid)
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }
  
  // Examples operations
  Future<DocumentReference> addExample(Map<String, dynamic> exampleData) async {
    if (exampleData['userId'] == null) {
      exampleData['userId'] = currentUserId;
    }
    exampleData['createdAt'] = DateTime.now().toString();
    
    return await examples.add(exampleData);
  }
  
  Stream<QuerySnapshot> getExamples() {
    return examples.orderBy('createdAt', descending: true).snapshots();
  }
  
  // Trash operations
  Future<void> moveToTrash(String collectionPath, String docId) async {
    final DocumentReference sourceDoc = _firestore.collection(collectionPath).doc(docId);
    final DocumentSnapshot sourceSnapshot = await sourceDoc.get();
    
    if (!sourceSnapshot.exists) {
      throw Exception('Document does not exist');
    }
    
    final Map<String, dynamic> data = sourceSnapshot.data() as Map<String, dynamic>;
    data['deletedAt'] = DateTime.now().toString();
    data['originalCollection'] = collectionPath;
    data['originalId'] = docId;
    
    await trash.add(data);
    await sourceDoc.delete();
  }
  
  Future<void> restoreFromTrash(String trashDocId) async {
    final DocumentSnapshot trashDoc = await trash.doc(trashDocId).get();
    
    if (!trashDoc.exists) {
      throw Exception('Document not found in trash');
    }
    
    final Map<String, dynamic> data = trashDoc.data() as Map<String, dynamic>;
    final String? originalCollection = data['originalCollection'];
    
    if (originalCollection == null) {
      throw Exception('Original collection info missing');
    }
    
    // Remove trash-specific fields
    data.remove('deletedAt');
    data.remove('originalCollection');
    data.remove('originalId');
    
    // Restore to original collection
    await _firestore.collection(originalCollection).add(data);
    
    // Remove from trash
    await trash.doc(trashDocId).delete();
  }
  
  Stream<QuerySnapshot> getUserTrash(String uid) {
    return trash
        .where('userId', isEqualTo: uid)
        .orderBy('deletedAt', descending: true)
        .snapshots();
  }
  
  // Generic query methods
  Future<QuerySnapshot> getCollection(String collectionPath) async {
    return await _firestore.collection(collectionPath).get();
  }
  
  Stream<QuerySnapshot> streamCollection(String collectionPath) {
    return _firestore.collection(collectionPath).snapshots();
  }
  
  Future<DocumentSnapshot> getDocument(String collectionPath, String docId) async {
    return await _firestore.collection(collectionPath).doc(docId).get();
  }
    Stream<DocumentSnapshot> streamDocument(String collectionPath, String docId) {
    return _firestore.collection(collectionPath).doc(docId).snapshots();
  }
}
