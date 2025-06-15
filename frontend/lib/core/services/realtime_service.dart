import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../data/models/rt_event.dart';
import '../utils/api_config.dart';
import 'auth_service.dart';

class RealTimeService {
  static WebSocketChannel? _ch;
  static final _ctrl = StreamController<RTEvent>.broadcast();

  static bool _busy = false;
  static int  _tries = 0;
  static const _max = 5, _base = 1000;

  //──────────────────────── helpers ────────────────────────
  static Uri _uri(String path, String token) {
    final base = Uri.parse(ApiConfig.wsUrl);           // ← سيحمل ws://
    return Uri(
      scheme: base.scheme,
      host:   base.host,
      port:   base.port,
      path:   path,                                    // يبدأ بـ /ws/…
      queryParameters: {'token': token},
    );
  }

  static Future<void> _open(Uri u, String t, Future<void> Function() retry) async {
    print('[WS] connecting to $u');                    // ← سترى ws:// …

    _ch?.sink.close();
    _ch = kIsWeb
        ? WebSocketChannel.connect(u)
        : IOWebSocketChannel.connect(u, headers: {'Authorization': 'Bearer $t'});

    _ch!.stream.listen(
          (raw) {
        _ctrl.add(RTEvent.fromJson(jsonDecode(raw)));
        _tries = 0;
      },
      onDone:  () => _retry(retry),
      onError: (_) => _retry(retry),
    );
  }

  static void _retry(Future<void> Function() retry) async {
    if (_tries >= _max || _busy) return;
    _tries++;
    await Future.delayed(Duration(milliseconds: _base * pow(2, _tries).toInt()));
    await retry();
  }

  //──────────────────────── public API ─────────────────────
  static Stream<RTEvent> stream() => _ctrl.stream;

  static Future<void> connectCommunity(int cid) =>
      _connect('/ws/community/$cid/', () => connectCommunity(cid));

  static Future<void> connectThread(String tid) =>
      _connect('/ws/thread/$tid/', () => connectThread(tid));

  static Future<void> connectAlerts(int uid) =>
      _connect('/ws/alerts/$uid/', () => connectAlerts(uid));

  static Future<void> _connect(String path, Future<void> Function() retry) async {
    if (_busy) return;
    _busy = true;
    try {
      String? tok = await AuthService.getToken() ?? await AuthService.refreshAccessToken();
      if (tok == null) throw Exception('no token');

      await _open(_uri(path, tok), tok, retry);
    } finally {
      _busy = false;
    }
  }

  static void dispose() {
    _ch?.sink.close();
    _ctrl.close();
    _busy = false;
    _tries = 0;
  }
}
