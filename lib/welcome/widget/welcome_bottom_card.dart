import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'welcome_button.dart';

class WelcomeBottomCard extends StatelessWidget {
  final VoidCallback onGetStarted;
  final VoidCallback onSignIn;

  const WelcomeBottomCard({
    super.key,
    required this.onGetStarted,
    required this.onSignIn,
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
              16,
              24,
              bottomPadding > 0 ? bottomPadding + 16 : 28,
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
                const SizedBox(height: 24),

                // Title
                const Text(
                  'Your Entertainment\nStarts Right Here',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                    height: 1.22,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 12),

                // Subtitle
                Text(
                  'Discover movies, series, sports, and Originals.\nStream anytime, anywhere effortlessly.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                    height: 1.45,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 28),

                // Primary Button: Get Started
                WelcomeButton(
                  text: 'Get Started',
                  isPrimary: true,
                  onPressed: onGetStarted,
                ),
                const SizedBox(height: 14),

                // Secondary Button: Sign In
                WelcomeButton(
                  text: 'Sign In',
                  isPrimary: false,
                  onPressed: onSignIn,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
