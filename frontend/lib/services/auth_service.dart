import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _baseUrl = "http://10.0.2.2:8000/api/accounts"; // api from backend

  // login
  static Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/login/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    return response.statusCode == 200; // 200 login is successful
  }

  // create account
  static Future<bool> register(
    String fullName,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/register/"), // api from backend
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "full_name": fullName, // Make sure the key name matches the API
        "email": email,
        "password": password,
      }),
    );

    return response.statusCode == 201; // 201 registration is successful
  }
}
