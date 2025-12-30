import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import '../widgets/multi_image_picker.dart';
import '../constants/app_constants.dart';

class ImageUploadScreen extends StatefulWidget {
  const ImageUploadScreen({Key? key}) : super(key: key);

  @override
  State<ImageUploadScreen> createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  List<AssetEntity> selectedImages = [];

  void _onImagesSelected(List<AssetEntity> images) {
    setState(() {
      selectedImages = images;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppConstants.backgroundColor),
      appBar: AppBar(
        title: Text(
          'Upload Images',
          style: TextStyle(
            color: Color(AppConstants.textColor),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(AppConstants.surfaceColor),
        elevation: 0,
        iconTheme: IconThemeData(
          color: Color(AppConstants.textColor),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Evidence Images',
              style: TextStyle(
                color: Color(AppConstants.textColor),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppConstants.spacingSm),
            Text(
              'Choose multiple images to upload as evidence. Long press in the gallery to select multiple images at once.',
              style: TextStyle(
                color: Color(AppConstants.textLightColor),
                fontSize: 16,
              ),
            ),
            SizedBox(height: AppConstants.spacingLg),
            Expanded(
              child: SingleChildScrollView(
                child: MultiImagePicker(
                  onImagesSelected: _onImagesSelected,
                  maxImages: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
