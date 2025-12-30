import 'package:flutter/material.dart';

/// Enhanced custom button with hover effects and better styling
/// Provides consistent button appearance across the app
class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final ButtonType type;
  final ButtonSize size;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
  }) : super(key: key);

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
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

  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: _isHovered ? [
                BoxShadow(
                  color: _getButtonColor(theme).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ] : [],
            ),
            child: FilledButton(
              onPressed: widget.isLoading ? null : widget.onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: _getButtonColor(theme),
                foregroundColor: _getTextColor(theme),
                padding: _getPadding(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: _isHovered ? 4 : 2,
              ),
              child: widget.isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _getTextColor(theme),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, size: _getIconSize()),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.text,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: _getFontSize(),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getButtonColor(ThemeData theme) {
    switch (widget.type) {
      case ButtonType.primary:
        return theme.colorScheme.primary;
      case ButtonType.secondary:
        return theme.colorScheme.secondary;
      case ButtonType.danger:
        return Colors.red.shade600;
      case ButtonType.success:
        return Colors.green.shade600;
      case ButtonType.outline:
        return Colors.transparent;
    }
  }

  Color _getTextColor(ThemeData theme) {
    switch (widget.type) {
      case ButtonType.outline:
        return theme.colorScheme.primary;
      default:
        return Colors.white;
    }
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(vertical: 12, horizontal: 16);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(vertical: 16, horizontal: 24);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(vertical: 20, horizontal: 32);
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 14;
      case ButtonSize.medium:
        return 16;
      case ButtonSize.large:
        return 18;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }
}

enum ButtonType { primary, secondary, danger, success, outline }
enum ButtonSize { small, medium, large }
