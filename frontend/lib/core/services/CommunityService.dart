import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/data/models/community_model.dart';
import 'package:frontend/core/utils/shared_prefs.dart';
import 'package:frontend/core/services/auth_service.dart';
import 'package:frontend/core/services/auth_http.dart';
import 'package:frontend/core/exceptions/community_exception.dart';
import 'package:http_parser/http_parser.dart';
import '../utils/api_config.dart';

class CommunityService {
  static String get _base => ApiConfig.baseUrl;
  //http://192.168.1.5:8000
  //static const String _baseUrl = "http://192.168.1.5:8000/api";
  /// جلب المجتمعات في مجال (Field) معيّن
  static Future<List<CommunityModel>> fetchCommunities(String areaId) async {
    final uri = Uri.parse('$_base/fields/$areaId/communities/');
    try {

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
  static Future<String> joinCommunity(
      int communityId, {
        String level = 'beginner',
      }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        throw CommunityException('No authentication token available');
      }

      final uri = Uri.parse('$_base/user-communities/');
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

      if (response.statusCode == 201) {
        // الـ API الآن يرجع {"detail": "...", "level": "<level>"}
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return body['level'] as String;
      } else {
        throw CommunityException(
          'Failed to join community: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw CommunityException('Error joining community: ${e.toString()}');
    }
  }
  /// يغيّر مستوى المستخدم في مجتمع موجود
  static Future<String> changeCommunityLevel(int communityId, String newLevel) async {
    final uri = Uri.parse('$_base/user-communities/change-level/');
    final response = await AuthHttp.post(
      uri,
      headers: { "Content-Type": "application/json" },
      body: jsonEncode({
        "community": communityId,
        "level": newLevel,
      }),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['level'] as String;
    } else {
      throw CommunityException(
        'Failed to change level: ${response.statusCode} - ${response.body}',
      );
    }
  }

  /// جلب المجتمعات التي انضم إليها المستخدم
  static Future<List<CommunityModel>> fetchMyCommunities() async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        throw CommunityException('No authentication token available');
      }

      final uri = Uri.parse("$_base/user-communities/my/");
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

      final uri = Uri.parse("$_base/user-communities/leave/?community_id=$communityId");
      final response = await http.delete(
        uri,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

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
      String? imagePath,
      ) async {
    final token = await SharedPrefs.getAccessToken();
    if (token == null || token.isEmpty) {
      throw CommunityException("لا يوجد توكن (AccessToken) محفوظ.");
    }

    final uri = Uri.parse("$_base/admin/communities/");
    var request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = "Bearer $token"
      ..fields['field'] = fieldId.toString()
      ..fields['name'] = name;

    if (imagePath != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imagePath,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode != 201) {
      final decoded = utf8.decode(responseBody.runes.toList());
      try {
        final errorJson = jsonDecode(decoded);
        throw CommunityException(errorJson['error'] ?? 'فشل إنشاء المجتمع');
      } catch (_) {
        throw CommunityException("فشل إنشاء المجتمع: $decoded");
      }
    }
  }

  /// تعديل مجتمع (Admin)
  static Future<void> updateCommunity(
      int communityId,
      int fieldId,
      String name,
      String? imagePath,
      ) async {
    final token = await SharedPrefs.getAccessToken();
    if (token == null || token.isEmpty) {
      throw CommunityException("لا يوجد توكن (AccessToken) محفوظ.");
    }

    final uri = Uri.parse("$_base/admin/communities/$communityId/");
    var request = http.MultipartRequest('PUT', uri)
      ..headers['Authorization'] = "Bearer $token"
      ..fields['field'] = fieldId.toString()
      ..fields['name'] = name;

    if (imagePath != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imagePath,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      final decoded = utf8.decode(responseBody.runes.toList());
      try {
        final errorJson = jsonDecode(decoded);
        throw CommunityException(errorJson['error'] ?? 'فشل تعديل المجتمع');
      } catch (_) {
        throw CommunityException("فشل تعديل المجتمع: $decoded");
      }
    }
  }

  /// حذف مجتمع (Admin)
  static Future<void> deleteCommunity(int communityId) async {
    final token = await SharedPrefs.getAccessToken();
    if (token == null || token.isEmpty) {
      throw CommunityException("لا يوجد توكن (AccessToken) محفوظ.");
    }

    final uri = Uri.parse("$_base/admin/communities/$communityId/");
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
        throw CommunityException(errorJson['error'] ?? 'فشل حذف المجتمع');
      } catch (_) {
        throw CommunityException("فشل حذف المجتمع: $decoded");
      }
    }
  }

  /// جلب مجتمعات مستخدم معيّن
  static Future<List<CommunityModel>> fetchCommunitiesForUser(int userId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) throw CommunityException('No authentication token available');
      final uri = Uri.parse("$_base/user-communities/for-user/$userId/");
      final response = await AuthHttp.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((j) => CommunityModel.fromJson(j)).toList();
      } else {
        throw CommunityException(
          'Failed to fetch communities for user $userId: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw CommunityException('Error fetching communities for user: ${e.toString()}');
    }
  }

  /// جلب جميع المجتمعات كأدمن
  static Future<List<CommunityModel>> fetchAdminCommunities() async {
    final token = await SharedPrefs.getAccessToken();
    if (token == null || token.isEmpty) {
      throw CommunityException('لا يوجد توكن متاح.');
    }

    final uri = Uri.parse("$_base/admin/communities/");
    final response = await http.get(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => CommunityModel.fromJson(json)).toList();
    } else {
      final decoded = utf8.decode(response.bodyBytes);
      throw CommunityException("فشل جلب المجتمعات: $decoded");
    }
  }
}
