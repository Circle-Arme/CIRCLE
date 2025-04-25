import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/core/utils/shared_prefs.dart';
import 'package:frontend/data/models/area_model.dart';

class FieldService {
  static const String _baseUrl = "http://10.0.2.2:8000/api/admin/fields";


  static Future<List<AreaModel>> fetchFields() async {
    final token = await SharedPrefs.getAccessToken();
    if (token == null) throw Exception("التوكن غير متوفر");

    final response = await http.get(
      Uri.parse("$_baseUrl/"),
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

  static Future<void> createField(String name, String description, String? image) async {
    final token = await SharedPrefs.getAccessToken();
    if (token == null) throw Exception("التوكن غير متوفر");

    final response = await http.post(
      Uri.parse("$_baseUrl/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "name": name,
        "description": description,
        "image": image,
      }),
    );

    if (response.statusCode == 201) {
      return;
    } else {
      final decoded = utf8.decode(response.bodyBytes);
      try {
        final errorJson = jsonDecode(decoded);
        throw Exception(errorJson['error'] ?? 'فشل إنشاء المجال');
      } catch (_) {
        throw Exception("فشل إنشاء المجال: $decoded");
      }
    }
  }

  static Future<void> updateField(int fieldId, String name, String description, String? image) async {
    final token = await SharedPrefs.getAccessToken();
    if (token == null) throw Exception("التوكن غير متوفر");

    final response = await http.put(
      Uri.parse("$_baseUrl/$fieldId/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "name": name,
        "description": description,
        "image": image,
      }),
    );

    if (response.statusCode == 200) {
      return;
    } else {
      final decoded = utf8.decode(response.bodyBytes);
      try {
        final errorJson = jsonDecode(decoded);
        throw Exception(errorJson['error'] ?? 'فشل تعديل المجال');
      } catch (_) {
        throw Exception("فشل تعديل المجال: $decoded");
      }
    }
  }

  static Future<void> deleteField(int fieldId) async {
    final token = await SharedPrefs.getAccessToken();
    if (token == null) throw Exception("التوكن غير متوفر");

    final response = await http.delete(
      Uri.parse("$_baseUrl/$fieldId/"),
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
        throw Exception(errorJson['error'] ?? 'فشل حذف المجال');
      } catch (_) {
        throw Exception("فشل حذف المجال: $decoded");
      }
    }
  }
}