import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Display widget for case tags with category-based styling
/// Shows case tags with appropriate colors and styling
class CaseTagsDisplay extends StatelessWidget {
  final List<String> tags;
  final int? maxVisible;
  final bool showCount;
  final double? fontSize;

  const CaseTagsDisplay({
    Key? key,
    required this.tags,
    this.maxVisible = 3,
    this.showCount = true,
    this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (tags.isEmpty) {
      return const SizedBox.shrink();
    }

    final visibleTags = maxVisible != null && tags.length > maxVisible!
        ? tags.take(maxVisible!).toList()
        : tags;
    
    final remainingCount = tags.length - visibleTags.length;

    return Wrap(
      spacing: AppConstants.spacingSm,
      runSpacing: AppConstants.spacingSm,
      children: [
        ...visibleTags.map((tag) => _buildTagChip(tag, theme)),
        if (remainingCount > 0 && showCount)
          _buildMoreChip(remainingCount, theme),
      ],
    );
  }

  Widget _buildTagChip(String tag, ThemeData theme) {
    final colors = _getTagColors(tag);
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        border: Border.all(
          color: colors.borderColor,
          width: 1,
        ),
      ),
      child: Text(
        tag,
        style: TextStyle(
          color: colors.textColor,
          fontSize: fontSize ?? 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildMoreChip(int count, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Color(AppConstants.textLightColor).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        border: Border.all(
          color: Color(AppConstants.textLightColor).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        '+$count more',
        style: TextStyle(
          color: Color(AppConstants.textLightColor),
          fontSize: fontSize ?? 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  TagColors _getTagColors(String tag) {
    // Categorize tags by crime type for color coding
    final tagLower = tag.toLowerCase();
    
    if (_isCyberCrime(tagLower)) {
      return TagColors(
        backgroundColor: Colors.purple.shade50.withOpacity(0.3),
        borderColor: Colors.purple.shade200.withOpacity(0.5),
        textColor: Colors.purple.shade300,
      );
    } else if (_isViolentCrime(tagLower)) {
      return TagColors(
        backgroundColor: Colors.red.shade50.withOpacity(0.3),
        borderColor: Colors.red.shade200.withOpacity(0.5),
        textColor: Colors.red.shade300,
      );
    } else if (_isFinancialCrime(tagLower)) {
      return TagColors(
        backgroundColor: Colors.green.shade50.withOpacity(0.3),
        borderColor: Colors.green.shade200.withOpacity(0.5),
        textColor: Colors.green.shade300,
      );
    } else if (_isPropertyCrime(tagLower)) {
      return TagColors(
        backgroundColor: Colors.orange.shade50.withOpacity(0.3),
        borderColor: Colors.orange.shade200.withOpacity(0.5),
        textColor: Colors.orange.shade300,
      );
    } else if (_isDrugCrime(tagLower)) {
      return TagColors(
        backgroundColor: Colors.brown.shade50.withOpacity(0.3),
        borderColor: Colors.brown.shade200.withOpacity(0.5),
        textColor: Colors.brown.shade300,
      );
    } else {
      // Default color for other tags
      return TagColors(
        backgroundColor: Color(AppConstants.primaryColor).withOpacity(0.1),
        borderColor: Color(AppConstants.primaryColor).withOpacity(0.3),
        textColor: Color(AppConstants.primaryColor),
      );
    }
  }

  bool _isCyberCrime(String tag) {
    return tag.contains('cyber') ||
        tag.contains('digital') ||
        tag.contains('hacking') ||
        tag.contains('data') ||
        tag.contains('internet') ||
        tag.contains('online') ||
        tag.contains('identity theft') ||
        tag.contains('phishing');
  }

  bool _isViolentCrime(String tag) {
    return tag.contains('murder') ||
        tag.contains('assault') ||
        tag.contains('robbery') ||
        tag.contains('kidnapping') ||
        tag.contains('domestic violence') ||
        tag.contains('sexual') ||
        tag.contains('abuse') ||
        tag.contains('terrorism');
  }

  bool _isFinancialCrime(String tag) {
    return tag.contains('fraud') ||
        tag.contains('money laundering') ||
        tag.contains('tax evasion') ||
        tag.contains('counterfeiting') ||
        tag.contains('white collar') ||
        tag.contains('financial') ||
        tag.contains('corruption') ||
        tag.contains('embezzlement');
  }

  bool _isPropertyCrime(String tag) {
    return tag.contains('theft') ||
        tag.contains('burglary') ||
        tag.contains('vandalism') ||
        tag.contains('arson') ||
        tag.contains('property');
  }

  bool _isDrugCrime(String tag) {
    return tag.contains('drug') ||
        tag.contains('narcotic') ||
        tag.contains('substance');
  }
}

class TagColors {
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  TagColors({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });
}
