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
  }

  @override
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
                                      'Edit Dashboard',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const Spacer(),
                                    ElevatedButton.icon(
                                      onPressed: _saveDashboard,
                                      icon: const Icon(Icons.save, size: 16),
                                      label: const Text('Save'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: const Color(0xFF4A90E2),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                  ],
                                ),
                              ),
                              // Editing area
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Dashboard title and description
                                    TextField(
                                      controller: _titleController,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Dashboard Title',
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: _descriptionController,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[700],
                                      ),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Add a description...',
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      maxLines: 2,
                                    ),
                                    const SizedBox(height: 16),
                                    // Layout selection
                                    Row(
                                      children: [
                                        const Text('Layout: '),
                                        const SizedBox(width: 8),
                                        DropdownButton<String>(
                                          value: _layout,
                                          items: const [
                                            DropdownMenuItem(
                                              value: 'grid',
                                              child: Text('Grid'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'list',
                                              child: Text('List'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'tabs',
                                              child: Text('Tabs'),
                                            ),
                                          ],
                                          onChanged: (value) {
                                            if (value != null) {
                                              setState(() {
                                                _layout = value;
                                              });
                                            }
                                          },
                                        ),
                                        const Spacer(),
                                        // Add widget button
                                        ElevatedButton.icon(
                                          onPressed: () => _showAddWidgetMenu(context),
                                          icon: const Icon(Icons.add),
                                          label: const Text('Add Widget'),
                                        ),
                                      ],
                                    ),
                                    const Divider(),
                                    const SizedBox(height: 16),
                                    // Widget area title
                                    Text(
                                      'Dashboard Widgets (${_dashboardWidgets.length})',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Display widgets or empty state
                                    Expanded(
                                      child: _dashboardWidgets.isEmpty
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
                                                    'No widgets added yet',
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 24),
                                                  ElevatedButton.icon(
                                                    onPressed: () => _showAddWidgetMenu(context),
                                                    icon: const Icon(Icons.add),
                                                    label: const Text('Add Widget'),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : GridView.builder(
                                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2,
                                                crossAxisSpacing: 16,
                                                mainAxisSpacing: 16,
                                                childAspectRatio: 1.5,
                                              ),
                                              itemCount: _dashboardWidgets.length,
                                              itemBuilder: (context, index) {
                                                final widget = _dashboardWidgets[index];
                                                return Card(
                                                  elevation: 2,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(16.0),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              widget['title'] ?? 'Unnamed Widget',
                                                              style: const TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                            const Spacer(),
                                                            IconButton(
                                                              icon: const Icon(Icons.delete_outline),
                                                              onPressed: () => _deleteWidget(widget['id']),
                                                              tooltip: 'Remove widget',
                                                            ),
                                                          ],
                                                        ),
                                                        const Divider(),
                                                        const Expanded(
                                                          child: Center(
                                                            child: Text('Widget Preview'),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
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
          // Loading overlay for save operation
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

  void _showAddWidgetMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Widget'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.bar_chart),
                title: const Text('Chart'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showAddChartOptions(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.table_chart),
                title: const Text('Table'),
                onTap: () {
                  Navigator.of(context).pop();
                  _addWidget('Table', 'table');
                },
              ),
              ListTile(
                leading: const Icon(Icons.text_fields),
                title: const Text('Text Block'),
                onTap: () {
                  Navigator.of(context).pop();
                  _addWidget('Text', 'text');
                },
              ),
              ListTile(
                leading: const Icon(Icons.query_stats),
                title: const Text('SQL Query'),
                onTap: () {
                  Navigator.of(context).pop();                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NewSqlQueryPage()),
                  );
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
                  _addWidget('Bar Chart', 'bar_chart');
                },
              ),
              ListTile(
                leading: const Icon(Icons.pie_chart),
                title: const Text('Pie Chart'),
                onTap: () {
                  Navigator.of(context).pop();
                  _addWidget('Pie Chart', 'pie_chart');
                },
              ),
              ListTile(
                leading: const Icon(Icons.show_chart),
                title: const Text('Line Chart'),
                onTap: () {
                  Navigator.of(context).pop();
                  _addWidget('Line Chart', 'line_chart');
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

  Future<void> _addWidget(String widgetTitle, String widgetType) async {
    try {
      setState(() => _isLoading = true);
      
      // Create a widget in Firestore
      final widgetData = {
        'title': widgetTitle,
        'type': widgetType,
        'createdAt': DateTime.now().toString(),
        'dashboardId': widget.dashboardId,
        'configuration': {
          'size': 'medium',
          'position': _dashboardWidgets.length,
        }
      };
        final widgetRef = await FirebaseFirestore.instance.collection('widgets').add(widgetData);
      
      // Update dashboard with new widget reference
      await _firestoreService.dashboards.doc(widget.dashboardId).update({
        'widgets': FieldValue.arrayUnion([widgetRef.id]),
        'updatedAt': DateTime.now().toString(),
      });
      
      // Reload dashboard data
      _loadDashboardData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$widgetTitle added to dashboard')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding widget: ${e.toString()}')),
      );
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _deleteWidget(String widgetId) async {
    try {
      setState(() => _isLoading = true);
      
      // Remove widget reference from dashboard
      await _firestoreService.dashboards.doc(widget.dashboardId).update({
        'widgets': FieldValue.arrayRemove([widgetId]),
        'updatedAt': DateTime.now().toString(),
      });
        // Delete the widget document
      await FirebaseFirestore.instance.collection('widgets').doc(widgetId).delete();
      
      // Reload dashboard data
      _loadDashboardData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Widget removed from dashboard')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing widget: ${e.toString()}')),
      );
      setState(() => _isLoading = false);
    }
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
