/// خدمة طلبات HTTP الخاصة بالتنبيهات (Alerts REST API).
///
/// تعتمد على AuthHttp لتنفيذ GET/PATCH مع تضمين التوكين.
/// ---------------------------------------------------------------------------
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:frontend/core/services/auth_http.dart';
import 'package:frontend/core/utils/api_config.dart';
import 'package:frontend/data/models/alert_model.dart';

class AlertService {
  AlertService._(); // منع الإنشاء

  static final Uri _baseUri =
  Uri.parse('${ApiConfig.baseUrl}/alerts/'); // ‎…/alerts/

  /// جلب قائمة التنبيهات.
  /// [unreadOnly] = true ⇒ جلب غير المقروءة فقط.
  static Future<List<AlertModel>> fetchAlerts({bool unreadOnly = false}) async {
    final uri = unreadOnly
        ? _baseUri.replace(queryParameters: {'unread': 'true'})
        : _baseUri;

    final http.Response res = await AuthHttp.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to fetch alerts • HTTP ${res.statusCode}');
    }

    final decoded = json.decode(utf8.decode(res.bodyBytes));
    final List<dynamic> list = (decoded is Map && decoded.containsKey('results'))
        ? decoded['results'] as List<dynamic>
        : decoded as List<dynamic>;

    return list
        .map<AlertModel>((j) => AlertModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  /// وضع تنبيه محدّد كمقروء.
  static Future<void> markRead(int id) async {
    final res =
    await AuthHttp.patch(_baseUri.resolve('$id/mark_read/')); // ‎…/42/mark_read/
    if (res.statusCode != 204) {
      throw Exception('Failed to mark alert as read • HTTP ${res.statusCode}');
    }
  }

  /// وضع جميع التنبيهات كمقروءة.
  static Future<void> markAllRead() async {
    final res =
    await AuthHttp.patch(_baseUri.resolve('mark_all_read/')); // ‎…/mark_all_read/
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception(
          'Failed to mark all alerts as read • HTTP ${res.statusCode}');
    }
  }
}
