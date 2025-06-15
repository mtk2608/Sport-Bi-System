import 'package:flutter/material.dart';
import '../widgets/collapsible_sidebar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isSidebarExpanded = true;
  bool _isLoading = false;

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
  
  // Example method with loading state and error handling
  Future<void> _refreshDashboard() async {
    try {
      _showLoading();
      // Simulate an async operation
      await Future.delayed(const Duration(seconds: 1));
      // Do something...
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error refreshing dashboard: ${e.toString()}')),
        );
      }
    } finally {
      _hideLoading();
    }
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
                              'Dashboard',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            const Spacer(),
                            // Action buttons
                            IconButton(
                              icon: Icon(Icons.refresh, color: Colors.grey[700]),
                              onPressed: _refreshDashboard,
                              tooltip: 'Refresh',
                            ),
                            IconButton(
                              icon: Icon(Icons.tune, color: Colors.grey[700]),
                              onPressed: () {},
                              tooltip: 'Settings',
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Content area
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Dashboard content...
                            // You can keep your existing content here
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
