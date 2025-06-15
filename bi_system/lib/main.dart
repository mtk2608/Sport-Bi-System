import 'package:flutter/material.dart';
import 'services/firebase_service.dart';
import 'widgets/auth_wrapper.dart';
import 'pages/homepage.dart';
import 'pages/analytics_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/edit_dashboard_page_updated.dart';
import 'widgets/team_dashboard_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with error handling
  final firebaseService = FirebaseService();
  await firebaseService.initializeFirebase();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sport BI System',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/home': (context) => const HomePage(),
        '/analytics': (context) => const AnalyticsPage(),
        '/dashboards': (context) => const DashboardPage(),
        '/teams': (context) => const TeamDashboardWidget(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/edit_dashboard') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) {
              return EditDashboardPage(dashboardId: args['dashboardId']);
            },
          );
        }
        return null;
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
