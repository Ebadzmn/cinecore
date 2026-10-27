import 'dart:async';
import 'dart:io' show Platform, Socket;
import 'package:flutter/foundation.dart';

class ApiConstants {
  static String? _customBaseUrl;
  static String? _resolvedBaseUrl;

  /// Development machine's Local LAN IP address (for physical mobile on same Wi-Fi)
  static const String devLanIp = '10.10.7.39';
  static const int port = 5000;
  static const String apiPath = '/api/v1';

  /// Set custom backend base URL if needed at runtime
  static void setCustomBaseUrl(String url) {
    _customBaseUrl = url;
  }

  /// Automatically tests and resolves the fastest working backend host:
  /// 1. 127.0.0.1 (Desktop, Web, or Physical device with 'adb reverse tcp:5000 tcp:5000')
  /// 2. devLanIp (10.10.7.39 - Physical device on same Wi-Fi)
  /// 3. 10.0.2.2 (Android Studio Emulator)
  static Future<void> autoDetectBaseUrl() async {
    if (kIsWeb) {
      _resolvedBaseUrl = 'http://localhost:$port$apiPath';
      return;
    }

    final candidates = [
      '127.0.0.1',
      devLanIp,
      if (Platform.isAndroid) '10.0.2.2',
    ];

    final completer = Completer<String?>();
    int pending = candidates.length;

    for (final host in candidates) {
      Socket.connect(host, port, timeout: const Duration(milliseconds: 1000)).then((socket) {
        socket.destroy();
        if (!completer.isCompleted) {
          completer.complete(host);
        }
      }).catchError((_) {
        pending--;
        if (pending == 0 && !completer.isCompleted) {
          completer.complete(null);
        }
      });
    }

    final fastestHost = await completer.future.timeout(
      const Duration(milliseconds: 1200),
      onTimeout: () => null,
    );

    if (fastestHost != null) {
      _resolvedBaseUrl = 'http://$fastestHost:$port$apiPath';
      debugPrint('📡 [API AUTO-DETECT] Connected to $fastestHost:$port -> $_resolvedBaseUrl');
    } else {
      // Smart default fallback
      if (Platform.isAndroid) {
        _resolvedBaseUrl = 'http://$devLanIp:$port$apiPath';
      } else {
        _resolvedBaseUrl = 'http://127.0.0.1:$port$apiPath';
      }
      debugPrint('📡 [API AUTO-DETECT] Fallback to $_resolvedBaseUrl');
    }
  }

  /// Automatically resolves localhost, physical device LAN IP, or Android emulator
  static String get baseUrl {
    if (_customBaseUrl != null && _customBaseUrl!.isNotEmpty) {
      return _customBaseUrl!;
    }
    if (_resolvedBaseUrl != null && _resolvedBaseUrl!.isNotEmpty) {
      return _resolvedBaseUrl!;
    }
    if (kIsWeb) {
      return 'http://localhost:$port$apiPath';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://$devLanIp:$port$apiPath';
      }
    } catch (_) {}
    return 'http://127.0.0.1:$port$apiPath';
  }

  static const int connectTimeout = 10000; // 10 seconds
  static const int receiveTimeout = 10000; // 10 seconds

  // Auth & User Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String guestLogin = '/auth/guest';
  static const String guestUpgrade = '/auth/guest/upgrade';
  static const String logout = '/auth/logout';
  static const String authMe = '/auth/me';
  static const String refreshToken = '/auth/refresh-token';
  static const String userProfile = '/users/me';
  
  static const String homeFeed = '/feed/home';
  static const String spotlight = '/feed/spotlight';
  static const String categories = '/feed/categories';
  static const String studios = '/studios';
  
  static const String movies = '/movies';
  static const String genres = '/movies/genres';
  static const String search = '/search';
  static const String trendingKeywords = '/search/trending-keywords';
  static const String watchlist = '/watchlist';
  static const String continueWatching = '/playback/continue-watching';
  static const String playbackHeartbeat = '/playback/heartbeat';
  static const String leaderboard = '/leaderboard';
}
