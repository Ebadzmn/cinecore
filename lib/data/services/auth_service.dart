import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
import '../models/auth_response_model.dart';
import '../models/user_profile_model.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  /// Register a new account (/api/v1/auth/register)
  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.register,
      data: {
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
      },
    );

    final responseData = response.data as Map<String, dynamic>;
    final data = (responseData['data'] as Map<String, dynamic>?) ?? {};
    return AuthResponseModel.fromJson(data);
  }

  /// Login with email and password (/api/v1/auth/login)
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.login,
      data: {
        'email': email.trim().toLowerCase(),
        'password': password,
      },
    );

    final responseData = response.data as Map<String, dynamic>;
    final data = (responseData['data'] as Map<String, dynamic>?) ?? {};
    return AuthResponseModel.fromJson(data);
  }

  /// Guest authentication session (/api/v1/auth/guest)
  Future<AuthResponseModel> guestLogin({
    String? deviceId,
    String? displayName,
  }) async {
    final payload = <String, dynamic>{};
    if (deviceId != null) payload['deviceId'] = deviceId;
    if (displayName != null) payload['displayName'] = displayName;

    final response = await _apiClient.post(
      ApiConstants.guestLogin,
      data: payload,
    );

    final responseData = response.data as Map<String, dynamic>;
    final data = (responseData['data'] as Map<String, dynamic>?) ?? {};
    return AuthResponseModel.fromJson(data);
  }

  /// Upgrade guest session to permanent registered account (/api/v1/auth/guest/upgrade)
  Future<AuthResponseModel> upgradeGuest({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.guestUpgrade,
      data: {
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
      },
    );

    final responseData = response.data as Map<String, dynamic>;
    final data = (responseData['data'] as Map<String, dynamic>?) ?? {};
    return AuthResponseModel.fromJson(data);
  }

  /// Get current user profile (/api/v1/auth/me)
  Future<UserProfileModel> getCurrentUser() async {
    final response = await _apiClient.get(ApiConstants.authMe);
    final responseData = response.data as Map<String, dynamic>;
    final data = (responseData['data'] as Map<String, dynamic>?) ?? {};
    return UserProfileModel.fromJson(data);
  }

  /// Update user profile (/api/v1/users/me)
  Future<UserProfileModel> updateProfile({
    String? displayName,
    String? avatarUrl,
  }) async {
    final payload = <String, dynamic>{};
    if (displayName != null) payload['displayName'] = displayName.trim();
    if (avatarUrl != null) payload['avatarUrl'] = avatarUrl.trim();

    final response = await _apiClient.patch(
      ApiConstants.userProfile,
      data: payload,
    );

    final responseData = response.data as Map<String, dynamic>;
    final data = (responseData['data'] as Map<String, dynamic>?) ?? {};
    return UserProfileModel.fromJson(data);
  }

  /// Logout current user session (/api/v1/auth/logout)
  Future<void> logout() async {
    try {
      await _apiClient.post(ApiConstants.logout);
    } catch (_) {
      // Local logout should still proceed even if offline
    }
  }
}
