import 'dart:convert';
import 'package:http/http.dart' as http;
import '../exceptions/auth_exception.dart';
import '../utils/shared_prefs.dart';
import 'package:frontend/data/models/user_profile_model.dart';

class LoggedUser {
  final String token;
  final String userType;
  final bool isNewUser;
  final int userId;
  final UserProfileModel userProfile;

  LoggedUser({
    required this.token,
    required this.userType,
    required this.isNewUser,
    required this.userId,
    required this.userProfile,
  });
}

class AuthService {
  static const String _baseUrl = "http://10.0.2.2:8000/api/accounts";

  /// تسجيل الدخول
  static Future<LoggedUser> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/login/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final access = data['access'] as String?;
        final refresh = data['refresh'] as String?;
        final user = data['user'];
        final userType = user['user_type'];
        final userId = user['id'];

        if (access == null || refresh == null) {
          throw AuthException('Tokens not found in response');
        }

        await SharedPrefs.saveAccessToken(access);
        await SharedPrefs.saveRefreshToken(refresh);

        final communityResponse = await http.get(
          Uri.parse("http://10.0.2.2:8000/api/user-communities/"),
          headers: {
            "Authorization": "Bearer $access",
            "Content-Type": "application/json",
          },
        );

        bool isNewUser = false;
        if (communityResponse.statusCode == 200) {
          final communities = jsonDecode(utf8.decode(communityResponse.bodyBytes));
          isNewUser = (communities as List).isEmpty;
        }

        final userProfile = UserProfileModel.fromJson(user);

        return LoggedUser(
          token: access,
          userType: userType,
          isNewUser: isNewUser,
          userId: userId,
          userProfile: userProfile,
        );
      } else {
        final decoded = utf8.decode(response.bodyBytes);
        final errorData = jsonDecode(decoded);
        final errorMessage = errorData['error'] ?? 'Login failed';
        throw AuthException(errorMessage);
      }
    } catch (e) {
      throw AuthException('فشل تسجيل الدخول: ${e.toString()}');
    }
  }

  /// التسجيل
  static Future<LoggedUser> register(String fullName, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/register/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "full_name": fullName,
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 201) {
        // ✅ بعد نجاح التسجيل، نعمل تسجيل دخول مباشرة
        return await login(email, password);
      } else {
        final decoded = utf8.decode(response.bodyBytes);
        final errorData = jsonDecode(decoded);
        final errorMessage = errorData['error'] ?? 'Registration failed';
        throw AuthException(errorMessage);
      }
    } catch (e) {
      throw AuthException('فشل التسجيل: ${e.toString()}');
    }
  }

  static Future<String?> getToken() async {
    return SharedPrefs.getAccessToken();
  }

  static Future<String?> getRefreshToken() async {
    return SharedPrefs.getRefreshToken();
  }

  static Future<String> refreshAccessToken() async {
    try {
      final refresh = await SharedPrefs.getRefreshToken();
      if (refresh == null) {
        throw AuthException("No refresh token found");
      }

      final response = await http.post(
        Uri.parse("http://10.0.2.2:8000/api/token/refresh/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"refresh": refresh}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccess = data['access'] as String?;

        if (newAccess == null) {
          throw AuthException('No access token returned');
        }

        await SharedPrefs.saveAccessToken(newAccess);
        return newAccess;
      } else {
        throw AuthException('Failed to refresh access token');
      }
    } catch (e) {
      throw AuthException('Error refreshing token: ${e.toString()}');
    }
  }

  static Future<void> logout() async {
    await SharedPrefs.clearAuthTokens();
    await SharedPrefs.clearUserProfile();
  }
}
