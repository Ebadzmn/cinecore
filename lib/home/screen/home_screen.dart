import '../widget/floating_feed_button.dart';
import 'community_feed_screen.dart';
import '../../controllers/community_controller.dart';
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
import '../widget/latest_movies_section.dart';
import '../widget/popular_series_row_section.dart';
import 'genre_movies_screen.dart';
import 'leaderboard_screen.dart';
import 'movie_player_screen.dart';
import 'search_screen.dart';
import 'watchlist_screen.dart';
import 'watch_history_screen.dart';
import '../../core/utils/navigation_utils.dart';
import '../../welcome/screen/welcome_screen.dart';
import '../../auth/screen/get_started_screen.dart';
import '../../auth/screen/login_screen.dart';
import 'my_posts_screen.dart';
import 'my_reports_screen.dart';
import '../widget/community/create_post_sheet.dart';
import '../../core/network/api_constants.dart';
import '../../data/models/community_post_model.dart';
import '../../data/models/app_system_status_model.dart';
import '../../core/utils/version_utils.dart';
import '../../data/services/app_system_service.dart';
import '../../splash/screen/force_update_screen.dart';
import '../../splash/screen/update_dialog.dart';
import '../../splash/screen/maintenance_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ScrollController _homeScrollController;
  AppUpdateModel? _activeAnnouncement;
  bool _hasCheckedSystemStatus = false;

  @override
  void initState() {
    super.initState();
    _homeScrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSystemStatusOnLaunch();
    });
  }

  Future<void> _checkSystemStatusOnLaunch() async {
    if (_hasCheckedSystemStatus) return;
    _hasCheckedSystemStatus = true;

    try {
      final status = await AppSystemService().checkAppStatus();
      if (!mounted) return;

      if (status.isMaintenance) {
        Get.offAll(() => MaintenanceScreen(initialStatus: status));
        return;
      }

      final appUpdate = status.appUpdate;
      if (appUpdate != null && AppVersionUtils.isUpdateAvailable(appUpdate)) {
        if (mounted) {
          setState(() {
            _activeAnnouncement = appUpdate;
          });
        }
        if (AppVersionUtils.isForceUpdateRequired(appUpdate)) {
          Get.offAll(() => ForceUpdateScreen(updateConfig: appUpdate));
        } else {
          UpdateDialog.show(context, updateConfig: appUpdate);
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _homeScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeController = Get.put(HomeController());
    final watchlistController = Get.put(WatchlistController());
    final authController = Get.find<AuthController>();
    final communityController = Get.isRegistered<CommunityController>()
        ? Get.find<CommunityController>()
        : Get.put(CommunityController());

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: const Color(0xFF090A0E),
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
                  _buildProfileTab(
                    context,
                    authController,
                    communityController,
                    watchlistController,
                  ),
                  const CommunityFeedScreen(showBackButton: false),
                ],
              ),
            ),

            // Floating Feed Button positioned slightly above the bottom navigation bar (hidden when keyboard is open)
            if (MediaQuery.of(context).viewInsets.bottom == 0)
              Positioned(
                left: 0,
                right: 0,
                bottom: (68.0 + (MediaQuery.of(context).padding.bottom > 0 ? (MediaQuery.of(context).padding.bottom * 0.5) : 0.0)) + 12.0,
                child: Center(
                  child: Obx(
                    () => FloatingFeedButton(
                      isSelected: homeController.selectedNavIndex.value == 4,
                      onTap: () {
                        if (homeController.selectedNavIndex.value != 4) {
                          homeController.changeNavIndex(4);
                        } else {
                          if (Get.isRegistered<CommunityController>()) {
                            Get.find<CommunityController>().loadFeed(refresh: true);
                          }
                        }
                      },
                    ),
                  ),
                ),
              ),

            // Floating Glass Bottom Navigation Bar (hidden when keyboard is open to maximize screen real estate and eliminate lag)
            if (MediaQuery.of(context).viewInsets.bottom == 0)
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
          controller: _homeScrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // 1. Top Header
            const SliverToBoxAdapter(child: HomeTopHeader()),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Announcement & Update Alert Banner (if broadcasted by admin)
            if (_activeAnnouncement != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        UpdateDialog.show(context, updateConfig: _activeAnnouncement!);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF280B0E), Color(0xFF141622)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFE50914).withValues(alpha: 0.4),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE50914).withValues(alpha: 0.12),
                              blurRadius: 16,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE50914).withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.campaign_rounded,
                                color: Color(0xFFFF5252),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          _activeAnnouncement!.title.isNotEmpty
                                              ? _activeAnnouncement!.title
                                              : 'Announcement',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 1.5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE50914).withValues(alpha: 0.25),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'v${_activeAnnouncement!.latestVersion}',
                                          style: const TextStyle(
                                            color: Color(0xFFFF8A80),
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _activeAnnouncement!.message,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.7),
                                      fontSize: 11.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE50914),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'View',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),

            // 2. Categories Pill Bar
            SliverToBoxAdapter(
              child: Obx(
                () => CategoryPillBar(
                  categories: homeController.categories.toList(),
                  selectedIndex: homeController.selectedCategoryIndex.value,
                  onCategorySelected: (index) {
                    homeController.changeCategory(index);
                    if (index > 0 && index < homeController.categories.length) {
                      final selectedCategory = homeController.categories[index];
                      Get.to(() => GenreMoviesScreen(genreName: selectedCategory.name));
                    }
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 22)),

            // 3. Dynamic Spotlight Hero Carousel Slider (from CMS)
            SliverToBoxAdapter(
              child: Obx(
                () => SpotlightHeroCard(
                  items: homeController.heroBanners.isNotEmpty
                      ? homeController.heroBanners.map((b) => b.toSpotlightItem()).toList()
                      : null,
                  onMovieTap: (item) => _handleBannerTap(homeController, item),
                  onWatchNow: (item) => _handleBannerWatchNow(homeController, item),
                  onAddToList: (item) {
                    final banner = homeController.heroBanners.firstWhereOrNull((b) => b.id == item.id);
                    if (banner?.movie != null) {
                      watchlistController.toggleWatchlist(banner!.movie!);
                    } else {
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
                    }
                  },
                ),
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

            // 5. Dynamic Home Sections (Admin Dashboard Controlled Order & Content)
            ..._buildDynamicSections(context, homeController),

            // 6. Continue Watching Section
            SliverToBoxAdapter(
              child: ContinueWatchingSection(
                onItemTap: (item) {
                  Get.to(
                    () => MoviePlayerScreen(
                      movieId: item.movieId ?? item.id,
                      movieType: item.movieType ?? 'MOVIE',
                      seasonNumber: item.seasonNumber,
                      episodeNumber: item.episodeNumber,
                      episodeTitle: item.episodeTitle,
                      initialPositionSeconds: item.positionSeconds,
                      title: item.title,
                      subtitle: item.episodeInfo,
                      heroImageUrl: item.imageUrl,
                    ),
                    transition: Transition.fadeIn,
                  );
                },
                onSeeAll: () => Get.to(() => const WatchHistoryScreen()),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 125)),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDynamicSections(
    BuildContext context,
    HomeController homeController,
  ) {
    return [
      SliverToBoxAdapter(
        child: Obx(() {
          final sections = homeController.homeSections.toList();
          if (sections.isEmpty) {
            // Fallback default sections
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TopBlockbustersSection(
                  onMovieTap: (movie) => _navigateToDetails(
                    movieId: movie.id,
                    title: movie.title,
                    subtitle: movie.genres,
                    heroImageUrl: movie.imageUrl,
                  ),
                  onSeeLeaderboard: () => Get.to(() => const LeaderboardScreen()),
                ),
                const SizedBox(height: 26),
                PopularSeriesRowSection(
                  onSeriesTap: (series) => _navigateToDetails(
                    movie: series,
                    movieId: series.id,
                    title: series.title,
                    subtitle: series.subtitle ?? series.genres,
                    heroImageUrl: series.imageUrl,
                  ),
                ),
                const SizedBox(height: 26),
                LatestMoviesSection(
                  onMovieTap: (movie) => _navigateToDetails(
                    movie: movie,
                    movieId: movie.id,
                    title: movie.title,
                    subtitle: movie.subtitle ?? movie.genres,
                    heroImageUrl: movie.imageUrl,
                  ),
                  onSeeAll: () => homeController.changeNavIndex(1),
                ),
                const SizedBox(height: 26),
                PeacockPicksSection(
                  onMovieTap: (movie) => _navigateToDetails(
                    movieId: movie.id,
                    title: movie.title,
                    subtitle: movie.subtitle ?? 'The Epic Sequel',
                    heroImageUrl: movie.imageUrl,
                  ),
                  onSeeAll: () => homeController.changeNavIndex(1),
                ),
                const SizedBox(height: 26),
              ],
            );
          }

          // Dynamic Sections from CMS
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: sections.where((s) => s.isActive).map((section) {
              Widget sectionWidget;
              if (section.key == 'top_10_blockbusters' || section.sectionType == 'TOP_10') {
                final rankedItems = section.items
                    .asMap()
                    .entries
                    .map((e) => e.value.toTopBlockbusterMovie(e.key))
                    .toList();
                sectionWidget = TopBlockbustersSection(
                  title: section.title,
                  subtitle: section.subtitle,
                  movies: rankedItems,
                  onMovieTap: (movie) {
                    final orig = section.movies.firstWhereOrNull((m) => m.id == movie.id);
                    _navigateToDetails(
                      movie: orig,
                      movieId: movie.id,
                      title: movie.title,
                      subtitle: movie.genres,
                      heroImageUrl: movie.imageUrl,
                    );
                  },
                  onSeeLeaderboard: () => Get.to(() => const LeaderboardScreen()),
                );
              } else if (section.key == 'latest_movies' || section.sectionType == 'GRID') {
                sectionWidget = LatestMoviesSection(
                  title: section.title,
                  subtitle: section.subtitle,
                  movies: section.movies.take(12).toList(),
                  onMovieTap: (movie) => _navigateToDetails(
                    movie: movie,
                    movieId: movie.id,
                    title: movie.title,
                    subtitle: movie.subtitle ?? movie.genres,
                    heroImageUrl: movie.imageUrl,
                  ),
                  onSeeAll: () => homeController.changeNavIndex(1),
                );
              } else if (section.key == 'latest_series' ||
                  section.key == 'top_series' ||
                  section.sectionType == 'SERIES_ROW') {
                sectionWidget = PopularSeriesRowSection(
                  title: section.title,
                  subtitle: section.subtitle,
                  series: section.movies.take(12).toList(),
                  onSeriesTap: (series) => _navigateToDetails(
                    movie: series,
                    movieId: series.id,
                    title: series.title,
                    subtitle: series.subtitle ?? series.genres,
                    heroImageUrl: series.imageUrl,
                  ),
                );
              } else {
                sectionWidget = GenreMovieRowSection(
                  genreName: section.title,
                  title: section.title,
                  subtitle: section.subtitle,
                  movies: section.movies,
                  onMovieTap: (movie) => _navigateToDetails(
                    movie: movie,
                    movieId: movie.id,
                    title: movie.title,
                    subtitle: movie.subtitle ?? movie.genres,
                    heroImageUrl: movie.imageUrl,
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 26),
                child: sectionWidget,
              );
            }).toList(),
          );
        }),
      ),
    ];
  }

  void _handleBannerTap(HomeController homeController, SpotlightMovieItem item) {
    final banner = homeController.heroBanners.firstWhereOrNull((b) => b.id == item.id);
    if (banner?.movie != null) {
      _navigateToDetails(
        movie: banner!.movie,
        movieId: banner.movie!.id,
        title: banner.title,
        subtitle: banner.subtitle,
        heroImageUrl: banner.displayImageUrl,
      );
    } else {
      _navigateToDetails(
        title: item.fullTitle,
        subtitle: item.subtitle,
        heroImageUrl: item.imageUrl,
      );
    }
  }

  void _handleBannerWatchNow(HomeController homeController, SpotlightMovieItem item) {
    final banner = homeController.heroBanners.firstWhereOrNull((b) => b.id == item.id);
    if (banner != null && banner.ctaAction == 'DETAILS') {
      _handleBannerTap(homeController, item);
      return;
    }
    if (banner?.movie != null) {
      if (banner!.movie!.isSeries) {
        _navigateToDetails(
          movie: banner.movie,
          movieId: banner.movie!.id,
          title: banner.title,
          subtitle: banner.subtitle,
          heroImageUrl: banner.displayImageUrl,
        );
      } else {
        _navigateToPlayer(
          movieId: banner.movie!.id,
          title: banner.title,
          subtitle: banner.subtitle,
          heroImageUrl: banner.displayImageUrl,
          watchUrl: banner.movie?.playbackUrl ?? banner.movie?.watchUrl,
        );
      }
    } else {
      _navigateToPlayer(
        movieId: item.id,
        title: item.fullTitle,
        subtitle: item.subtitle,
        heroImageUrl: item.imageUrl,
      );
    }
  }

  void _navigateToDetails({
    String? movieId,
    MovieModel? movie,
    required String title,
    required String subtitle,
    required String heroImageUrl,
  }) {
    navigateToMediaDetails(
      mediaId: movieId ?? movie?.id,
      media: movie,
      title: title,
      subtitle: subtitle,
      heroImageUrl: heroImageUrl,
    );
  }

  void _navigateToPlayer({
    String? movieId,
    required String title,
    required String subtitle,
    required String heroImageUrl,
    String? watchUrl,
    double initialPositionSeconds = 0.0,
  }) {
    Get.to(
      () => MoviePlayerScreen(
        movieId: movieId,
        title: title,
        subtitle: subtitle,
        heroImageUrl: heroImageUrl,
        watchUrl: watchUrl,
        initialPositionSeconds: initialPositionSeconds,
      ),
      transition: Transition.fadeIn,
    );
  }

  Future<void> _handleManualUpdateCheck(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text('Checking for CineCore updates...'),
          ],
        ),
        duration: Duration(milliseconds: 1000),
        backgroundColor: Color(0xFF141622),
      ),
    );

    try {
      final status = await AppSystemService().checkAppStatus();
      if (!context.mounted) return;

      final appUpdate = status.appUpdate;
      if (appUpdate != null && AppVersionUtils.isUpdateAvailable(appUpdate)) {
        if (AppVersionUtils.isForceUpdateRequired(appUpdate)) {
          Get.to(() => ForceUpdateScreen(updateConfig: appUpdate));
        } else {
          UpdateDialog.show(context, updateConfig: appUpdate);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'CineCore is up to date (v${AppVersionUtils.currentAppVersion})',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF141622),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to connect to update server.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Widget _buildProfileTab(
    BuildContext context,
    AuthController authController,
    CommunityController communityController,
    WatchlistController watchlistController,
  ) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        child: Obx(() {
          final profile = authController.userProfile.value;
          final myPosts = communityController.myPosts;
          final isLoadingPosts = communityController.isLoadingMyPosts.value;

          int totalLikes = 0;
          for (final p in myPosts) {
            totalLikes += p.likesCount;
          }

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
                    'ACCOUNT & PROFILE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Profile Info Card
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
                          profile.displayName.isNotEmpty
                              ? profile.displayName[0].toUpperCase()
                              : 'A',
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
                            profile.email.isNotEmpty
                                ? profile.email
                                : 'Guest Session',
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

              // Guest Upgrade Card
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
                        'Unlock your personal community posts, watchlist, playback history, and member privileges.',
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
              ] else ...[
                // Engagement & Stats Summary
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141622),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.07),
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildProfileStatColumn(
                        label: 'My Posts',
                        value: '${myPosts.length}',
                        icon: Icons.dynamic_feed_rounded,
                        color: const Color(0xFFF59E0B),
                        onTap: () => Get.to(() => const MyPostsScreen()),
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                      _buildProfileStatColumn(
                        label: 'Likes Received',
                        value: '$totalLikes',
                        icon: Icons.favorite_rounded,
                        color: const Color(0xFFEF4444),
                        onTap: () => Get.to(() => const MyPostsScreen()),
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                      _buildProfileStatColumn(
                        label: 'Saved List',
                        value: '${watchlistController.watchlist.length}',
                        icon: Icons.bookmark_rounded,
                        color: const Color(0xFF38BDF8),
                        onTap: () => Get.find<HomeController>().changeNavIndex(2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ==================== MY POSTS SECTION ====================
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'MY POSTS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2235),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${myPosts.length}',
                        style: const TextStyle(
                          color: Color(0xFFF59E0B),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Get.to(() => const MyPostsScreen()),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Row(
                        children: [
                          Text(
                            'View All',
                            style: TextStyle(
                              color: Color(0xFFF59E0B),
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 2),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Color(0xFFF59E0B),
                            size: 11,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Posts content
                if (isLoadingPosts && myPosts.isEmpty)
                  Container(
                    height: 100,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF141622),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFF59E0B),
                    ),
                  )
                else if (myPosts.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141622),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F2436),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.dynamic_feed_rounded,
                            color: Color(0xFF94A3B8),
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'No Posts Published Yet',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Share movies, series reviews, or moments to track discussions here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton.icon(
                          onPressed: () {
                            Get.bottomSheet(
                              const CreatePostSheet(),
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                            );
                          },
                          icon: const Icon(Icons.add_rounded, size: 16),
                          label: const Text(
                            'Create Your First Post',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF59E0B),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 9,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  // Display latest 2-3 posts as interactive preview cards
                  ...myPosts.take(3).map((post) => _buildProfilePostPreview(post)),
                  if (myPosts.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      child: OutlinedButton(
                        onPressed: () => Get.to(() => const MyPostsScreen()),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFFBBF24),
                          side: BorderSide(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(double.infinity, 40),
                        ),
                        child: Text(
                          'View All My Posts (${myPosts.length})',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                ],
                const SizedBox(height: 20),
              ],

              // Navigation Tiles Section
              _buildProfileNavTile(
                icon: Icons.dynamic_feed_rounded,
                iconColor: const Color(0xFFF59E0B),
                title: 'My Posts & Activity',
                subtitle: 'Manage and track interactions on all your posts',
                trailingText: '${myPosts.length}',
                onTap: () => Get.to(() => const MyPostsScreen()),
              ),
              const SizedBox(height: 10),

              _buildProfileNavTile(
                icon: Icons.history_rounded,
                iconColor: const Color(0xFF38BDF8),
                title: 'Watch History & Resume',
                subtitle: 'View completed and in-progress movies & series',
                onTap: () => Get.to(() => const WatchHistoryScreen()),
              ),
              const SizedBox(height: 10),

              _buildProfileNavTile(
                icon: Icons.flag_rounded,
                iconColor: const Color(0xFFEF4444),
                title: 'My Reports & Safety',
                subtitle: 'Track status and updates of your submitted reports',
                trailingText: communityController.myReports.isNotEmpty
                    ? '${communityController.myReports.length}'
                    : null,
                onTap: () => Get.to(() => const MyReportsScreen()),
              ),
              const SizedBox(height: 10),

              _buildProfileNavTile(
                icon: Icons.system_update_alt_rounded,
                iconColor: const Color(0xFF10B981),
                title: 'Check for Updates',
                subtitle: 'Current build: v${AppVersionUtils.currentAppVersion}',
                trailingText: 'v${AppVersionUtils.currentAppVersion}',
                onTap: () => _handleManualUpdateCheck(context),
              ),
              const SizedBox(height: 24),

              // Logout Button
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
              const SizedBox(height: 26),

              // CineCore Brand Footer
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.25),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'CineCore Cinema Stream • v1.0.0',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.35),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildProfileStatColumn({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 14, color: color),
                  const SizedBox(width: 5),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePostPreview(CommunityPostModel post) {
    String timeAgo(DateTime dt) {
      final diff = DateTime.now().difference(dt);
      if (diff.inDays > 7) {
        return '${dt.day}/${dt.month}';
      } else if (diff.inDays >= 1) {
        return '${diff.inDays}d ago';
      } else if (diff.inHours >= 1) {
        return '${diff.inHours}h ago';
      } else if (diff.inMinutes >= 1) {
        return '${diff.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF161822),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: InkWell(
        onTap: () => Get.to(() => const MyPostsScreen()),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (post.images.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    ApiConstants.resolveImageUrl(post.images.first),
                    width: 54,
                    height: 54,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(
                      width: 54,
                      height: 54,
                      color: const Color(0xFF1F2436),
                      child: const Icon(
                        Icons.image_not_supported_rounded,
                        color: Colors.white38,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (post.movie != null) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.movie_creation_rounded,
                            color: Color(0xFFFBBF24),
                            size: 11,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              post.movie!.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFFFBBF24),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                    ],
                    Text(
                      post.caption.isNotEmpty ? post.caption : 'Shared media',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.favorite_rounded,
                              color: Color(0xFFEF4444),
                              size: 11,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${post.likesCount}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.chat_bubble_rounded,
                              color: Color(0xFF38BDF8),
                              size: 11,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${post.commentsCount}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          timeAgo(post.createdAt),
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white24,
                size: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileNavTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: const Color(0xFF161822),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: iconColor.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (trailingText != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  trailingText,
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white38,
              size: 13,
            ),
          ],
        ),
      ),
    );
  }
}
