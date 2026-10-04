import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:cinecore/main.dart';
import 'package:cinecore/home/screen/movie_details_screen.dart';
import 'package:cinecore/home/screen/movie_player_screen.dart';

void main() {
  testWidgets('Welcome screen renders properly', (WidgetTester tester) async {
    await tester.pumpWidget(const CineCoreApp());

    expect(find.text('Your Entertainment\nStarts Right Here'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('Movie Details screen renders exact layout elements', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MovieDetailsScreen(),
      ),
    );

    // Verify Title & Subtitle
    expect(find.text('SCREAM VII'), findsOneWidget);
    expect(find.text('The Bloodline Returns'), findsOneWidget);

    // Verify Badges & Specs
    expect(find.text('8.9 Critical Acclaim'), findsOneWidget);
    expect(find.text('Top 10 Worldwide'), findsOneWidget);
    expect(find.text('4K ULTRA HD'), findsOneWidget);
    expect(find.text('IMAX'), findsOneWidget);

    // Verify Action CTA
    expect(find.text('Watch Now'), findsOneWidget);
    expect(find.text('Watchlist'), findsNWidgets(2)); // Action tile + Bottom nav bar
    expect(find.text('Trailer'), findsOneWidget);
    expect(find.text('Download'), findsOneWidget);
    expect(find.text('Lounge'), findsOneWidget);

    // Verify Critic & Fan review stats
    expect(find.text('94%'), findsOneWidget);
    expect(find.text('Certified Fresh'), findsOneWidget);
    expect(find.text('91%'), findsOneWidget);
    expect(find.text('50k+ Ratings'), findsOneWidget);

    // Verify Dolby Atmos Bar
    expect(find.text('Dolby Atmos'), findsOneWidget);

    // Verify Sections
    expect(find.text('Cast & Crew'), findsOneWidget);

    // Scroll down to reveal lower sliver sections in the viewport
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('More Like This'), findsOneWidget);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -450));
    await tester.pumpAndSettle();
    expect(find.text('Screenshots'), findsOneWidget);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -450));
    await tester.pumpAndSettle();
    expect(find.text('Trailers & Extras'), findsOneWidget);
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

    // Verify Title & Specs
    expect(find.text('SCREAM VII'), findsOneWidget);
    expect(find.text('The Bloodline Returns'), findsOneWidget);
    expect(find.text('4K HDR'), findsOneWidget);
    expect(find.text('Dolby Atmos'), findsOneWidget);
    expect(find.text('1.0x'), findsOneWidget);

    // Verify icons
    expect(find.byIcon(Icons.replay_10_rounded), findsOneWidget);
    expect(find.byIcon(Icons.forward_10_rounded), findsOneWidget);
    expect(find.byIcon(Icons.subtitles_rounded), findsOneWidget);
    expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
  });
}
