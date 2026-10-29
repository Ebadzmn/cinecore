import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/auth_controller.dart';
import 'core/network/api_constants.dart';
import 'core/storage/auth_storage.dart';
import 'splash/screen/splash_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Auto-detect optimal backend URL (LAN IP, ADB USB reverse, or Emulator)
  await ApiConstants.autoDetectBaseUrl();

  // 2. Preload stored token & session before the first UI frame renders
  await AuthStorage().init();

  // 3. Initialize permanent AuthController and restore active credentials
  final authController = Get.put(AuthController(), permanent: true);
  await authController.restoreSession();

  // 4. Launch App
  runApp(const CineCoreApp());
}

class CineCoreApp extends StatelessWidget {
  const CineCoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'CineCore',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      defaultTransition: Transition.fadeIn,
      home: const SplashScreen(),
    );
  }
}
