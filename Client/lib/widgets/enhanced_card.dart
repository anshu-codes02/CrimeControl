import 'package:flutter/material.dart';

/// Enhanced card component with hover effects and better styling
/// Provides consistent card appearance across the app
class EnhancedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final double? elevation;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final bool enableHoverEffect;

  const EnhancedCard({
    Key? key,
    required this.child,
    this.onTap,
    this.padding,
    this.elevation,
    this.backgroundColor,
    this.borderRadius,
    this.enableHoverEffect = true,
  }) : super(key: key);

  @override
  State<EnhancedCard> createState() => _EnhancedCardState();
}

class _EnhancedCardState extends State<EnhancedCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _elevationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _elevationAnimation = Tween<double>(
      begin: widget.elevation ?? 2,
      end: (widget.elevation ?? 2) + 4,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovered) {
    if (!widget.enableHoverEffect) return;
    
    setState(() => _isHovered = isHovered);
    if (isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Material(
              elevation: _elevationAnimation.value,
              borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
              color: widget.backgroundColor ?? theme.cardColor,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
                    border: _isHovered ? Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      width: 1,
                    ) : null,
                  ),
                  padding: widget.padding ?? const EdgeInsets.all(16),
                  child: widget.child,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
