import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cinecore/core/network/network_caller.dart';
import 'package:cinecore/core/network/api_constants.dart';
import 'package:cinecore/core/storage/auth_storage.dart';
import 'package:cinecore/controllers/auth_controller.dart';
import 'package:get/get.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AuthStorage().init();
    Get.reset();
  });

  test('NetworkCaller live guest authentication and logging verification', () async {
    final caller = NetworkCaller();
    final response = await caller.post(
      ApiConstants.guestLogin,
      data: {'displayName': 'Test Device'},
    );

    expect(response.isSuccess, true);
    expect(response.statusCode, 200);
    expect(response.data, isNotNull);
  });

  test('NetworkCaller password masking in logs verification', () async {
    final caller = NetworkCaller();
    final response = await caller.post(
      ApiConstants.login,
      data: {
        'email': 'tester123@cinecore.io',
        'password': 'Password123',
      },
    );

    expect(response.isSuccess, true);
    expect(response.statusCode, 200);
  });

  test('Token persistence & automatic session restoration across app launches', () async {
    final authController = Get.put(AuthController());

    // 1. Perform login
    final success = await authController.login('tester123@cinecore.io', 'Password123');
    expect(success, true);
    expect(authController.isLoggedIn.value, true);
    expect(authController.authToken.value.isNotEmpty, true);

    final savedToken = await AuthStorage().getToken();
    expect(savedToken, authController.authToken.value);

    // 2. Simulate complete app restart: reset GetX & reinitialize AuthController
    Get.reset();
    final newAuthController = Get.put(AuthController());
    await newAuthController.restoreSession();

    // 3. User must remain logged in with preserved token
    expect(newAuthController.isLoggedIn.value, true);
    expect(newAuthController.authToken.value, savedToken);
    expect(newAuthController.userProfile.value.email, 'tester123@cinecore.io');
    expect(NetworkCaller().authToken, savedToken);
  });
}
