import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _baseUrl =
      "https://your-api.com/api"; // استبدل بعنوان الـ API الفعلي

  // تسجيل الدخول
  static Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    return response.statusCode == 200; // نجاح تسجيل الدخول إذا كان 200
  }

  // إنشاء حساب جديد
  static Future<bool> register(
      String fullName, String email, String password) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/register"), // استبدل بالـ API الفعلي
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "full_name": fullName, // تأكد من أن اسم المفتاح متطابق مع الـ API
        "email": email,
        "password": password,
      }),
    );

    return response.statusCode == 201; // نجاح إنشاء الحساب إذا كان 201
  }
}
