import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/auth_controller.dart';
import 'core/storage/auth_storage.dart';
import 'home/screen/home_screen.dart';
import 'theme/app_theme.dart';
import 'welcome/screen/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Preload stored token & session before the first UI frame renders
  await AuthStorage().init();

  // 2. Initialize permanent AuthController and restore active credentials
  final authController = Get.put(AuthController(), permanent: true);
  await authController.restoreSession();

  // 3. Launch App
  runApp(const CineCoreApp());
}

class CineCoreApp extends StatelessWidget {
  const CineCoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    return GetMaterialApp(
      title: 'CineCore',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      defaultTransition: Transition.fadeIn,
      home: Obx(() {
        // If user is logged in (token and session active), navigate directly to HomeScreen
        if (authController.isLoggedIn.value) {
          return const HomeScreen();
        }
        // If not logged in, present Welcome onboarding screen
        return const WelcomeScreen();
      }),
    );
  }
}
