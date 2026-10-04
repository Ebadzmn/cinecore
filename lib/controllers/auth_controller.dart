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
    subscriptionTier: 'CINEMAX 4K VIP',
    isVip: true,
  ).obs;

  final RxBool isLoggedIn = true.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
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

  void toggleVipStatus() {
    userProfile.value = UserProfileModel(
      id: userProfile.value.id,
      email: userProfile.value.email,
      displayName: userProfile.value.displayName,
      avatarUrl: userProfile.value.avatarUrl,
      subscriptionTier: userProfile.value.isVip ? 'STANDARD HD' : 'CINEMAX 4K VIP',
      isVip: !userProfile.value.isVip,
    );
  }
}
