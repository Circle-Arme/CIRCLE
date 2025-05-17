import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';   // ← MediaType
import 'package:mime/mime.dart';
import 'package:frontend/core/utils/shared_prefs.dart';
import 'package:frontend/data/models/area_model.dart';
import '../utils/api_config.dart';
import 'auth_http.dart';
import 'auth_service.dart';

class FieldService {
  static String get _fieldsAdminBase => '${ApiConfig.baseUrl}/admin/fields';
  //http://192.168.1.5:8000
  //static const String _baseUrl = "http://192.168.1.5:8000/api/admin/fields";

  static Future<List<AreaModel>> fetchFields() async {
    final token = await SharedPrefs.getAccessToken();
    if (token == null) throw Exception("التوكن غير متوفر");

    final uri = Uri.parse('$_fieldsAdminBase/');
    final response = await http.get(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonData.map((json) => AreaModel.fromJson(json)).toList();
    } else {
      final decoded = utf8.decode(response.bodyBytes);
      try {
        final errorJson = jsonDecode(decoded);
        throw Exception(errorJson['error'] ?? 'فشل جلب المجالات');
      } catch (_) {
        throw Exception("فشل جلب المجالات: $decoded");
      }
    }
  }



  static Future<void> createField(
      String name,
      String description,
      String? imagePath,
      ) async {
    final token = await SharedPrefs.getAccessToken();
    if (token == null) throw Exception("التوكن غير متوفر");

    // إذا لم تُرسل صورة أو كان path فارغاً → استعمل JSON
    if (imagePath == null || imagePath.trim().isEmpty) {
      final resp = await AuthHttp.post(
        Uri.parse('$_fieldsAdminBase/'),
        body: {"name": name, "description": description},
      );
      if (resp.statusCode != 201) {
        debugPrint('⛔️ Field‑400: ${resp.body}');
        throw Exception('فشل إنشاء المجال: ${resp.body}');
      }
      return;
    }

    final uri = Uri.parse('$_fieldsAdminBase/');

    // إن وُجدت صورة نستخدم MultipartRequest
    if (imagePath != null) {
      final req = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['name']        = name
        ..fields['description'] = description;

      final mime  = lookupMimeType(imagePath) ?? 'image/jpeg';
      final parts = mime.split('/');                  // ["image", "png"]

      req.files.add(await http.MultipartFile.fromPath(
        'image',
        imagePath,
        contentType: MediaType(parts[0], parts[1]),
      ));

      final resp = await AuthHttp.sendMultipartWithAuth(req);
      if (resp.statusCode != 201) {
        final body = await resp.stream.bytesToString();
        debugPrint('⛔️ Field‑400: $body');
        throw Exception('فشل إنشاء المجال: $body');
      }
    } else {
      // بدون صورة → JSON عادى
      final resp = await AuthHttp.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type':  'application/json',
        },
        body: jsonEncode({"name": name, "description": description}),
      );

      if (resp.statusCode != 201) {
        debugPrint('⛔️ Field‑400: ${resp.body}');
        throw Exception('فشل إنشاء المجال: ${resp.body}');
      }
    }
  }


  static Future<void> updateField(
      int    fieldId,
      String name,
      String description,
      String? imagePath,
      ) async {

    final token = await SharedPrefs.getAccessToken();
    if (token == null) throw Exception("التوكن غير متوفر");

    final uri = Uri.parse('$_fieldsAdminBase/$fieldId/');   // ← أضف id

    if (imagePath != null) {
      final req = http.MultipartRequest('PUT', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['name']        = name
        ..fields['description'] = description;

      final mime  = lookupMimeType(imagePath) ?? 'image/jpeg';
      final parts = mime.split('/');

      req.files.add(await http.MultipartFile.fromPath(
        'image',
        imagePath,
        contentType: MediaType(parts[0], parts[1]),
      ));

      final resp = await AuthHttp.sendMultipartWithAuth(req);
      if (resp.statusCode != 200) {
        final body = await resp.stream.bytesToString();
        throw Exception('فشل تعديل المجال: $body');
      }
    } else {
      final resp = await AuthHttp.patch(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type':  'application/json',
        },
        body: jsonEncode({"name": name, "description": description}),
      );

      if (resp.statusCode != 200) {
        throw Exception('فشل تعديل المجال: ${resp.body}');
      }
    }
  }


  static Future<void> deleteField(int fieldId) async {
    final token = await SharedPrefs.getAccessToken();
    if (token == null) throw Exception("التوكن غير متوفر");

    final uri = Uri.parse('$_fieldsAdminBase/$fieldId/');   // ← أضف id
    final resp = await http.delete(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (resp.statusCode != 204 && resp.statusCode != 200) {
      throw Exception('فشل حذف المجال: ${resp.body}');
    }
  }

}