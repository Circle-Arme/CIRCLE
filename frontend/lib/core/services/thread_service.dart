import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:frontend/data/models/thread_model.dart';
import 'auth_service.dart';

class ThreadService {
  static const String baseUrl = "http://10.0.2.2:8000/api"; // استبدل الرابط حسب الخادم

  /// جلب قائمة الثريدات بناءً على المجتمع ونوع الثريد (نقاش أو فرص عمل)
  static Future<List<ThreadModel>> fetchThreads(int communityId, {bool isJobOpportunity = false}) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse("$baseUrl/threads?community_id=$communityId&is_job_opportunity=$isJobOpportunity"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ThreadModel.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        throw Exception("المصدر غير موجود (404)");
      } else {
        throw Exception("خطأ في الخادم: ${response.statusCode}");
      }
    } on SocketException {
      throw Exception("لا يوجد اتصال بالإنترنت");
    } catch (e) {
      rethrow;
    }
  }

  /// إنشاء ثريد جديد
  static Future<ThreadModel> createThread(
      int communityId,
      String title,
      String content,
      String classification,
      List<String> tags, {
        bool isJobOpportunity = false,
      }) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse("$baseUrl/threads"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "community_id": communityId,
          "title": title,
          "content": content,
          "classification": classification,
          "tags": tags,
          "is_job_opportunity": isJobOpportunity,
        }),
      );
      if (response.statusCode == 201) {
        return ThreadModel.fromJson(json.decode(response.body));
      } else {
        throw Exception("فشل إنشاء الثريد (Status: ${response.statusCode})");
      }
    } on SocketException {
      throw Exception("لا يوجد اتصال بالإنترنت");
    } catch (e) {
      rethrow;
    }
  }
}
