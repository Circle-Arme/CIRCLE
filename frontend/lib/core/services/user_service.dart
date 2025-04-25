import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/data/models/user_model.dart';

class UserService {
  static Future<UserModel> fetchUser() async {
    final response = await http.get(Uri.parse("http://10.0.2.2:8000/api/me"));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return UserModel.fromJson(jsonData);
    } else {
      throw Exception("فشل في تحميل بيانات المستخدم");
    }
  }
}
