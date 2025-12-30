import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Enhanced app bar with consistent styling and optional actions
/// Provides better visual hierarchy and user experience
class EnhancedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const EnhancedAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(AppConstants.backgroundColor),
            Color(AppConstants.backgroundColor).withOpacity(0.95),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AppBar(
        title: Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Color(AppConstants.textColor),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: leading ?? 
            (showBackButton && Navigator.canPop(context)
                ? IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: Color(AppConstants.textColor),
                    ),
                    onPressed: onBackPressed ?? () => Navigator.pop(context),
                  )
                : null),
        actions: actions?.map((action) {
          // Wrap actions in enhanced styling
          if (action is IconButton) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Color(AppConstants.surfaceColor).withOpacity(0.8),
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              ),
              child: action,
            );
          }
          return action;
        }).toList(),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(AppConstants.backgroundColor),
                Color(AppConstants.backgroundColor).withOpacity(0.98),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
