import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/badge.dart';
import '../models/badge_with_multiplier.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BadgeService {
  static const String baseUrl = '${AppConstants.baseUrl}/badges';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token'); // Fixed: Use correct key matching AuthService
    print('=== TOKEN DEBUG ===');
    print('Retrieved token: ${token != null ? 'Token exists (${token.length} chars)' : 'No token found'}');
    print('==================');
    return token;
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Award a badge to a user (for RECRUITERS and ORGANIZATIONS)
  Future<Map<String, dynamic>> awardBadge({
    required int awarderId,
    required int userId,
    required int badgeId,
    required String reason,
    int? caseId,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = json.encode({
        'awarderId': awarderId,
        'userId': userId,
        'badgeId': badgeId,
        'reason': reason,
        if (caseId != null) 'caseId': caseId,
      });

      print('=== BADGE AWARD DEBUG ===');
      print('URL: $baseUrl/award');
      print('Headers: $headers');
      print('Body: $body');
      print('========================');

      final response = await http.post(
        Uri.parse('$baseUrl/award'),
        headers: headers,
        body: body,
      );

      print('=== RESPONSE DEBUG ===');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      print('=====================');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data;
        } else {
          throw Exception(data['message'] ?? 'Failed to award badge');
        }
      } else {
        throw Exception('Failed to award badge: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Badge award error: ${e.toString()}');
      throw Exception('Failed to award badge: ${e.toString()}');
    }
  }

  /// Get all available badges
  Future<List<Badge>> getAvailableBadges() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/available'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> badgesJson = data['badges'];
          return badgesJson.map((json) => Badge.fromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch badges');
        }
      } else {
        // Fallback to the regular getAllBadges endpoint
        return getAllBadges();
      }
    } catch (e) {
      throw Exception('Failed to fetch available badges: ${e.toString()}');
    }
  }

  /// Get all badges (fallback method)
  Future<List<Badge>> getAllBadges() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> badgesJson = json.decode(response.body);
        return badgesJson.map((json) => Badge.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch badges: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch badges: ${e.toString()}');
    }
  }

  /// Get badges for a user
  Future<List<Map<String, dynamic>>> getUserBadges(int userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/user/$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> badgesJson = json.decode(response.body);
        return badgesJson.map((json) => json as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to fetch user badges: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch user badges: ${e.toString()}');
    }
  }

  /// Get badges with multiplier information for a user
  Future<List<BadgeWithMultiplier>> getUserBadgesWithMultipliers(int userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/user/$userId/multipliers'),
        headers: headers,
      );

      print('=== BADGES WITH MULTIPLIERS DEBUG ===');
      print('URL: $baseUrl/user/$userId/multipliers');
      print('Status Code: ${response.statusCode}');
      print('Response: ${response.body}');
      print('====================================');

      if (response.statusCode == 200) {
        final List<dynamic> badgesJson = json.decode(response.body);
        return badgesJson.map((json) => BadgeWithMultiplier.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch user badges with multipliers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch user badges with multipliers: ${e.toString()}');
    }
  }

  /// Get badges awarded by a specific user
  Future<List<Map<String, dynamic>>> getBadgesAwardedBy(int awarderId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/awarded-by/$awarderId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> badgesJson = data['badges'];
          return badgesJson.map((json) => json as Map<String, dynamic>).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch awarded badges');
        }
      } else {
        throw Exception('Failed to fetch awarded badges: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch awarded badges: ${e.toString()}');
    }
  }

  /// Check if a user can award badges
  Future<bool> canAwardBadges(int userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/can-award/$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['canAward'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Revoke a badge
  Future<void> revokeBadge(int badgeAwardId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/revoke/$badgeAwardId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to revoke badge');
      }
    } catch (e) {
      throw Exception('Failed to revoke badge: ${e.toString()}');
    }
  }

  /// Get badge statistics for display
  Future<Map<String, dynamic>> getBadgeStats(int userId) async {
    try {
      final badges = await getUserBadges(userId);
      
      Map<String, int> tierCounts = {
        'BRONZE': 0,
        'SILVER': 0,
        'GOLD': 0,
        'PLATINUM': 0,
      };

      for (var badgeAward in badges) {
        final badge = badgeAward['badge'];
        if (badge != null && badge['tier'] != null) {
          final tier = badge['tier'].toString().toUpperCase();
          tierCounts[tier] = (tierCounts[tier] ?? 0) + 1;
        }
      }

      return {
        'totalBadges': badges.length,
        'bronzeBadges': tierCounts['BRONZE'] ?? 0,
        'silverBadges': tierCounts['SILVER'] ?? 0,
        'goldBadges': tierCounts['GOLD'] ?? 0,
        'platinumBadges': tierCounts['PLATINUM'] ?? 0,
        'badges': badges,
      };
    } catch (e) {
      throw Exception('Failed to calculate badge stats: ${e.toString()}');
    }
  }
}
