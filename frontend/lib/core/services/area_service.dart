import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/data/models/area_model.dart';

class AreaService {
  static Future<List<AreaModel>> fetchAreas() async {
    final response = await http.get(
      Uri.parse("http://10.0.2.2:8000/api/fields/"), // أو IP جهازك
    );

    if (response.statusCode == 200) {
      final List jsonList = jsonDecode(response.body);
      return jsonList.map((json) => AreaModel.fromJson(json)).toList();
    } else {
      throw Exception("فشل في تحميل المجالات");
    }
  }
}
