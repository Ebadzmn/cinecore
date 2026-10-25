import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controller/welcome_controller.dart';
import '../widget/movie_poster_grid.dart';
import '../widget/welcome_bottom_card.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late final WelcomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WelcomeController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: const Color(0xFF0C0D11),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF08090C),
        body: Stack(
          children: [
            // 1. Moving Background Movie Stream Grid (full view, vibrant & crystal clear)
            const Positioned.fill(
              child: MoviePosterGrid(),
            ),

            // 2. Minimal Top Ambient Shadow for Status Bar Icons visibility (subtle 50px only)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 50,
              child: IgnorePointer(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x6608090C),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 3. Bottom Glass Card
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: WelcomeBottomCard(
                onGetStarted: () => _controller.onGetStarted(context),
                onSignIn: () => _controller.onSignIn(context),
                onGuestLogin: () => _controller.onGuestLogin(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
