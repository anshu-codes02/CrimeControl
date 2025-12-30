import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../widgets/enhanced_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/multi_select_chips.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _selectedRole = 'SOLVER';
  List<String> _selectedExpertise = [];
  final List<String> roles = ['SOLVER', 'ORGANIZATION', 'ADMIN', 'RECRUITER'];
  
  // Available expertise areas matching backend categories
  final List<String> _availableExpertise = [
    'Theft',
    'Fraud',
    'Cybercrime',
    'Assault',
    'Robbery',
    'Murder',
    'Drug Offense',
    'Burglary',
    'Vandalism',
    'Kidnapping',
    'Domestic Violence',
    'White Collar Crime',
    'Identity Theft',
    'Money Laundering',
    'Human Trafficking',
    'Terrorism',
    'Corruption',
    'Tax Evasion',
    'Counterfeiting',
    'Intellectual Property',
    'Environmental Crime',
    'Organized Crime',
    'Sexual Offense',
    'Child Abuse',
    'Elder Abuse',
    'Missing Person',
    'Cold Case',
    'Digital Forensics',
    'Financial Investigation',
    'Forensic Accounting',
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: theme.colorScheme.primary,
      ),
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
                  const SizedBox(height: 10),
                  Text(
                    'Create Account',
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Join the crime solving community',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  // First Name Field
                  EnhancedTextField(
                    controller: _firstNameController,
                    labelText: 'First Name',
                    hintText: 'Enter your first name',
                    prefixIcon: Icons.person_outline_rounded,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  
                  // Last Name Field
                  EnhancedTextField(
                    controller: _lastNameController,
                    labelText: 'Last Name',
                    hintText: 'Enter your last name',
                    prefixIcon: Icons.person_outline_rounded,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  
                  // Username Field
                  EnhancedTextField(
                    controller: _usernameController,
                    labelText: 'Username',
                    hintText: 'Choose a unique username',
                    prefixIcon: Icons.alternate_email_rounded,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a username';
                      }
                      if (value.length < 3) {
                        return 'Username must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  
                  // Email Field
                  EnhancedTextField(
                    controller: _emailController,
                    labelText: 'Email Address',
                    hintText: 'Enter your email address',
                    prefixIcon: Icons.email_rounded,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  
                  // Password Field
                  EnhancedTextField(
                    controller: _passwordController,
                    labelText: 'Password',
                    hintText: 'Create a secure password',
                    prefixIcon: Icons.lock_rounded,
                    obscureText: _obscurePassword,
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
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.spacingLg),
                  
                  // Role Selection
                  Container(
                    decoration: BoxDecoration(
                      color: Color(AppConstants.surfaceColor),
                      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                      border: Border.all(
                        color: Color(AppConstants.textLightColor).withOpacity(0.3),
                      ),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedRole,
                      items: roles.map((role) {
                        IconData roleIcon;
                        String roleDescription;
                        switch (role) {
                          case 'SOLVER':
                            roleIcon = Icons.psychology_rounded;
                            roleDescription = 'Help solve cases and collaborate';
                            break;
                          case 'ORGANIZATION':
                            roleIcon = Icons.business_rounded;
                            roleDescription = 'Post cases and seek help';
                            break;
                          case 'ADMIN':
                            roleIcon = Icons.admin_panel_settings_rounded;
                            roleDescription = 'System administration';
                            break;
                          case 'RECRUITER':
                            roleIcon = Icons.people_rounded;
                            roleDescription = 'Recruit talent for cases';
                            break;
                          default:
                            roleIcon = Icons.person_rounded;
                            roleDescription = '';
                        }
                        return DropdownMenuItem(
                          value: role,
                          child: Row(
                            children: [
                              Icon(roleIcon, size: 20),
                              const SizedBox(width: AppConstants.spacingSm),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    role.replaceAll('_', ' '),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (roleDescription.isNotEmpty)
                                    Text(
                                      roleDescription,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: Color(AppConstants.textLightColor),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value!;
                          _selectedExpertise.clear(); // Clear expertise when role changes
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Select Your Role',
                        prefixIcon: Icon(Icons.verified_user_rounded),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingMd,
                          vertical: AppConstants.spacingSm,
                        ),
                      ),
                      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                      dropdownColor: Color(AppConstants.surfaceColor),
                      style: theme.textTheme.bodyMedium,
                      isExpanded: true,
                    ),
                  ),
                  const SizedBox(height: 22),
                  // Expertise Selection (show only for SOLVER role)
                  if (_selectedRole == 'SOLVER') ...[
                    MultiSelectChips(
                      title: 'Areas of Expertise',
                      hint: 'Select your areas of expertise (optional)',
                      options: _availableExpertise,
                      selectedOptions: _selectedExpertise,
                      maxSelections: 5,
                      onChanged: (selected) {
                        setState(() {
                          _selectedExpertise = selected;
                        });
                      },
                    ),
                    const SizedBox(height: AppConstants.spacingLg),
                  ],
                  // Register Button
                  CustomButton(
                    text: 'Create Account',
                    onPressed: _isLoading ? null : _handleRegister,
                    isLoading: _isLoading,
                    icon: Icons.person_add_rounded,
                    type: ButtonType.primary,
                    size: ButtonSize.large,
                  ),
                  const SizedBox(height: 18),
                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Sign In',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.primary,
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

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    
    try {
      final userJson = {
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'role': _selectedRole,
        'password': _passwordController.text.trim(),
        'expertiseAreas': _selectedExpertise,
      };
      
      // Debug logging for registration data
      print('=== REGISTRATION DEBUG ===');
      print('Registration Data: $userJson');
      print('Selected Expertise: $_selectedExpertise');
      print('Selected Expertise Length: ${_selectedExpertise.length}');
      print('=========================');
      
      final authService = AuthService();
      await authService.register(userJson);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful! Please log in.'),
          backgroundColor: Color(AppConstants.successColor),
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      // Navigate to login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: ${e.toString()}'),
          backgroundColor: const Color(AppConstants.errorColor),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
