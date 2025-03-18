import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _baseUrl =
      "https://your-api.com/api"; // Replace with actual API URL

  static Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      // Login success
      return true;
    } else {
      // Login failed
      return false;
    }
  }
}
