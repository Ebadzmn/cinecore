import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class ApiConstants {
  static String? _customBaseUrl;

  /// Set custom backend base URL if needed at runtime
  static void setCustomBaseUrl(String url) {
    _customBaseUrl = url;
  }

  /// Automatically resolves localhost, Android emulator (10.0.2.2), or custom host
  static String get baseUrl {
    if (_customBaseUrl != null && _customBaseUrl!.isNotEmpty) {
      return _customBaseUrl!;
    }
    if (kIsWeb) {
      return 'http://localhost:5000/api/v1';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:5000/api/v1';
      }
    } catch (_) {}
    return 'http://localhost:5000/api/v1';
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
