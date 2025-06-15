import 'package:flutter/material.dart';
import 'edit_dashboard_page.dart';
import '../widgets/collapsible_sidebar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isSidebarExpanded = true;

  void _toggleSidebar() {
    setState(() {
      _isSidebarExpanded = !_isSidebarExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Row(
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
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      const Text(
                        'Tayfeb Kamalidien\'s Personal Collection',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.search, color: Colors.grey),
                        onPressed: () {
                          // Handle search
                        },
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle new action
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, size: 16),
                              SizedBox(width: 4),
                              Text('New'),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.grey),
                        onPressed: () {
                          // Handle settings
                        },
                      ),
                    ],
                  ),
                ),
                // Main dashboard content
                Expanded(
                  child: Column(
                    children: [
                      // Header section with title and actions
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        color: Colors.white,
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Test',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.grey),
                              onPressed: () {
                                // Handle edit
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.share, color: Colors.grey),
                              onPressed: () {
                                // Handle share
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.star_border, color: Colors.grey),
                              onPressed: () {
                                // Handle favorite
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.bookmark_border, color: Colors.grey),
                              onPressed: () {
                                // Handle bookmark
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.more_vert, color: Colors.grey),
                              onPressed: () {
                                // Handle more options
                              },
                            ),
                          ],
                        ),
                      ),
                      // Main content area
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          color: Colors.white,
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
                                // Empty state text
                                const Text(
                                  'This dashboard is empty',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Click on the ✏️ Edit button to add questions, filters, links, or text.',
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
                                    // Navigate to edit dashboard page
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => const EditDashboardPage(dashboardId: 'default'),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
