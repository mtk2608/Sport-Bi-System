# Firestore Integration Guide for Sport BI System

This guide explains how to work with Firestore in the Sport BI System project.

## Setup

1. Make sure Firebase is properly initialized in `main.dart`:
   ```dart
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp(
       options: DefaultFirebaseOptions.currentPlatform,
     );
     runApp(const MyApp());
   }
   ```

2. Ensure all required Firebase packages are in `pubspec.yaml`:
   ```yaml
   firebase_core: ^2.25.4
   firebase_auth: ^4.17.4
   cloud_firestore: ^4.15.4
   ```

## Data Structure

The application uses the following Firestore collections:

- **users**: User profiles and settings
- **dashboards**: Dashboard configurations 
- **models**: Analytics models
- **databases**: Database connections
- **metrics**: Metric definitions
- **analytics**: Analytics reports
- **personal_collection**: User's saved items
- **examples**: Example templates
- **widgets**: Dashboard visualization widgets
- **trash**: Deleted items that can be restored

## Using FirestoreService

The `FirestoreService` class in `lib/services/firestore_service.dart` provides a unified API for interacting with Firestore:

```dart
final _firestoreService = FirestoreService();

// Create a document
final newDashboard = {
  'name': 'Performance Dashboard',
  'description': 'Track team performance metrics',
  // Additional fields
};
final docRef = await _firestoreService.createDashboard(newDashboard);

// Read documents
final snapshot = await _firestoreService.getUserDashboards(userId);
final dashboards = snapshot.docs.map((doc) => YourModel.fromFirestore(doc)).toList();

// Update a document
await _firestoreService.updateDashboard(dashboardId, {'name': 'Updated Name'});

// Delete a document
await _firestoreService.deleteDashboard(dashboardId);

// Listen to real-time updates
_firestoreService.getUserAnalytics(userId).listen((snapshot) {
  final analytics = snapshot.docs.map((doc) => AnalyticsModel.fromFirestore(doc)).toList();
  // Update UI with new data
});
```

## Data Models

Create model classes to convert between Firestore documents and Dart objects:

```dart
class DashboardItem {
  final String id;
  final String name;
  final String description;
  final String createdAt;
  final String updatedAt;
  final List<String> widgets;
  
  // Constructor
  
  // FromFirestore factory
  factory DashboardItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return DashboardItem(
      id: doc.id,
      name: data['name'] ?? 'Untitled',
      // Other fields
    );
  }
  
  // ToFirestore method
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      // Other fields
    };
  }
}
```

## Best Practices

1. **Always handle loading states**: Show loading indicators when fetching data.
2. **Implement error handling**: Catch errors from Firestore operations.
3. **Use transactions** for multi-step operations.
4. **Index your queries** in the Firebase Console.
5. **Denormalize data** when needed for faster reads.
6. **Use batch operations** for multiple writes.
7. **Set security rules** to protect your data.

## Example Pages Using Firestore

- `analytics_page.dart`: Displays and manages analytics reports
- `dashboard_page.dart`: Shows user dashboards
- `edit_dashboard_page_updated.dart`: Edits dashboard contents with widgets

## Security Rules

Remember to set appropriate security rules in the Firebase Console to secure your data. Example:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /dashboards/{dashboardId} {
      allow read, write: if request.auth != null && resource.data.userId == request.auth.uid;
    }
    // Additional rules
  }
}
```

## Troubleshooting

- Check Firebase Console for errors
- Verify indexes are created for complex queries
- Ensure documents exist before attempting to read them
- Check network connectivity
- Verify Firebase initialization is complete before accessing Firestore
