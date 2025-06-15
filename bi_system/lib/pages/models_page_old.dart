import 'package:flutter/material.dart';
import '../widgets/collapsible_sidebar.dart';

class Model {
  final String id;
  final String name;
  final String description;
  final String type;
  final String lastModified;
  final String createdBy;
  final String accuracy;

  Model({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.lastModified,
    required this.createdBy,
    required this.accuracy,
  });
}

class ModelsPage extends StatefulWidget {
  const ModelsPage({super.key});

  @override
  State<ModelsPage> createState() => _ModelsPageState();
}

class _ModelsPageState extends State<ModelsPage> {
  bool _isSidebarExpanded = true;
  bool _isLoading = false;
  String _searchQuery = '';
  List<Model> _models = [];
  
  @override
  void initState() {
    super.initState();
    _loadModels();
  }

  Future<void> _loadModels() async {
    try {
      _showLoading();
      // Simulate loading from a database
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data
      setState(() {
        _models = [
          Model(
            id: '1',
            name: 'Football Player Performance',
            description: 'Predicts player performance based on historical data',
            type: 'Regression',
            lastModified: '2023-08-15',
            createdBy: 'John Doe',
            accuracy: '87%',
          ),
          Model(
            id: '2',
            name: 'Basketball Team Analysis',
            description: 'Analyzes team dynamics and predicts game outcomes',
            type: 'Classification',
            lastModified: '2023-09-23',
            createdBy: 'Jane Smith',
            accuracy: '92%',
          ),
          Model(
            id: '3',
            name: 'Athlete Injury Risk',
            description: 'Predicts injury risk for athletes based on workload and recovery metrics',
            type: 'Neural Network',
            lastModified: '2023-10-05',
            createdBy: 'David Johnson',
            accuracy: '85%',
          ),
          Model(
            id: '4',
            name: 'Match Outcome Predictor',
            description: 'Predicts match results based on team statistics and historical performance',
            type: 'Ensemble',
            lastModified: '2023-11-12',
            createdBy: 'Sarah Williams',
            accuracy: '79%',
          ),
        ];
      });
    } catch (e) {
      _showError('Failed to load models: ${e.toString()}');
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
  
  List<Model> get _filteredModels {
    if (_searchQuery.isEmpty) {
      return _models;
    }
    return _models.where((model) => 
      model.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      model.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      model.type.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }
  
  void _createNewModel() {
    // Navigate to model creation page or show dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Model'),
        content: const Text('Model creation functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  void _viewModelDetails(Model model) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(model.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${model.type}'),
            const SizedBox(height: 8),
            Text('Description: ${model.description}'),
            const SizedBox(height: 8),
            Text('Accuracy: ${model.accuracy}'),
            const SizedBox(height: 8),
            Text('Created by: ${model.createdBy}'),
            const SizedBox(height: 8),
            Text('Last modified: ${model.lastModified}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Edit model implementation would go here
            },
            child: const Text('Edit Model'),
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
                currentPage: 'Models',
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
                              'Models',
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
                                  hintText: 'Search models...',
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
                            // Create new model button
                            ElevatedButton.icon(
                              onPressed: _createNewModel,
                              icon: const Icon(Icons.add),
                              label: const Text('New Model'),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Models",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.refresh),
                                  onPressed: _loadModels,
                                  tooltip: 'Refresh models',
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Models grid
                            Expanded(
                              child: _filteredModels.isEmpty
                                ? Center(
                                    child: Text(
                                      _searchQuery.isEmpty
                                        ? "No models available. Create your first model!"
                                        : "No models match your search criteria.",
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
                                    itemCount: _filteredModels.length,
                                    itemBuilder: (context, index) {
                                      final model = _filteredModels[index];
                                      return Card(
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: InkWell(
                                          onTap: () => _viewModelDetails(model),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.model_training,
                                                      color: Colors.blue[700],
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        model.name,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  model.description,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const Spacer(),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Type: ${model.type}',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[700],
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: Colors.green[100],
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      child: Text(
                                                        'Accuracy: ${model.accuracy}',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.green[800],
                                                        ),
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
