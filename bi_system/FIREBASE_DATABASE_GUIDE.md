# Firebase Database Integration Guide

This guide explains how to integrate and use Firebase Firestore database in your Sport BI System.

## Setup (Already Done)

Your project already has Firebase setup with:
1. Firebase Core
2. Firebase Authentication
3. Cloud Firestore

The initialization is done in `main.dart`:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

## Database Service

We've created a comprehensive `DatabaseService` class that provides a wrapper around Firestore operations:
- Located at: `lib/services/database_service.dart`
- This service handles common database operations like create, read, update, delete
- Automatically adds metadata like userId, timestamps to documents
- Supports advanced queries, transactions, and batch operations

## Example Service 

For Sport-specific data management, we've created a `SportDataService`:
- Located at: `lib/services/sport_data_service.dart`
- Uses `DatabaseService` to perform sport-specific operations
- Manages teams, players, matches, and statistics

## Using the Database Services

### Basic Usage

```dart
import 'package:bi_system/services/database_service.dart';

class YourClass {
  final DatabaseService _db = DatabaseService();
  
  Future<void> createExample() async {
    // Create a document
    final docRef = await _db.createDocument('collection_name', {
      'field1': 'value1',
      'field2': 42,
      'field3': true,
    });
    
    // Get a document
    final docSnapshot = await _db.getDocument('collection_name', docRef.id);
    final data = docSnapshot.data() as Map<String, dynamic>; 
    
    // Update a document
    await _db.updateDocument('collection_name', docRef.id, {
      'field1': 'updated value',
    });
    
    // Delete a document
    await _db.deleteDocument('collection_name', docRef.id);
  }
}
```

### Real-time Updates

```dart
import 'package:bi_system/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RealtimeDataWidget extends StatelessWidget {
  final DatabaseService _db = DatabaseService();
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.streamCollection('your_collection'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        
        final docs = snapshot.data!.docs;
        
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            
            return ListTile(
              title: Text(data['name'] ?? 'Unnamed'),
              subtitle: Text(data['description'] ?? ''),
            );
          },
        );
      },
    );
  }
}
```

### Using SportDataService

```dart
import 'package:bi_system/services/sport_data_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeamListScreen extends StatefulWidget {
  @override
  _TeamListScreenState createState() => _TeamListScreenState();
}

class _TeamListScreenState extends State<TeamListScreen> {
  final SportDataService _sportService = SportDataService();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Teams'),
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: _sportService.getUserTeams(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          final teams = snapshot.data!;
          
          if (teams.isEmpty) {
            return Center(child: Text('No teams found. Create one!'));
          }
          
          return ListView.builder(
            itemCount: teams.length,
            itemBuilder: (context, index) {
              final team = teams[index].data() as Map<String, dynamic>;
              
              return ListTile(
                leading: CircleAvatar(
                  child: Text(team['name'][0] ?? 'T'),
                ),
                title: Text(team['name'] ?? 'Unnamed Team'),
                subtitle: Text('${team['playerCount'] ?? 0} players'),
                onTap: () {
                  // Navigate to team details screen
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // Show dialog to create new team
        },
      ),
    );
  }
}
```

## Firestore Security Rules

Don't forget to set up proper security rules in your Firebase console to protect your data. Here's a basic example:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read and write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Teams can be read by anyone, but only created/updated by authenticated users
    match /teams/{teamId} {
      allow read: if true;
      allow create, update, delete: if request.auth != null && request.resource.data.userId == request.auth.uid;
    }
    
    // General rule for user-owned documents
    match /{collection}/{docId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
                              resource.data.userId == request.auth.uid;
    }
  }
}
```

## Data Structure Recommendations

Here's a recommended structure for your sport data collections:

- **teams**: Information about teams
  - teamName, sport, logo, coachId, etc.
  
- **players**: Player profiles
  - name, position, teamId, jerseyNumber, bio, etc.
  
- **matches**: Game/match information
  - teamId, opponentId, date, location, result, etc.
  
- **statistics**: Performance data
  - playerId, matchId, metrics (points, assists, etc.)
  
- **training**: Training sessions
  - teamId, date, duration, focus, etc.
  
- **metrics**: Custom metric definitions
  - name, description, unit, formula, etc.

## Advanced Techniques

### Transaction Example
```dart
Future<void> transferPlayer(String playerId, String fromTeamId, String toTeamId) async {
  await _db.runTransaction((transaction) async {
    // Update player document
    transaction.update(
      _db.getCollection('players').doc(playerId), 
      {'teamId': toTeamId}
    );
    
    // Decrement player count in old team
    transaction.update(
      _db.getCollection('teams').doc(fromTeamId),
      {'playerCount': FieldValue.increment(-1)}
    );
    
    // Increment player count in new team
    transaction.update(
      _db.getCollection('teams').doc(toTeamId),
      {'playerCount': FieldValue.increment(1)}
    );
  });
}
```

### Batch Writes
```dart
Future<void> createTeamWithPlayers(String teamName, List<Map<String, dynamic>> players) async {
  final teamRef = _db.getCollection('teams').doc();
  final teamId = teamRef.id;
  
  await _db.batchWrite((batch) {
    // Create team
    batch.set(teamRef, {
      'name': teamName,
      'playerCount': players.length,
      'userId': _db.currentUserId,
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    // Create players
    for (var player in players) {
      final playerRef = _db.getCollection('players').doc();
      player['teamId'] = teamId;
      player['userId'] = _db.currentUserId;
      
      batch.set(playerRef, player);
    }
  });
}
