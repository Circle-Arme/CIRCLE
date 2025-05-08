// lib/core/services/auth_http.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/core/services/auth_service.dart';

class AuthHttp {
  /// GET مع هيدر Authorization وإعادة محاولة عند 401
  static Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    String? token = await AuthService.getToken();
    if (token == null) throw Exception("🔐 لا يوجد توكن.");

    var response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 401) {
      // توكن منتهي، نحاول تحديثه
      token = await AuthService.refreshAccessToken();
      response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
        },
      );
    }

    return response;

  }

  /// POST مع Content-Type: application/json
  /// يحوّل الـ body تلقائيًا إلى JSON String إذا لم يكن String
  static Future<http.Response> post(
      Uri url, {
        Map<String, String>? headers,
        dynamic body,
      }) async {
    String? token = await AuthService.getToken();
    if (token == null) throw Exception("🔐 لا يوجد توكن.");

    // جمع الهيدرز الأساسي مع أي هيدرز إضافية
    final fullHeaders = {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
      ...?headers,
    };

    // تحويل body إلى JSON String إذا لم يكن String
    String? encodedBody;
    if (body == null) {
      encodedBody = null;
    } else if (body is String) {
      encodedBody = body;
    } else {
      encodedBody = jsonEncode(body);
    }

    var response = await http.post(
      url,
      headers: fullHeaders,
      body: encodedBody,
    );

    if (response.statusCode == 401) {
      // توكن منتهي، نجرب تحديثه ثم نعيد الإرسال
      token = await AuthService.refreshAccessToken();
      final retryHeaders = {
        ...fullHeaders,
        "Authorization": "Bearer $token",
      };
      response = await http.post(
        url,
        headers: retryHeaders,
        body: encodedBody,
      );
    }

    return response;
  }

// لاحقًا يمكنك إضافة put, delete بنفس النمط
}
