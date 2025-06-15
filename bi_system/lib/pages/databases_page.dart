import 'package:flutter/material.dart';
import '../widgets/collapsible_sidebar.dart';

class DatabaseConnection {
  final String id;
  final String name;
  final String type;
  final String host;
  final String status;
  final String lastConnected;
  final List<String> tables;

  DatabaseConnection({
    required this.id,
    required this.name,
    required this.type,
    required this.host,
    required this.status,
    required this.lastConnected,
    required this.tables,
  });
}

class DatabasesPage extends StatefulWidget {
  const DatabasesPage({super.key});

  @override
  State<DatabasesPage> createState() => _DatabasesPageState();
}

class _DatabasesPageState extends State<DatabasesPage> {
  bool _isSidebarExpanded = true;
  bool _isLoading = false;
  String _searchQuery = '';
  List<DatabaseConnection> _connections = [];
  DatabaseConnection? _selectedDatabase;
  
  @override
  void initState() {
    super.initState();
    _loadDatabases();
  }

  Future<void> _loadDatabases() async {
    try {
      _showLoading();
      // Simulate loading from a database
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data
      setState(() {
        _connections = [
          DatabaseConnection(
            id: '1',
            name: 'Sports Analytics DB',
            type: 'PostgreSQL',
            host: 'sports-analytics.db.example.com',
            status: 'Connected',
            lastConnected: '2023-11-15 10:30',
            tables: ['players', 'teams', 'matches', 'statistics', 'injuries'],
          ),
          DatabaseConnection(
            id: '2',
            name: 'Player Performance DB',
            type: 'MySQL',
            host: 'player-metrics.db.example.com',
            status: 'Connected',
            lastConnected: '2023-11-15 09:45',
            tables: ['performance_metrics', 'training_data', 'health_records'],
          ),
          DatabaseConnection(
            id: '3',
            name: 'Match History Archive',
            type: 'MongoDB',
            host: 'matches.db.example.com',
            status: 'Disconnected',
            lastConnected: '2023-11-12 16:20',
            tables: ['matches', 'events', 'highlights'],
          ),
          DatabaseConnection(
            id: '4',
            name: 'Team Statistics',
            type: 'Oracle',
            host: 'team-stats.db.example.com',
            status: 'Connected',
            lastConnected: '2023-11-15 08:15',
            tables: ['team_performance', 'player_stats', 'historical_data'],
          ),
        ];
      });
    } catch (e) {
      _showError('Failed to load database connections: ${e.toString()}');
    } finally {
      _hideLoading();
    }
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarExpanded = !_isSidebarExpanded;
    });
  }
  
  // Function to show loading indicator
  void _showLoading() {
    setState(() {
      _isLoading = true;
    });
  }
  
  // Function to hide loading indicator
  void _hideLoading() {
    setState(() {
      _isLoading = false;
    });
  }
  
  // Show error message
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  
  List<DatabaseConnection> get _filteredConnections {
    if (_searchQuery.isEmpty) {
      return _connections;
    }
    return _connections.where((conn) => 
      conn.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      conn.type.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      conn.host.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }
  
  void _addNewConnection() {
    // Show dialog to add a new database connection
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Database Connection'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Connection Name',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Database Type',
                ),
                items: ['PostgreSQL', 'MySQL', 'MongoDB', 'Oracle', 'SQL Server', 'SQLite']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {},
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Host',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Port',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Database Name',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Username',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Logic to add a new connection would go here
              Navigator.of(context).pop();
              _showError('Connection added successfully!'); // Show success message
            },
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }
  
  void _selectDatabase(DatabaseConnection db) {
    setState(() {
      _selectedDatabase = db;
    });
  }
  
  void _testConnection(DatabaseConnection db) async {
    try {
      _showLoading();
      // Simulate a network request
      await Future.delayed(const Duration(seconds: 2));
      
      // Show success message
      _showError('Successfully connected to ${db.name}');
    } catch (e) {
      _showError('Connection test failed: ${e.toString()}');
    } finally {
      _hideLoading();
    }
  }

  Widget _buildDatabaseDetails() {
    if (_selectedDatabase == null) {
      return Center(
        child: Text(
          'Select a database connection to view details',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      );
    }
    
    final db = _selectedDatabase!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              db.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: db.status == 'Connected' ? Colors.green[100] : Colors.red[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                db.status,
                style: TextStyle(
                  fontSize: 12,
                  color: db.status == 'Connected' ? Colors.green[800] : Colors.red[800],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Type: ${db.type}'),
        const SizedBox(height: 8),
        Text('Host: ${db.host}'),
        const SizedBox(height: 8),
        Text('Last Connected: ${db.lastConnected}'),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              'Tables',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${db.tables.length})',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: db.tables.length,
            itemBuilder: (context, index) {
              final table = db.tables[index];
              return ListTile(
                leading: const Icon(Icons.table_chart),
                title: Text(table),
                dense: true,
                onTap: () {
                  // Show table structure
                },
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton.icon(
              onPressed: () => _testConnection(db),
              icon: const Icon(Icons.refresh),
              label: const Text('Test Connection'),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () {
                // Open query editor
              },
              icon: const Icon(Icons.code),
              label: const Text('Query Editor'),
            ),
          ],
        ),
      ],
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
                currentPage: 'Databases',
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
                              'Databases',
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
                                  hintText: 'Search connections...',
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
                            // Add new connection button
                            ElevatedButton.icon(
                              onPressed: _addNewConnection,
                              icon: const Icon(Icons.add),
                              label: const Text('New Connection'),
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
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left side - Connection list
                            Expanded(
                              flex: 2,
                              child: Card(
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            'Database Connections',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '(${_filteredConnections.length})',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            icon: const Icon(Icons.refresh),
                                            onPressed: _loadDatabases,
                                            tooltip: 'Refresh connections',
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Divider(height: 1),
                                    Expanded(
                                      child: _filteredConnections.isEmpty
                                          ? Center(
                                              child: Text(
                                                _searchQuery.isEmpty
                                                    ? "No database connections. Add your first connection!"
                                                    : "No connections match your search criteria.",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            )
                                          : ListView.builder(
                                              itemCount: _filteredConnections.length,
                                              itemBuilder: (context, index) {
                                                final conn = _filteredConnections[index];
                                                final isSelected = _selectedDatabase?.id == conn.id;
                                                return ListTile(
                                                  selected: isSelected,
                                                  selectedTileColor: Colors.blue[50],
                                                  leading: Icon(
                                                    Icons.storage,
                                                    color: conn.status == 'Connected'
                                                        ? Colors.green
                                                        : Colors.red,
                                                  ),
                                                  title: Text(
                                                    conn.name,
                                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                                  ),
                                                  subtitle: Text(
                                                    '${conn.type} • ${conn.host}',
                                                    style: const TextStyle(fontSize: 12),
                                                  ),
                                                  trailing: PopupMenuButton(
                                                    itemBuilder: (context) => [
                                                      const PopupMenuItem(
                                                        value: 'test',
                                                        child: Text('Test Connection'),
                                                      ),
                                                      const PopupMenuItem(
                                                        value: 'edit',
                                                        child: Text('Edit Connection'),
                                                      ),
                                                      const PopupMenuItem(
                                                        value: 'delete',
                                                        child: Text('Delete Connection'),
                                                      ),
                                                    ],
                                                    onSelected: (value) {
                                                      if (value == 'test') {
                                                        _testConnection(conn);
                                                      }
                                                    },
                                                  ),
                                                  onTap: () => _selectDatabase(conn),
                                                );
                                              },
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            // Right side - Connection details
                            Expanded(
                              flex: 3,
                              child: Card(
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: _buildDatabaseDetails(),
                                ),
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
