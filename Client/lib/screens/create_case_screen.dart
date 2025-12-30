import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_constants.dart';
import '../widgets/enhanced_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/multi_select_chips.dart';
import '../widgets/simple_multi_image_picker.dart';
import '../services/auth_service.dart';

class CreateCaseScreen extends StatefulWidget {
  final VoidCallback? onCaseCreated;
  const CreateCaseScreen({super.key, this.onCaseCreated});

  @override
  State<CreateCaseScreen> createState() => _CreateCaseScreenState();
}

class _CreateCaseScreenState extends State<CreateCaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  List<XFile> _selectedImages = [];
  XFile? _mediaFile;
  bool _isLoading = false;
  List<String> _selectedTags = [];
  
  // Available case categories
  final List<String> _availableCategories = [
    'Theft',
    'Fraud',
    'Cybercrime',
    'Assault',
    'Robbery',
    'Murder',
    'Drug Offense',
    'Burglary',
    'Vandalism',
    'Kidnapping',
    'Domestic Violence',
    'White Collar Crime',
    'Identity Theft',
    'Money Laundering',
    'Human Trafficking',
    'Terrorism',
    'Corruption',
    'Tax Evasion',
    'Counterfeiting',
    'Intellectual Property',
    'Environmental Crime',
    'Organized Crime',
    'Sexual Offense',
    'Child Abuse',
    'Elder Abuse',
    'Missing Person',
    'Cold Case',
    'Digital Forensics',
    'Financial Investigation',
    'Forensic Accounting',
  ];

  void _onImagesSelected(List<XFile> images) {
    print('=== _onImagesSelected called with ${images.length} images ===');
    setState(() {
      _selectedImages = images;
    });
    print('=== State updated, _selectedImages now has ${_selectedImages.length} images ===');
  }

  Future<void> _pickMedia() async {
    final picked = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _mediaFile = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Validate that at least one tag is selected
    if (_selectedTags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one category for the case'),
          backgroundColor: Color(AppConstants.errorColor),
        ),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      await AuthService().postCaseWithMedia(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        imageFiles: _selectedImages, // Send all selected images
        mediaFile: _mediaFile,
        tags: _selectedTags,
      );
      widget.onCaseCreated?.call();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Case created successfully!'),
          backgroundColor: Color(AppConstants.successColor),
        ),
      );
      
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create case: $e'),
          backgroundColor: const Color(AppConstants.errorColor),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Case'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Form(
          key: _formKey,
          child: ListView(
            key: const ValueKey('create_case_form'), // Add key to maintain scroll position
            children: [
              // Case Title
              EnhancedTextField(
                controller: _titleController,
                labelText: 'Case Title',
                hintText: 'Enter a descriptive title for the case',
                prefixIcon: Icons.title_rounded,
                validator: (v) => v == null || v.isEmpty ? 'Enter case title' : null,
              ),
              const SizedBox(height: AppConstants.spacingMd),
              
              // Case Description
              EnhancedTextField(
                controller: _descController,
                labelText: 'Case Description',
                hintText: 'Provide detailed information about the case',
                prefixIcon: Icons.description_rounded,
                maxLines: 4,
                validator: (v) => v == null || v.isEmpty ? 'Enter case description' : null,
              ),
              const SizedBox(height: AppConstants.spacingLg),
              
              // Case Categories/Tags Selection
              MultiSelectChips(
                title: 'Case Categories',
                hint: 'Select relevant categories for this case (1-5 categories)',
                options: _availableCategories,
                selectedOptions: _selectedTags,
                maxSelections: 5,
                onChanged: (selected) {
                  setState(() {
                    _selectedTags = selected;
                  });
                },
              ),
              const SizedBox(height: AppConstants.spacingLg),
              
              // Media Selection Section
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingMd),
                decoration: BoxDecoration(
                  color: Color(AppConstants.surfaceColor),
                  borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                  border: Border.all(
                    color: Color(AppConstants.textLightColor).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Evidence & Media',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingSm),
                    Text(
                      'Upload images or videos related to the case (optional)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Color(AppConstants.textLightColor),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMd),
                    
                    // Multi-Image Selection
                    SimpleMultiImagePicker(
                      key: const ValueKey('multi_image_picker'), // Add key for state preservation
                      selectedImages: _selectedImages, // Pass the selected images
                      onImagesSelected: _onImagesSelected,
                      maxImages: 5,
                    ),
                    const SizedBox(height: AppConstants.spacingMd),
                    
                    // Video Selection  
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Pick Video',
                            onPressed: _pickMedia,
                            icon: Icons.videocam_rounded,
                            type: ButtonType.outline,
                            size: ButtonSize.medium,
                          ),
                        ),
                        if (_mediaFile != null) ...[
                          const SizedBox(width: AppConstants.spacingSm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.spacingSm,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Color(AppConstants.successColor).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 16,
                                  color: Color(AppConstants.successColor),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Video selected',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Color(AppConstants.successColor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spacingXl),
              
              // Submit Button
              CustomButton(
                text: 'Create Case',
                onPressed: _isLoading ? null : _submit,
                isLoading: _isLoading,
                icon: Icons.add_circle_rounded,
                type: ButtonType.primary,
                size: ButtonSize.large,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
