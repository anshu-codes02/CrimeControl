import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Multi-select chip widget for tags and expertise areas
/// Provides an intuitive way to select multiple categories/tags
class MultiSelectChips extends StatefulWidget {
  final List<String> options;
  final List<String> selectedOptions;
  final Function(List<String>) onChanged;
  final String title;
  final String? hint;
  final int? maxSelections;
  final bool wrap;

  const MultiSelectChips({
    Key? key,
    required this.options,
    required this.selectedOptions,
    required this.onChanged,
    required this.title,
    this.hint,
    this.maxSelections,
    this.wrap = true,
  }) : super(key: key);

  @override
  State<MultiSelectChips> createState() => _MultiSelectChipsState();
}

class _MultiSelectChipsState extends State<MultiSelectChips> {
  late List<String> _selectedItems;

  @override
  void initState() {
    super.initState();
    _selectedItems = List.from(widget.selectedOptions);
  }

  void _toggleSelection(String item) {
    setState(() {
      if (_selectedItems.contains(item)) {
        _selectedItems.remove(item);
      } else {
        if (widget.maxSelections == null || 
            _selectedItems.length < widget.maxSelections!) {
          _selectedItems.add(item);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Maximum ${widget.maxSelections} selections allowed'),
              backgroundColor: Color(AppConstants.warningColor),
            ),
          );
          return;
        }
      }
      widget.onChanged(_selectedItems);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (widget.hint != null) ...[
          const SizedBox(height: AppConstants.spacingSm),
          Text(
            widget.hint!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Color(AppConstants.textLightColor),
            ),
          ),
        ],
        const SizedBox(height: AppConstants.spacingMd),
        if (widget.wrap)
          Wrap(
            spacing: AppConstants.spacingSm,
            runSpacing: AppConstants.spacingSm,
            children: widget.options.map((option) => _buildChip(option, theme)).toList(),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: widget.options
                  .map((option) => Padding(
                        padding: const EdgeInsets.only(right: AppConstants.spacingSm),
                        child: _buildChip(option, theme),
                      ))
                  .toList(),
            ),
          ),
        if (_selectedItems.isNotEmpty) ...[
          const SizedBox(height: AppConstants.spacingMd),
          Text(
            'Selected (${_selectedItems.length}${widget.maxSelections != null ? '/${widget.maxSelections}' : ''}):',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Color(AppConstants.textLightColor),
            ),
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Wrap(
            spacing: AppConstants.spacingSm,
            runSpacing: AppConstants.spacingSm,
            children: _selectedItems
                .map((item) => _buildSelectedChip(item, theme))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildChip(String option, ThemeData theme) {
    final isSelected = _selectedItems.contains(option);
    
    return GestureDetector(
      onTap: () => _toggleSelection(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMd,
          vertical: AppConstants.spacingSm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Color(AppConstants.primaryColor)
              : Color(AppConstants.surfaceColor),
          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
          border: Border.all(
            color: isSelected
                ? Color(AppConstants.primaryColor)
                : Color(AppConstants.textLightColor).withOpacity(0.3),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Color(AppConstants.primaryColor).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          option,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isSelected
                ? Colors.white
                : Color(AppConstants.textColor),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedChip(String item, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Color(AppConstants.primaryColor).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        border: Border.all(
          color: Color(AppConstants.primaryColor).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Color(AppConstants.primaryColor),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: AppConstants.spacingSm),
          GestureDetector(
            onTap: () => _toggleSelection(item),
            child: Icon(
              Icons.close_rounded,
              size: 16,
              color: Color(AppConstants.primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
