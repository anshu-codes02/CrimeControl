import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CaseService {
  static const String baseUrl = '${AppConstants.baseUrl}/api/cases';

  /// Get headers with authentication token
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  /// Close a case
  Future<Map<String, dynamic>> closeCase(int caseId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/$caseId/close'),
        headers: headers,
      );

      print('=== CLOSE CASE DEBUG ===');
      print('URL: $baseUrl/$caseId/close');
      print('Status Code: ${response.statusCode}');
      print('Response: ${response.body}');
      print('========================');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorResponse = json.decode(response.body);
        throw Exception(errorResponse['error'] ?? 'Failed to close case');
      }
    } catch (e) {
      throw Exception('Failed to close case: ${e.toString()}');
    }
  }

  /// Delete a case (only allowed 24 hours after closing)
  Future<Map<String, dynamic>> deleteCase(int caseId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/$caseId'),
        headers: headers,
      );

      print('=== DELETE CASE DEBUG ===');
      print('URL: $baseUrl/$caseId');
      print('Status Code: ${response.statusCode}');
      print('Response: ${response.body}');
      print('=========================');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorResponse = json.decode(response.body);
        throw Exception(errorResponse['error'] ?? 'Failed to delete case');
      }
    } catch (e) {
      throw Exception('Failed to delete case: ${e.toString()}');
    }
  }

  /// Check if a case can be deleted
  Future<Map<String, dynamic>> canDeleteCase(int caseId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/$caseId/can-delete'),
        headers: headers,
      );

      print('=== CAN DELETE CASE DEBUG ===');
      print('URL: $baseUrl/$caseId/can-delete');
      print('Status Code: ${response.statusCode}');
      print('Response: ${response.body}');
      print('=============================');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorResponse = json.decode(response.body);
        throw Exception(errorResponse['error'] ?? 'Failed to check deletion status');
      }
    } catch (e) {
      throw Exception('Failed to check deletion status: ${e.toString()}');
    }
  }

  /// Get all cases that can be deleted (admin only)
  Future<List<Map<String, dynamic>>> getDeletableCases() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/deletable'),
        headers: headers,
      );

      print('=== DELETABLE CASES DEBUG ===');
      print('URL: $baseUrl/deletable');
      print('Status Code: ${response.statusCode}');
      print('Response: ${response.body}');
      print('=============================');

      if (response.statusCode == 200) {
        final List<dynamic> casesJson = json.decode(response.body);
        return casesJson.map((json) => json as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to fetch deletable cases: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch deletable cases: ${e.toString()}');
    }
  }

  /// Get case by ID
  Future<Map<String, dynamic>> getCaseById(int caseId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/$caseId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch case: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch case: ${e.toString()}');
    }
  }

  /// Get all cases
  Future<List<Map<String, dynamic>>> getAllCases() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> casesJson = json.decode(response.body);
        return casesJson.map((json) => json as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to fetch cases: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch cases: ${e.toString()}');
    }
  }

  /// Create a new case
  Future<Map<String, dynamic>> createCase(Map<String, dynamic> caseData) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: json.encode(caseData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final errorResponse = json.decode(response.body);
        throw Exception(errorResponse['error'] ?? 'Failed to create case');
      }
    } catch (e) {
      throw Exception('Failed to create case: ${e.toString()}');
    }
  }
}
