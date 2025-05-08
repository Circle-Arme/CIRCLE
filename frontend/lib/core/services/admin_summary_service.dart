import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:frontend/core/utils/shared_prefs.dart';
import '../utils/api_config.dart';

/// نموذج مبسّط للإحصاءات
class SummaryStats {
  final int totalUsers;
  final int totalOrganizations;
  final int totalAdmins;
  final int totalFields;
  final int totalCommunities;
  final int totalThreads;
  final int totalReplies;

  SummaryStats.fromJson(Map<String, dynamic> j)
      : totalUsers         = j['total_users']        ?? 0,
        totalOrganizations = j['total_organizations']?? 0,
        totalAdmins        = j['total_admins']       ?? 0,
        totalFields        = j['total_fields']       ?? 0,
        totalCommunities   = j['total_communities']  ?? 0,
        totalThreads       = j['total_threads']      ?? 0,
        totalReplies       = j['total_replies']      ?? 0;
}

/// نموذج لعنصر “أحدث عملية”
class RecentAction {
  final String type;   // user / community / thread
  final int    id;
  final String title;  // email أو name أو title
  final DateTime when;

  RecentAction.fromJson(Map<String, dynamic> j)
      : type  = j['type'],
        id    = j['id'],
        title = (j['email'] ?? j['name'] ?? j['title'] ?? '').toString(),
        when  = DateTime.parse(j['when']);
}

/// حزمة الملخّص الكاملة
class SummaryData {
  final SummaryStats stats;
  final List<RecentAction> recent;
  SummaryData({required this.stats, required this.recent});
}

class AdminSummaryService {
  static String get _baseUrl => ApiConfig.baseUrl;
  static Uri get _summaryUri => Uri.parse('$_baseUrl/admin/summary/');
  //static const _url = 'http://192.168.1.5:8000/api/admin/summary/';
  //http://192.168.1.5:8000

  static Future<SummaryData> fetchSummary() async {
    final token = await SharedPrefs.getAccessToken();
    if (token == null) throw Exception('No access token');

    final res = await http.get(
      _summaryUri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type' : 'application/json',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load summary: ${res.statusCode}');
    }

    final Map<String, dynamic> json = jsonDecode(utf8.decode(res.bodyBytes));
    final stats  = SummaryStats.fromJson(json['stats'] ?? {});
    final recent = (json['recent'] as List<dynamic>? ?? [])
        .map((e) => RecentAction.fromJson(e))
        .toList();
    return SummaryData(stats: stats, recent: recent);
  }
}
