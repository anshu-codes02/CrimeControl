import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../constants/app_constants.dart';

class SimpleMultiImagePicker extends StatefulWidget {
  final Function(List<XFile>) onImagesSelected;
  final int maxImages;
  final List<XFile> selectedImages; // Accept selected images from parent
  
  const SimpleMultiImagePicker({
    Key? key,
    required this.onImagesSelected,
    this.maxImages = 10,
    this.selectedImages = const [], // Default to empty list
  }) : super(key: key);

  @override
  State<SimpleMultiImagePicker> createState() => _SimpleMultiImagePickerState();
}

class _SimpleMultiImagePickerState extends State<SimpleMultiImagePicker> {
  final ImagePicker _picker = ImagePicker();

  // Use the images from parent widget
  List<XFile> get _selectedImages => widget.selectedImages;

  Future<void> _pickImages() async {
    print('=== PICKING IMAGES ===');
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      print('Picked ${images.length} images');
      
      if (images.isNotEmpty) {
        List<XFile> newImages = [..._selectedImages]; // Start with existing images
        
        // Add new images but respect max limit
        for (XFile image in images) {
          if (newImages.length < widget.maxImages) {
            newImages.add(image);
          } else {
            break;
          }
        }
        
        if (newImages.length > widget.maxImages) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Maximum ${widget.maxImages} images allowed'),
              backgroundColor: Color(AppConstants.warningColor),
            ),
          );
          newImages = newImages.take(widget.maxImages).toList();
        }
        
        widget.onImagesSelected(newImages);
      }
    } catch (e) {
      print('Error picking images: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting images: $e'),
          backgroundColor: Color(AppConstants.errorColor),
        ),
      );
    }
  }

  void _removeImage(int index) {
    List<XFile> newImages = [..._selectedImages];
    newImages.removeAt(index);
    widget.onImagesSelected(newImages);
  }

  void _clearImages() {
    widget.onImagesSelected([]);
  }

  @override
  Widget build(BuildContext context) {
    print('=== SimpleMultiImagePicker build: ${_selectedImages.length} images ===');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image selection button
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            color: Color(AppConstants.surfaceColor),
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            border: Border.all(
              color: Color(AppConstants.primaryColor).withOpacity(0.3),
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
          child: InkWell(
            onTap: _pickImages,
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 48,
                  color: Color(AppConstants.primaryColor),
                ),
                SizedBox(height: AppConstants.spacingSm),
                Text(
                  'Select Multiple Images',
                  style: TextStyle(
                    color: Color(AppConstants.textColor),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: AppConstants.spacingXs),
                Text(
                  'Tap to select multiple images',
                  style: TextStyle(
                    color: Color(AppConstants.textLightColor),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Selected images grid
        if (_selectedImages.isNotEmpty) ...[
          SizedBox(height: AppConstants.spacingMd),
          Text(
            '${_selectedImages.length} image(s) selected',
            style: TextStyle(
              color: Color(AppConstants.textColor),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: AppConstants.spacingSm),
          Container(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(right: AppConstants.spacingSm),
                  width: 100,
                  height: 100,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                        child: Image.file(
                          File(_selectedImages[index].path),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Color(AppConstants.errorColor),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Action buttons
          SizedBox(height: AppConstants.spacingMd),
          ElevatedButton(
            onPressed: _clearImages,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(AppConstants.surfaceColor),
              foregroundColor: Color(AppConstants.textColor),
              padding: EdgeInsets.symmetric(
                vertical: AppConstants.spacingMd,
                horizontal: AppConstants.spacingLg,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusSm),
              ),
            ),
            child: Text('Clear All'),
          ),
        ],
      ],
    );
  }
}
