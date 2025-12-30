import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/rating.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RatingService {
  static const String baseUrl = '${AppConstants.baseUrl}/ratings';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token'); // Fixed: Use correct key matching AuthService
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Rate a user
  Future<Rating> rateUser({
    required int raterId,
    required int ratedUserId,
    required int rating,
    required String comment,
    required String category,
    int? caseId,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = json.encode({
        'raterId': raterId,
        'ratedUserId': ratedUserId,
        'rating': rating,
        'comment': comment,
        'category': category,
        if (caseId != null) 'caseId': caseId,
      });

      final response = await http.post(
        Uri.parse('$baseUrl/rate'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return Rating.fromJson(data['rating']);
        } else {
          throw Exception(data['message'] ?? 'Failed to submit rating');
        }
      } else {
        throw Exception('Failed to submit rating: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to submit rating: ${e.toString()}');
    }
  }

  /// Get ratings for a user
  Future<List<Rating>> getUserRatings(int userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/user/$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> ratingsJson = data['ratings'];
          return ratingsJson.map((json) => Rating.fromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch ratings');
        }
      } else {
        throw Exception('Failed to fetch ratings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch ratings: ${e.toString()}');
    }
  }

  /// Get ratings given by a user
  Future<List<Rating>> getRatingsByRater(int raterId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/by-rater/$raterId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> ratingsJson = data['ratings'];
          return ratingsJson.map((json) => Rating.fromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch ratings');
        }
      } else {
        throw Exception('Failed to fetch ratings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch ratings: ${e.toString()}');
    }
  }

  /// Check if a user can rate another user
  Future<bool> canRate(int raterId, int ratedUserId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/can-rate/$raterId/$ratedUserId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['canRate'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Delete a rating
  Future<void> deleteRating(int ratingId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/$ratingId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to delete rating');
      }
    } catch (e) {
      throw Exception('Failed to delete rating: ${e.toString()}');
    }
  }

  /// Get user rating statistics
  Future<Map<String, dynamic>> getUserRatingStats(int userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/user/$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return {
            'averageRating': data['averageRating'] ?? 0.0,
            'totalRatings': data['totalRatings'] ?? 0,
            'ratings': data['ratings'] ?? [],
          };
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch rating stats');
        }
      } else {
        throw Exception('Failed to fetch rating stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch rating stats: ${e.toString()}');
    }
  }
}
