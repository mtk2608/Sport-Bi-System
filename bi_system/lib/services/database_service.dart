import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Get the current authenticated user ID
  String? get currentUserId => _auth.currentUser?.uid;
  
  // Get a reference to a specific collection
  CollectionReference getCollection(String collectionName) {
    return _firestore.collection(collectionName);
  }
  
  // Create a new document in a collection
  Future<DocumentReference> createDocument(String collectionName, Map<String, dynamic> data) async {
    // Add userId to the document if user is authenticated
    if (currentUserId != null) {
      data['userId'] = currentUserId;
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();
    }
    
    return await _firestore.collection(collectionName).add(data);
  }
  
  // Create a document with a specific ID
  Future<void> createDocumentWithId(String collectionName, String docId, Map<String, dynamic> data) async {
    if (currentUserId != null) {
      data['userId'] = currentUserId;
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();
    }
    
    return await _firestore.collection(collectionName).doc(docId).set(data);
  }
  
  // Get a document by ID
  Future<DocumentSnapshot> getDocument(String collectionName, String docId) async {
    return await _firestore.collection(collectionName).doc(docId).get();
  }
  
  // Get all documents in a collection
  Future<QuerySnapshot> getDocuments(String collectionName) async {
    return await _firestore.collection(collectionName).get();
  }
  
  // Get documents with query
  Future<QuerySnapshot> queryDocuments(
    String collectionName, {
    List<List<dynamic>> whereConditions = const [],
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    Query query = _firestore.collection(collectionName);
    
    // Apply where conditions if provided
    for (var condition in whereConditions) {
      if (condition.length == 3) {
        query = query.where(condition[0], isEqualTo: condition[1] == '==' ? condition[2] : null);
        query = query.where(condition[0], isGreaterThan: condition[1] == '>' ? condition[2] : null);
        query = query.where(condition[0], isLessThan: condition[1] == '<' ? condition[2] : null);
        // Add more conditions as needed
      }
    }
    
    // Apply ordering if provided
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }
    
    // Apply limit if provided
    if (limit != null) {
      query = query.limit(limit);
    }
    
    return await query.get();
  }
  
  // Get documents belonging to the current user
  Future<QuerySnapshot> getUserDocuments(String collectionName) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }
    
    return await _firestore
        .collection(collectionName)
        .where('userId', isEqualTo: currentUserId)
        .get();
  }
  
  // Update a document
  Future<void> updateDocument(String collectionName, String docId, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    
    return await _firestore.collection(collectionName).doc(docId).update(data);
  }
  
  // Delete a document
  Future<void> deleteDocument(String collectionName, String docId) async {
    return await _firestore.collection(collectionName).doc(docId).delete();
  }
  
  // Stream a single document (real-time updates)
  Stream<DocumentSnapshot> streamDocument(String collectionName, String docId) {
    return _firestore.collection(collectionName).doc(docId).snapshots();
  }
  
  // Stream a collection (real-time updates)
  Stream<QuerySnapshot> streamCollection(String collectionName) {
    return _firestore.collection(collectionName).snapshots();
  }
  
  // Stream user documents (real-time updates)
  Stream<QuerySnapshot> streamUserDocuments(String collectionName) {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }
    
    return _firestore
        .collection(collectionName)
        .where('userId', isEqualTo: currentUserId)
        .snapshots();
  }
  
  // Transaction example - use for operations that need to be atomic
  Future<void> runTransaction(Function(Transaction) updateFunction) async {
    return await _firestore.runTransaction((Transaction transaction) async {
      return await updateFunction(transaction);
    });
  }
  
  // Batch write example - use for multiple operations that need to succeed or fail together
  Future<void> batchWrite(Function(WriteBatch) updateFunction) async {
    WriteBatch batch = _firestore.batch();
    updateFunction(batch);
    return await batch.commit();
  }
}
