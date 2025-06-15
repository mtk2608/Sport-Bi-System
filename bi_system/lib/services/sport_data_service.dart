import 'package:cloud_firestore/cloud_firestore.dart';
import 'database_service.dart';

// Example class to demonstrate Firebase Database usage
class SportDataService {
  final DatabaseService _databaseService = DatabaseService();
  
  // Collection names
  final String _teamsCollection = 'teams';
  final String _playersCollection = 'players';
  final String _matchesCollection = 'matches';
  final String _statsCollection = 'statistics';
  
  // Team operations
  Future<DocumentReference> createTeam(Map<String, dynamic> teamData) async {
    return await _databaseService.createDocument(_teamsCollection, teamData);
  }
  
  Future<List<QueryDocumentSnapshot>> getUserTeams() async {
    QuerySnapshot snapshot = await _databaseService.getUserDocuments(_teamsCollection);
    return snapshot.docs;
  }
  
  Future<DocumentSnapshot> getTeam(String teamId) async {
    return await _databaseService.getDocument(_teamsCollection, teamId);
  }
  
  Future<void> updateTeam(String teamId, Map<String, dynamic> teamData) async {
    return await _databaseService.updateDocument(_teamsCollection, teamId, teamData);
  }
  
  Future<void> deleteTeam(String teamId) async {
    // First, get all players associated with this team
    QuerySnapshot playersSnapshot = await _databaseService
        .getCollection(_playersCollection)
        .where('teamId', isEqualTo: teamId)
        .get();
    
    // Use batch to delete team and its players
    await _databaseService.batchWrite((batch) {
      // Delete the team
      batch.delete(_databaseService.getCollection(_teamsCollection).doc(teamId));
      
      // Delete all players associated with the team
      for (var playerDoc in playersSnapshot.docs) {
        batch.delete(playerDoc.reference);
      }
    });
  }
  
  // Player operations
  Future<DocumentReference> addPlayer(Map<String, dynamic> playerData) async {
    return await _databaseService.createDocument(_playersCollection, playerData);
  }
  
  Future<List<QueryDocumentSnapshot>> getTeamPlayers(String teamId) async {
    QuerySnapshot snapshot = await _databaseService
        .getCollection(_playersCollection)
        .where('teamId', isEqualTo: teamId)
        .get();
    return snapshot.docs;
  }
  
  // Match operations
  Future<DocumentReference> createMatch(Map<String, dynamic> matchData) async {
    return await _databaseService.createDocument(_matchesCollection, matchData);
  }
  
  Future<List<QueryDocumentSnapshot>> getUpcomingMatches() async {
    QuerySnapshot snapshot = await _databaseService
        .getCollection(_matchesCollection)
        .where('matchDate', isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('matchDate')
        .get();
    return snapshot.docs;
  }
  
  Future<List<QueryDocumentSnapshot>> getPastMatches() async {
    QuerySnapshot snapshot = await _databaseService
        .getCollection(_matchesCollection)
        .where('matchDate', isLessThan: Timestamp.now())
        .orderBy('matchDate', descending: true)
        .get();
    return snapshot.docs;
  }
  
  // Statistics operations
  Future<DocumentReference> recordStats(Map<String, dynamic> statsData) async {
    return await _databaseService.createDocument(_statsCollection, statsData);
  }
  
  Future<List<QueryDocumentSnapshot>> getPlayerStats(String playerId) async {
    QuerySnapshot snapshot = await _databaseService
        .getCollection(_statsCollection)
        .where('playerId', isEqualTo: playerId)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs;
  }
  
  // Real-time updates example
  Stream<QuerySnapshot> streamTeamMatches(String teamId) {
    return _databaseService
        .getCollection(_matchesCollection)
        .where('teamId', isEqualTo: teamId)
        .orderBy('matchDate')
        .snapshots();
  }
  
  // Advanced query example - Get top players by specific stat
  Future<List<QueryDocumentSnapshot>> getTopPlayersByStat(
      String statName, 
      {int limit = 10}) async {
    QuerySnapshot snapshot = await _databaseService
        .getCollection(_statsCollection)
        .orderBy(statName, descending: true)
        .limit(limit)
        .get();
    return snapshot.docs;
  }
}
