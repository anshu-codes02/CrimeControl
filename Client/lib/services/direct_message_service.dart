import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import 'auth_service.dart';
import 'dart:convert';

class DirectMessageService {
  Future<bool> isEligibleForDM(
    dynamic currentUserId,
    dynamic otherUserId,
  ) async {
    int user1 =
        currentUserId is String ? int.parse(currentUserId) : currentUserId;
    int user2 = otherUserId is String ? int.parse(otherUserId) : otherUserId;
    final token = await AuthService().getToken();
    final response = await http.get(
      Uri.parse(
        '${AppConstants.baseUrl}/dm/eligible?user1=$user1&user2=$user2',
      ),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['eligible'] == true;
    }
    return false;
  }
}
