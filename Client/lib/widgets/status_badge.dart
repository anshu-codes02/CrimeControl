import 'package:flutter/material.dart';

/// Enhanced status badge with better styling and color coding
/// Provides consistent status display across the app
class StatusBadge extends StatelessWidget {
  final String status;
  final StatusType? type;
  final double? fontSize;
  final EdgeInsets? padding;

  const StatusBadge({
    Key? key,
    required this.status,
    this.type,
    this.fontSize,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusType = type ?? _getStatusType(status);
    final colors = _getStatusColors(statusType, theme);

    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.borderColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: colors.indicatorColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: colors.textColor,
              fontSize: fontSize ?? 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  StatusType _getStatusType(String status) {
    switch (status.toLowerCase()) {
      case 'open':
      case 'active':
      case 'in_progress':
      case 'investigating':
        return StatusType.active;
      case 'closed':
      case 'resolved':
      case 'completed':
        return StatusType.success;
      case 'pending':
      case 'under_review':
      case 'waiting':
        return StatusType.warning;
      case 'urgent':
      case 'critical':
      case 'high_priority':
        return StatusType.critical;
      case 'suspended':
      case 'cancelled':
      case 'rejected':
        return StatusType.error;
      default:
        return StatusType.neutral;
    }
  }

  StatusColors _getStatusColors(StatusType type, ThemeData theme) {
    switch (type) {
      case StatusType.active:
        return StatusColors(
          backgroundColor: Colors.blue.shade50.withOpacity(0.3),
          borderColor: Colors.blue.shade200.withOpacity(0.5),
          textColor: Colors.blue.shade300,
          indicatorColor: Colors.blue.shade400,
        );
      case StatusType.success:
        return StatusColors(
          backgroundColor: Colors.green.shade50.withOpacity(0.3),
          borderColor: Colors.green.shade200.withOpacity(0.5),
          textColor: Colors.green.shade300,
          indicatorColor: Colors.green.shade400,
        );
      case StatusType.warning:
        return StatusColors(
          backgroundColor: Colors.orange.shade50.withOpacity(0.3),
          borderColor: Colors.orange.shade200.withOpacity(0.5),
          textColor: Colors.orange.shade300,
          indicatorColor: Colors.orange.shade400,
        );
      case StatusType.critical:
        return StatusColors(
          backgroundColor: Colors.red.shade50.withOpacity(0.3),
          borderColor: Colors.red.shade200.withOpacity(0.5),
          textColor: Colors.red.shade300,
          indicatorColor: Colors.red.shade400,
        );
      case StatusType.error:
        return StatusColors(
          backgroundColor: Colors.red.shade900.withOpacity(0.2),
          borderColor: Colors.red.shade800.withOpacity(0.5),
          textColor: Colors.red.shade200,
          indicatorColor: Colors.red.shade400,
        );
      case StatusType.neutral:
        return StatusColors(
          backgroundColor: theme.colorScheme.surface.withOpacity(0.5),
          borderColor: theme.colorScheme.outline.withOpacity(0.3),
          textColor: theme.colorScheme.onSurface.withOpacity(0.8),
          indicatorColor: theme.colorScheme.onSurface.withOpacity(0.6),
        );
    }
  }
}

class StatusColors {
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final Color indicatorColor;

  StatusColors({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.indicatorColor,
  });
}

enum StatusType {
  active,
  success,
  warning,
  critical,
  error,
  neutral,
}
