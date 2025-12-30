import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../widgets/enhanced_text_field.dart';
import '../widgets/custom_button.dart';
import 'register_screen.dart';
import '../main.dart'; // Import MainNavigation instead of HomeScreen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 28.0,
              vertical: 32.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppConstants.spacingXl),
                  // Enhanced avatar with gradient background
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(AppConstants.primaryColor),
                          Color(AppConstants.secondaryColor),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(AppConstants.primaryColor).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.security_rounded,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingLg),
                  // Enhanced title with gradient text effect
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        Color(AppConstants.primaryColor),
                        Color(AppConstants.secondaryColor),
                      ],
                    ).createShader(bounds),
                    child: Text(
                      'CrimeNet',
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingSm),
                  Text(
                    'Secure Crime Collaboration Platform',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Color(AppConstants.textLightColor),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.spacing2Xl),
                  // Enhanced Username Field
                  EnhancedTextField(
                    controller: _usernameController,
                    labelText: 'Username',
                    hintText: 'Enter your username',
                    prefixIcon: Icons.person_rounded,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  // Enhanced Password Field
                  EnhancedTextField(
                    controller: _passwordController,
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    obscureText: _obscurePassword,
                    prefixIcon: Icons.lock_rounded,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.spacingLg),
                  // Enhanced Login Button
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return CustomButton(
                        text: 'Sign In',
                        onPressed: authProvider.isLoading ? null : _handleLogin,
                        isLoading: authProvider.isLoading,
                        icon: Icons.login_rounded,
                        type: ButtonType.primary,
                        size: ButtonSize.large,
                      );
                    },
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  // Enhanced Error Message
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      if (authProvider.error != null) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: AppConstants.spacingSm),
                          padding: const EdgeInsets.all(AppConstants.spacingMd),
                          decoration: BoxDecoration(
                            color: Color(AppConstants.errorColor).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                            border: Border.all(
                              color: Color(AppConstants.errorColor).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                color: Color(AppConstants.errorColor),
                                size: 20,
                              ),
                              const SizedBox(width: AppConstants.spacingSm),
                              Expanded(
                                child: Text(
                                  authProvider.error!,
                                  style: TextStyle(
                                    color: Color(AppConstants.errorColor),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  // Enhanced Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Color(AppConstants.textLightColor),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Color(AppConstants.primaryColor),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spacingSm,
                          ),
                        ),
                        child: Text(
                          'Sign Up',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: Color(AppConstants.primaryColor),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (authProvider.isLoggedIn && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
      }
    }
  }
}
