import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'login_screen.dart';
import '../models/user.dart';
import '../models/badge.dart' as BadgeModel;
import '../services/auth_service.dart';
import '../services/rating_service.dart';
import '../services/badge_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/rating_dialog.dart';
import 'dm_chat_screen.dart';

class ProfileScreen extends StatefulWidget {
  final int? userId;
  ProfileScreen({Key? key, userId})
    : userId = userId is String ? int.tryParse(userId) : userId,
      super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  User? _currentUser;
  bool _isLoading = true;
  String? _error;
  bool _canRate = false;
  bool _canAwardBadges = false;
  List<Map<String, dynamic>> _userBadges = [];

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      User? user;
      if (widget.userId != null) {
        print(widget.userId!.toString() + " darpan");
        user = await AuthService().getUserById(widget.userId!);
        if (user == null &&
            ModalRoute.of(context)?.settings.arguments is String) {
          // Fallback: try to fetch by username if provided as argument
          final username =
              ModalRoute.of(context)?.settings.arguments as String?;
          if (username != null && username.isNotEmpty) {
            user = await AuthService().getUserByUsername(username);
          }
        }
        if (user == null) {
          setState(() {
            _user = null;
            _isLoading = false;
            _error = 'User not found.';
          });
          return;
        }
      } else {
        user = await AuthService().getCurrentUser();
      }
      
      // Get current user for permission checks
      _currentUser = await AuthService().getCurrentUser();
      
      // Debug logging for expertise areas
      if (user != null) {
        print('=== USER PROFILE DEBUG ===');
        print('User ID: ${user.id}');
        print('Username: ${user.username}');
        print('Role: ${user.role}');
        print('Expertise Areas: ${user.expertiseAreas}');
        print('Expertise Areas Length: ${user.expertiseAreas.length}');
        print('Specializations List: ${user.specializationsList}');
        print('Expertise (String): ${user.expertise}');
        print('========================');
      }
      
