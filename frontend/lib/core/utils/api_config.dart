import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// عدِّل هذا الـ IP فقط عند تغيّره داخل شبكتك
const _lan = '192.168.1.5:8000';

String _http(String host) => 'http://$host/api';
String _ws  (String host) => 'ws://$host';        // <-- لاحِظ ws://

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb)            return _http('localhost:8000');
    if (Platform.isAndroid) return _http(_lan);
    if (Platform.isIOS)     return _http('127.0.0.1:8000');
    return _http('localhost:8000');
  }

  static String get wsUrl {
    if (kIsWeb)            return _ws('localhost:8000');
    if (Platform.isAndroid) return _ws(_lan);
    if (Platform.isIOS)     return _ws('127.0.0.1:8000');
    return _ws('localhost:8000');
  }
}
