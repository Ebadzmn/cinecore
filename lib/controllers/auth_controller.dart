import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../core/network/network_caller.dart';
import '../core/storage/auth_storage.dart';
import '../data/models/user_profile_model.dart';
import '../data/services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final AuthStorage _authStorage = AuthStorage();

  final Rx<UserProfileModel> userProfile = const UserProfileModel(
    id: '',
    email: '',
    displayName: 'Guest Cinephile',
    avatarUrl: '',
    isGuest: true,
    status: 'ACTIVE',
  ).obs;

  final RxString authToken = ''.obs;
  final RxBool isLoggedIn = false.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Hook automatic logout on expired 401 responses
    NetworkCaller.onUnauthorized = () {
      if (isLoggedIn.value && authToken.value.isNotEmpty) {
        debugPrint('⚠️ [AuthController] 401 Unauthorized received - Session expired');
        logout();
      }
    };
    restoreSession();
  }

  /// Automatically restore saved credentials & user session on app launch
  Future<void> restoreSession() async {
    try {
      final savedToken = await _authStorage.getToken();
      final savedUser = await _authStorage.getUser();

      if (savedToken != null && savedToken.trim().isNotEmpty) {
        final cleanToken = savedToken.trim();
        authToken.value = cleanToken;
        isLoggedIn.value = true;
        NetworkCaller().setAuthToken(cleanToken);
        ApiClient().setAuthToken(cleanToken);

        if (savedUser != null) {
          userProfile.value = savedUser;
        }

        debugPrint('🔑 [AuthController] Active session restored for: ${userProfile.value.displayName} (${userProfile.value.email})');

        // Verify session in background without locking UI or kicking user out on bad network
        _verifySessionInBackground();
      } else {
        debugPrint('ℹ️ [AuthController] No existing login session found');
      }
    } catch (e) {
      debugPrint('⚠️ [AuthController] Error restoring session: $e');
    }
  }

  /// Verifies token validity with backend in the background
  void _verifySessionInBackground() async {
    try {
      final freshProfile = await _authService.getCurrentUser();
      userProfile.value = freshProfile;
      await _authStorage.saveUser(freshProfile);
      debugPrint('✅ [AuthController] Background session verified and profile refreshed');
    } on UnauthorizedException {
      debugPrint('❌ [AuthController] Token has expired on server. Logging out.');
      await logout();
    } on ForbiddenException {
      debugPrint('⛔ [AuthController] User account is blocked on server. Logging out.');
      await logout();
    } catch (e) {
      // Network timeout / connection error / server restart:
      // DO NOT logout! Keep the user logged in with cached data.
      debugPrint('📡 [AuthController] Background session check skipped due to network: $e');
    }
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final authResponse = await _authService.login(
        email: email,
        password: password,
      );

      final token = authResponse.token.trim();
      authToken.value = token;
      userProfile.value = authResponse.user;
      isLoggedIn.value = true;

      NetworkCaller().setAuthToken(token);
      ApiClient().setAuthToken(token);

      // Persist token & profile to storage
      await _authStorage.saveToken(token);
      await _authStorage.saveUser(authResponse.user);

      debugPrint('✅ [AuthController] Successfully logged in & saved session for: ${authResponse.user.email}');
      return true;
    } on AppException catch (e) {
      errorMessage.value = e.message;
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to login: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Register a new account
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final authResponse = await _authService.register(
        name: name,
        email: email,
        password: password,
      );

      final token = authResponse.token.trim();
      authToken.value = token;
      userProfile.value = authResponse.user;
      isLoggedIn.value = true;

      NetworkCaller().setAuthToken(token);
      ApiClient().setAuthToken(token);

      // Persist token & profile to storage
      await _authStorage.saveToken(token);
      await _authStorage.saveUser(authResponse.user);

      debugPrint('✅ [AuthController] Successfully registered & saved session for: ${authResponse.user.email}');
      return true;
    } on AppException catch (e) {
      errorMessage.value = e.message;
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to create account: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Guest session login
  Future<void> loginAsGuest({String? deviceId, String? displayName}) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final authResponse = await _authService.guestLogin(
        deviceId: deviceId,
        displayName: displayName,
      );

      final token = authResponse.token.trim();
      authToken.value = token;
      userProfile.value = authResponse.user;
      isLoggedIn.value = true;

      NetworkCaller().setAuthToken(token);
      ApiClient().setAuthToken(token);

      await _authStorage.saveToken(token);
      await _authStorage.saveUser(authResponse.user);
    } catch (e) {
      // Fallback offline guest if network unreachable
      userProfile.value = const UserProfileModel(
        id: 'guest_local',
        email: '',
        displayName: 'Guest Cinephile',
        avatarUrl: '',
        isGuest: true,
        status: 'ACTIVE',
      );
      isLoggedIn.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  /// Upgrade guest session to permanent account
  Future<bool> upgradeGuest({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final authResponse = await _authService.upgradeGuest(
        name: name,
        email: email,
        password: password,
      );

      final token = authResponse.token.trim();
      authToken.value = token;
      userProfile.value = authResponse.user;
      isLoggedIn.value = true;

      NetworkCaller().setAuthToken(token);
      ApiClient().setAuthToken(token);

      await _authStorage.saveToken(token);
      await _authStorage.saveUser(authResponse.user);

      return true;
    } on AppException catch (e) {
      errorMessage.value = e.message;
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to upgrade account: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Reload user profile from backend
  Future<void> loadUserProfile() async {
    try {
      isLoading.value = true;
      final profile = await _authService.getCurrentUser();
      userProfile.value = profile;
      await _authStorage.saveUser(profile);
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  /// Update user profile
  Future<bool> updateProfile({String? displayName, String? avatarUrl}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final updated = await _authService.updateProfile(
        displayName: displayName,
        avatarUrl: avatarUrl,
      );
      userProfile.value = updated;
      await _authStorage.saveUser(updated);
      return true;
    } on AppException catch (e) {
      errorMessage.value = e.message;
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to update profile: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Sign out current user and clear stored token
  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (_) {}

    authToken.value = '';
    isLoggedIn.value = false;
    userProfile.value = const UserProfileModel(
      id: '',
      email: '',
      displayName: 'Guest Cinephile',
      avatarUrl: '',
      isGuest: true,
      status: 'ACTIVE',
    );

    NetworkCaller().setAuthToken(null);
    ApiClient().setAuthToken(null);
    await _authStorage.clear();
    debugPrint('👋 [AuthController] Logged out successfully');
  }
}
