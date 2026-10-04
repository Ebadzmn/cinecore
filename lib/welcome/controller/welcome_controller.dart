import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../home/screen/home_screen.dart';

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
    Get.off(
      () => const HomeScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 400),
    );
  }

  void onSignIn(BuildContext context) {
    Get.off(
      () => const HomeScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 400),
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
