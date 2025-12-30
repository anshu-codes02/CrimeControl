import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../models/case.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../widgets/enhanced_card.dart';
import '../widgets/status_badge.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/case_tags_display.dart';
import 'create_case_screen.dart';
import 'case_detail_screen.dart';
import 'dm_list_screen.dart';

class CasesScreen extends StatefulWidget {
  final User? user;
  const CasesScreen({super.key, this.user});

  @override
  State<CasesScreen> createState() => _CasesScreenState();
}

class _CasesScreenState extends State<CasesScreen> {
  late Future<List<Case>> _casesFuture;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      _casesFuture = _authService.fetchCases();
    });
  }

  void _navigateToCreateCase() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateCaseScreen(
          onCaseCreated: () {
            _initializeData(); // Refresh cases list
          },
        ),
      ),
    );
    if (result == true) {
      _initializeData(); // Refresh cases list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = widget.user ?? authProvider.user;
        
        if (user == null) {
          print("darpan null user - user not logged in or failed to fetch");
        } else {
          print("darpan user found: ${user.username}, role: ${user.role}");
        }
        
        final canPost =
            user != null && (user.role == 'ADMIN' || user.role == 'ORGANIZATION');
        print("darpan canPost: $canPost, user role: ${user?.role}");
        
        final theme = Theme.of(context);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Active Cases'),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.message_rounded),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DMInboxScreen()),
                  );
                },
                tooltip: 'Messages',
              ),
            ],
          ),
          floatingActionButton: canPost
              ? FloatingActionButton.extended(
                  onPressed: _navigateToCreateCase,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('New Case'),
                  tooltip: 'Create New Case',
                )
              : null,
          body: FutureBuilder<List<Case>>(
            future: _casesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Padding(
                  padding: const EdgeInsets.all(AppConstants.spacingMd),
                  child: Column(
                    children: List.generate(
                      5,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: AppConstants.spacingMd),
                        child: ShimmerCard(height: 120),
                      ),
                    ),
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.spacingLg),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 64,
                          color: Color(AppConstants.errorColor),
                        ),
                        const SizedBox(height: AppConstants.spacingMd),
                        Text(
                          'Error loading cases',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Color(AppConstants.errorColor),
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingSm),
                        Text(
                          '${snapshot.error}',
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.spacingLg),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_open_rounded,
                          size: 64,
                          color: Color(AppConstants.textLightColor),
                        ),
                        const SizedBox(height: AppConstants.spacingMd),
                        Text(
                          'No cases found',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Color(AppConstants.textLightColor),
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingSm),
                        Text(
                          'Cases will appear here when they are created',
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              final cases = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(AppConstants.spacingMd),
                itemCount: cases.length,
                itemBuilder: (context, index) {
                  final c = cases[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppConstants.spacingMd),
                    child: EnhancedCard(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CaseDetailScreen(caseItem: c),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Case header with image and title
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Case image or icon
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                                  gradient: c.imageUrl != null && c.imageUrl!.isNotEmpty
                                      ? null
                                      : LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(AppConstants.primaryColor),
                                            Color(AppConstants.secondaryColor),
                                          ],
                                        ),
                                ),
                                child: c.imageUrl != null && c.imageUrl!.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                                        child: Image.network(
                                          c.imageUrl!,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stack) => Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Color(AppConstants.primaryColor),
                                                  Color(AppConstants.secondaryColor),
                                                ],
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.folder_rounded,
                                              color: Colors.white,
                                              size: 40,
                                            ),
                                          ),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.folder_rounded,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                              ),
                              const SizedBox(width: AppConstants.spacingMd),
                              // Case details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.title,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: AppConstants.spacingSm),
                                    Text(
                                      c.description,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: Color(AppConstants.textLightColor),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.spacingMd),
                          // Tags display
                          if (c.tags.isNotEmpty) ...[
                            CaseTagsDisplay(
                              tags: c.tags,
                              maxVisible: 3,
                            ),
                            const SizedBox(height: AppConstants.spacingSm),
                          ],
                          // Status and timestamp row
                          Row(
                            children: [
                              StatusBadge(status: c.status),
                              if (c.caseType != null) ...[
                                const SizedBox(width: AppConstants.spacingSm),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppConstants.spacingSm,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(AppConstants.secondaryColor).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                                    border: Border.all(
                                      color: Color(AppConstants.secondaryColor).withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    c.caseType!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Color(AppConstants.secondaryColor),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                              const Spacer(),
                              if (c.postedAt != null) ...[
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 16,
                                  color: Color(AppConstants.textLightColor),
                                ),
                                const SizedBox(width: AppConstants.spacingSm),
                                Text(
                                  c.postedAt!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Color(AppConstants.textLightColor),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
