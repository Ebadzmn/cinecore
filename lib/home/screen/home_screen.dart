import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/watchlist_controller.dart';
import '../../data/models/movie_model.dart';
import '../widget/category_pill_bar.dart';
import '../widget/continue_watching_section.dart';
import '../widget/custom_glass_bottom_nav_bar.dart';
import '../widget/home_top_header.dart';
import '../widget/peacock_picks_section.dart';
import '../widget/spotlight_hero_card.dart';
import '../widget/genre_movie_row_section.dart';
import '../widget/genres_horizontal_section.dart';
import '../widget/top_blockbusters_section.dart';
import 'genre_movies_screen.dart';
import 'leaderboard_screen.dart';
import 'movie_details_screen.dart';
import 'movie_player_screen.dart';
import 'search_screen.dart';
import 'watchlist_screen.dart';
import '../../welcome/screen/welcome_screen.dart';
import '../../auth/screen/get_started_screen.dart';
import '../../auth/screen/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.put(HomeController());
    final watchlistController = Get.put(WatchlistController());
    final authController = Get.find<AuthController>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: const Color(0xFF090A0E),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF090A0E),
        body: Stack(
          children: [
            // Ambient Top Spotlight Glow
            Positioned(
              top: -60,
              left: 0,
              right: 0,
              height: 250,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.6),
                      radius: 1.2,
                      colors: [
                        const Color(0xFFF59E0B).withValues(alpha: 0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Tab Content using Obx
            Obx(
              () => IndexedStack(
                index: homeController.selectedNavIndex.value,
                children: [
                  _buildHomeFeed(context, homeController, watchlistController),
                  const SearchScreen(showBackButton: false),
                  WatchlistScreen(
                    onExploreMore: () => homeController.changeNavIndex(0),
                  ),
                  _buildProfileTab(context, authController),
                ],
              ),
            ),

            // Floating Glass Bottom Navigation Bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Obx(
                () => CustomGlassBottomNavBar(
                  currentIndex: homeController.selectedNavIndex.value,
                  onTap: (index) => homeController.changeNavIndex(index),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeFeed(
    BuildContext context,
    HomeController homeController,
    WatchlistController watchlistController,
  ) {
    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: const Color(0xFFF59E0B),
        backgroundColor: const Color(0xFF161822),
        onRefresh: () => homeController.loadHomeData(),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // 1. Top Header
            const SliverToBoxAdapter(child: HomeTopHeader()),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // 2. Categories Pill Bar
            SliverToBoxAdapter(
              child: Obx(
                () => CategoryPillBar(
                  selectedIndex: homeController.selectedCategoryIndex.value,
                  onCategorySelected: (index) => homeController.changeCategory(index),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 22)),

            // 3. Spotlight Hero Carousel Slider
            SliverToBoxAdapter(
              child: SpotlightHeroCard(
                onMovieTap: (item) => _navigateToDetails(
                  title: item.fullTitle,
                  subtitle: item.subtitle,
                  heroImageUrl: item.imageUrl,
                ),
                onWatchNow: (item) => _navigateToPlayer(
                  title: item.fullTitle,
                  subtitle: item.subtitle,
                  heroImageUrl: item.imageUrl,
                ),
                onAddToList: (item) {
                  watchlistController.toggleWatchlist(
                    MovieModel(
                      id: item.fullTitle.toLowerCase().replaceAll(' ', '_'),
                      title: item.fullTitle,
                      subtitle: item.subtitle,
                      imageUrl: item.imageUrl,
                      rating: 9.3,
                      resolution: '4K Ultra HD',
                      genres: 'Action, Sci-Fi',
                    ),
                  );
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 22)),

            // 4. Genres Capsule Section
            SliverToBoxAdapter(
              child: GenresHorizontalSection(
                onGenreSelected: (genre) {
                  Get.to(() => GenreMoviesScreen(genreName: genre.name));
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 26)),

            // 5. Action Movies (10 items)
            SliverToBoxAdapter(
              child: GenreMovieRowSection(
                genreName: 'Action',
                title: 'Action Movies',
                onMovieTap: (movie) => _navigateToDetails(
                  title: movie.title,
                  subtitle: movie.subtitle ?? movie.genres,
                  heroImageUrl: movie.imageUrl,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 26)),

            // 6. Top 10 Blockbusters Section
            SliverToBoxAdapter(
              child: TopBlockbustersSection(
                onMovieTap: (movie) => _navigateToDetails(
                  title: movie.title,
                  subtitle: movie.genres,
                  heroImageUrl: movie.imageUrl,
                ),
                onSeeLeaderboard: () => Get.to(() => const LeaderboardScreen()),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 26)),

            // 7. Crime Movies (10 items)
            SliverToBoxAdapter(
              child: GenreMovieRowSection(
                genreName: 'Crime',
                title: 'Crime & Mystery',
                onMovieTap: (movie) => _navigateToDetails(
                  title: movie.title,
                  subtitle: movie.subtitle ?? movie.genres,
                  heroImageUrl: movie.imageUrl,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 26)),

            // 8. Science Fiction Movies (10 items)
            SliverToBoxAdapter(
              child: GenreMovieRowSection(
                genreName: 'Science Fiction',
                title: 'Science Fiction',
                onMovieTap: (movie) => _navigateToDetails(
                  title: movie.title,
                  subtitle: movie.subtitle ?? movie.genres,
                  heroImageUrl: movie.imageUrl,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 26)),

            // 9. Peacock Picks Section
            SliverToBoxAdapter(
              child: PeacockPicksSection(
                onMovieTap: (movie) => _navigateToDetails(
                  title: movie.title,
                  subtitle: movie.subtitle ?? 'The Epic Sequel',
                  heroImageUrl: movie.imageUrl,
                ),
                onSeeAll: () => homeController.changeNavIndex(1),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 26)),

            // 10. Thriller Movies (10 items)
            SliverToBoxAdapter(
              child: GenreMovieRowSection(
                genreName: 'Thriller',
                title: 'Edge-of-Seat Thrillers',
                onMovieTap: (movie) => _navigateToDetails(
                  title: movie.title,
                  subtitle: movie.subtitle ?? movie.genres,
                  heroImageUrl: movie.imageUrl,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 26)),

            // 11. Continue Watching Section
            SliverToBoxAdapter(
              child: ContinueWatchingSection(
                onItemTap: (item) => _navigateToPlayer(
                  title: item.title,
                  subtitle: item.episodeInfo,
                  heroImageUrl: item.imageUrl,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 95)),
          ],
        ),
      ),
    );
  }

  void _navigateToDetails({
    required String title,
    required String subtitle,
    required String heroImageUrl,
  }) {
    Get.to(
      () => MovieDetailsScreen(
        title: title,
        subtitle: subtitle,
        heroImageUrl: heroImageUrl,
      ),
      transition: Transition.fadeIn,
    );
  }

  void _navigateToPlayer({
    required String title,
    required String subtitle,
    required String heroImageUrl,
  }) {
    Get.to(
      () => MoviePlayerScreen(
        title: title,
        subtitle: subtitle,
        heroImageUrl: heroImageUrl,
      ),
      transition: Transition.fadeIn,
    );
  }

  Widget _buildProfileTab(BuildContext context, AuthController authController) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Obx(() {
          final profile = authController.userProfile.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 22,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Text(
                    'ACCOUNT & SETTINGS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xFF161822),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFFFBBF24), Color(0xFFF97316)],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          profile.displayName.isNotEmpty ? profile.displayName[0] : 'A',
                          style: const TextStyle(
                            color: Color(0xFF090A0E),
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            profile.email,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              profile.isGuest ? 'GUEST' : 'MEMBER',
                              style: const TextStyle(
                                color: Color(0xFFFBBF24),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (profile.isGuest) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1A11),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.stars_rounded, color: Color(0xFFFBBF24), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Upgrade to Full Member',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Unlock your personal watchlist, synchronized playback history, and member privileges.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF59E0B),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 11),
                              ),
                              onPressed: () {
                                Get.to(() => const GetStartedScreen());
                              },
                              child: const Text(
                                'Create Account',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 11),
                              ),
                              onPressed: () {
                                Get.to(() => const LoginScreen());
                              },
                              child: const Text(
                                'Sign In',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              GestureDetector(
                onTap: () async {
                  await authController.logout();
                  Get.offAll(
                    () => const WelcomeScreen(),
                    transition: Transition.fadeIn,
                    duration: const Duration(milliseconds: 350),
                  );
                },
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF161822),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded, color: Colors.red.shade400, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        profile.isGuest ? 'Leave Guest Mode' : 'Sign Out',
                        style: TextStyle(
                          color: Colors.red.shade400,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
