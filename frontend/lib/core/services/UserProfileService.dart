import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/data/models/user_profile_model.dart';
import 'package:frontend/core/utils/shared_prefs.dart';

class UserProfileService {
  static const String _baseUrl = "http://10.0.2.2:8000/api/accounts";

  /// 📡 تحديث التوكن عند انتهاء الصلاحية
  static Future<void> refreshAccessToken() async {
    final refreshToken = await SharedPrefs.getRefreshToken();
    if (refreshToken == null) throw Exception("لا يوجد Refresh Token");

    final response = await http.post(
      Uri.parse("http://10.0.2.2:8000/api/token/refresh/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"refresh": refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final newAccessToken = data["access"];
      await SharedPrefs.saveAccessToken(newAccessToken);
    } else {
      final decoded = utf8.decode(response.bodyBytes);
      throw Exception("فشل تجديد التوكن: $decoded");
    }
  }

  /// 🔄 حفظ البروفايل في السيرفر
  static Future<void> saveUserProfile(UserProfileModel profile) async {
    try {
      await _sendProfile(profile); // دالة ترسل الطلب
    } catch (e) {
      if (e.toString().contains("Token is expired")) {
        await refreshAccessToken();
        await _sendProfile(profile); // إعادة المحاولة
      } else {
        rethrow;
      }
    }
  }

  static Future<void> _sendProfile(UserProfileModel profile) async {
    final token = await SharedPrefs.getAccessToken();
    if (token == null) throw Exception("التوكن غير متوفر");

    final response = await http.put(
      Uri.parse("$_baseUrl/profile/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(profile.toJson()),
    );

    if (response.statusCode != 200) {
      final decoded = utf8.decode(response.bodyBytes);
      throw Exception("فشل حفظ البروفايل في السيرفر: $decoded");
    }
  }

  /// 📦 تخزين البروفايل محليًا
  static Future<void> saveUserProfileLocally(UserProfileModel profile) async {
    final prefs = await SharedPrefs.prefs();
    prefs.setString('user_profile', jsonEncode(profile.toJson()));
  }

  /// 📥 استرجاع البروفايل من التخزين المحلي
  static Future<UserProfileModel?> getUserProfileFromLocal() async {
    final prefs = await SharedPrefs.prefs();
    final jsonString = prefs.getString('user_profile');
    if (jsonString != null) {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return UserProfileModel.fromJson(json);
    }
    return null;
  }

  /// 📡 تحميل البروفايل من السيرفر
  static Future<UserProfileModel> fetchUserProfileFromServer() async {
    final token = await SharedPrefs.getAccessToken();
    if (token == null) throw Exception("التوكن غير متوفر");

    final response = await http.get(
      Uri.parse("$_baseUrl/profile/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return UserProfileModel.fromJson(json);
    } else {
      final decoded = utf8.decode(response.bodyBytes);

      if (decoded.contains('<html')) {
        // السيرفر أرجع صفحة HTML بدل JSON
        throw Exception("السيرفر أرجع صفحة HTML بدل JSON - تحقق من السيرفر");
      }

      try {
        final errorJson = jsonDecode(decoded);
        final errorMsg = errorJson['error'] ?? decoded;
        throw Exception("فشل تحميل البروفايل من السيرفر: $errorMsg");
      } catch (_) {
        throw Exception("فشل تحميل البروفايل من السيرفر: $decoded");
      }
    }
  }
  static Future<UserProfileModel> fetchUserProfileById(String id) async {
    final token = await SharedPrefs.getAccessToken();
    if (token == null) throw Exception("التوكن غير متوفر");

    final res = await http.get(
      Uri.parse("$_baseUrl/profile/$id/"),            // عدّل المسار ليناسب API
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (res.statusCode == 200) {
      return UserProfileModel.fromJson(jsonDecode(res.body));
    } else if (res.statusCode == 401) {
      await refreshAccessToken();
      return fetchUserProfileById(id);              // إعادة المحاولة
    }
    throw Exception("فشل جلب بروفايل المستخدم: ${res.statusCode}");
  }
}

