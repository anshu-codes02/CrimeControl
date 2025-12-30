import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../widgets/rating_stars.dart';
import '../widgets/custom_button.dart';
import '../widgets/enhanced_text_field.dart';

class RatingDialog extends StatefulWidget {
  final String userName;
  final String userRole;
  final String caseTitle;
  final Function(double rating, String comment) onSubmit;

  const RatingDialog({  
    super.key,
    required this.userName,
    required this.userRole,
    required this.caseTitle,
    required this.onSubmit,
  });

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  double _rating = 0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
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
        decoration: BoxDecoration(
          color: Color(AppConstants.surfaceColor),
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppConstants.spacingSm),
                  decoration: BoxDecoration(
                    color: Color(AppConstants.primaryColor).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  ),
                  child: Icon(
                    Icons.star_rounded,
                    color: Color(AppConstants.primaryColor),
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rate Collaboration',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'How was working with ${widget.userName}?',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Color(AppConstants.textLightColor),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingLg),
            
            // Case info
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              decoration: BoxDecoration(
                color: Color(AppConstants.backgroundColor),
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                border: Border.all(
                  color: Color(AppConstants.textLightColor).withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Case: ${widget.caseTitle}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.userRole}: ${widget.userName}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Color(AppConstants.textLightColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacingLg),
            
            // Rating section
            Text(
              'Your Rating',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Center(
              child: InteractiveRating(
                initialRating: _rating,
                size: 40,
                onRatingChanged: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Center(
              child: Text(
                _getRatingText(_rating),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Color(AppConstants.textLightColor),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingLg),
            
            // Comment section
            Text(
              'Comment (Optional)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            EnhancedTextField(
              controller: _commentController,
              labelText: 'Share your experience',
              hintText: 'What did you think about this collaboration?',
              maxLines: 3,
              prefixIcon: Icons.comment_rounded,
            ),
            const SizedBox(height: AppConstants.spacingXl),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Cancel',
                    onPressed: () => Navigator.of(context).pop(),
                    type: ButtonType.outline,
                    size: ButtonSize.large,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingMd),
                Expanded(
                  child: CustomButton(
                    text: 'Submit Rating',
                    onPressed: _rating > 0 && !_isSubmitting
                        ? () async {
                            setState(() => _isSubmitting = true);
                            await widget.onSubmit(_rating, _commentController.text.trim());
                            if (mounted) Navigator.of(context).pop();
                          }
                        : null,
                    isLoading: _isSubmitting,
                    icon: Icons.send_rounded,
                    type: ButtonType.primary,
                    size: ButtonSize.large,
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

  String _getRatingText(double rating) {
    switch (rating.toInt()) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return 'Select a rating';
    }
  }
}