      // Check permissions if viewing another user's profile
      if (_currentUser != null && user != null && _currentUser!.id != user.id) {
        // Check if current user can rate this user
        _canRate = await RatingService().canRate(_currentUser!.id!, user.id!);
        
        // Check if current user can award badges
        _canAwardBadges = await BadgeService().canAwardBadges(_currentUser!.id!);
        
        // Fetch user's badges for display
        _userBadges = await BadgeService().getUserBadges(user.id!);
      }
      
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showRatingDialog() {
    if (_currentUser == null || _user == null) return;
    
    showDialog(
      context: context,
      builder: (context) => RatingDialog(
        userName: _user!.displayName,
        userRole: _user!.role,
        caseTitle: 'Profile Rating',
        onSubmit: (rating, comment) async {
          try {
            await RatingService().rateUser(
              raterId: _currentUser!.id!,
              ratedUserId: _user!.id!,
              rating: rating.round(),
              comment: comment,
              category: 'OVERALL',
            );
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Rating submitted successfully!'),
                  backgroundColor: Color(AppConstants.successColor),
                ),
              );
              
              // Refresh user data to show updated rating
              _fetchUser();
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to submit rating: ${e.toString()}'),
                  backgroundColor: const Color(AppConstants.errorColor),
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showBadgeAwardDialog() {
    if (_currentUser == null || _user == null) return;
    
    showDialog(
      context: context,
      builder: (context) => _SimpleBadgeDialog(
        userToAward: _user!,
        awarder: _currentUser!,
        onBadgeAwarded: () {
          // Refresh user data to show new badge
          _fetchUser();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          FutureBuilder<User?>(
            future: AuthService().getCurrentUser(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data == null || _user == null)
                return const SizedBox.shrink();
              final currentUserId = snapshot.data!.id;
              if (_user!.id == currentUserId) {
                return IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'Logout',
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('auth_token'); // Fixed: Use correct key matching AuthService
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed('/login');
                    }
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text('Error: $_error'))
              : _user == null
              ? const Center(child: Text('No user data'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Profile Header
                    Card(
                      color: theme.cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: theme.colorScheme.primary
                                  .withOpacity(0.15),
                              child: const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _user!.displayName,
                              style: theme.textTheme.displayLarge?.copyWith(
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _user!.bio?.isNotEmpty == true
                                  ? _user!.bio!
                                  : 'No bio',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.7,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatItem(
                                  'Cases Solved',
                                  _user!.solvedCasesCount.toString(),
                                  theme,
                                ),
                                _buildStatItem(
                                  'Rating',
                                  _user!.averageRating.toStringAsFixed(1),
                                  theme,
                                ),
                                _buildStatItem(
                                  'Badges',
                                  _user!.badges.length.toString(),
                                  theme,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Profile Sections
                    _buildSection('Personal Information', [
                      _buildProfileItem(
                        Icons.email,
                        'Email',
                        _user!.email ?? 'Not provided',
                        theme,
                      ),
                      if (_user!.phoneNumber != null &&
                          _user!.phoneNumber!.isNotEmpty)
                        _buildProfileItem(
                          Icons.phone,
                          'Phone',
                          _user!.phoneNumber!,
                          theme,
                        ),
                      if (_user!.location != null &&
                          _user!.location!.isNotEmpty)
                        _buildProfileItem(
                          Icons.location_on,
                          'Location',
                          _user!.location!,
                          theme,
                        ),
                      if (_user!.experience != null &&
                          _user!.experience!.isNotEmpty)
                        _buildProfileItem(
                          Icons.work,
                          'Experience',
                          _user!.experience!,
                          theme,
                        ),
                    ], theme),
                    const SizedBox(height: 16),
                    _buildSection('Expertise', [
                      if (_user!.expertiseAreas.isNotEmpty)
                        Container(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.security,
                                      size: 20,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Areas of Expertise',
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: _user!.expertiseAreas.map((area) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: theme.colorScheme.primary.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    area,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )).toList(),
                              ),
                            ],
                          ),
                        ),
                      if (_user!.specializationsList.isNotEmpty)
                        _buildProfileItem(
                          Icons.security,
                          'Specialization',
                          _user!.specializationsList.join(', '),
                          theme,
                        ),
                      if (_user!.certifications != null &&
                          _user!.certifications!.isNotEmpty)
                        _buildProfileItem(
                          Icons.school,
                          'Certifications',
                          _user!.certifications!,
                          theme,
                        ),
                      if (_user!.expertise != null &&
                          _user!.expertise!.isNotEmpty)
                        _buildProfileItem(
                          Icons.star,
                          'Skills',
                          _user!.expertise!,
                          theme,
                        ),
                    ], theme),
                    const SizedBox(height: 16),
                    
                    // Badges Section
                    _buildSection('Badges & Achievements', [
                      if (_userBadges.isNotEmpty)
                        Container(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 12.0,
                                runSpacing: 12.0,
                                children: _userBadges.map((badgeAward) {
                                  final badge = badgeAward['badge'];
                                  if (badge == null) return const SizedBox.shrink();
                                  
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(int.parse(badge['color']?.replaceFirst('#', '0xFF') ?? '0xFF4CAF50')).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                                      border: Border.all(
                                        color: Color(int.parse(badge['color']?.replaceFirst('#', '0xFF') ?? '0xFF4CAF50')).withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.military_tech,
                                          size: 20,
                                          color: Color(int.parse(badge['color']?.replaceFirst('#', '0xFF') ?? '0xFF4CAF50')),
                                        ),
                                        const SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              badge['displayName'] ?? badge['name'] ?? 'Badge',
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: Color(int.parse(badge['color']?.replaceFirst('#', '0xFF') ?? '0xFF4CAF50')),
                                              ),
                                            ),
                                            if (badge['tier'] != null)
                                              Text(
                                                badge['tier'].toString().toUpperCase(),
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                  fontSize: 10,
                                                  color: Color(int.parse(badge['color']?.replaceFirst('#', '0xFF') ?? '0xFF4CAF50')).withOpacity(0.7),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      if (_userBadges.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Icon(
                                Icons.military_tech,
                                size: 48,
                                color: theme.colorScheme.onSurface.withOpacity(0.3),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No badges earned yet',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                    ], theme),
                    const SizedBox(height: 16),
                    _buildSection('Account', [
                      _buildProfileItem(
                        Icons.privacy_tip,
                        'Privacy',
                        _user!.role,
                        theme,
                      ),
                      _buildProfileItem(
                        Icons.language,
                        'Language',
                        'English',
                        theme,
                      ),
                      if (_user!.createdAt != null)
                        _buildProfileItem(
                          Icons.calendar_today,
                          'Joined',
                          _user!.createdAt!.toLocal().toString().split(' ')[0],
                          theme,
                        ),
                    ], theme),
                    const SizedBox(height: 24),
                    // Action Buttons
                    FutureBuilder<User?>(
                      future: AuthService().getCurrentUser(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data == null) {
                          return const SizedBox.shrink();
                        }
                        final currentUserId = snapshot.data!.id;
                        if (_user!.id == currentUserId) {
                          return Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: () {},
                                  style: FilledButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Edit Profile'),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () async {
                                    final prefs = await SharedPreferences.getInstance();
                                    await prefs.remove('auth_token'); // Clear token on logout
                                    if (context.mounted) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => const LoginScreen(),
                                        ),
                                      );
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: theme.colorScheme.primary,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Logout',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else {
                          // Show action buttons for other users
                          return Column(
                            children: [
                              // Send Message button
                              _buildChatButton(
                                forceShow: true,
                                theme: theme,
                              ),
                              
                              // Rating and Badge buttons for authorized users
                              if (_canRate || _canAwardBadges) ...[
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    if (_canRate)
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: _showRatingDialog,
                                          icon: const Icon(Icons.star_rounded),
                                          label: const Text('Rate User'),
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(
                                              color: theme.colorScheme.primary,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (_canRate && _canAwardBadges)
                                      const SizedBox(width: 12),
                                    if (_canAwardBadges)
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: _showBadgeAwardDialog,
                                          icon: const Icon(Icons.military_tech),
                                          label: const Text('Award Badge'),
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(
                                              color: Color(AppConstants.secondaryColor),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ],
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
    );
  }

  Widget _buildStatItem(String label, String value, ThemeData theme) {
    return Column(
      children: [
        Text(value, style: theme.textTheme.titleLarge),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children, ThemeData theme) {
    return Card(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(title, style: theme.textTheme.titleLarge),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildProfileItem(
    IconData icon,
    String label,
    String value,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                Text(value, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatButton({bool forceShow = false, required ThemeData theme}) {
    if (_user == null) return const SizedBox.shrink();
    return FutureBuilder<User?>(
      future: AuthService().getCurrentUser(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null)
          return const SizedBox.shrink();
        final currentUserId = snapshot.data!.id;
        if (!forceShow && _user!.id == currentUserId)
          return const SizedBox.shrink();
        return SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            icon: const Icon(Icons.message),
            onPressed: () async {
              final currentId = currentUserId;
              final otherId = _user!.id;
              if (currentId == null || otherId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid user ID.')),
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DMChatScreen(peerUser: _user!),
                ),
              );
            },
            label: const Text('Send Message'),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Simple Badge Award Dialog
class _SimpleBadgeDialog extends StatefulWidget {
  final User userToAward;
  final User awarder;
  final VoidCallback onBadgeAwarded;

  const _SimpleBadgeDialog({
    required this.userToAward,
    required this.awarder,
    required this.onBadgeAwarded,
  });

  @override
  State<_SimpleBadgeDialog> createState() => _SimpleBadgeDialogState();
}

class _SimpleBadgeDialogState extends State<_SimpleBadgeDialog> {
  List<BadgeModel.Badge> _availableBadges = [];
  BadgeModel.Badge? _selectedBadge;
  final _reasonController = TextEditingController();
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBadges();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadBadges() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      print('Loading badges...');
      final badges = await BadgeService().getAvailableBadges();
      print('Loaded ${badges.length} badges');
      
      setState(() {
        _availableBadges = badges;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading badges: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load badges: ${e.toString()}';
      });
    }
  }

  Future<void> _awardBadge() async {
    if (_selectedBadge == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a badge'),
          backgroundColor: Color(AppConstants.errorColor),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      print('Awarding badge: ${_selectedBadge!.name} (ID: ${_selectedBadge!.id})');
      await BadgeService().awardBadge(
        awarderId: widget.awarder.id!,
        userId: widget.userToAward.id!,
        badgeId: _selectedBadge!.id,
        reason: _reasonController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Badge awarded successfully!'),
            backgroundColor: Color(AppConstants.successColor),
          ),
        );

        widget.onBadgeAwarded();
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Error awarding badge: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to award badge: ${e.toString()}'),
            backgroundColor: const Color(AppConstants.errorColor),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.military_tech,
                    color: Color(AppConstants.secondaryColor),
                    size: 24,
                  ),
                  const SizedBox(width: AppConstants.spacingSm),
                  Expanded(
                    child: Text(
                      'Award Badge to ${widget.userToAward.displayName}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingLg),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppConstants.spacingLg),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(AppConstants.spacingMd),
                  decoration: BoxDecoration(
                    color: const Color(AppConstants.errorColor).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    border: Border.all(
                      color: const Color(AppConstants.errorColor).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _errorMessage!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(AppConstants.errorColor),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingSm),
                      ElevatedButton(
                        onPressed: _loadBadges,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              else ...[
                // Badge Selection
                Text(
                  'Select Badge',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingSm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(AppConstants.textLightColor).withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<BadgeModel.Badge>(
                      value: _selectedBadge,
                      hint: Text('Choose a badge to award (${_availableBadges.length} available)'),
                      onChanged: (BadgeModel.Badge? newValue) {
                        setState(() {
                          _selectedBadge = newValue;
                        });
                        print('Selected badge: ${newValue?.name} (ID: ${newValue?.id})');
                      },
                      items: _availableBadges.map<DropdownMenuItem<BadgeModel.Badge>>((BadgeModel.Badge badge) {
                        return DropdownMenuItem<BadgeModel.Badge>(
                          value: badge,
                          child: Text(
                            badge.name,
                            style: theme.textTheme.bodyMedium,
                          ),
                        );
                      }).toList(),
                      isExpanded: true,
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingLg),

                // Reason
                Text(
                  'Reason (Optional)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingSm),
                TextField(
                  controller: _reasonController,
                  decoration: InputDecoration(
                    hintText: 'Why are you awarding this badge?',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    ),
                    contentPadding: const EdgeInsets.all(AppConstants.spacingMd),
                  ),
                  maxLines: 3,
                  maxLength: 200,
                ),
              ],

              const SizedBox(height: AppConstants.spacingLg),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingMd),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (_isSubmitting || _isLoading || _errorMessage != null) ? null : _awardBadge,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(AppConstants.secondaryColor),
                        foregroundColor: Colors.white,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Award Badge'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
