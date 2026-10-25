import 'package:get/get.dart';
import '../data/models/user_profile_model.dart';
import '../data/services/movie_api_service.dart';

class AuthController extends GetxController {
  final MovieApiService _apiService = MovieApiService();

  final Rx<UserProfileModel> userProfile = const UserProfileModel(
    id: 'usr_austin_1',
    email: 'austin.rivera@cinecore.io',
    displayName: 'Austin Rivera',
    avatarUrl: '',
    isGuest: false,
  ).obs;

  final RxBool isLoggedIn = false.obs;
  final RxBool isLoading = false.obs;

  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;
      final result = await _apiService.login(email: email, password: password);
      if (result != null && result['user'] != null) {
        final u = result['user'] as Map<String, dynamic>;
        userProfile.value = UserProfileModel(
          id: u['id']?.toString() ?? 'usr_1',
          email: u['email']?.toString() ?? email,
          displayName: u['displayName']?.toString() ??
              u['name']?.toString() ??
              (email.contains('@') ? email.split('@').first : 'User'),
          avatarUrl: u['avatarUrl']?.toString() ?? '',
          isGuest: false,
        );
        isLoggedIn.value = true;
        return true;
      }
      return false;
    } catch (_) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      final result = await _apiService.register(
        name: name,
        email: email,
        password: password,
      );
      if (result != null && result['user'] != null) {
        final u = result['user'] as Map<String, dynamic>;
        userProfile.value = UserProfileModel(
          id: u['id']?.toString() ?? 'usr_new',
          email: u['email']?.toString() ?? email,
          displayName: u['displayName']?.toString() ?? name,
          avatarUrl: u['avatarUrl']?.toString() ?? '',
          isGuest: false,
        );
        isLoggedIn.value = true;
        return true;
      }
      return false;
    } catch (_) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginAsGuest() async {
    isLoading.value = true;
    try {
      final result = await _apiService.loginGuest();
      if (result != null && result['user'] != null) {
        final u = result['user'] as Map<String, dynamic>;
        userProfile.value = UserProfileModel(
          id: u['id']?.toString() ?? 'usr_guest',
          email: '',
          displayName: u['displayName']?.toString() ?? 'Guest Cinephile',
          avatarUrl: '',
          isGuest: true,
        );
      } else {
        userProfile.value = const UserProfileModel(
          id: 'usr_guest',
          email: '',
          displayName: 'Guest Cinephile',
          avatarUrl: '',
          isGuest: true,
        );
      }
    } catch (_) {
      userProfile.value = const UserProfileModel(
        id: 'usr_guest',
        email: '',
        displayName: 'Guest Cinephile',
        avatarUrl: '',
        isGuest: true,
      );
    } finally {
      isLoggedIn.value = true;
      isLoading.value = false;
    }
  }

  Future<void> loadUserProfile() async {
    try {
      isLoading.value = true;
      final profile = await _apiService.getUserProfile();
      userProfile.value = profile;
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    isLoggedIn.value = false;
    userProfile.value = const UserProfileModel(
      id: '',
      email: '',
      displayName: 'Guest',
      avatarUrl: '',
      isGuest: true,
    );
  }
}
