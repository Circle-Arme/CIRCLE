import 'package:http/http.dart' as http;
import 'package:frontend/core/utils/shared_prefs.dart';
import 'dart:convert';
import '../utils/api_config.dart';

class UploadService {
  static String get _url => '${ApiConfig.baseUrl}/accounts/profile/upload-avatar/';
  //static const _url = 'http://192.168.1.5:8000/api/accounts/profile/upload-avatar/';
  //http://192.168.1.5:8000

  static Future<String> uploadAvatar(String filePath) async {
    final token = await SharedPrefs.getAccessToken();
    if (token == null) throw Exception('No token');

    // إعداد الطلب كـ MultipartRequest
    final request = http.MultipartRequest('POST', Uri.parse(_url))
      ..headers['Authorization'] = 'Bearer $token';

    // تأكد من اسم الحقل يطابق serializer (avatar)
    final multipartFile =
    await http.MultipartFile.fromPath('avatar', filePath);
    request.files.add(multipartFile);

    // أرسل الطلب وانتظر الاستجابة
    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode == 200) {
      final data = jsonDecode(body) as Map<String, dynamic>;
      return data['avatar'] as String;   // ترجع URL الصورة الجديدة
    }

    throw Exception('Upload failed: $body');
  }
}
