import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/movie_details_controller.dart';
import '../../controllers/watchlist_controller.dart';
import '../../data/models/movie_model.dart';
import '../widget/details/movie_cast_list.dart';
import '../widget/details/movie_metadata_badges.dart';
import '../widget/details/movie_related_grid.dart';
import '../widget/details/movie_screenshots_gallery.dart';
import 'movie_player_screen.dart';

class MovieDetailsScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final String heroImageUrl;

  const MovieDetailsScreen({
    super.key,
    this.title = 'SCREAM VII',
    this.subtitle = 'The Bloodline Returns',
    this.heroImageUrl =
        'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?q=80&w=1200&auto=format&fit=crop',
  });

  @override
  Widget build(BuildContext context) {
    final detailsController = Get.put(
      MovieDetailsController(movieId: title.toLowerCase().replaceAll(' ', '_')),
      tag: title,
    );
    final watchlistController = Get.find<WatchlistController>();

    final movieEntity = MovieModel(
      id: title.toLowerCase().replaceAll(' ', '_'),
      title: title,
      subtitle: subtitle,
      imageUrl: heroImageUrl,
      rating: 9.3,
      releaseYear: '2025',
      duration: '2h 14m',
      resolution: '4K Ultra HD',
      genres: 'Horror, Mystery, Thriller',
      studio: 'Paramount Pictures',
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF090A0E),
        body: Stack(
          children: [
            // Scrollable Content
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 1. Hero Backdrop & Player Teaser
                SliverToBoxAdapter(
                  child: Stack(
                    children: [
                      Container(
                        height: 380,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(heroImageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.3),
                                Colors.transparent,
                                const Color(0xFF090A0E).withValues(alpha: 0.8),
                                const Color(0xFF090A0E),
                              ],
                              stops: const [0.0, 0.4, 0.85, 1.0],
                            ),
                          ),
                        ),
                      ),
                      // Play Button Overlay
                      Positioned.fill(
                        child: Center(
                          child: GestureDetector(
                            onTap: () => _navigateToPlayer(title, subtitle, heroImageUrl),
                            child: Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFF59E0B),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                                    blurRadius: 24,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.black,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Title, Badges & Actions
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Color(0xFFFBBF24),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Badges (Rating, Year, Duration, 4K)
                        const MovieMetadataBadges(
                          rating: 9.3,
                          releaseYear: '2025',
                          duration: '2h 14m',
                          resolution: '4K Ultra HD',
                          ageRating: 'R',
                        ),
                        const SizedBox(height: 20),

                        // Primary Action Buttons (Watch Now + Add to Watchlist)
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: ElevatedButton.icon(
                                onPressed: () => _navigateToPlayer(title, subtitle, heroImageUrl),
                                icon: const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 24),
                                label: const Text(
                                  'WATCH NOW',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF59E0B),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Obx(() {
                              final isInWatchlist = watchlistController.isMovieInWatchlist(title);
                              return Expanded(
                                flex: 2,
                                child: OutlinedButton.icon(
                                  onPressed: () => watchlistController.toggleWatchlist(movieEntity),
                                  icon: Icon(
                                    isInWatchlist ? Icons.check_rounded : Icons.bookmark_add_outlined,
                                    color: isInWatchlist ? const Color(0xFFFBBF24) : Colors.white,
                                    size: 18,
                                  ),
                                  label: Text(
                                    isInWatchlist ? 'SAVED' : 'WATCHLIST',
                                    style: TextStyle(
                                      color: isInWatchlist ? const Color(0xFFFBBF24) : Colors.white,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: isInWatchlist ? const Color(0xFFF59E0B) : const Color(0xFF2A2D3A),
                                      width: 1.2,
                                    ),
                                    backgroundColor: const Color(0xFF161822),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                        const SizedBox(height: 22),

                        // Synopsis Card
                        _buildSynopsis(detailsController),
                        const SizedBox(height: 26),
                      ],
                    ),
                  ),
                ),

                // 3. Cast & Crew Section
                SliverToBoxAdapter(
                  child: Obx(
                    () => MovieCastList(castMembers: detailsController.castMembers.toList()),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // 4. Production Stills Gallery
                SliverToBoxAdapter(
                  child: Obx(
                    () => MovieScreenshotsGallery(screenshots: detailsController.screenshots.toList()),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // 5. More Like This / Related Movies
                SliverToBoxAdapter(
                  child: Obx(
                    () => MovieRelatedGrid(
                      relatedMovies: detailsController.relatedMovies.toList(),
                      onMovieTap: (movie) {
                        Get.to(
                          () => MovieDetailsScreen(
                            title: movie.title,
                            subtitle: movie.genres,
                            heroImageUrl: movie.imageUrl,
                          ),
                          preventDuplicates: false,
                        );
                      },
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),

            // Top Floating Back Button
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSynopsis(MovieDetailsController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161822),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2D3A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'STORYLINE',
            style: TextStyle(
              color: Color(0xFFFBBF24),
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => Text(
              'As a new string of brutal murders shocks the survivors in Woodsboro, old secrets unravel about the original bloodline. Sam and Tara must face the most calculated and terrifying Ghostface yet, as the rules of the franchise evolve into uncharted psychological warfare.',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.5,
              ),
              maxLines: controller.isSynopsisExpanded.value ? null : 3,
              overflow: controller.isSynopsisExpanded.value ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => controller.toggleSynopsis(),
            child: Obx(
              () => Text(
                controller.isSynopsisExpanded.value ? 'Show Less ▲' : 'Read More ▼',
                style: const TextStyle(
                  color: Color(0xFFF59E0B),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPlayer(String title, String subtitle, String heroImageUrl) {
    Get.to(
      () => MoviePlayerScreen(
        title: title,
        subtitle: subtitle,
        heroImageUrl: heroImageUrl,
      ),
      transition: Transition.fadeIn,
    );
  }
}
