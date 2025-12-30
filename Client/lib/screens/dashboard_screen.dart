import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'cases_screen.dart';

// NOTE: This DashboardScreen is deprecated to avoid duplicate navigation
// Use MainNavigation from main.dart instead
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    // Redirect to CasesScreen to avoid duplicate navigation
    return CasesScreen();
  }
}
