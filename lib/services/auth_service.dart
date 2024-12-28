import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../config/config_url.dart';
import '../model/UserModel.dart';

class AuthService {
  // đường dẫn tới API login
  String get apiUrl => "${Config_URL.baseUrl}Authenticate/login";

  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token != null) {
      final decodedToken = JwtDecoder.decode(token);
      return User.fromJson(decodedToken);
    }
    return null;
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          "success": data['status'],
          "token": data['token'],
          "twoFactorEnabled": data['twoFactorEnabled'] ?? false,
          "message": data['message']
        };
      }
      return {"success": false, "message": "Login failed: ${response.statusCode}"};
    } catch (e) {
      return {"success": false, "message": "Network error: $e"};
    }
  }

  Future<bool> logout() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove('jwt_token');
  }
  
  Future<Map<String, dynamic>> userInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    try {
      final response = await http.get(
        Uri.parse("${Config_URL.baseUrl}Authenticate/user-details"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );
      final data = jsonDecode(response.body);
      if (data['status']) {
        return {
          "success": true,
          "user": {
            "userName": data['userDetails']['username'],
            "email": data['userDetails']['email'],
            "avatarUrl": data['userDetails']['avatarUrl'],
            "initials": data['userDetails']['initials']
          }
        };
      }
      return {"success": false, "message": "Failed to fetch user data"};
    } catch (e) {
      return {"success": false, "message": "Network error: $e"};
    }
  }

  Future<Map<String, dynamic>> setupTotp() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      final response = await http.get(
        Uri.parse("${Config_URL.baseUrl}Authenticate/setup-totp"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      final data = jsonDecode(response.body);
      return {
        "success": response.statusCode == 200,
        "secretKey": data['secretKey']
      };
    } catch (e) {
      return {"success": false, "message": "Network error: $e"};
    }
  }

  Future<Map<String, dynamic>> loginWithTotp(String username, String password, String totpCode) async {
    try {
      final response = await http.post(
        Uri.parse("${Config_URL.baseUrl}Authenticate/login-with-totp?totpCode=$totpCode"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          "success": true,
          "token": data['token'],
        };
      }
      return {"success": false, "message": "Invalid TOTP code"};
    } catch (e) {
      return {"success": false, "message": "Network error: $e"};
    }
  }
}
