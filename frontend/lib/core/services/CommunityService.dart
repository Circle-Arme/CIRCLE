import 'dart:convert';
import 'package:http/http.dart' as http;
import '../exceptions/community_exception.dart';
import '../../data/models/community_model.dart';
import 'auth_service.dart';

class CommunityService {
  static const String _baseUrl = "http://10.0.2.2:8000/api"; // ← تم التعديل هنا

  // 🔹 جلب الكميونتي حسب المجال
  static Future<List<CommunityModel>> fetchCommunities(String areaId) async {
    try {
      final response = await http.get(Uri.parse("$_baseUrl/fields/$areaId/communities/"));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => CommunityModel.fromJson(json)).toList();
      } else {
        throw CommunityException('Failed to fetch communities');
      }
    } catch (e) {
      throw CommunityException('Error fetching communities: ${e.toString()}');
    }
  }

  // 🔹 الانضمام لمجتمع
  static Future<void> joinCommunity(int communityId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse("$_baseUrl/user-communities/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"community": communityId}),
      );
      if (response.statusCode != 201) {
        throw CommunityException('Failed to join community');
      }
    } catch (e) {
      throw CommunityException('Error joining community: ${e.toString()}');
    }
  }

  // 🔹 جلب المجتمعات التي انضم إليها المستخدم الحالي
  static Future<List<CommunityModel>> fetchMyCommunities() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse("$_baseUrl/user-communities/my/"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => CommunityModel.fromJson(json)).toList();
      } else {
        throw CommunityException('Failed to fetch joined communities');
      }
    } catch (e) {
      throw CommunityException('Error fetching joined communities: ${e.toString()}');
    }
  }

}
