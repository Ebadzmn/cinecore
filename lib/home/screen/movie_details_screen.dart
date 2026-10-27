import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../../controllers/movie_details_controller.dart';
import '../../controllers/watchlist_controller.dart';
import '../../data/models/movie_model.dart';
import '../widget/details/movie_cast_list.dart';
import '../widget/details/movie_metadata_badges.dart';
import '../widget/details/movie_related_grid.dart';
import '../widget/details/movie_screenshots_gallery.dart';
import '../widget/details/movie_synopsis_card.dart';
import '../widget/details/hero_title_description.dart';
import '../../core/utils/navigation_utils.dart';
import 'series_details_screen.dart';

class MovieDetailsScreen extends StatelessWidget {
  final String? movieId;
  final MovieModel? movie;
  final String title;
  final String subtitle;
  final String heroImageUrl;

  const MovieDetailsScreen({
    super.key,
    this.movieId,
    this.movie,
    this.title = 'SCREAM VII',
    this.subtitle = 'The Bloodline Returns',
    this.heroImageUrl =
        'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?q=80&w=1200&auto=format&fit=crop',
  });

  @override
  Widget build(BuildContext context) {
    final effectiveId = movieId ??
        movie?.id ??
        (title.isNotEmpty ? title.toLowerCase().replaceAll(' ', '_') : 'movie');

    final detailsController = Get.put(
      MovieDetailsController(
        movieId: effectiveId,
        initialMovie: movie,
      ),
      tag: effectiveId,
    );

    final watchlistController = Get.find<WatchlistController>();

    if (movie != null && movie!.isSeries) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.off(
          () => SeriesDetailsScreen(
            seriesId: effectiveId,
            series: movie,
            title: title,
            subtitle: subtitle,
            heroImageUrl: heroImageUrl,
          ),
        );
      });
    }

    detailsController.movie.listen((loaded) {
      if (loaded != null && loaded.isSeries) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.off(
            () => SeriesDetailsScreen(
              seriesId: loaded.id,
              series: loaded,
              title: loaded.title,
              subtitle: loaded.genres,
              heroImageUrl: loaded.imageUrl,
            ),
          );
        });
      }
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF090A0E),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Top Horizontal Section: Inline Video Player or Hero Backdrop
            SliverToBoxAdapter(
              child: Obx(() {
                if (detailsController.isVideoActive.value) {
                  return _buildInlineVideoPlayer(context, detailsController);
                }
                return _buildHeroBackdrop(context, detailsController);
              }),
            ),

            // 2. Title, Badges & Actions
            SliverToBoxAdapter(
              child: Obx(() {
                final currentMovie = detailsController.movie.value ?? movie;
                final activeTitle = currentMovie?.title ?? title;
                final activeSubtitle = currentMovie?.tagline ??
                    currentMovie?.subtitle ??
                    (currentMovie?.genres != null ? currentMovie!.genres : subtitle);

                final movieEntity = currentMovie ??
                    MovieModel(
                      id: effectiveId,
                      title: activeTitle,
                      subtitle: activeSubtitle,
                      imageUrl: heroImageUrl,
                      rating: 9.0,
                    );

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activeTitle.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          height: 1.2,
                        ),
                      ),
                      HeroTitleDescription(text: activeSubtitle),
                      const SizedBox(height: 2),

                      // Badges (Rating, Year, Duration, Resolution, Age)
                      MovieMetadataBadges(
                        rating: currentMovie?.rating ?? 8.5,
                        releaseYear: currentMovie?.releaseYear ?? '2024',
                        duration: currentMovie?.duration ?? '2h 00m',
                        resolution: currentMovie?.resolution ?? '4K Ultra HD',
                        ageRating: currentMovie?.ageRating ?? 'PG-13',
                      ),
                      const SizedBox(height: 14),

                      // Genres Pills
                      if (currentMovie != null && currentMovie.genres.isNotEmpty)
                        _buildGenresChips(currentMovie.genres),

                      if (currentMovie != null && currentMovie.isSeries) ...[
                        const SizedBox(height: 14),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Get.off(
                                () => SeriesDetailsScreen(
                                  seriesId: currentMovie.id,
                                  series: currentMovie,
                                  title: activeTitle,
                                  subtitle: activeSubtitle,
                                  heroImageUrl: heroImageUrl,
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFF59E0B).withValues(alpha: 0.2),
                                    const Color(0xFF1E2130),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFF59E0B).withValues(alpha: 0.6),
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF59E0B),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.video_library_rounded, color: Colors.black, size: 20),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'TV SERIES AVAILABLE',
                                          style: TextStyle(
                                            color: Color(0xFFFBBF24),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                        Text(
                                          'Explore ${currentMovie.totalSeasons > 0 ? '${currentMovie.totalSeasons} Seasons &' : ''} Episodes',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFF59E0B), size: 14),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Primary Action Buttons (Watch Now inline + Add to Watchlist)
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: ElevatedButton.icon(
                              onPressed: () => detailsController.startInlinePlayback(),
                              icon: const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 24),
                              label: Text(
                                detailsController.isVideoActive.value ? 'PLAYING AT TOP' : 'WATCH NOW',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 13.5,
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
                                elevation: 6,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Obx(() {
                            final isInWatchlist = watchlistController.isMovieInWatchlist(activeTitle);
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
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: isInWatchlist
                                        ? const Color(0xFFF59E0B)
                                        : const Color(0xFF2A2D3A),
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
                      _buildSynopsis(detailsController, currentMovie),
                      const SizedBox(height: 22),

                      // Technical & Production Metadata Grid
                      if (currentMovie != null) ...[
                        _buildMetadataGrid(currentMovie),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                );
              }),
            ),

            // 3. Cast & Crew Section
            SliverToBoxAdapter(
              child: Obx(
                () => MovieCastList(castMembers: detailsController.castMembers.toList()),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 26)),

            // 4. Production Stills Gallery (if available)
            SliverToBoxAdapter(
              child: Obx(() {
                if (detailsController.screenshots.isEmpty) return const SizedBox.shrink();
                return Column(
                  children: [
                    MovieScreenshotsGallery(screenshots: detailsController.screenshots.toList()),
                    const SizedBox(height: 26),
                  ],
                );
              }),
            ),

            // 5. “More Like This” Section (other movies from same category/genre)
            SliverToBoxAdapter(
              child: Obx(
                () => MovieRelatedGrid(
                  relatedMovies: detailsController.moreLikeThisMovies.toList(),
                  onMovieTap: (selectedMovie) {
                    navigateToMediaDetails(media: selectedMovie);
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 48)),
          ],
        ),
      ),
    );
  }

  // --- 1. Top Section: Inline Horizontal Video Player ---
  Widget _buildInlineVideoPlayer(BuildContext context, MovieDetailsController controller) {
    return Container(
      color: Colors.black,
      width: double.infinity,
      child: SafeArea(
        bottom: false,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: GestureDetector(
            onTap: () => controller.toggleControls(),
            behavior: HitTestBehavior.opaque,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Video Stream Surface
                if (controller.isVideoInitialized.value &&
                    controller.videoPlayerController != null)
                  Center(
                    child: AspectRatio(
                      aspectRatio: controller.videoPlayerController!.value.aspectRatio > 0
                          ? controller.videoPlayerController!.value.aspectRatio
                          : 16 / 9,
                      child: VideoPlayer(controller.videoPlayerController!),
                    ),
                  )
                else
                  Container(
                    color: const Color(0xFF090A0E),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFF59E0B),
                        strokeWidth: 3,
                      ),
                    ),
                  ),

                // Buffering / Quality Switching Spinner
                if (controller.isVideoBuffering.value || controller.isQualityChanging.value)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          color: Color(0xFFF59E0B),
                          strokeWidth: 3,
                        ),
                        if (controller.isQualityChanging.value) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Switching to ${controller.selectedQuality.value}...',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                // Error Notice
                if (controller.videoHasError.value)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Stream unavailable or connecting...',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => controller.startInlinePlayback(),
                            child: const Text(
                              'RETRY',
                              style: TextStyle(
                                color: Color(0xFFF59E0B),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Video HUD Controls Overlay
                if (controller.showVideoControls.value) ...[
                  // Gradient shadow
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.75),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.85),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),

                  // Top Bar: Back / Close inline, Title & Controls (Quality, Mute, Speed)
                  Positioned(
                    top: 8,
                    left: 12,
                    right: 12,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => controller.stopInlinePlayback(),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 15,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Video Quality button
                        GestureDetector(
                          onTap: () => _showQualitySelectionSheet(context, controller),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF161822),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF2A2D3A)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.tune_rounded, color: Color(0xFFFBBF24), size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  controller.selectedQuality.value,
                                  style: const TextStyle(
                                    color: Color(0xFFFBBF24),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Mute button
                        GestureDetector(
                          onTap: () => controller.toggleMute(),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF161822),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF2A2D3A)),
                            ),
                            child: Icon(
                              controller.isMuted.value
                                   ? Icons.volume_off_rounded
                                  : Icons.volume_up_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Speed button
                        GestureDetector(
                          onTap: () => controller.cycleSpeed(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF161822),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF2A2D3A)),
                            ),
                            child: Text(
                              '${controller.videoSpeed.value}x',
                              style: const TextStyle(
                                color: Color(0xFFFBBF24),
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Center Controls: Rewind, Play/Pause, Forward
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          iconSize: 32,
                          icon: const Icon(Icons.replay_10_rounded, color: Colors.white),
                          onPressed: () => controller.seekBy(-10),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () => controller.togglePlayPause(),
                          child: Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFF59E0B),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                                  blurRadius: 18,
                                ),
                              ],
                            ),
                            child: Icon(
                              controller.isVideoPlaying.value
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.black,
                              size: 34,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          iconSize: 32,
                          icon: const Icon(Icons.forward_10_rounded, color: Colors.white),
                          onPressed: () => controller.seekBy(10),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Timeline Bar
                  Positioned(
                    bottom: 4,
                    left: 12,
                    right: 12,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3,
                            activeTrackColor: const Color(0xFFF59E0B),
                            inactiveTrackColor: Colors.white24,
                            thumbColor: const Color(0xFFFBBF24),
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                          ),
                          child: Slider(
                            value: controller.currentVideoSeconds.value.clamp(
                              0.0,
                              controller.totalVideoSeconds.value > 0
                                  ? controller.totalVideoSeconds.value
                                  : 100.0,
                            ),
                            min: 0.0,
                            max: controller.totalVideoSeconds.value > 0
                                ? controller.totalVideoSeconds.value
                                : 100.0,
                            onChanged: (val) => controller.seekTo(val),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${controller.formatTime(controller.currentVideoSeconds.value)} / ${controller.formatTime(controller.totalVideoSeconds.value)}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => _showQualitySelectionSheet(context, controller),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.hd_outlined, color: Color(0xFFFBBF24), size: 11),
                                          const SizedBox(width: 3),
                                          Text(
                                            controller.selectedQuality.value.toUpperCase(),
                                            style: const TextStyle(
                                              color: Color(0xFFFBBF24),
                                              fontSize: 8.5,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () => controller.stopInlinePlayback(),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      color: Colors.white70,
                                      size: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Quality Selection Bottom Sheet ---
  void _showQualitySelectionSheet(BuildContext context, MovieDetailsController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          decoration: const BoxDecoration(
            color: Color(0xFF12141D),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: Color(0xFF2A2D3A), width: 1.5),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Title Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: Color(0xFFFBBF24),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'VIDEO QUALITY',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Select preferred streaming resolution',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Divider(color: Color(0xFF202330), height: 1),
                const SizedBox(height: 12),

                // Dynamic Quality Options List from M3U Playlist
                Obx(() {
                  if (controller.isQualitiesLoading.value && controller.availableQualities.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFF59E0B),
                          strokeWidth: 2.5,
                        ),
                      ),
                    );
                  }

                  if (controller.availableQualities.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          'Only standard quality available for this video',
                          style: TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      ),
                    );
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: controller.availableQualities.map((opt) {
                      final isSelected = controller.selectedQuality.value == opt.id;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              Navigator.of(ctx).pop();
                              controller.changeQuality(opt);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFF59E0B).withValues(alpha: 0.12)
                                    : const Color(0xFF161822),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFF59E0B)
                                      : const Color(0xFF252837),
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFFF59E0B)
                                          : const Color(0xFF202330),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      opt.badge,
                                      style: TextStyle(
                                        color: isSelected ? Colors.black : Colors.white70,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          opt.title,
                                          style: TextStyle(
                                            color: isSelected ? const Color(0xFFFBBF24) : Colors.white,
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          opt.subtitle,
                                          style: TextStyle(
                                            color: isSelected ? Colors.white70 : Colors.white54,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: Color(0xFFF59E0B),
                                      size: 20,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- 2. Top Section: Hero Backdrop (When not playing) ---
  Widget _buildHeroBackdrop(BuildContext context, MovieDetailsController controller) {
    final currentMovie = controller.movie.value ?? movie;
    final activeImage = (currentMovie?.backdropUrl != null &&
            currentMovie!.backdropUrl!.isNotEmpty)
        ? currentMovie.backdropUrl!
        : ((currentMovie?.imageUrl != null && currentMovie!.imageUrl.isNotEmpty)
            ? currentMovie.imageUrl
            : heroImageUrl);

    return Stack(
      children: [
        Container(
          height: 380,
          width: double.infinity,
          color: const Color(0xFF161822),
          child: Image.network(
            activeImage,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              color: const Color(0xFF161822),
              child: const Center(
                child: Icon(Icons.movie_creation_outlined, color: Colors.white24, size: 64),
              ),
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
                  Colors.black.withValues(alpha: 0.35),
                  Colors.transparent,
                  const Color(0xFF090A0E).withValues(alpha: 0.85),
                  const Color(0xFF090A0E),
                ],
                stops: const [0.0, 0.4, 0.82, 1.0],
              ),
            ),
          ),
        ),
        // Big Center Play Button (starts inline horizontal playback)
        Positioned.fill(
          child: Center(
            child: GestureDetector(
              onTap: () => controller.startInlinePlayback(),
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF59E0B),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.55),
                      blurRadius: 28,
                      spreadRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.black,
                  size: 44,
                ),
              ),
            ),
          ),
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
                color: Colors.black.withValues(alpha: 0.65),
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
    );
  }

  Widget _buildGenresChips(String genres) {
    final list = genres.split(',').map((g) => g.trim()).where((g) => g.isNotEmpty).toList();
    if (list.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: list.map((genre) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF161822),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF2A2D3A)),
          ),
          child: Text(
            genre,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSynopsis(MovieDetailsController controller, MovieModel? currentMovie) {
    return Obx(
      () => MovieSynopsisCard(
        synopsis: currentMovie?.synopsis,
        subtitle: currentMovie?.subtitle,
        tagline: currentMovie?.tagline,
        director: currentMovie?.director,
        studio: currentMovie?.studio,
        audioCodec: currentMovie?.audioCodec,
        videoCodec: currentMovie?.videoCodec,
        releaseYear: currentMovie?.releaseYear,
        category: currentMovie?.category,
        isExpanded: controller.isSynopsisExpanded.value,
        onToggleExpand: () => controller.toggleSynopsis(),
      ),
    );
  }

  Widget _buildMetadataGrid(MovieModel currentMovie) {
    final items = <Map<String, dynamic>>[];

    if (currentMovie.director != null && currentMovie.director!.isNotEmpty) {
      items.add({
        'icon': Icons.movie_filter_outlined,
        'label': 'Director',
        'value': currentMovie.director!,
      });
    }
    if (currentMovie.category != null && currentMovie.category!.isNotEmpty) {
      items.add({
        'icon': Icons.category_outlined,
        'label': 'Category',
        'value': currentMovie.category!,
      });
    }
    if (currentMovie.studio != null && currentMovie.studio!.isNotEmpty) {
      items.add({
        'icon': Icons.business_outlined,
        'label': 'Studio',
        'value': currentMovie.studio!,
      });
    }
    if (currentMovie.videoCodec != null && currentMovie.videoCodec!.isNotEmpty) {
      items.add({
        'icon': Icons.videocam_outlined,
        'label': 'Video Codec',
        'value': currentMovie.videoCodec!.toUpperCase(),
      });
    }
    if (currentMovie.audioCodec != null && currentMovie.audioCodec!.isNotEmpty) {
      items.add({
        'icon': Icons.surround_sound_rounded,
        'label': 'Audio Codec',
        'value': currentMovie.audioCodec!.toUpperCase(),
      });
    }
    if (currentMovie.type != null && currentMovie.type!.isNotEmpty) {
      items.add({
        'icon': Icons.video_collection_outlined,
        'label': 'Format',
        'value': currentMovie.type!,
      });
    }
    if (currentMovie.releaseYear != null && currentMovie.releaseYear!.isNotEmpty) {
      items.add({
        'icon': Icons.calendar_today_outlined,
        'label': 'Release Year',
        'value': currentMovie.releaseYear!,
      });
    }
    if (currentMovie.duration.isNotEmpty) {
      items.add({
        'icon': Icons.schedule_rounded,
        'label': 'Runtime',
        'value': currentMovie.duration,
      });
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF161926),
            Color(0xFF11131E),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF262A3B),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: Color(0xFFFBBF24),
                  size: 15,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'PRODUCTION & TECHNICAL SPECS',
                style: TextStyle(
                  color: Color(0xFFFBBF24),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final double itemWidth = (constraints.maxWidth - 12) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 10,
                children: items.map((item) {
                  return Container(
                    width: itemWidth,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141723),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF232738),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1D2132),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            item['icon'] as IconData,
                            color: const Color(0xFFFBBF24),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item['label'] as String,
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item['value'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
