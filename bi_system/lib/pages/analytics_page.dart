import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/collapsible_sidebar.dart';
import '../services/firestore_service.dart';

class AnalyticsReport {
  final String id;
  final String name;
  final String description;
  final String createdAt;
  final String sportType;
  final Map<String, dynamic> data;

  AnalyticsReport({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.sportType,
    required this.data,
  });

  factory AnalyticsReport.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AnalyticsReport(
      id: doc.id,
      name: data['name'] ?? 'Untitled Report',
      description: data['description'] ?? 'No description',
      createdAt: data['createdAt'] ?? DateTime.now().toString(),
      sportType: data['sportType'] ?? 'General',
      data: data['reportData'] ?? {},
    );
  }
}

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  bool _isSidebarExpanded = true;
  bool _isLoading = false;
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<AnalyticsReport> _reports = [];
  String? _errorMessage;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        setState(() {
          _errorMessage = "You must be logged in to view analytics";
          _isLoading = false;
        });
        return;
      }

      // Fetch analytics for the current user
      final snapshot = await _firestoreService.analytics
          .where('userId', isEqualTo: currentUser.uid)
          .get();
          
      List<AnalyticsReport> reports = snapshot.docs
          .map((doc) => AnalyticsReport.fromFirestore(doc))
          .toList();

      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load analytics: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarExpanded = !_isSidebarExpanded;
    });
  }

  // Filter reports based on search query
  List<AnalyticsReport> get _filteredReports {
    if (_searchQuery.isEmpty) {
      return _reports;
    }
    
    return _reports.where((report) => 
      report.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      report.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      report.sportType.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  // Create a new analytics report
  void _createNewReport() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    String selectedSportType = 'Football';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Analytics Report'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Report Name',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Sport Type',
                ),
                value: selectedSportType,
                items: ['Football', 'Basketball', 'Baseball', 'Tennis', 'Golf', 'Other']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedSportType = value;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a report name')),
                  );
                  return;
                }
                
                Navigator.pop(context);
                setState(() => _isLoading = true);
                
                // Save the report data to Firestore
                final reportData = {
                  'name': nameController.text.trim(),
                  'description': descriptionController.text.trim(),
                  'createdAt': DateTime.now().toString(),
                  'userId': _auth.currentUser?.uid,
                  'sportType': selectedSportType,
                  'reportData': {
                    'metrics': ['goals', 'assists', 'passes'],
                    'period': 'Last 10 Games',
                  }
                };
                
                await _firestoreService.createAnalytics(reportData);
                _loadAnalytics(); // Refresh the data
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report created successfully!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error creating report: ${e.toString()}')),
                );
              } finally {
                setState(() => _isLoading = false);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  // Delete a report
  Future<void> _deleteReport(String reportId) async {
    try {
      setState(() => _isLoading = true);
      
      await _firestoreService.analytics.doc(reportId).delete();
      
      setState(() {
        _reports.removeWhere((report) => report.id == reportId);
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report deleted successfully')),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting report: ${e.toString()}')),
      );
    }
  }

  // View report details
  void _viewReportDetails(AnalyticsReport report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(report.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sport Type: ${report.sportType}'),
              const SizedBox(height: 8),
              Text('Created: ${DateTime.parse(report.createdAt).toString().split('.')[0]}'),
              const SizedBox(height: 16),
              Text(report.description),
              const SizedBox(height: 24),
              Text('Report Data:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Metrics: ${(report.data['metrics'] as List?)?.join(', ') ?? 'None'}'),
              Text('Period: ${report.data['period'] ?? 'Not specified'}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          Row(
            children: [
              // Collapsible Sidebar
              CollapsibleSidebar(
                isExpanded: _isSidebarExpanded,
                onToggle: _toggleSidebar,
                currentPage: 'Analytics',
              ),
              // Main content
              Expanded(
                child: Column(
                  children: [
                    // Top app bar
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Text(
                              'Analytics',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            const Spacer(),
                            // Search box
                            Container(
                              width: 300,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Search analytics...',
                                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _searchQuery = value;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Create new analytics report button
                            ElevatedButton.icon(
                              onPressed: _createNewReport,
                              icon: const Icon(Icons.add),
                              label: const Text('New Report'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Content area
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: _isLoading 
                            ? const Center(child: CircularProgressIndicator())
                            : _errorMessage != null
                                ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Analytics Reports",
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.refresh),
                                            onPressed: _loadAnalytics,
                                            tooltip: 'Refresh reports',
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      // Analytics reports grid
                                      Expanded(
                                        child: _filteredReports.isEmpty
                                            ? Center(
                                                child: Text(
                                                  _searchQuery.isNotEmpty
                                                      ? "No reports matching '${_searchQuery}'"
                                                      : "No analytics reports available. Create your first report!",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              )
                                            : GridView.builder(
                                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 3,
                                                  childAspectRatio: 1.5,
                                                  crossAxisSpacing: 16,
                                                  mainAxisSpacing: 16,
                                                ),
                                                itemCount: _filteredReports.length,
                                                itemBuilder: (context, index) {
                                                  final report = _filteredReports[index];
                                                  return Card(
                                                    elevation: 2,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: InkWell(
                                                      onTap: () => _viewReportDetails(report),
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(16.0),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Expanded(
                                                                  child: Text(
                                                                    report.name,
                                                                    style: const TextStyle(
                                                                      fontSize: 18, 
                                                                      fontWeight: FontWeight.bold,
                                                                    ),
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                ),
                                                                PopupMenuButton<String>(
                                                                  onSelected: (value) {
                                                                    if (value == 'delete') {
                                                                      showDialog(
                                                                        context: context,
                                                                        builder: (context) => AlertDialog(
                                                                          title: const Text('Delete Report'),
                                                                          content: Text('Are you sure you want to delete "${report.name}"?'),
                                                                          actions: [
                                                                            TextButton(
                                                                              onPressed: () => Navigator.pop(context),
                                                                              child: const Text('Cancel'),
                                                                            ),
                                                                            TextButton(
                                                                              onPressed: () {
                                                                                Navigator.pop(context);
                                                                                _deleteReport(report.id);
                                                                              },
                                                                              child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      );
                                                                    }
                                                                  },
                                                                  itemBuilder: (context) => [
                                                                    const PopupMenuItem<String>(
                                                                      value: 'delete',
                                                                      child: Text('Delete'),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(height: 8),
                                                            Text(
                                                              report.description,
                                                              style: TextStyle(
                                                                color: Colors.grey[700],
                                                                fontSize: 14,
                                                              ),
                                                              maxLines: 2,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                            const Spacer(),
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Container(
                                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                                  decoration: BoxDecoration(
                                                                    color: Colors.blue.withOpacity(0.1),
                                                                    borderRadius: BorderRadius.circular(12),
                                                                  ),
                                                                  child: Text(
                                                                    report.sportType,
                                                                    style: const TextStyle(
                                                                      color: Colors.blue,
                                                                      fontSize: 12,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Text(
                                                                  DateTime.parse(report.createdAt).toString().split(' ')[0],
                                                                  style: TextStyle(
                                                                    color: Colors.grey[500],
                                                                    fontSize: 12,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                      ),
                                    ],
                                  ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
