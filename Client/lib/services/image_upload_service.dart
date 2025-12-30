import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import '../constants/app_constants.dart';

class ImageUploadService {
  Future<void> uploadImages(List<XFile> images) async {
    var uri = Uri.parse('${AppConstants.baseUrl}/upload');
    var request = http.MultipartRequest('POST', uri);

    for (var image in images) {
      request.files.add(await http.MultipartFile.fromPath('files', image.path));
    }

    var response = await request.send();
    if (response.statusCode == 200) {
      print('Upload successful');
    } else {
      print('Upload failed');
      throw Exception('Upload failed with status: ${response.statusCode}');
    }
  }

  Future<void> uploadAssetFiles(List<File> files) async {
    var uri = Uri.parse('${AppConstants.baseUrl}/upload');
    var request = http.MultipartRequest('POST', uri);

    for (var file in files) {
      request.files.add(await http.MultipartFile.fromPath('files', file.path));
    }

    var response = await request.send();
    if (response.statusCode == 200) {
      print('Upload successful');
    } else {
      print('Upload failed');
      throw Exception('Upload failed with status: ${response.statusCode}');
    }
  }
}
