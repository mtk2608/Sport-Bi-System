import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/collapsible_sidebar.dart';
import '../services/firestore_service.dart';

class DashboardItem {
  final String id;
  final String name;
  final String description;
  final String createdAt;
  final String updatedAt;
  final List<String> widgets;
  final String layout;

  DashboardItem({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.widgets,
    required this.layout,
  });

  factory DashboardItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return DashboardItem(
      id: doc.id,
      name: data['name'] ?? 'Untitled Dashboard',
      description: data['description'] ?? 'No description',
      createdAt: data['createdAt'] ?? DateTime.now().toString(),
      updatedAt: data['updatedAt'] ?? DateTime.now().toString(),
      widgets: List<String>.from(data['widgets'] ?? []),
      layout: data['layout'] ?? 'grid',
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isSidebarExpanded = true;
  bool _isLoading = false;
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<DashboardItem> _dashboards = [];
  String? _errorMessage;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDashboards();
  }

  Future<void> _loadDashboards() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        setState(() {
          _errorMessage = "You must be logged in to view dashboards";
          _isLoading = false;
        });
        return;
      }

      // Fetch dashboards for the current user
      final snapshot = await _firestoreService.dashboards
          .where('userId', isEqualTo: currentUser.uid)
          .orderBy('updatedAt', descending: true)
          .get();
          
      List<DashboardItem> dashboards = snapshot.docs
          .map((doc) => DashboardItem.fromFirestore(doc))
          .toList();

      setState(() {
        _dashboards = dashboards;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load dashboards: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarExpanded = !_isSidebarExpanded;
    });
  }

  // Filter dashboards based on search query
  List<DashboardItem> get _filteredDashboards {
    if (_searchQuery.isEmpty) {
      return _dashboards;
    }
    
    return _dashboards.where((dashboard) => 
      dashboard.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      dashboard.description.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  // Create a new dashboard
  void _createNewDashboard() async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Dashboard'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Dashboard Name',
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
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a dashboard name')),
                );
                return;
              }
              
              Navigator.pop(context, {
                'name': nameController.text.trim(),
                'description': descriptionController.text.trim(),
              });
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        setState(() => _isLoading = true);
        
        // Create the dashboard in Firestore
        final dashboardData = {
          'name': result['name'],
          'description': result['description'],
          'userId': _auth.currentUser?.uid,
          'createdAt': DateTime.now().toString(),
          'updatedAt': DateTime.now().toString(),
          'widgets': <String>[],
          'layout': 'grid',
        };
        
        await _firestoreService.createDashboard(dashboardData);
        _loadDashboards(); // Refresh the data
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dashboard created successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating dashboard: ${e.toString()}')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  // Delete a dashboard
  Future<void> _deleteDashboard(String dashboardId) async {
    try {
      setState(() => _isLoading = true);
      
      await _firestoreService.deleteDashboard(dashboardId);
      
      setState(() {
        _dashboards.removeWhere((dashboard) => dashboard.id == dashboardId);
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dashboard deleted successfully')),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting dashboard: ${e.toString()}')),
      );
    }
  }
  // Edit a dashboard
  void _editDashboard(DashboardItem dashboard) {
    Navigator.pushNamed(
      context,
      '/edit_dashboard',
      arguments: {'dashboardId': dashboard.id},
    ).then((_) => _loadDashboards());
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
                currentPage: 'Home',
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
                              'Dashboards',
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
                                  hintText: 'Search dashboards...',
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
                            // Create new dashboard button
                            ElevatedButton.icon(
                              onPressed: _createNewDashboard,
                              icon: const Icon(Icons.add),
                              label: const Text('New Dashboard'),
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
                                            "My Dashboards",
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.refresh),
                                            onPressed: _loadDashboards,
                                            tooltip: 'Refresh dashboards',
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      // Dashboard grid
                                      Expanded(
                                        child: _filteredDashboards.isEmpty
                                            ? Center(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.dashboard_outlined,
                                                      size: 64,
                                                      color: Colors.grey[400],
                                                    ),
                                                    const SizedBox(height: 16),
                                                    Text(
                                                      _searchQuery.isNotEmpty
                                                          ? "No dashboards matching '${_searchQuery}'"
                                                          : "No dashboards yet. Create your first dashboard!",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 24),
                                                    if (_searchQuery.isEmpty)
                                                      ElevatedButton(
                                                        onPressed: _createNewDashboard,
                                                        child: const Text('Create Dashboard'),
                                                      ),
                                                  ],
                                                ),
                                              )
                                            : GridView.builder(
                                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 3,
                                                  childAspectRatio: 1.2,
                                                  crossAxisSpacing: 16,
                                                  mainAxisSpacing: 16,
                                                ),
                                                itemCount: _filteredDashboards.length,
                                                itemBuilder: (context, index) {
                                                  final dashboard = _filteredDashboards[index];
                                                  return Card(
                                                    elevation: 2,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: InkWell(
                                                      onTap: () => _editDashboard(dashboard),
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
                                                                    dashboard.name,
                                                                    style: const TextStyle(
                                                                      fontSize: 18, 
                                                                      fontWeight: FontWeight.bold,
                                                                    ),
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                ),
                                                                PopupMenuButton<String>(
                                                                  onSelected: (value) {
                                                                    if (value == 'edit') {
                                                                      _editDashboard(dashboard);
                                                                    } else if (value == 'delete') {
                                                                      showDialog(
                                                                        context: context,
                                                                        builder: (context) => AlertDialog(
                                                                          title: const Text('Delete Dashboard'),
                                                                          content: Text('Are you sure you want to delete "${dashboard.name}"?'),
                                                                          actions: [
                                                                            TextButton(
                                                                              onPressed: () => Navigator.pop(context),
                                                                              child: const Text('Cancel'),
                                                                            ),
                                                                            TextButton(
                                                                              onPressed: () {
                                                                                Navigator.pop(context);
                                                                                _deleteDashboard(dashboard.id);
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
                                                                      value: 'edit',
                                                                      child: Text('Edit'),
                                                                    ),
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
                                                              dashboard.description,
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
                                                                Text(
                                                                  "${dashboard.widgets.length} widgets",
                                                                  style: TextStyle(
                                                                    color: Colors.grey[600],
                                                                    fontSize: 12,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  "Updated: ${DateTime.parse(dashboard.updatedAt).toString().split(' ')[0]}",
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
