import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';
import '../constants/app_constants.dart';

class CustomGalleryPicker extends StatefulWidget {
  final Function(List<AssetEntity>) onImagesSelected;
  final int maxImages;
  
  const CustomGalleryPicker({
    Key? key,
    required this.onImagesSelected,
    this.maxImages = 10,
  }) : super(key: key);

  @override
  State<CustomGalleryPicker> createState() => _CustomGalleryPickerState();
}

class _CustomGalleryPickerState extends State<CustomGalleryPicker> {
  List<AssetEntity> _assets = [];
  List<AssetEntity> _selectedAssets = [];
  bool _isLoading = true;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _requestPermissionAndLoadAssets();
  }

  Future<void> _requestPermissionAndLoadAssets() async {
    print('=== REQUESTING PHOTO PERMISSION ===');
    final PermissionState permission = await PhotoManager.requestPermissionExtend();
    print('Permission result: ${permission.toString()}');
    print('Is auth: ${permission.isAuth}');
    
    if (permission.isAuth) {
      print('Permission granted, loading assets...');
      setState(() {
        _hasPermission = true;
      });
      await _loadAssets();
    } else {
      print('Permission denied');
      setState(() {
        _hasPermission = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAssets() async {
    print('=== LOADING ASSETS ===');
    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
    );
    print('Found ${paths.length} paths');

    if (paths.isNotEmpty) {
      print('Loading assets from first path: ${paths.first.name}');
      final List<AssetEntity> assets = await paths.first.getAssetListPaged(
        page: 0,
        size: 1000,
      );
      print('Loaded ${assets.length} assets');

      setState(() {
        _assets = assets;
        _isLoading = false;
      });
    } else {
      print('No asset paths found');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleSelection(AssetEntity asset) {
    setState(() {
      if (_selectedAssets.contains(asset)) {
        _selectedAssets.remove(asset);
      } else {
        if (_selectedAssets.length < widget.maxImages) {
          _selectedAssets.add(asset);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Maximum ${widget.maxImages} images allowed'),
              backgroundColor: Color(AppConstants.warningColor),
            ),
          );
        }
      }
    });
    widget.onImagesSelected(_selectedAssets);
  }

  void _selectAll() {
    setState(() {
      _selectedAssets.clear();
      _selectedAssets.addAll(_assets.take(widget.maxImages));
    });
    widget.onImagesSelected(_selectedAssets);
  }

  void _clearSelection() {
    setState(() {
      _selectedAssets.clear();
    });
    widget.onImagesSelected(_selectedAssets);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(AppConstants.primaryColor)),
        ),
      );
    }

    if (!_hasPermission) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: Color(AppConstants.textLightColor),
            ),
            SizedBox(height: AppConstants.spacingMd),
            Text(
              'Gallery permission required',
              style: TextStyle(
                color: Color(AppConstants.textColor),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: AppConstants.spacingSm),
            Text(
              'Please grant permission to access your photos',
              style: TextStyle(
                color: Color(AppConstants.textLightColor),
                fontSize: 14,
              ),
            ),
            SizedBox(height: AppConstants.spacingLg),
            ElevatedButton(
              onPressed: () {
                openAppSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(AppConstants.primaryColor),
                foregroundColor: Colors.white,
              ),
              child: Text('Open Settings'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header with selection info and actions
        Container(
          padding: EdgeInsets.all(AppConstants.spacingMd),
          color: Color(AppConstants.surfaceColor),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${_selectedAssets.length} of ${widget.maxImages} selected',
                  style: TextStyle(
                    color: Color(AppConstants.textColor),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (_selectedAssets.isNotEmpty)
                TextButton(
                  onPressed: _clearSelection,
                  child: Text(
                    'Clear',
                    style: TextStyle(
                      color: Color(AppConstants.errorColor),
                    ),
                  ),
                ),
              TextButton(
                onPressed: _selectAll,
                child: Text(
                  'Select All',
                  style: TextStyle(
                    color: Color(AppConstants.primaryColor),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Gallery grid
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(AppConstants.spacingSm),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: AppConstants.spacingSm,
              mainAxisSpacing: AppConstants.spacingSm,
            ),
            itemCount: _assets.length,
            itemBuilder: (context, index) {
              final asset = _assets[index];
              final isSelected = _selectedAssets.contains(asset);
              
              return GestureDetector(
                onTap: () => _toggleSelection(asset),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                    border: isSelected
                        ? Border.all(
                            color: Color(AppConstants.primaryColor),
                            width: 3,
                          )
                        : null,
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                        child: AssetEntityImage(
                          asset,
                          isOriginal: false,
                          thumbnailSize: ThumbnailSize.square(200),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      
                      // Selection overlay
                      if (isSelected)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                            color: Color(AppConstants.primaryColor).withOpacity(0.3),
                          ),
                        ),
                      
                      // Selection number
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Color(AppConstants.primaryColor)
                                : Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: isSelected
                                ? Text(
                                    '${_selectedAssets.indexOf(asset) + 1}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class AssetEntityImage extends StatelessWidget {
  final AssetEntity asset;
  final bool isOriginal;
  final ThumbnailSize? thumbnailSize;
  final BoxFit? fit;
  final double? width;
  final double? height;

  const AssetEntityImage(
    this.asset, {
    Key? key,
    this.isOriginal = true,
    this.thumbnailSize,
    this.fit,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailDataWithSize(
        thumbnailSize ?? ThumbnailSize.square(200),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            fit: fit ?? BoxFit.cover,
            width: width,
            height: height,
          );
        }
        return Container(
          width: width,
          height: height,
          color: Color(AppConstants.surfaceColor),
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(AppConstants.primaryColor)),
            ),
          ),
        );
      },
    );
  }
}
