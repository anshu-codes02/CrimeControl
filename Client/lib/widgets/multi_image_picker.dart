import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:io';
import '../constants/app_constants.dart';
import '../services/image_upload_service.dart';
import 'custom_gallery_picker.dart';

class MultiImagePicker extends StatefulWidget {
  final Function(List<AssetEntity>) onImagesSelected;
  final int maxImages;
  
  const MultiImagePicker({
    Key? key,
    required this.onImagesSelected,
    this.maxImages = 10,
  }) : super(key: key);

  @override
  State<MultiImagePicker> createState() => _MultiImagePickerState();
}

class _MultiImagePickerState extends State<MultiImagePicker> {
  final ImageUploadService _uploadService = ImageUploadService();
  List<AssetEntity> _selectedImages = [];
  bool _isUploading = false;
  bool _showGallery = false;

  void _openGallery() {
    print('=== OPENING GALLERY ===');
    setState(() {
      _showGallery = true;
    });
    print('Gallery state set to: $_showGallery');
  }

  void _closeGallery() {
    setState(() {
      _showGallery = false;
    });
  }

  void _onGalleryImagesSelected(List<AssetEntity> images) {
    setState(() {
      _selectedImages = images;
    });
    widget.onImagesSelected(_selectedImages);
  }

  Future<void> _uploadImages() async {
    if (_selectedImages.isEmpty) return;
    
    setState(() {
      _isUploading = true;
    });

    try {
      // Convert AssetEntity to File
      List<File> files = [];
      for (AssetEntity asset in _selectedImages) {
        final file = await asset.file;
        if (file != null) {
          files.add(file);
        }
      }

      if (files.isNotEmpty) {
        await _uploadService.uploadAssetFiles(files);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Images uploaded successfully!'),
            backgroundColor: Color(AppConstants.successColor),
          ),
        );
        _clearImages();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: Color(AppConstants.errorColor),
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
    widget.onImagesSelected(_selectedImages);
  }

  void _clearImages() {
    setState(() {
      _selectedImages.clear();
    });
    widget.onImagesSelected(_selectedImages);
  }

  @override
  Widget build(BuildContext context) {
    if (_showGallery) {
      return Column(
        children: [
          // Header with back button
          Container(
            padding: EdgeInsets.all(AppConstants.spacingMd),
            color: Color(AppConstants.surfaceColor),
            child: Row(
              children: [
                IconButton(
                  onPressed: _closeGallery,
                  icon: Icon(
                    Icons.arrow_back,
                    color: Color(AppConstants.textColor),
                  ),
                ),
                Text(
                  'Select Images',
                  style: TextStyle(
                    color: Color(AppConstants.textColor),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                if (_selectedImages.isNotEmpty)
                  TextButton(
                    onPressed: _closeGallery,
                    child: Text(
                      'Done',
                      style: TextStyle(
                        color: Color(AppConstants.primaryColor),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Gallery picker
          Expanded(
            child: CustomGalleryPicker(
              onImagesSelected: _onGalleryImagesSelected,
              maxImages: widget.maxImages,
            ),
          ),
        ],
      );
    }

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
            onTap: _openGallery,
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
                  'Tap to open gallery and select multiple',
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
                        child: AssetEntityImage(
                          _selectedImages[index],
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
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _uploadImages,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(AppConstants.primaryColor),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: AppConstants.spacingMd),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                    ),
                  ),
                  child: _isUploading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: AppConstants.spacingSm),
                            Text('Uploading...'),
                          ],
                        )
                      : Text('Upload Images'),
                ),
              ),
              SizedBox(width: AppConstants.spacingSm),
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
                child: Text('Clear'),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
