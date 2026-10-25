import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/screen/get_started_screen.dart';
import '../../auth/screen/login_screen.dart';

import '../../controllers/auth_controller.dart';
import '../../home/screen/home_screen.dart';
import '../../theme/app_colors.dart';

class WelcomeController extends ChangeNotifier {
  late ScrollController column1Controller;
  late ScrollController column2Controller;
  late ScrollController column3Controller;

  bool _isDisposed = false;

  WelcomeController() {
    column1Controller = ScrollController(initialScrollOffset: 40);
    column2Controller = ScrollController(initialScrollOffset: 120);
    column3Controller = ScrollController(initialScrollOffset: 20);
  }

  void onGetStarted(BuildContext context) {
    Get.to(
      () => const GetStartedScreen(),
      transition: Transition.rightToLeftWithFade,
      duration: const Duration(milliseconds: 350),
    );
  }

  void onSignIn(BuildContext context) {
    Get.to(
      () => const LoginScreen(),
      transition: Transition.rightToLeftWithFade,
      duration: const Duration(milliseconds: 350),
    );
  }

  void onGuestLogin(BuildContext context) async {
    final authController = Get.put(AuthController());
    await authController.loginAsGuest();
    Get.offAll(
      () => const HomeScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 400),
    );
    Get.snackbar(
      'Guest Mode Active',
      'Welcome to CineCore! Browsing as Guest.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF161822),
      colorText: AppColors.primary,
      icon: const Icon(Icons.explore_rounded, color: AppColors.primary),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    column1Controller.dispose();
    column2Controller.dispose();
    column3Controller.dispose();
    super.dispose();
  }

  bool get isDisposed => _isDisposed;
}
