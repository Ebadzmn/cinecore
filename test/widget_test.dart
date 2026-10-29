import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cinecore/controllers/watchlist_controller.dart';
import 'package:cinecore/controllers/movie_player_controller.dart';
import 'package:cinecore/home/screen/movie_player_screen.dart';

void main() {
  setUp(() {
    Get.reset();
    Get.put(WatchlistController());
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('Movie Player screen renders and displays playback controls', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MoviePlayerScreen(
          title: 'SCREAM VII',
          subtitle: 'The Bloodline Returns',
        ),
      ),
    );

    // Verify Title & Subtitle
    expect(find.text('SCREAM VII'), findsOneWidget);
    expect(find.text('The Bloodline Returns'), findsOneWidget);
    expect(find.text('Auto'), findsOneWidget);
    expect(find.text('1.0x'), findsOneWidget);

    // Verify playback icons
    expect(find.byIcon(Icons.replay_10_rounded), findsOneWidget);
    expect(find.byIcon(Icons.forward_10_rounded), findsOneWidget);
    expect(find.byIcon(Icons.tune_rounded), findsOneWidget);

    // Explicitly delete controller with tag to cancel active periodic tickers
    final controllerTag = 'scream_vii__0_0';
    if (Get.isRegistered<MoviePlayerController>(tag: controllerTag)) {
      Get.delete<MoviePlayerController>(tag: controllerTag, force: true);
    }
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  });
}
