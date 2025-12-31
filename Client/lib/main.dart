import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'constants/app_constants.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dm_list_screen.dart';
import 'screens/cases_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/hiring_main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CrimeControlApp());
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  
  // direct screen lists
  static List<Widget> _screens = <Widget>[
    CasesScreen(),
    DMInboxScreen(),
    HiringMainScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Color(AppConstants.surfaceColor),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppConstants.radiusLg),
            topRight: Radius.circular(AppConstants.radiusLg),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          indicatorColor: Color(AppConstants.primaryColor).withOpacity(0.2),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          height: 80,
          destinations: [
            NavigationDestination(
              icon: Icon(
                Icons.folder_outlined,
                color: _selectedIndex == 0
                    ? Color(AppConstants.primaryColor)
                    : Color(AppConstants.textLightColor),
              ),
              selectedIcon: Icon(
                Icons.folder_rounded,
                color: Color(AppConstants.primaryColor),
              ),
              label: 'Cases',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.message_outlined,
                color: _selectedIndex == 1
                    ? Color(AppConstants.primaryColor)
                    : Color(AppConstants.textLightColor),
              ),
              selectedIcon: Icon(
                Icons.message_rounded,
                color: Color(AppConstants.primaryColor),
              ),
              label: 'Chat',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.work_outlined,
                color: _selectedIndex == 2
                    ? Color(AppConstants.primaryColor)
                    : Color(AppConstants.textLightColor),
              ),
              selectedIcon: Icon(
                Icons.work_rounded,
                color: Color(AppConstants.primaryColor),
              ),
              label: 'Hiring',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.person_outlined,
                color: _selectedIndex == 3
                    ? Color(AppConstants.primaryColor)
                    : Color(AppConstants.textLightColor),
              ),
              selectedIcon: Icon(
                Icons.person_rounded,
                color: Color(AppConstants.primaryColor),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class CrimeControlApp extends StatelessWidget {
  const CrimeControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: MaterialApp(
        title: 'Crime Control',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Color(AppConstants.primaryColor),
            brightness: Brightness.dark,
            primary: Color(AppConstants.primaryColor),
            secondary: Color(AppConstants.secondaryColor),
            surface: Color(AppConstants.surfaceColor),
            background: Color(AppConstants.backgroundColor),
            onSurface: Color(AppConstants.textColor),
            onBackground: Color(AppConstants.textColor),
            error: Color(AppConstants.errorColor),
          ),
          scaffoldBackgroundColor: Color(AppConstants.backgroundColor),
          cardColor: Color(AppConstants.cardColor),
          // Enhanced typography with better hierarchy
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(AppConstants.textColor),
              letterSpacing: -0.5,
            ),
            displayMedium: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(AppConstants.textColor),
              letterSpacing: -0.25,
            ),
            titleLarge: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(AppConstants.textColor),
              letterSpacing: 0,
            ),
            titleMedium: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(AppConstants.textColor),
            ),
            titleSmall: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(AppConstants.textColor),
            ),
            bodyLarge: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.normal,
              color: Color(AppConstants.textColor),
            ),
            bodyMedium: TextStyle(
              fontSize: 16,
              color: Color(AppConstants.textLightColor),
            ),
            bodySmall: TextStyle(
              fontSize: 14,
              color: Color(AppConstants.textLightColor),
            ),
            labelLarge: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(AppConstants.textColor),
              letterSpacing: 0.5,
            ),
          ),
          // Enhanced input decoration theme
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              borderSide: BorderSide(
                color: Color(AppConstants.textLightColor).withOpacity(0.3),
              ),
            ),
            filled: true,
            fillColor: Color(AppConstants.surfaceColor),
            labelStyle: const TextStyle(color: Color(AppConstants.textLightColor)),
            hintStyle: TextStyle(
              color: Color(AppConstants.textLightColor).withOpacity(0.6),
            ),
            prefixIconColor: Color(AppConstants.textLightColor),
            suffixIconColor: Color(AppConstants.textLightColor),
            contentPadding: const EdgeInsets.symmetric(
              vertical: AppConstants.spacingMd,
              horizontal: AppConstants.spacingMd,
            ),
          ),
          // Enhanced button themes
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(AppConstants.primaryColor),
              foregroundColor: Colors.white,
          elevation: AppConstants.elevationSm,
              shadowColor: Color(AppConstants.primaryColor).withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spacingMd,
                horizontal: AppConstants.spacingLg,
              ),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: Color(AppConstants.primaryColor),
              foregroundColor: Colors.white,
              elevation: AppConstants.elevationSm,
              shadowColor: Color(AppConstants.primaryColor).withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spacingMd,
                horizontal: AppConstants.spacingLg,
              ),
            ),
          ),
          // Enhanced card theme
          cardTheme: CardTheme(
            elevation: AppConstants.elevationSm,
            color: Color(AppConstants.cardColor),
            shadowColor: Colors.black.withOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            ),
            margin: const EdgeInsets.symmetric(
              vertical: AppConstants.spacingSm,
              horizontal: AppConstants.spacingSm,
            ),
          ),
          // Enhanced app bar theme
          appBarTheme: AppBarTheme(
            backgroundColor: Color(AppConstants.backgroundColor),
            foregroundColor: Color(AppConstants.textColor),
            elevation: 0,
            centerTitle: true,
            titleTextStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(AppConstants.textColor),
            ),
          ),
          // Enhanced snackbar theme
          snackBarTheme: SnackBarThemeData(
            backgroundColor: Color(AppConstants.cardColor),
            contentTextStyle: const TextStyle(color: Color(AppConstants.textColor)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            ),
            behavior: SnackBarBehavior.floating,
          ),
          // Enhanced floating action button theme
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Color(AppConstants.primaryColor),
            foregroundColor: Colors.white,
            elevation: AppConstants.elevationMd,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            ),
          ),
        ),
        home: AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    if (authProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (authProvider.isLoggedIn) {
      return const MainNavigation();
    } else {
      return const LoginScreen();
    }
  }
}
