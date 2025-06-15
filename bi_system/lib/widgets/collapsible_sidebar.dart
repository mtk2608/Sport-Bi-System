import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../pages/homepage.dart';
import '../pages/personal_collection_page.dart';
import '../pages/examples_page.dart';
import '../pages/models_page.dart';
import '../pages/databases_page.dart';
import '../pages/metrics_page.dart';
import '../pages/trash_page.dart';

class CollapsibleSidebar extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final String currentPage;

  const CollapsibleSidebar({
    super.key,
    required this.isExpanded,
    required this.onToggle,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isExpanded ? 250 : 60,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with logo and hamburger
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.grey),
                  onPressed: onToggle,
                ),
                if (isExpanded) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.dashboard,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Navigation items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [                _buildNavItem(
                  icon: Icons.home_outlined,
                  label: 'Home',
                  isSelected: currentPage == 'Home',
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  },
                ),
                const SizedBox(height: 24),
                if (isExpanded)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Text(
                          'COLLECTIONS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.more_horiz,
                          size: 16,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),                _buildNavItem(
                  icon: Icons.analytics_outlined,
                  label: 'Analytics',
                  isSelected: currentPage == 'Analytics',
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/analytics');
                  },
                ),                _buildNavItem(
                  icon: Icons.person_outline,
                  label: 'Your personal collection',
                  isSelected: currentPage == 'Your personal collection',
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const PersonalCollectionPage()),
                    );
                  },                ),
                _buildNavItem(
                  icon: Icons.dashboard_outlined,
                  label: 'Dashboards',
                  isSelected: currentPage == 'Dashboards',
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/dashboards');
                  },
                ),
                _buildNavItem(
                  icon: Icons.sports_soccer_outlined,
                  label: 'Teams',
                  isSelected: currentPage == 'Teams',
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/teams');
                  },
                ),                
                _buildNavItem(
                  icon: Icons.folder_outlined,
                  label: 'Examples',
                  isSelected: currentPage == 'Examples',
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const ExamplesPage()),
                    );
                  },
                ),
                const SizedBox(height: 24),
                if (isExpanded)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Text(
                          'BROWSE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),                  ),
                const SizedBox(height: 12),
                _buildNavItem(
                  icon: Icons.model_training_outlined,
                  label: 'Models',
                  isSelected: currentPage == 'Models',
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const ModelsPage()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildNavItem(
                  icon: Icons.storage_outlined,  
                  label: 'Databases',
                  isSelected: currentPage == 'Databases',
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const DatabasesPage()),
                    );
                  },
                ),                _buildNavItem(
                  icon: Icons.trending_up_outlined,
                  label: 'Metrics',
                  isSelected: currentPage == 'Metrics',
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MetricsPage()),
                    );
                  },
                ),const SizedBox(height: 24),                _buildNavItem(
                  icon: Icons.delete_outline,
                  label: 'Trash',
                  isSelected: currentPage == 'Trash',
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const TrashPage()),
                    );
                  },
                ),
                const Spacer(),                // Sign out option
                Container(
                  margin: const EdgeInsets.all(8),
                  child: _buildNavItem(
                    icon: Icons.logout,
                    label: 'Sign Out',
                    isSelected: false,
                    onTap: () async {
                      try {
                        final authService = AuthService();
                        await authService.signOut();
                        // When signed out, the AuthWrapper will automatically navigate to the SignInPage
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error signing out: ${e.toString()}')),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected ? Colors.blue : Colors.grey[600],
                ),
                if (isExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                        color: isSelected ? Colors.blue : Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
