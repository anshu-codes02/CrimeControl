import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import '../constants/app_constants.dart';
import '../models/user.dart';
import '../models/case.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/comment.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.authUrl}/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );
      print("$username $password");
      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final data = json.decode(response.body);
          if (data is Map<String, dynamic>) {
            // If user info is at the root, wrap it in a 'user' field for consistency
            if (data.containsKey('user')) {
              await _saveToken(data['token']);
              await _saveUser(User.fromJson(data['user']));
              return data;
            } else {
              // Extract user info from root keys
              final userMap = <String, dynamic>{
                'id': data['id'],
                'username': data['username'],
                'email': data['email'],
                'role': data['role'],
                // add more fields if needed
              };
              await _saveToken(data['token']);
              await _saveUser(User.fromJson(userMap));
              return {'token': data['token'], 'user': userMap};
            }
          } else {
            throw Exception('Unexpected response format: ${response.body}');
          }
        } else {
          throw Exception('Empty response body');
        }
      } else {
        // Try to parse error message from backend, else return generic error
        String errorMsg = 'Login failed: Status ${response.statusCode}';
        if (response.body.isNotEmpty) {
          try {
            final err = json.decode(response.body);
            if (err is Map<String, dynamic> && err['error'] != null) {
              errorMsg = err['error'].toString();
            } else {
              errorMsg = response.body;
            }
          } catch (_) {
            errorMsg = response.body;
          }
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('Login exception: ${e.toString()}');
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<User> register(Map<String, dynamic> userJson) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.authUrl}/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userJson),
      );

      if (response.statusCode == 200) {
        return User.fromJson(json.decode(response.body));
      } else {
        throw Exception('Registration failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        await http.post(
          Uri.parse('${AppConstants.authUrl}/logout'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
      }
    } catch (e) {
      // Ignore logout errors
    } finally {
      await _clearAuthData();
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      // First try to get user from local storage
      final storedUser = await getUserFromStorage();
      if (storedUser != null) {
        print('Found stored user: ${storedUser.username}');
        return storedUser;
      }

      // If no stored user, check if we have a token
      final token = await getToken();
      if (token == null) {
        print('No token found, user not logged in');
        return null;
      }

      // Try to get user from server with timeout
      final response = await http
          .get(
            Uri.parse('${AppConstants.authUrl}/me'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final user = User.fromJson(json.decode(response.body));
        await _saveUser(user);
        print('Retrieved user from server: ${user.username}');
        return user;
      } else {
        print('Failed to get user from server: ${response.statusCode}');
        // If server call fails, clear the token
        await _clearAuthData();
        return null;
      }
    } catch (e) {
      print('Error getting current user: $e');
      // If any error occurs, clear auth data and return null
      await _clearAuthData();
      return null;
    }
  }

  Future<List<Case>> fetchCases() async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/cases'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Case.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch cases: ${response.body}');
    }
  }

  Future<void> postCase(Map<String, dynamic> caseData) async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/cases'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(caseData),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to post case: ${response.body}');
    }
  }

  Future<List<Comment>> fetchCaseComments(int caseId) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/cases/$caseId/comments'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print("see the comments" + data.toString());
      return data.map((json) => Comment.fromJson(json)).toList();
    } else {
      print("see the comments" + "error");

      throw Exception('Failed to fetch comments: ${response.body}');
    }
  }

  Future<void> postCaseComment(int caseId, String content) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/cases/$caseId/comments'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'content': content}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to post comment: ${response.body}');
    }
  }

  Future<User?> getUserById(int userId) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('${AppConstants.usersUrl}/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      return null;
    }
  }

  Future<User?> getUserByUsername(String username) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('${AppConstants.usersUrl}/username/$username'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      return null;
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
  }

  Future<User?> getUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      return User.fromJson(json.decode(userData));
    }
    return null;
  }

  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  Future<String?> uploadFileToFirebase(File file, String path) async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      final ref = FirebaseStorage.instance.ref().child(path);
      
      // For web platform, we need to use putData instead of putFile
      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        print("firebase "+bytes.toString());
        await ref.putData(bytes);
           print("firebase "+ref.getDownloadURL().toString());
        return await ref.getDownloadURL();
      } else {
        // For mobile platforms, use putFile
        await ref.putFile(file);
        return await ref.getDownloadURL();
      }
    } catch (e, stack) {
      print('Firebase upload error: $e');
      print('Stack trace: $stack');
      return null;
    }
  }

  // New method for XFile (works on web)
  Future<String?> uploadXFileToFirebase(XFile xFile, String path) async {
    try {
      print('=== FIREBASE UPLOAD DEBUG ===');
      print('Starting upload for: ${xFile.name}');
      print('File size: ${await xFile.length()} bytes');

      if (Firebase.apps.isEmpty) {
        print('Initializing Firebase...');
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      final ref = FirebaseStorage.instance.ref().child(path);
      print('Firebase reference created: $path');

      // Read bytes directly from XFile (works on all platforms)
      final bytes = await xFile.readAsBytes();
      print('File bytes read: ${bytes.length} bytes');

      print('Starting Firebase upload with 30s timeout...');
      final uploadTask = await ref.putData(bytes).timeout(const Duration(seconds: 30), onTimeout: () {
        print('=== FIREBASE UPLOAD TIMEOUT ===');
        throw Exception('Firebase upload timed out after 30 seconds');
      });
      print('UploadTask result: $uploadTask');

      String? downloadUrl;
      try {
        downloadUrl = await ref.getDownloadURL();
        print('Download URL: $downloadUrl');
      } catch (e) {
        print('=== ERROR GETTING DOWNLOAD URL ===');
        print('Error: $e');
        downloadUrl = null;
      }

      if (downloadUrl == null) {
        print('=== FIREBASE UPLOAD FAILED: Download URL is null ===');
      } else {
        print('=== FIREBASE UPLOAD SUCCESS ===');
      }
      return downloadUrl;
    } catch (e, stack) {
      print('=== FIREBASE UPLOAD ERROR ===');
      print('Error: $e');
      print('Stack trace: $stack');
      print('==============================');
      return null;
    }
  }

  Future<void> postCaseWithMedia({
    required String title,
    required String description,
    List<XFile>? imageFiles, // Changed from single XFile to List<XFile>
    XFile? mediaFile,
    List<String>? tags,
  }) async {
    try {
      print('=== CASE POSTING DEBUG ===');
      print('Title: $title');
      print('Description: $description');
      print('Number of images: ${imageFiles?.length ?? 0}');
      print('Has media: ${mediaFile != null}');
      print('Tags: $tags');
      
      List<String> imageUrls = [];
      String? mediaUrl;
      
      // Upload multiple images
      if (imageFiles != null && imageFiles.isNotEmpty) {
        print('Starting multiple image upload...');
        for (int i = 0; i < imageFiles.length; i++) {
          final imageFile = imageFiles[i];
          print('Uploading image ${i + 1}/${imageFiles.length}...');
          final imageUrl = await uploadXFileToFirebase(
            imageFile,
            'case_images/${DateTime.now().millisecondsSinceEpoch}_${i}_${imageFile.name}',
          );
          print('Firebase image URL ${i + 1}: $imageUrl');
          if (imageUrl != null) {
            imageUrls.add(imageUrl);
          } else {
            print('=== IMAGE UPLOAD ERROR: Image URL is null for image ${i + 1} ===');
          }
        }
      }
      
      if (mediaFile != null) {
        print('Starting media upload...');
        mediaUrl = await uploadXFileToFirebase(
          mediaFile,
          'case_media/${DateTime.now().millisecondsSinceEpoch}_${mediaFile.name}',
        );
        print('Firebase media URL: $mediaUrl');
      }
      
      print('Creating case data...');
      final caseData = {
        'title': title,
        'description': description,
        'imageUrls': imageUrls, // Changed from imageUrl to imageUrls
        'imageUrl': imageUrls.isNotEmpty ? imageUrls.first : null, // Keep backward compatibility
        'mediaUrl': mediaUrl,
        'tags': tags ?? [],
      };
      print('Case data: $caseData');
      
      print('Getting auth token...');
      final token = await getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      
      print('Posting case to backend...');
      final response = await http.post(
        Uri.parse('${AppConstants.casesUrl}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(caseData),
      );
      
      print('Backend response status: ${response.statusCode}');
      print('Backend response body: ${response.body}');
      
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to create case: ${response.statusCode} - ${response.body}');
      }
      
      print('=== CASE POSTED SUCCESSFULLY ===');
    } catch (e, stack) {
      print('=== CASE POSTING ERROR ===');
      print('Error: $e');
      print('Stack trace: $stack');
      print('==========================');
      rethrow;
    }
  }
}
