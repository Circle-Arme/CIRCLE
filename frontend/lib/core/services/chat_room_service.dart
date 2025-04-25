import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/core/utils/shared_prefs.dart';
import 'package:frontend/data/models/chat_room_model.dart';

class ChatRoomService {
  // استخدام مسار الأدمن لإنشاء غرف الدردشة
  static const String _baseUrl = "http://10.0.2.2:8000/api/admin/chat-rooms";

  static Future<void> createChatRoom(int communityId, String name, String type) async {
    final token = await SharedPrefs.getAccessToken();
    if (token == null) throw Exception("التوكن غير متوفر");

    final uri = Uri.parse("$_baseUrl/");
    final response = await http.post(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "community": communityId,
        "name": name,
        "type": type, // "general", "advanced", "job_opportunities"
      }),
    );

    if (response.statusCode == 201) {
      return;
    } else {
      final decoded = utf8.decode(response.bodyBytes);
      try {
        final errorJson = jsonDecode(decoded);
        throw Exception(errorJson['error'] ?? 'فشل إنشاء الغرفة');
      } catch (_) {
        throw Exception("فشل إنشاء الغرفة: $decoded");
      }
    }
  }
}
