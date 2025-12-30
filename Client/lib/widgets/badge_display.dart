import 'package:flutter/material.dart' hide Badge;
import '../models/badge.dart';
import '../constants/app_constants.dart';

class BadgeDisplay extends StatelessWidget {
  final Badge badge;
  final double size;
  final bool showName;
  final bool showDescription;

  const BadgeDisplay({
    super.key,
    required this.badge,
    this.size = 40,
    this.showName = true,
    this.showDescription = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: badge.isUnlocked 
            ? badge.color.withOpacity(0.1)
            : Color(AppConstants.textLightColor).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(
          color: badge.isUnlocked 
              ? badge.color.withOpacity(0.3)
              : Color(AppConstants.textLightColor).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            badge.icon,
            size: size,
            color: badge.isUnlocked 
                ? badge.color
                : Color(AppConstants.textLightColor),
          ),
          if (showName) ...[
            const SizedBox(height: 4),
            Text(
              badge.name,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: badge.isUnlocked 
                    ? null
                    : Color(AppConstants.textLightColor),
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (showDescription) ...[
            const SizedBox(height: 2),
            Text(
              badge.description,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: Color(AppConstants.textLightColor),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class BadgeGrid extends StatelessWidget {
  final List<Badge> badges;
  final int crossAxisCount;

  const BadgeGrid({
    super.key,
    required this.badges,
    this.crossAxisCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.8,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        return BadgeDisplay(
          badge: badges[index],
          size: 32,
          showName: true,
        );
      },
    );
  }
}

class BadgeRow extends StatelessWidget {
  final List<Badge> badges;
  final int maxVisible;

  const BadgeRow({
    super.key,
    required this.badges,
    this.maxVisible = 5,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visibleBadges = badges.take(maxVisible).toList();
    final hasMore = badges.length > maxVisible;

    return Row(
      children: [
        ...visibleBadges.map((badge) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: BadgeDisplay(
            badge: badge,
            size: 24,
            showName: false,
          ),
        )),
        if (hasMore)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(AppConstants.surfaceColor),
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              border: Border.all(
                color: Color(AppConstants.textLightColor).withOpacity(0.3),
              ),
            ),
            child: Center(
              child: Text(
                '+${badges.length - maxVisible}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Color(AppConstants.textLightColor),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
