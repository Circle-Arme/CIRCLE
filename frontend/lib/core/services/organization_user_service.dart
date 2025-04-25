import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/core/utils/shared_prefs.dart';
import 'package:frontend/data/models/user_profile_model.dart';

class OrganizationUserService {
  // لتعديل بيانات منظمة نستخدم endpoint خاص بالأدمن
  static const String _fetchBaseUrl = "http://10.0.2.2:8000/api/accounts/admin/org-users";
  static const String _createBaseUrl = "http://10.0.2.2:8000/api/accounts/admin/create-org-user";
  static const String _updateBaseUrl = "http://10.0.2.2:8000/api/accounts/admin/update-org-user";
  static const String _deleteBaseUrl = "http://10.0.2.2:8000/api/accounts/admin/delete-org-user";

  // 🔹 جلب مستخدمي المنظمات
  static Future<List<UserProfileModel>> fetchOrganizationUsers() async {
    final token = await SharedPrefs.getAccessToken();
    if (token == null) throw Exception("التوكن غير متوفر");

    final uri = Uri.parse("$_fetchBaseUrl/");
    final response = await http.get(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonData.map((json) => UserProfileModel.fromJson(json)).toList();
    } else {
      final decoded = utf8.decode(response.bodyBytes);
      try {
        final errorJson = jsonDecode(decoded);
        throw Exception(errorJson['error'] ?? 'فشل جلب المنظمات');
      } catch (_) {
        throw Exception("فشل جلب المنظمات: $decoded");
      }
    }
  }

  // 🔹 إنشاء مستخدم منظمة
  static Future<void> createOrganizationUser(UserProfileModel profile, String password) async {
    final token = await SharedPrefs.getAccessToken();
    if (token == null) throw Exception("التوكن غير متوفر");

    final uri = Uri.parse("$_createBaseUrl/");
    final response = await http.post(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "name": profile.name,
        "work_education": profile.workEducation,
        "position": profile.position,
        "description": profile.description,
        "email": profile.email,
        "password": password,
        "user_type": "organization",
      }),
    );

    if (response.statusCode == 201) {
      return;
    } else {
      final decoded = utf8.decode(response.bodyBytes);
      try {
        final errorJson = jsonDecode(decoded);
        throw Exception(errorJson['error'] ?? 'فشل إنشاء المنظمة');
      } catch (_) {
        throw Exception("فشل إنشاء المنظمة: $decoded");
      }
    }
  }

  // 🔹 تعديل مستخدم منظمة (استخدم PATCH)
  static Future<void> updateOrganizationUser(int userId, UserProfileModel profile) async {
    final token = await SharedPrefs.getAccessToken();
    if (token == null) throw Exception("التوكن غير متوفر");

    final uri = Uri.parse("$_updateBaseUrl/$userId/");
    final response = await http.patch(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "name": profile.name,
        "work_education": profile.workEducation,
        "position": profile.position,
        "description": profile.description,
        "email": profile.email,
        "user_type": "organization",
      }),
    );

    if (response.statusCode == 200) {
      return;
    } else {
      final decoded = utf8.decode(response.bodyBytes);
      try {
        final errorJson = jsonDecode(decoded);
        throw Exception(errorJson['error'] ?? 'فشل تعديل المنظمة');
      } catch (_) {
        throw Exception("فشل تعديل المنظمة: $decoded");
      }
    }
  }

  // 🔹 حذف مستخدم منظمة
  static Future<void> deleteOrganizationUser(int userId) async {
    final token = await SharedPrefs.getAccessToken();
    if (token == null) throw Exception("التوكن غير متوفر");

    final uri = Uri.parse("$_deleteBaseUrl/$userId/");
    final response = await http.delete(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return;
    } else {
      final decoded = utf8.decode(response.bodyBytes);
      try {
        final errorJson = jsonDecode(decoded);
        throw Exception(errorJson['error'] ?? 'فشل حذف المنظمة');
      } catch (_) {
        throw Exception("فشل حذف المنظمة: $decoded");
      }
    }
  }
}
