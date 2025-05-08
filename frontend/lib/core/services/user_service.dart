import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/data/models/user_model.dart';
import '../utils/api_config.dart';

class UserService {
  static Future<UserModel> fetchUser() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/me');
    final response = await http.get(uri);
    //final response = await http.get(Uri.parse("http://192.168.1.5:8000/api/me"));
    //http://192.168.1.5:8000

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return UserModel.fromJson(jsonData);
    } else {
      throw Exception("فشل في تحميل بيانات المستخدم");
    }
  }
}
