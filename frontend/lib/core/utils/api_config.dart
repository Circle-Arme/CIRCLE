// lib/core/utils/api_config.dart

import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

/// تحوي عناوين السيرفر لكل سيناريو:
const _webHost        = 'http://localhost:8000/api';
const _androidEmuHost = 'http://10.0.2.2:8000/api';
const _iosSimHost     = 'http://127.0.0.1:8000/api';

/// Base URL يتم اختياره تلقائيًا حسب المنصّة:
class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) return _webHost;           // عند flutter run -d chrome
    if (Platform.isAndroid) return _androidEmuHost; // عند المحاكي
    if (Platform.isIOS)     return _iosSimHost;     // عند محاكي iOS
    // لأي جهاز آخر (Windows/macOS/Linux)
    return _webHost;
  }
}
