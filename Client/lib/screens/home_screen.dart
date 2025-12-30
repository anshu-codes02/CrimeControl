import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'cases_screen.dart';

// NOTE: This HomeScreen is deprecated to avoid duplicate navigation
// Use MainNavigation from main.dart instead
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    // Simply return CasesScreen to avoid duplicate navigation
    return CasesScreen(user: user);
  }
}
