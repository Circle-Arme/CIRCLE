import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/core/utils/shared_prefs.dart';
import 'package:frontend/data/models/chat_room_model.dart';
import '../utils/api_config.dart';

class ChatRoomService {
  // استخدام مسار الأدمن لإنشاء غرف الدردشة
  static String get _adminBase => '${ApiConfig.baseUrl}/admin/chat-rooms';
  //static const String _baseUrl = "http://192.168.1.5:8000/api/admin/chat-rooms";
//http://192.168.1.5:8000
  static Future<void> createChatRoom(int communityId, String name, String type) async {
    final token = await SharedPrefs.getAccessToken();
    if (token == null) throw Exception("التوكن غير متوفر");

    final uri = Uri.parse('$_adminBase/');
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
