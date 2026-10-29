import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../core/utils/version_utils.dart';
import '../../data/models/app_system_status_model.dart';
import '../../data/services/app_system_service.dart';
import '../../home/screen/home_screen.dart';
import '../../welcome/screen/welcome_screen.dart';
import 'force_update_screen.dart';
import 'maintenance_screen.dart';
import 'update_dialog.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeIn));

    _animController.forward();
    _navigateToNext();
  }

  void _proceedToApp() {
    final authController = Get.find<AuthController>();
    if (authController.isLoggedIn.value) {
      Get.offAll(
        () => const HomeScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 600),
      );
    } else {
      Get.offAll(
        () => const WelcomeScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 600),
      );
    }
  }

  Future<void> _navigateToNext() async {
    // 1. Check real-time server maintenance & app update status in parallel with splash animation
    final statusFuture = AppSystemService().checkAppStatus();
    final delayFuture = Future.delayed(const Duration(milliseconds: 2000));

    final results = await Future.wait([statusFuture, delayFuture]);
    final status = results[0] as AppSystemStatusModel;

    if (!mounted) return;

    // 2. If Maintenance is ON (App is OFF by Admin) -> show MaintenanceScreen
    if (status.isMaintenance) {
      Get.offAll(
        () => MaintenanceScreen(initialStatus: status),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 600),
      );
      return;
    }

    // 3. App Update check
    final appUpdate = status.appUpdate;
    if (appUpdate != null && AppVersionUtils.isUpdateAvailable(appUpdate)) {
      if (AppVersionUtils.isForceUpdateRequired(appUpdate)) {
        // Required (Force Update): Blocks app usage completely
        Get.offAll(
          () => ForceUpdateScreen(updateConfig: appUpdate),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 600),
        );
        return;
      } else {
        // Non-Required (Optional): Show update dialog with 'Later' option
        await UpdateDialog.show(
          context,
          updateConfig: appUpdate,
        );
        if (!mounted) return;
        _proceedToApp();
        return;
      }
    }

    // 4. If App is Live & Up-to-date -> proceed normally
    _proceedToApp();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: const Color(0xFF08090C),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF08090C),
        body: Stack(
          children: [
            // Ambient Red Glow in background
            Positioned(
              top: MediaQuery.of(context).size.height * 0.35,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.18),
                        blurRadius: 120,
                        spreadRadius: 40,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Centered Animated Brand Logo
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // CineCore 3D Logo
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFFE11D48,
                              ).withValues(alpha: 0.28),
                              blurRadius: 36,
                              spreadRadius: 4,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // CineCore Brand Text
                      const Text(
                        'CineCore',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Tagline
                      Text(
                        'Stream Cinema In 4K Ultra HD',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Subtle bottom loader
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFFEF4444).withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}