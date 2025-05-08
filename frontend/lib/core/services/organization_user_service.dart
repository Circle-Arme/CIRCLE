import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/core/utils/shared_prefs.dart';
import 'package:frontend/data/models/user_profile_model.dart';
import '../utils/api_config.dart';

class OrganizationUserService {
  // لتعديل بيانات منظمة نستخدم endpoint خاص بالأدمن
  static String get _fetchBase  => '${ApiConfig.baseUrl}/accounts/admin/org-users';
  static String get _createBase => '${ApiConfig.baseUrl}/accounts/admin/create-org-user';
  static String get _updateBase => '${ApiConfig.baseUrl}/accounts/admin/update-org-user';
  static String get _deleteBase => '${ApiConfig.baseUrl}/accounts/admin/delete-org-user';
  //http://192.168.1.5:8000
  //static const String _fetchBaseUrl = "http://192.168.1.5:8000/api/accounts/admin/org-users";
  //static const String _createBaseUrl = "http://192.168.1.5:8000/api/accounts/admin/create-org-user";
  //static const String _updateBaseUrl = "http://192.168.1.5:8000/api/accounts/admin/update-org-user";
  //static const String _deleteBaseUrl = "http://192.168.1.5:8000/api/accounts/admin/delete-org-user";
  // 🔹 جلب مستخدمي المنظمات
  static Future<List<UserProfileModel>> fetchOrganizationUsers() async {
    final token = await SharedPrefs.getAccessToken();
    if (token == null) throw Exception("التوكن غير متوفر");

    final uri   = Uri.parse('$_fetchBase/');
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

    final uri   = Uri.parse('$_createBase/');
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
        "website"     : profile.website,
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

    final uri = Uri.parse('$_updateBase/$userId/');
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
        "website"        : profile.website,
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

    final uri = Uri.parse('$_deleteBase/$userId/');
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

  /// جلب بروفايل مستخدم مؤسسة (يُستدعى في _loadLatestProfile)
  static Future<UserProfileModel> fetchUserProfileById(String id) async {
    final token = await SharedPrefs.getAccessToken();
    final uri   = Uri.parse("http://10.0.2.2:8000/api/accounts/profile/$id/");
    //final uri   = Uri.parse("http://192.168.1.5:8000/api/accounts/profile/$id/");
    //http://192.168.1.5:8000
    final resp  = await http.get(uri, headers: {
      "Authorization": "Bearer $token",
      "Content-Type" : "application/json"
    });
    if (resp.statusCode == 200) {
      return UserProfileModel.fromJson(jsonDecode(resp.body));
    }
    throw Exception("فشل تحميل البروفايل: ${resp.statusCode} ${resp.body}");
  }

}
