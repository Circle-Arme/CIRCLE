import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/data/models/area_model.dart';
import '../utils/api_config.dart';

class AreaService {
  static Future<List<AreaModel>> fetchAreas() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/fields/'),
      //Uri.parse("http://192.168.1.5:8000/api/fields/"),
    );

    if (response.statusCode == 200) {
      final List jsonList = jsonDecode(response.body);
      return jsonList.map((json) => AreaModel.fromJson(json)).toList();
    } else {
      throw Exception("فشل في تحميل المجالات");
    }
  }
}
