import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/hiring_post.dart';
import '../models/hiring_application.dart';
import '../models/hiring_chat_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HiringService {
  final String baseUrl = AppConstants.baseUrl;

  // Helper to get token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // --- Hiring Posts ---
  Future<List<HiringPost>> getPosts() async {
    final token = await _getToken();
    final res = await http.get(
      Uri.parse('$baseUrl/hiring-posts'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      return data.map((e) => HiringPost.fromJson(e)).toList();
    }
    throw Exception('Failed to load posts');
  }

  Future<HiringPost> createPost(HiringPost post) async {
    final token = await _getToken();
    final res = await http.post(
      Uri.parse('$baseUrl/hiring-posts'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(post.toJson()),
    );
    if (res.statusCode == 200) {
      return HiringPost.fromJson(json.decode(res.body));
    }
    throw Exception('Failed to create post');
  }

  // --- Applications ---
  Future<List<HiringApplication>> getApplicationsForPost(int postId) async {
    final token = await _getToken();
    final res = await http.get(
      Uri.parse('$baseUrl/hiring-applications/post/$postId'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      return data.map((e) => HiringApplication.fromJson(e)).toList();
    }
    throw Exception('Failed to load applications');
  }

  Future<HiringApplication> applyToPost(HiringApplication application) async {
    final token = await _getToken();
    final res = await http.post(
      Uri.parse('$baseUrl/hiring-applications'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(application.toJson()),
    );
    if (res.statusCode == 200) {
      return HiringApplication.fromJson(json.decode(res.body));
    }
    throw Exception('Failed to apply');
  }

  // --- Chat ---
  Future<List<HiringChatMessage>> getChatMessages(int applicationId) async {
    final token = await _getToken();
    final res = await http.get(
      Uri.parse('$baseUrl/hiring-chats/application/$applicationId'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      return data.map((e) => HiringChatMessage.fromJson(e)).toList();
    }
    throw Exception('Failed to load chat messages');
  }

  Future<HiringChatMessage> sendChatMessage(HiringChatMessage message) async {
    final token = await _getToken();
    final res = await http.post(
      Uri.parse('$baseUrl/hiring-chats'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(message.toJson()),
    );
    if (res.statusCode == 200) {
      return HiringChatMessage.fromJson(json.decode(res.body));
    }
    throw Exception('Failed to send message');
  }
}
