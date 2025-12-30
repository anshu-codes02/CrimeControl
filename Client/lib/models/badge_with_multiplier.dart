import 'package:flutter/material.dart';

class BadgeWithMultiplier {
  final int badgeId;
  final String name;
  final String displayName;
  final String description;
  final String? icon;
  final String? color;
  final String type;
  final String tier;
  final int count;
  final DateTime firstEarned;
  final DateTime lastEarned;

  BadgeWithMultiplier({
    required this.badgeId,
    required this.name,
    required this.displayName,
    required this.description,
    this.icon,
    this.color,
    required this.type,
    required this.tier,
    required this.count,
    required this.firstEarned,
    required this.lastEarned,
  });

  factory BadgeWithMultiplier.fromJson(Map<String, dynamic> json) {
    return BadgeWithMultiplier(
      badgeId: json['badgeId'],
      name: json['name'],
      displayName: json['displayName'],
      description: json['description'],
      icon: json['icon'],
      color: json['color'],
      type: json['type'],
      tier: json['tier'],
      count: json['count'],
      firstEarned: DateTime.parse(json['firstEarned']),
      lastEarned: DateTime.parse(json['lastEarned']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'badgeId': badgeId,
      'name': name,
      'displayName': displayName,
      'description': description,
      'icon': icon,
      'color': color,
      'type': type,
      'tier': tier,
      'count': count,
      'firstEarned': firstEarned.toIso8601String(),
      'lastEarned': lastEarned.toIso8601String(),
    };
  }

  /// Get the display text for the multiplier (e.g., "x2", "x3")
  /// Returns empty string if count is 1
  String get multiplierText {
    return count > 1 ? 'x$count' : '';
  }

  /// Check if this badge has been earned multiple times
  bool get hasMultiplier {
    return count > 1;
  }

  /// Get the color as a Flutter Color object
  Color get badgeColor {
    if (color != null && color!.isNotEmpty) {
      try {
        // Remove # if present and convert to int
        String colorString = color!.replaceAll('#', '');
        return Color(int.parse('FF$colorString', radix: 16));
      } catch (e) {
        return _getDefaultColorByTier();
      }
    }
    return _getDefaultColorByTier();
  }

  /// Get default color based on tier
  Color _getDefaultColorByTier() {
    switch (tier.toLowerCase()) {
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

  /// Get icon based on badge type or use default
  IconData get badgeIcon {
    switch (type.toLowerCase()) {
      case 'case_solver':
        return Icons.check_circle;
      case 'expert':
        return Icons.star;
      case 'rating':
        return Icons.thumb_up;
      case 'specialization':
        return Icons.school;
      case 'milestone':
        return Icons.flag;
      case 'achievement':
        return Icons.emoji_events;
      case 'innovation':
        return Icons.lightbulb;
      case 'academic':
        return Icons.menu_book;
      case 'community':
        return Icons.people;
      case 'education':
        return Icons.school;
      default:
        return Icons.military_tech;
    }
  }

  @override
  String toString() {
    return 'BadgeWithMultiplier{name: $name, count: $count, tier: $tier}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BadgeWithMultiplier &&
          runtimeType == other.runtimeType &&
          badgeId == other.badgeId;

  @override
  int get hashCode => badgeId.hashCode;
}
