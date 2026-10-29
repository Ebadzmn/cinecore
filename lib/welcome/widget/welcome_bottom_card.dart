import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'welcome_button.dart';

class WelcomeBottomCard extends StatelessWidget {
  final VoidCallback onGetStarted;
  final VoidCallback onSignIn;
  final VoidCallback onGuestLogin;

  const WelcomeBottomCard({
    super.key,
    required this.onGetStarted,
    required this.onSignIn,
    required this.onGuestLogin,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    const cardRadius = BorderRadius.only(
      topLeft: Radius.circular(38),
      topRight: Radius.circular(38),
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.65),
            blurRadius: 40,
            spreadRadius: 2,
            offset: const Offset(0, -10),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 30,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: cardRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: cardRadius,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF1B1D26).withValues(alpha: 0.85),
                  const Color(0xFF101218).withValues(alpha: 0.94),
                  const Color(0xFF090A0D).withValues(alpha: 0.98),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
                width: 1.2,
              ),
            ),
            padding: EdgeInsets.fromLTRB(
              24,
              14,
              24,
              bottomPadding > 0 ? bottomPadding + 12 : 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Minimal Drag Handle Pill
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // CineCore Brand 3D Logo
                Center(
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Title
                const Text(
                  'Your Entertainment\nStarts Right Here',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    height: 1.22,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 10),

                // Subtitle
                Text(
                  'Discover movies, series, sports, and Originals.\nStream anytime, anywhere effortlessly.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13.5,
                    height: 1.4,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 22),

                // Primary Button: Get Started
                WelcomeButton(
                  text: 'Get Started',
                  isPrimary: true,
                  onPressed: onGetStarted,
                ),
                const SizedBox(height: 12),

                // Secondary Button: Sign In
                WelcomeButton(
                  text: 'Sign In',
                  isPrimary: false,
                  onPressed: onSignIn,
                ),
                const SizedBox(height: 12),

                // Tertiary Button: Login as Guest
                GestureDetector(
                  onTap: onGuestLogin,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFF13151D).withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        width: 1.1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.explore_outlined,
                            color: AppColors.primary,
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Login as Guest',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
