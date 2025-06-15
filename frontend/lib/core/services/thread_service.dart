import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/core/services/auth_service.dart';
import 'package:frontend/core/services/auth_http.dart';
import 'package:frontend/data/models/thread_model.dart';
import '../utils/api_config.dart';
import '../utils/json_helpers.dart';

class ThreadService {
  static String get _base => ApiConfig.baseUrl;

  /// جلب قائمة الثريدات
  static Future<List<ThreadModel>> fetchThreads(
      int communityId, {
        required String roomType,
        bool isJobOpportunity = false,
      }) async {
    final uri = Uri.parse(
        '$_base/threads/?community_id=$communityId&room_type=$roomType&is_job_opportunity=$isJobOpportunity');
    final res = await AuthHttp.get(uri);
    if (res.statusCode != 200) {
      throw Exception("خطأ في الخادم: ${res.statusCode}");
    }
    final decoded = json.decode(utf8.decode(res.bodyBytes));
    final list    = asList(decoded);               // ← هنا

    return list.map((j) => ThreadModel.fromJson(j)).toList();
  }

  /// جلب ثريد واحد بالتفاصيل (مع الشجرة)
  static Future<ThreadModel> getThreadById(String threadId) async {
    final uri = Uri.parse("$_base/threads/$threadId/");
    final res = await AuthHttp.get(uri);
    if (res.statusCode != 200) {
      throw Exception("فشل جلب الثريد");
    }
    return ThreadModel.fromJson(json.decode(utf8.decode(res.bodyBytes)));
  }

  /// إنشاء ثريد جديد (مع مرفق إن وجد)
  static Future<ThreadModel> createThread(
      int communityId,
      String roomType,
      String title,
      String details,
      String classification,
      List<String> tags, {
        PlatformFile? file,
        bool isJobOpportunity = false,
        String? jobType,
        String? location,
        String? salary,
        String? jobLink,
        String? jobLinkType,
      }) async {
    String? token = await AuthService.getToken();
    if (token == null) throw Exception("No valid token found");

    // جلب chat_room المناسب
    final crm = Uri.parse("$_base/chat-rooms/?community_id=$communityId&type=$roomType");
    final cr = await AuthHttp.get(crm);
    if (cr.statusCode != 200) throw Exception("فشل جلب ChatRoom");
    final decodedRooms = json.decode(utf8.decode(cr.bodyBytes));
    final rooms        = asList(decodedRooms);       // ← بدلاً من cast مباشر
    if (rooms.isEmpty) throw Exception("لا توجد غرف متاحة لهذا المجتمع");
    final roomId = rooms.first['id'];


    // بناء الطلب متعدد الأجزاء
    var req = http.MultipartRequest('POST', Uri.parse("$_base/threads/"));
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
      if (jobLink != null) req.fields['job_link'] = jobLink;
      if (jobLinkType != null) req.fields['job_link_type'] = jobLinkType;
    }
    if (file != null) {
      req.files.add(await http.MultipartFile.fromPath('file_attachment', file.path!));
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
      throw Exception("فشل إنشاء الثريد: ${resp.statusCode} ${resp.body}");
    }
    return ThreadModel.fromJson(json.decode(utf8.decode(resp.bodyBytes)));
  }

  static Future<void> deleteThread(int threadId) async {
    final uri = Uri.parse('$_base/threads/$threadId/');
    final res = await AuthHttp.delete(uri);
    if (res.statusCode != 204) {
      throw Exception("خطأ في الحذف: ${res.statusCode}");
    }
  }

  /// تعديل ثريد (مع دعم تحديث الملف)
  static Future<ThreadModel> updateThread(
      int threadId, {
        String? title,
        String? details,
        String? classification,
        List<String>? tags,
        PlatformFile? file,
        bool isJobOpportunity = false,
        String? jobType,
        String? location,
        String? salary,
        String? jobLink,
        String? jobLinkType,
      }) async {
    String? token = await AuthService.getToken();
    if (token == null) throw Exception("No valid token found");

    var req = http.MultipartRequest('PATCH', Uri.parse('$_base/threads/$threadId/'));
    req.headers['Authorization'] = "Bearer $token";

    if (title != null) req.fields['title'] = title;
    if (details != null) req.fields['details'] = details;
    if (classification != null) req.fields['classification'] = classification;
    if (tags != null) req.fields['tags'] = json.encode(tags);
    if (jobType != null) req.fields['job_type'] = jobType;
    if (location != null) req.fields['location'] = location;
    if (salary != null) req.fields['salary'] = salary;
    if (jobLink != null) req.fields['job_link'] = jobLink;
    if (jobLinkType != null) req.fields['job_link_type'] = jobLinkType;
    req.fields['is_job_opportunity'] = isJobOpportunity.toString();

    if (file != null) {
      req.files.add(await http.MultipartFile.fromPath('file_attachment', file.path!));
    }

    var streamed = await req.send();
    var resp = await http.Response.fromStream(streamed);
    if (resp.statusCode == 401) {
      token = await AuthService.refreshAccessToken();
      req.headers['Authorization'] = "Bearer $token";
      streamed = await req.send();
      resp = await http.Response.fromStream(streamed);
    }
    if (resp.statusCode != 200) {
      throw Exception("خطأ في التعديل: ${resp.statusCode} ${resp.body}");
    }

    final data = json.decode(utf8.decode(resp.bodyBytes));
    return ThreadModel.fromJson(data);
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
        Uri.parse("$_base/replies/"),
        body: {
          "thread": threadId,
          "reply_text": replyText,
          if (parentReplyId != null) "parent_reply": parentReplyId,
        },
      );
      if (res.statusCode == 401) {
        token = await AuthService.refreshAccessToken();
        await AuthHttp.post(
          Uri.parse("$_base/replies/"),
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

    var req = http.MultipartRequest('POST', Uri.parse("$_base/replies/"));
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
    final uri = Uri.parse("$_base/likes/");
    final res = await AuthHttp.post(
      uri,
      body: {"thread": threadId},
    );
    if (res.statusCode != 201 && res.statusCode != 204) {
      throw Exception("فشل تعديل الإعجاب: ${res.statusCode} ${res.body}");
    }
  }

  /// تبديل الإعجاب على ردّ
  static Future<void> toggleReplyLike(String replyId) async {
    final uri = Uri.parse("$_base/likes/");
    final res = await AuthHttp.post(
      uri,
      body: {"reply": replyId},
    );
    if (res.statusCode != 201 && res.statusCode != 204) {
      throw Exception("فشل تعديل الإعجاب على الرد: ${res.statusCode} ${res.body}");
    }
  }
}