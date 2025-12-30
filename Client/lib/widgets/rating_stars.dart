import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double size;
  final bool showText;
  final int? totalRatings;

  const RatingStars({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 16,
    this.showText = true,
    this.totalRatings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(maxRating, (index) {
            if (index < rating.floor()) {
              // Full star
              return Icon(
                Icons.star,
                color: Color(AppConstants.warningColor),
                size: size,
              );
            } else if (index < rating) {
              // Half star
              return Icon(
                Icons.star_half,
                color: Color(AppConstants.warningColor),
                size: size,
              );
            } else {
              // Empty star
              return Icon(
                Icons.star_border,
                color: Color(AppConstants.textLightColor),
                size: size,
              );
            }
          }),
        ),
        if (showText) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (totalRatings != null) ...[
            const SizedBox(width: 2),
            Text(
              '($totalRatings)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Color(AppConstants.textLightColor),
              ),
            ),
          ],
        ],
      ],
    );
  }
}

class InteractiveRating extends StatefulWidget {
  final double initialRating;
  final int maxRating;
  final double size;
  final Function(double) onRatingChanged;

  const InteractiveRating({
    super.key,
    this.initialRating = 0,
    this.maxRating = 5,
    this.size = 32,
    required this.onRatingChanged,
  });

  @override
  State<InteractiveRating> createState() => _InteractiveRatingState();
}

class _InteractiveRatingState extends State<InteractiveRating> {
  late double _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.maxRating, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _currentRating = (index + 1).toDouble();
            });
            widget.onRatingChanged(_currentRating);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              index < _currentRating ? Icons.star : Icons.star_border,
              color: index < _currentRating
                  ? Color(AppConstants.warningColor)
                  : Color(AppConstants.textLightColor),
              size: widget.size,
            ),
          ),
        );
      }),
    );
  }
}
