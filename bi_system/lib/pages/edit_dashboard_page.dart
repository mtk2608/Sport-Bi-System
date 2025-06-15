import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'new_sql_query_page.dart';
import '../widgets/collapsible_sidebar.dart';
import '../services/firestore_service.dart';

class EditDashboardPage extends StatefulWidget {
  final String dashboardId;
  
  const EditDashboardPage({
    super.key, 
    required this.dashboardId,
  });

  @override
  State<EditDashboardPage> createState() => _EditDashboardPageState();
}

class _EditDashboardPageState extends State<EditDashboardPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSidebarExpanded = true;
  bool _isLoading = true;
  String? _errorMessage;
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _dashboardWidgets = [];
  String _layout = 'grid';
  
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }
  
  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      // Fetch dashboard data from Firestore
      DocumentSnapshot dashboardDoc = await _firestoreService.getDashboard(widget.dashboardId);
      
      if (!dashboardDoc.exists) {
        setState(() {
          _errorMessage = "Dashboard not found";
          _isLoading = false;
        });
        return;
      }
      
      Map<String, dynamic> dashboardData = dashboardDoc.data() as Map<String, dynamic>;
      
      // Update UI with dashboard data
      _titleController.text = dashboardData['name'] ?? '';
      _descriptionController.text = dashboardData['description'] ?? '';
      _layout = dashboardData['layout'] ?? 'grid';
      
      // Load widgets data
      List<dynamic>? widgetIds = dashboardData['widgets'] as List<dynamic>?;
      List<Map<String, dynamic>> widgets = [];
      
      if (widgetIds != null && widgetIds.isNotEmpty) {
        // Fetch each widget data
        for (String widgetId in List<String>.from(widgetIds)) {
          try {
            DocumentSnapshot widgetDoc = await _firestoreService.getDocument('widgets', widgetId);
            if (widgetDoc.exists) {
              widgets.add({
                'id': widgetId,
                ...widgetDoc.data() as Map<String, dynamic>,
              });
            }
          } catch (e) {
            print('Error loading widget $widgetId: $e');
          }
        }
      }
      
      setState(() {
        _dashboardWidgets = widgets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Error loading dashboard: ${e.toString()}";
        _isLoading = false;
      });
    }
  }
  
  Future<void> _saveDashboard() async {
    try {
      setState(() => _isLoading = true);
      
      // Update dashboard data
      Map<String, dynamic> updatedData = {
        'name': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'layout': _layout,
        'updatedAt': DateTime.now().toString(),
      };
      
      await _firestoreService.updateDashboard(widget.dashboardId, updatedData);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dashboard saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving dashboard: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarExpanded = !_isSidebarExpanded;
    });
  }  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              // Collapsible Sidebar
              CollapsibleSidebar(
                isExpanded: _isSidebarExpanded,
                onToggle: _toggleSidebar,
                currentPage: 'Edit Dashboard',
              ),
              // Main content
              Expanded(
                child: _isLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                        ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
                        : Column(
                            children: [
                              // Blue editing header
                              Container(
                                width: double.infinity,
                                height: 60,
                                color: const Color(0xFF4A90E2),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 16),
                                    const Icon(Icons.edit, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'You\'re editing this dashboard',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _saveDashboard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF4A90E2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text('Save'),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
                // Main content area
                Expanded(
                  child: Container(
                    color: Colors.grey[50],
                    child: Column(
                      children: [
                        // Header section with title and toolbar
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          color: Colors.white,
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _titleController,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Enter dashboard title...',
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.add, color: Colors.grey),
                                onPressed: () {
                                  // Handle add
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.text_fields, color: Colors.grey),
                                onPressed: () {
                                  // Handle text
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.link, color: Colors.grey),
                                onPressed: () {
                                  // Handle link
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.grid_view, color: Colors.grey),
                                onPressed: () {
                                  // Handle grid
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.filter_list, color: Colors.grey),
                                onPressed: () {
                                  // Handle filter
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.more_horiz, color: Colors.grey),
                                onPressed: () {
                                  // Handle more
                                },
                              ),
                            ],
                          ),
                        ),
                        // Tab section
                        Container(
                          width: double.infinity,
                          color: Colors.white,
                          child: Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(left: 24),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Color(0xFF4A90E2),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Tab 1',
                                        style: TextStyle(
                                          color: Color(0xFF4A90E2),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.add, size: 20),
                                      onPressed: () {
                                        // Handle add tab
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Main editing area
                        Expanded(
                          child: Row(
                            children: [
                              // Main content area
                              Expanded(
                                child: Container(
                                  color: Colors.white,
                                  margin: const EdgeInsets.all(1),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        // Empty state icon
                                        Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.insert_chart_outlined,
                                            size: 40,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        const Text(
                                          'Create a new question or browse your',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const Text(
                                          'collections for an existing one.',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Add link or text cards. You can arrange cards manually, or start',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          'with some default layouts by adding ⊞ a section.',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 32),
                                        // Add a chart button
                                        ElevatedButton(
                                          onPressed: () {
                                            _showAddChartOptions(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF4A90E2),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                          ),
                                          child: const Text(
                                            'Add a chart',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Right sidebar
                              Container(
                                width: 300,
                                color: Colors.white,
                                child: Column(
                                  children: [
                                    // Search bar
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      child: TextField(
                                        controller: _searchController,
                                        decoration: InputDecoration(
                                          hintText: 'Search...',
                                          prefixIcon: const Icon(Icons.search),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: BorderSide(color: Colors.grey[300]!),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: BorderSide(color: Colors.grey[300]!),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Quick actions
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () {
                                                // Handle new question
                                              },
                                              icon: const Icon(Icons.help_outline, size: 18),
                                              label: const Text('New Question'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                foregroundColor: const Color(0xFF4A90E2),
                                                side: const BorderSide(color: Color(0xFF4A90E2)),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                padding: const EdgeInsets.symmetric(vertical: 12),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) => const NewSqlQueryPage(),
                                                  ),
                                                );
                                              },
                                              icon: const Icon(Icons.code, size: 18),
                                              label: const Text('New SQL query'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                foregroundColor: const Color(0xFF4A90E2),
                                                side: const BorderSide(color: Color(0xFF4A90E2)),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                padding: const EdgeInsets.symmetric(vertical: 12),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Collections section
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Row(
                                        children: [
                                          Text(
                                            'OUR ANALYSIS',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            'TAYFEB KAMALIDIEN\'S PERSONAL...',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Empty state
                                    Expanded(
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.folder_outlined,
                                              size: 48,
                                              color: Colors.grey[400],
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'Nothing here',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 16,
                                              ),                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
      
    ]
      )
    );
  }

  void _showAddChartOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Chart Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.bar_chart),
                title: const Text('Bar Chart'),
                onTap: () {
                  Navigator.of(context).pop();
                  _addChart('Bar Chart');
                },
              ),
              ListTile(
                leading: const Icon(Icons.pie_chart),
                title: const Text('Pie Chart'),
                onTap: () {
                  Navigator.of(context).pop();
                  _addChart('Pie Chart');
                },
              ),
              ListTile(
                leading: const Icon(Icons.show_chart),
                title: const Text('Line Chart'),
                onTap: () {
                  Navigator.of(context).pop();
                  _addChart('Line Chart');
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _addChart(String chartType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$chartType added to dashboard!'),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
