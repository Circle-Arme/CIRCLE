// lib/services/user_profile_service.dart
//
// خدمة التعامل مع بروفايل المستخدم (حفظ، تحميل، تحديث التوكن…).

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:frontend/data/models/user_profile_model.dart';
import 'package:frontend/core/utils/shared_prefs.dart';
import '../utils/api_config.dart';

class UserProfileService {
  static String get _accountsBase => '${ApiConfig.baseUrl}/accounts';
  //static const String _baseUrl = 'http://192.168.1.5:8000/api/accounts';
  //http://192.168.1.5:8000

  // ---------------------------------------------------------------
  // 🔄 تجديد التوكن عند انتهاء صلاحيته
  // ---------------------------------------------------------------
  static Future<void> refreshAccessToken() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/token/refresh/');
    final refreshToken = await SharedPrefs.getRefreshToken();
    if (refreshToken == null) throw Exception('لا يوجد Refresh Token');

    final res = await http.post(
      uri, // ../ للوصول إلى /api/token/refresh/
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': refreshToken}),
    );

    if (res.statusCode == 200) {
      final newAccess = jsonDecode(res.body)['access'];
      await SharedPrefs.saveAccessToken(newAccess);
    } else {
      throw Exception('فشل تجديد التوكن: ${res.body}');
    }
  }

  // ---------------------------------------------------------------
  // 🔄 حفظ البروفايل (نصوص فقط) في السيرفر
  // ---------------------------------------------------------------
  static Future<void> saveUserProfile(UserProfileModel profile) async {
    try {
      await _sendProfile(profile);
    } on Exception catch (e) {
      if (e.toString().contains('Token is expired')) {
        await refreshAccessToken();
        await _sendProfile(profile);
      } else {
        rethrow;
      }
    }
  }

  // PATCH  لإرسال الحقول القابلة للتعديل فقط
  static Future<void> _sendProfile(UserProfileModel profile) async {
    final uri = Uri.parse('$_accountsBase/profile/');
    final token = await SharedPrefs.getAccessToken();
    if (token == null) throw Exception('التوكن غير متوفر');

    final response = await http.patch(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': profile.name,
        'work_education': profile.workEducation,
        'position': profile.position,
        'description': profile.description,
        'website': profile.website,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('فشل حفظ البروفايل: ${response.body}');
    }
  }

  // ---------------------------------------------------------------
  // 📦 التخزين المحلي
  // ---------------------------------------------------------------
  static Future<void> saveUserProfileLocally(UserProfileModel profile) async {
    final prefs = await SharedPrefs.prefs();
    prefs.setString('user_profile', jsonEncode(profile.toJson()));
  }

  static Future<UserProfileModel?> getUserProfileFromLocal() async {
    final prefs = await SharedPrefs.prefs();
    final jsonString = prefs.getString('user_profile');
    if (jsonString != null) {
      return UserProfileModel.fromJson(jsonDecode(jsonString));
    }
    return null;
  }

  // ---------------------------------------------------------------
  // 📥 تحميل البروفايل (الحالي) من السيرفر
  // ---------------------------------------------------------------
  static Future<UserProfileModel> fetchUserProfileFromServer() async {
    final uri = Uri.parse('$_accountsBase/profile/');
    final token = await SharedPrefs.getAccessToken();
    if (token == null) throw Exception('التوكن غير متوفر');

    final res = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode == 200) {
      return UserProfileModel.fromJson(jsonDecode(res.body));
    }
    throw Exception('فشل تحميل البروفايل: ${res.body}');
  }

  // ---------------------------------------------------------------
  // 📥 تحميل بروفايل مستخدم آخر بالـ ID
  // ---------------------------------------------------------------
  static Future<UserProfileModel> fetchUserProfileById(String id) async {
    final uri = Uri.parse('$_accountsBase/profile/');
    final token = await SharedPrefs.getAccessToken();
    if (token == null) throw Exception('التوكن غير متوفر');

    final res = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode == 200) {
      return UserProfileModel.fromJson(jsonDecode(res.body));
    }
    if (res.statusCode == 401) {
      await refreshAccessToken();
      return fetchUserProfileById(id); // إعادة المحاولة بعد التجديد
    }
    throw Exception('فشل جلب بروفايل المستخدم: ${res.statusCode}');
  }
}
