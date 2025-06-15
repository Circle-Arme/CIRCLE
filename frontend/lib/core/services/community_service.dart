import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/data/models/community_model.dart';
import 'package:frontend/core/utils/shared_prefs.dart';
import 'package:frontend/core/services/auth_service.dart';
import 'package:frontend/core/services/auth_http.dart';
import 'package:frontend/core/exceptions/community_exception.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../utils/api_config.dart';
import '../utils/json_helpers.dart';

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
        final decoded = jsonDecode(response.body);
        final list    = asList(decoded);
        return list.map((j) => CommunityModel.fromJson(j)).toList();

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
        await SharedPrefs.saveCommunityLevel(communityId, level);
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
    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) {
      throw CommunityException('No authentication token available');
    }

    final uri = Uri.parse('$_base/user-communities/change-level/');
    final response = await AuthHttp.post(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "community": communityId,
        "level": newLevel,
      }),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      print('Changed community level to: ${body['level']}');
      await SharedPrefs.saveCommunityLevel(communityId, newLevel);
      return body['level'] as String;
    } else {
      throw CommunityException(
        'Failed to change level: ${response.statusCode} - ${response.body}',
      );
    }
  }


  /// استرجاع مستوى المستخدم في مجتمع معين
  static Future<String> fetchCommunityLevel(int communityId) async {
    // ① جرّب المخزن المحلّى أولاً (يقلّل الاتصالات)
    final cached = await SharedPrefs.getCommunityLevel(communityId);
    if (cached != null) return cached;                     // «null» لا «both»

    // ② اطلب من الـAPI
    final token = await AuthService.getToken();
    final uri   = Uri.parse(
        '$_base/user-communities/level/?community_id=$communityId');
    final resp  = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type':  'application/json',
    });

    if (resp.statusCode == 200) {
      final level = jsonDecode(resp.body)['level'] as String;
      await SharedPrefs.saveCommunityLevel(communityId, level);
      return level;
    } else if (resp.statusCode == 404) {
      throw CommunityException('You are not a member of this community');
    } else {
      throw CommunityException('Failed to fetch level: ${resp.body}');
    }


    // ③ فى حالة حدوث خطأ أعد «both» كخيار أخير
    //return 'both';
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
        final decoded = jsonDecode(response.body);
        final list    = asList(decoded);
        return list.map((j) => CommunityModel.fromJson(j)).toList();

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
  static Future<void> createCommunity(int fieldId, String name, String? imagePath) async {
    final token = await SharedPrefs.getAccessToken();
    if (token == null || token.isEmpty) {
      throw CommunityException("لا يوجد توكن (AccessToken) محفوظ.");
    }
    final uri = Uri.parse("$_base/admin/communities/");
    if (imagePath != null) {
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = "Bearer $token"
        ..fields['field'] = fieldId.toString()
        ..fields['name'] = name;
      final mime = lookupMimeType(imagePath) ?? 'image/jpeg';
      final parts = mime.split('/');
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imagePath,
          contentType: MediaType(parts[0], parts[1]),
        ),
      );
      final response = await AuthHttp.sendMultipartWithAuth(request);
      final responseBody = await response.stream.bytesToString();
      if (response.statusCode != 201) {
        debugPrint('⛔️ Community‑400: $responseBody');
        final decoded = utf8.decode(responseBody.runes.toList());
        try {
          final errorJson = jsonDecode(decoded);
          throw CommunityException(errorJson['error'] ?? 'فشل إنشاء المجتمع');
        } catch (_) {
          throw CommunityException("فشل إنشاء المجتمع: $decoded");
        }
      }
    } else {
      final response = await AuthHttp.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'field': fieldId,
          'name': name,
        }),
      );
      if (response.statusCode != 201) {
        debugPrint('⛔️ Community‑400: ${response.body}');
        final decoded = utf8.decode(response.bodyBytes);
        try {
          final errorJson = jsonDecode(decoded);
          throw CommunityException(errorJson['error'] ?? 'فشل إنشاء المجتمع');
        } catch (_) {
          throw CommunityException("فشل إنشاء المجتمع: $decoded");
        }
      }
    }
  }

  /// تعديل مجتمع (Admin)
  static Future<void> updateCommunity(
      int communityId,
      int fieldId,
      String name,
      String? imagePath, {
        bool clearImage = false, // NEW: Flag to clear the existing image
      }) async {
    final token = await SharedPrefs.getAccessToken();
    if (token == null || token.isEmpty) {
      throw CommunityException("No authentication token available.");
    }

    final uri = Uri.parse("$_base/admin/communities/$communityId/");
    final request = http.MultipartRequest('PUT', uri)
      ..headers['Authorization'] = "Bearer $token"
      ..fields['field'] = fieldId.toString()
      ..fields['name'] = name;

    if (clearImage) {
      request.fields['clear_image'] = 'true'; // NEW: Signal to backend to clear image
    }

    if (imagePath != null) {
      final mime = lookupMimeType(imagePath) ?? 'image/jpeg';
      final parts = mime.split('/');
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imagePath,
          contentType: MediaType(parts[0], parts[1]),
        ),
      );
    }

    final response = await AuthHttp.sendMultipartWithAuth(request);
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      final decoded = utf8.decode(responseBody.runes.toList());
      try {
        final errorJson = jsonDecode(decoded);
        throw CommunityException(errorJson['error'] ?? 'Failed to update community');
      } catch (_) {
        throw CommunityException("Failed to update community: $decoded");
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

    if (response.statusCode != 204 && response.statusCode != 200) {
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
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final list    = asList(decoded);
      return list.map((j) => CommunityModel.fromJson(j)).toList();
    }

    // jeson error
    final decodedErr = utf8.decode(response.bodyBytes);
    try {
      final errJson = jsonDecode(decodedErr);
      throw CommunityException(errJson['error'] ?? 'فشل جلب المجتمعات');
    } catch (_) {
      throw CommunityException('فشل جلب المجتمعات: $decodedErr');
    }
  }
}
