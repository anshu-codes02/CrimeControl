import 'package:flutter/material.dart';
import '../models/badge_with_multiplier.dart';

class BadgeWithMultiplierWidget extends StatelessWidget {
  final BadgeWithMultiplier badge;
  final VoidCallback? onTap;
  final double size;
  final bool showDetails;

  const BadgeWithMultiplierWidget({
    Key? key,
    required this.badge,
    this.onTap,
    this.size = 60.0,
    this.showDetails = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge with multiplier
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Main badge container
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: badge.badgeColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _getBorderColor(),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: badge.badgeColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    badge.badgeIcon,
                    size: size * 0.5,
                    color: _getIconColor(),
                  ),
                ),
                // Multiplier badge
                if (badge.hasMultiplier)
                  Positioned(
                    top: -5,
                    right: -5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: Text(
                        badge.multiplierText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                // Tier indicator
                Positioned(
                  bottom: -2,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: _getTierColor(),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
            if (showDetails) ...[
              const SizedBox(height: 8),
              // Badge name
              Text(
                badge.displayName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              // Badge tier
              Text(
                badge.tier.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  color: _getTierColor(),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              // Count info for multipliers
              if (badge.hasMultiplier)
                Text(
                  'Earned ${badge.count} times',
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getBorderColor() {
    switch (badge.tier.toLowerCase()) {
      case 'bronze':
        return const Color(0xFF8B4513);
      case 'silver':
        return const Color(0xFF808080);
      case 'gold':
        return const Color(0xFFB8860B);
      case 'platinum':
        return const Color(0xFF71706E);
      default:
        return Colors.grey;
    }
  }

  Color _getIconColor() {
    // Use white icon for darker badge colors, dark icon for lighter colors
    final luminance = badge.badgeColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  Color _getTierColor() {
    switch (badge.tier.toLowerCase()) {
      case 'bronze':
        return const Color(0xFFCD7F32);
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'gold':
        return const Color(0xFFFFD700);
      case 'platinum':
        return const Color(0xFFE5E4E2);
      default:
        return Colors.grey;
    }
  }
}

class BadgeMultiplierGrid extends StatelessWidget {
  final List<BadgeWithMultiplier> badges;
  final Function(BadgeWithMultiplier)? onBadgeTap;
  final int crossAxisCount;
  final double badgeSize;
  final bool showDetails;

  const BadgeMultiplierGrid({
    Key? key,
    required this.badges,
    this.onBadgeTap,
    this.crossAxisCount = 4,
    this.badgeSize = 60.0,
    this.showDetails = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.military_tech,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No badges earned yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: showDetails ? 0.8 : 1.0,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        return BadgeWithMultiplierWidget(
          badge: badge,
          size: badgeSize,
          showDetails: showDetails,
          onTap: onBadgeTap != null ? () => onBadgeTap!(badge) : null,
        );
      },
    );
  }
}

class BadgeDetailDialog extends StatelessWidget {
  final BadgeWithMultiplier badge;

  const BadgeDetailDialog({
    Key? key,
    required this.badge,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            badge.badgeIcon,
            color: badge.badgeColor,
            size: 30,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  badge.displayName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${badge.tier.toUpperCase()} TIER',
                  style: TextStyle(
                    fontSize: 12,
                    color: badge.badgeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            badge.description,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          if (badge.hasMultiplier) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.repeat, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Earned ${badge.count} times',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          _buildInfoRow('Type', badge.type.replaceAll('_', ' ').toUpperCase()),
          _buildInfoRow('First Earned', _formatDate(badge.firstEarned)),
          if (badge.hasMultiplier)
            _buildInfoRow('Last Earned', _formatDate(badge.lastEarned)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
