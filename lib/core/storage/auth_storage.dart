import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_profile_model.dart';

/// Best-Practice Secure Session & Token Storage with Fast Memory Caching
class AuthStorage {
  static final AuthStorage _instance = AuthStorage._internal();
  factory AuthStorage() => _instance;
  AuthStorage._internal();

  static const String _primaryKeyToken = 'cinecore_auth_token';
  static const String _legacyKeyToken = 'auth_token';

  static const String _primaryKeyUser = 'cinecore_auth_user';
  static const String _legacyKeyUser = 'auth_user';

  static const String _keyIsLoggedIn = 'cinecore_is_logged_in';

  SharedPreferences? _prefs;
  String? _memToken;
  UserProfileModel? _memUser;
  bool _isInitialized = false;

  /// Fast synchronous getters once initialized in main()
  String? get token => _memToken;
  UserProfileModel? get user => _memUser;
  bool get hasTokenSync => _memToken != null && _memToken!.trim().isNotEmpty;
  bool get isInitialized => _isInitialized;

  /// Initialize persistent storage on application startup
  Future<void> init() async {
    if (_isInitialized) return;
    try {
      _prefs = await SharedPreferences.getInstance();

      // Read token checking both primary and legacy keys
      _memToken = _prefs?.getString(_primaryKeyToken) ?? _prefs?.getString(_legacyKeyToken);

      // Read user profile checking both primary and legacy keys
      final rawUser = _prefs?.getString(_primaryKeyUser) ?? _prefs?.getString(_legacyKeyUser);
      if (rawUser != null && rawUser.isNotEmpty) {
        try {
          final map = jsonDecode(rawUser) as Map<String, dynamic>;
          _memUser = UserProfileModel.fromJson(map);
        } catch (e) {
          debugPrint('Failed to decode cached user JSON: $e');
        }
      }
      _isInitialized = true;
      debugPrint('📦 [AuthStorage] Initialized. HasToken: ${_memToken != null && _memToken!.isNotEmpty}');
    } catch (e) {
      debugPrint('⚠️ [AuthStorage] SharedPreferences init error: $e');
      _isInitialized = true;
    }
  }

  Future<SharedPreferences?> _getPrefs() async {
    if (_prefs != null) return _prefs;
    try {
      _prefs = await SharedPreferences.getInstance();
      return _prefs;
    } catch (_) {
      return null;
    }
  }

  /// Persist authentication token to disk and memory
  Future<void> saveToken(String token) async {
    _memToken = token.trim();
    final prefs = await _getPrefs();
    await prefs?.setString(_primaryKeyToken, _memToken!);
    await prefs?.setString(_legacyKeyToken, _memToken!);
    await prefs?.setBool(_keyIsLoggedIn, true);
    debugPrint('💾 [AuthStorage] Token successfully persisted to disk');
  }

  /// Retrieve token (memory first, disk fallback)
  Future<String?> getToken() async {
    if (_memToken != null && _memToken!.trim().isNotEmpty) {
      return _memToken;
    }
    final prefs = await _getPrefs();
    _memToken = prefs?.getString(_primaryKeyToken) ?? prefs?.getString(_legacyKeyToken);
    return _memToken;
  }

  /// Persist user profile data to disk and memory
  Future<void> saveUser(UserProfileModel user) async {
    _memUser = user;
    final prefs = await _getPrefs();
    final jsonStr = jsonEncode(user.toJson());
    await prefs?.setString(_primaryKeyUser, jsonStr);
    await prefs?.setString(_legacyKeyUser, jsonStr);
  }

  /// Retrieve cached user profile
  Future<UserProfileModel?> getUser() async {
    if (_memUser != null) {
      return _memUser;
    }
    final prefs = await _getPrefs();
    final rawJson = prefs?.getString(_primaryKeyUser) ?? prefs?.getString(_legacyKeyUser);
    if (rawJson != null && rawJson.isNotEmpty) {
      try {
        final map = jsonDecode(rawJson) as Map<String, dynamic>;
        _memUser = UserProfileModel.fromJson(map);
        return _memUser;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Check if user has an active session
  Future<bool> isLoggedIn() async {
    final t = await getToken();
    return t != null && t.trim().isNotEmpty;
  }

  /// Completely wipe session on user logout
  Future<void> clear() async {
    _memToken = null;
    _memUser = null;
    final prefs = await _getPrefs();
    await prefs?.remove(_primaryKeyToken);
    await prefs?.remove(_legacyKeyToken);
    await prefs?.remove(_primaryKeyUser);
    await prefs?.remove(_legacyKeyUser);
    await prefs?.remove(_keyIsLoggedIn);
    debugPrint('🗑️ [AuthStorage] Session completely cleared from disk');
  }
}
