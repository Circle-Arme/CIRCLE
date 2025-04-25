import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/data/models/community_model.dart';
import 'package:frontend/core/utils/shared_prefs.dart';
import 'package:frontend/core/services/auth_service.dart';
import 'package:frontend/core/services/auth_http.dart';
import 'package:frontend/core/exceptions/community_exception.dart';

class CommunityService {
  static const String _baseUrl = "http://10.0.2.2:8000/api";

  /// جلب المجتمعات في مجال (Field) معيّن
  static Future<List<CommunityModel>> fetchCommunities(String areaId) async {
    try {
      final uri = Uri.parse("$_baseUrl/fields/$areaId/communities/");
      final response = await AuthHttp.get(uri);


      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => CommunityModel.fromJson(json)).toList();
      } else {
        throw CommunityException(
          'Failed to fetch communities: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw CommunityException('Error fetching communities: ${e.toString()}');
    }
  }

  /// الانضمام لمجتمع مع تحديد المستوى
  /// لا يحتاج صلاحية أدمن
  static Future<void> joinCommunity(
      int communityId, {
        String level = 'beginner',
      }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        throw CommunityException('No authentication token available');
      }

      final uri = Uri.parse("$_baseUrl/user-communities/");
      final response = await AuthHttp.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "community": communityId,
          "level": level,
        }),
      );

      if (response.statusCode != 201) {
        throw CommunityException(
          'Failed to join community: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw CommunityException('Error joining community: ${e.toString()}');
    }
  }

  /// جلب المجتمعات التي انضم إليها المستخدم
  static Future<List<CommunityModel>> fetchMyCommunities() async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        throw CommunityException('No authentication token available');
      }

      final uri = Uri.parse("$_baseUrl/user-communities/my/");
      final response = await AuthHttp.get(uri);


      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => CommunityModel.fromJson(json)).toList();
      } else {
        throw CommunityException(
          'Failed to fetch joined communities: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw CommunityException('Error fetching joined communities: ${e.toString()}');
    }
  }

  /// مغادرة مجتمع معيّن
  static Future<void> leaveCommunity(int communityId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        throw CommunityException('No authentication token available');
      }

      final uri = Uri.parse("$_baseUrl/user-communities/leave/?community_id=$communityId");
      final response = await http.delete(
        uri,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      // في الـ backend، تعيد 204 أو 200 إذا نجحت
      if (response.statusCode != 204 && response.statusCode != 200) {
        throw CommunityException(
          'Failed to leave community: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw CommunityException('Error leaving community: ${e.toString()}');
    }
  }

  /// إنشاء مجتمع جديد (Admin)
  static Future<void> createCommunity(
      int fieldId,
      String name,
      String? image,
      ) async {
    final token = await SharedPrefs.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception("لا يوجد توكن (AccessToken) محفوظ.");
    }

    final uri = Uri.parse("$_baseUrl/admin/communities/");
    final response = await http.post(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "field": fieldId,
        "name": name,
        "image": image,
      }),
    );

    if (response.statusCode != 201) {
      final decoded = utf8.decode(response.bodyBytes);
      try {
        final errorJson = jsonDecode(decoded);
        throw Exception(errorJson['error'] ?? 'فشل إنشاء المجتمع');
      } catch (_) {
        throw Exception("فشل إنشاء المجتمع: $decoded");
      }
    }
  }

  /// تعديل مجتمع (Admin)
  static Future<void> updateCommunity(
      int communityId,
      int fieldId,
      String name,
      String? image,
      ) async {
    final token = await SharedPrefs.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception("لا يوجد توكن (AccessToken) محفوظ.");
    }

    final uri = Uri.parse("$_baseUrl/admin/communities/$communityId/");
    final response = await http.put(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "field": fieldId,
        "name": name,
        "image": image,
      }),
    );

    if (response.statusCode != 200) {
      final decoded = utf8.decode(response.bodyBytes);
      try {
        final errorJson = jsonDecode(decoded);
        throw Exception(errorJson['error'] ?? 'فشل تعديل المجتمع');
      } catch (_) {
        throw Exception("فشل تعديل المجتمع: $decoded");
      }
    }
  }

  /// حذف مجتمع (Admin)
  static Future<void> deleteCommunity(int communityId) async {
    final token = await SharedPrefs.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception("لا يوجد توكن (AccessToken) محفوظ.");
    }

    final uri = Uri.parse("$_baseUrl/admin/communities/$communityId/");
    final response = await http.delete(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode != 200) {
      final decoded = utf8.decode(response.bodyBytes);
      try {
        final errorJson = jsonDecode(decoded);
        throw Exception(errorJson['error'] ?? 'فشل حذف المجتمع');
      } catch (_) {
        throw Exception("فشل حذف المجتمع: $decoded");
      }
    }
  }
  static Future<List<CommunityModel>> fetchCommunitiesForUser(int userId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No authentication token');
      final uri = Uri.parse("$_baseUrl/user-communities/for-user/$userId/");
      final response = await AuthHttp.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((j) => CommunityModel.fromJson(j)).toList();
      } else {
        throw Exception('Failed to fetch communities for user $userId: '
            '${response.statusCode} ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
