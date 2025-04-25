// lib/core/services/thread_service.dart

import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/core/services/auth_service.dart';
import 'package:frontend/core/services/auth_http.dart';
import 'package:frontend/data/models/thread_model.dart';

class ThreadService {
  static const String baseUrl = "http://10.0.2.2:8000/api";

  /// جلب قائمة الثريدات
  static Future<List<ThreadModel>> fetchThreads(
      int communityId, {
        bool isJobOpportunity = false,
      }) async {
    final url = Uri.parse(
      "$baseUrl/threads/?community_id=$communityId&is_job_opportunity=$isJobOpportunity",
    );
    final res = await AuthHttp.get(url);
    if (res.statusCode != 200) {
      throw Exception("خطأ في الخادم: ${res.statusCode}");
    }
    final List<dynamic> data = json.decode(utf8.decode(res.bodyBytes));
    return data.map((j) => ThreadModel.fromJson(j)).toList();
  }

  /// جلب ثريد واحد بالتفاصيل (مع الشجرة)
  static Future<ThreadModel> getThreadById(String threadId) async {
    final url = Uri.parse("$baseUrl/threads/$threadId/");
    final res = await AuthHttp.get(url);
    if (res.statusCode != 200) {
      throw Exception("فشل جلب الثريد");
    }
    return ThreadModel.fromJson(json.decode(utf8.decode(res.bodyBytes)));
  }

  /// إنشاء ثريد جديد (مع مرفق إن وجد)
  static Future<ThreadModel> createThread(
      int communityId,
      String title,
      String details,
      String classification,
      List<String> tags, {
        PlatformFile? file,
        bool isJobOpportunity = false,
        String? jobType,
        String? location,
        String? salary,
      }) async {
    String? token = await AuthService.getToken();
    if (token == null) throw Exception("No valid token found");

    // جلب chat_room المناسب
    final crm = Uri.parse("$baseUrl/chat-rooms/?community_id=$communityId");
    final cr = await AuthHttp.get(crm);
    if (cr.statusCode != 200) throw Exception("فشل جلب ChatRoom");
    final rooms = json.decode(utf8.decode(cr.bodyBytes)) as List<dynamic>;
    if (rooms.isEmpty) throw Exception("لا توجد غرف متاحة لهذا المجتمع");
    final roomId = rooms.first['id'];

    // بناء الطلب متعدد الأجزاء
    var req = http.MultipartRequest('POST', Uri.parse("$baseUrl/threads/"));
    req.headers['Authorization'] = "Bearer $token";
    req.fields
      ..['chat_room'] = roomId.toString()
      ..['title'] = title
      ..['details'] = details
      ..['classification'] = classification
      ..['tags'] = json.encode(tags)
      ..['is_job_opportunity'] = isJobOpportunity.toString();
    if (isJobOpportunity) {
      if (jobType != null) req.fields['job_type'] = jobType;
      if (location != null) req.fields['location'] = location;
      if (salary != null) req.fields['salary'] = salary;
    }
    if (file != null) {
      req.files.add(
        await http.MultipartFile.fromPath('file_attachment', file.path!),
      );
    }

    var streamed = await req.send();
    var resp = await http.Response.fromStream(streamed);
    if (resp.statusCode == 401) {
      token = await AuthService.refreshAccessToken();
      req.headers['Authorization'] = "Bearer $token";
      streamed = await req.send();
      resp = await http.Response.fromStream(streamed);
    }
    if (resp.statusCode != 201) {
      throw Exception("فشل إنشاء الثريد: ${resp.statusCode}");
    }
    return ThreadModel.fromJson(json.decode(utf8.decode(resp.bodyBytes)));
  }

  /// إنشاء رد (مع دعم الملف والرد المتداخل)
  static Future<void> createReply(
      String threadId,
      String replyText, {
        PlatformFile? file,
        String? parentReplyId,
      }) async {
    String? token = await AuthService.getToken();
    if (token == null) throw Exception("No valid token found");

    if (file == null) {
      final res = await AuthHttp.post(
        Uri.parse("$baseUrl/replies/"),
        body: {
          "thread": threadId,
          "reply_text": replyText,
          if (parentReplyId != null) "parent_reply": parentReplyId,
        },
      );
      if (res.statusCode == 401) {
        token = await AuthService.refreshAccessToken();
        await AuthHttp.post(
          Uri.parse("$baseUrl/replies/"),
          body: {
            "thread": threadId,
            "reply_text": replyText,
            if (parentReplyId != null) "parent_reply": parentReplyId,
          },
        );
      }
      if (res.statusCode != 201) {
        throw Exception("فشل إضافة الرد: ${res.statusCode}");
      }
      return;
    }

    var req = http.MultipartRequest('POST', Uri.parse("$baseUrl/replies/"));
    req.headers['Authorization'] = "Bearer $token";
    req.fields
      ..['thread'] = threadId
      ..['reply_text'] = replyText;
    if (parentReplyId != null) req.fields['parent_reply'] = parentReplyId;
    req.files.add(await http.MultipartFile.fromPath('file', file.path!));

    var streamed = await req.send();
    var resp = await http.Response.fromStream(streamed);
    if (resp.statusCode == 401) {
      token = await AuthService.refreshAccessToken();
      req.headers['Authorization'] = "Bearer $token";
      streamed = await req.send();
      resp = await http.Response.fromStream(streamed);
    }
    if (resp.statusCode != 201) {
      throw Exception("فشل إضافة الرد بالمرفق: ${resp.statusCode}");
    }
  }

  /// تبديل الإعجاب على الثريد
  static Future<void> toggleLike(String threadId) async {
    final url = Uri.parse("$baseUrl/likes/");
    final res = await AuthHttp.post(
      url,
      body: {"thread": threadId},
    );
    if (res.statusCode != 201 && res.statusCode != 204) {
      throw Exception("فشل تعديل الإعجاب: ${res.statusCode} ${res.body}");
    }
  }

  /// تبديل الإعجاب على ردّ
  static Future<void> toggleReplyLike(String replyId) async {
    final url = Uri.parse("$baseUrl/likes/");
    final res = await AuthHttp.post(
      url,
      body: {"reply": replyId},
    );
    if (res.statusCode != 201 && res.statusCode != 204) {
      throw Exception("فشل تعديل الإعجاب على الرد: ${res.statusCode} ${res.body}");
    }
  }
}
