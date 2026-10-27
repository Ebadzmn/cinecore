import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../../controllers/series_details_controller.dart';
import '../../controllers/watchlist_controller.dart';
import '../../data/models/episode_model.dart';
import '../../data/models/movie_model.dart';
import '../widget/details/movie_cast_list.dart';
import '../widget/details/movie_metadata_badges.dart';
import '../widget/details/movie_related_grid.dart';
import '../widget/details/movie_screenshots_gallery.dart';
import '../widget/details/movie_synopsis_card.dart';
import '../widget/details/hero_title_description.dart';
import '../../core/utils/navigation_utils.dart';

class SeriesDetailsScreen extends StatefulWidget {
  final String? seriesId;
  final MovieModel? series;
  final String title;
  final String subtitle;
  final String heroImageUrl;

  const SeriesDetailsScreen({
    super.key,
    this.seriesId,
    this.series,
    this.title = 'BREAKING BAD',
    this.subtitle = 'Remember My Name',
    this.heroImageUrl =
        'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?q=80&w=1200&auto=format&fit=crop',
  });

  @override
  State<SeriesDetailsScreen> createState() => _SeriesDetailsScreenState();
}

class _SeriesDetailsScreenState extends State<SeriesDetailsScreen> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _seasonsScrollController = ScrollController();
  final Map<int, GlobalKey> _seasonKeys = {};

  @override
  void dispose() {
    _scrollController.dispose();
    _seasonsScrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _scrollToSeason(int seasonNum) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final key = _seasonKeys[seasonNum];
      if (key?.currentContext != null) {
        Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeInOutCubic,
          alignment: 0.35,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final effectiveId = widget.seriesId ??
        widget.series?.id ??
        (widget.title.isNotEmpty ? widget.title.toLowerCase().replaceAll(' ', '_') : 'series');

    final controller = Get.put(
      SeriesDetailsController(
        seriesId: effectiveId,
        initialSeries: widget.series,
      ),
      tag: 'series_$effectiveId',
    );

    final watchlistController = Get.find<WatchlistController>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF090A0E),
        body: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Top Section: Inline Video Player OR Hero Backdrop
            SliverToBoxAdapter(
              child: Obx(() {
                if (controller.isVideoActive.value) {
                  return _buildInlineVideoPlayer(context, controller);
                }
                return _buildHeroBackdrop(context, controller);
              }),
            ),

            // 2. Title, Badges, Synopsis & Actions
            SliverToBoxAdapter(
              child: Obx(() {
                final currentSeries = controller.series.value ?? widget.series;
                final activeTitle = currentSeries?.title ?? widget.title;
                final activeSubtitle = currentSeries?.tagline ??
                    currentSeries?.subtitle ??
                    (currentSeries?.genres != null ? currentSeries!.genres : widget.subtitle);

                final seriesEntity = currentSeries ??
                    MovieModel(
                      id: effectiveId,
                      title: activeTitle,
                      subtitle: activeSubtitle,
                      imageUrl: widget.heroImageUrl,
                      rating: 9.5,
                      type: 'SERIES',
                    );

                final int seasonCount = controller.availableSeasons.isNotEmpty
                    ? controller.availableSeasons.length
                    : (currentSeries?.totalSeasons ?? 1);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Series Title
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

                      // Metadata Badges (Rating, Seasons count, Year, Resolution, Age)
                      MovieMetadataBadges(
                        rating: currentSeries?.rating ?? 9.5,
                        releaseYear: currentSeries?.releaseYear ?? '2024',
                        duration: '$seasonCount ${seasonCount == 1 ? 'Season' : 'Seasons'}',
                        resolution: currentSeries?.resolution ?? '4K Ultra HD',
                        ageRating: currentSeries?.ageRating ?? 'TV-MA',
                      ),
                      const SizedBox(height: 14),

                      // Genres Pills
                      if (currentSeries != null && currentSeries.genres.isNotEmpty)
                        _buildGenresChips(currentSeries.genres),

                      const SizedBox(height: 18),

                      // Quick Action Buttons
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                final staged = controller.currentPlayingEpisode.value;
                                if (staged != null &&
                                    staged.seasonNumber == controller.selectedSeasonNumber.value) {
                                  controller.playEpisode(staged);
                                } else {
                                  final seasonEps = controller.currentSeasonEpisodes;
                                  if (seasonEps.isNotEmpty) {
                                    controller.playEpisode(seasonEps.first);
                                  } else if (staged != null) {
                                    controller.playEpisode(staged);
                                  } else if (controller.allEpisodes.isNotEmpty) {
                                    controller.playEpisode(controller.allEpisodes.first);
                                  }
                                }
                                _scrollToTop();
                              },
                              icon: const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 24),
                              label: Text(
                                controller.isVideoActive.value
                                    ? 'PLAYING AT TOP'
                                    : 'PLAY S${controller.selectedSeasonNumber.value} E1',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
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
                                onPressed: () => watchlistController.toggleWatchlist(seriesEntity),
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

                      const SizedBox(height: 18),

                      // Synopsis Section
                      MovieSynopsisCard(
                        synopsis: currentSeries?.synopsis,
                        subtitle: currentSeries?.subtitle,
                        tagline: currentSeries?.tagline,
                        director: currentSeries?.director,
                        studio: currentSeries?.studio,
                        audioCodec: currentSeries?.audioCodec,
                        videoCodec: currentSeries?.videoCodec,
                        releaseYear: currentSeries?.releaseYear,
                        category: currentSeries?.category,
                        isExpanded: controller.isSynopsisExpanded.value,
                        onToggleExpand: () => controller.toggleSynopsis(),
                      ),
                    ],
                  ),
                );
              }),
            ),

            // 3. Seasons & Episodes Section (Core Requirement)
            SliverToBoxAdapter(
              child: _buildSeasonsAndEpisodesSection(context, controller),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // 4. Cast & Crew Section
            SliverToBoxAdapter(
              child: Obx(
                () => MovieCastList(castMembers: controller.castMembers.toList()),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 26)),

            // 5. Production Stills Gallery (if available)
            SliverToBoxAdapter(
              child: Obx(() {
                if (controller.screenshots.isEmpty) return const SizedBox.shrink();
                return Column(
                  children: [
                    MovieScreenshotsGallery(screenshots: controller.screenshots.toList()),
                    const SizedBox(height: 26),
                  ],
                );
              }),
            ),

            // 6. “More Like This” Section
            SliverToBoxAdapter(
              child: Obx(
                () => MovieRelatedGrid(
                  relatedMovies: controller.moreLikeThisMovies.toList(),
                  onMovieTap: (selectedItem) {
                    navigateToMediaDetails(media: selectedItem);
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 56)),
          ],
        ),
      ),
    );
  }

  // --- Inline Video Player Section for Episodes ---
  Widget _buildInlineVideoPlayer(BuildContext context, SeriesDetailsController controller) {
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
                            'Episode stream unavailable or connecting...',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              if (controller.currentPlayingEpisode.value != null) {
                                controller.playEpisode(controller.currentPlayingEpisode.value!);
                              }
                            },
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

                  // Top Bar: Back, Episode Title & Controls (Quality, Mute, Speed)
                  Positioned(
                    top: 8,
                    left: 12,
                    right: 12,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => controller.stopPlayback(),
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
                          child: Obx(() {
                            final ep = controller.currentPlayingEpisode.value;
                            final epLabel = ep != null
                                ? '${ep.episodeCode} • ${ep.title}'
                                : widget.title;
                            return Text(
                              epLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            );
                          }),
                        ),
                        // Dynamic Quality Selector Button
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

                  // Center Controls: Prev Episode, Rewind, Play/Pause, Forward, Next Episode
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          iconSize: 26,
                          icon: const Icon(Icons.skip_previous_rounded, color: Colors.white70),
                          tooltip: 'Previous Episode',
                          onPressed: () => controller.playPreviousEpisode(),
                        ),
                        IconButton(
                          iconSize: 32,
                          icon: const Icon(Icons.replay_10_rounded, color: Colors.white),
                          onPressed: () => controller.seekBy(-10),
                        ),
                        const SizedBox(width: 14),
                        GestureDetector(
                          onTap: () => controller.togglePlayPause(),
                          child: Container(
                            width: 52,
                            height: 52,
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
                              size: 32,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        IconButton(
                          iconSize: 32,
                          icon: const Icon(Icons.forward_10_rounded, color: Colors.white),
                          onPressed: () => controller.seekBy(10),
                        ),
                        IconButton(
                          iconSize: 26,
                          icon: const Icon(Icons.skip_next_rounded, color: Colors.white70),
                          tooltip: 'Next Episode',
                          onPressed: () => controller.playNextEpisode(),
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
                                    onTap: () => controller.stopPlayback(),
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

  // --- Hero Backdrop Section (When not playing) ---
  Widget _buildHeroBackdrop(BuildContext context, SeriesDetailsController controller) {
    final currentSeries = controller.series.value ?? widget.series;
    final activeImage = (currentSeries?.backdropUrl != null &&
            currentSeries!.backdropUrl!.isNotEmpty)
        ? currentSeries.backdropUrl!
        : ((currentSeries?.imageUrl != null && currentSeries!.imageUrl.isNotEmpty)
            ? currentSeries.imageUrl
            : widget.heroImageUrl);

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
              child: const Icon(Icons.tv_rounded, color: Colors.white24, size: 60),
            ),
          ),
        ),

        // Gradient Fade Overlays
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.6),
                  Colors.transparent,
                  const Color(0xFF090A0E).withValues(alpha: 0.9),
                  const Color(0xFF090A0E),
                ],
                stops: const [0.0, 0.35, 0.8, 1.0],
              ),
            ),
          ),
        ),

        // Back Button
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.6)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.tv_rounded, color: Color(0xFFFBBF24), size: 14),
                      SizedBox(width: 5),
                      Text(
                        'TV SERIES',
                        style: TextStyle(
                          color: Color(0xFFFBBF24),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Center Play Circle Overlay
        Positioned.fill(
          child: Center(
            child: GestureDetector(
              onTap: () {
                if (controller.currentPlayingEpisode.value != null) {
                  controller.playEpisode(controller.currentPlayingEpisode.value!);
                } else if (controller.allEpisodes.isNotEmpty) {
                  controller.playEpisode(controller.allEpisodes.first);
                }
                _scrollToTop();
              },
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF59E0B),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.black,
                  size: 38,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- Seasons & Episodes Section ---
  Widget _buildSeasonsAndEpisodesSection(BuildContext context, SeriesDetailsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.video_library_rounded, color: Color(0xFFFBBF24), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'SEASONS & EPISODES',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Obx(() {
                final epCount = controller.currentSeasonEpisodes.length;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161822),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF2A2D3A)),
                  ),
                  child: Text(
                    '$epCount ${epCount == 1 ? 'Episode' : 'Episodes'}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Horizontal Season Pills Selector
        Obx(() {
          final seasons = controller.availableSeasons.toList();
          final selectedSeason = controller.selectedSeasonNumber.value;
          if (seasons.isEmpty) return const SizedBox.shrink();

          return SizedBox(
            height: 42,
            child: ListView.separated(
              controller: _seasonsScrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: seasons.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final seasonNum = seasons[index];
                final isSelected = selectedSeason == seasonNum;
                final count = controller.allEpisodes
                    .where((e) => e.seasonNumber == seasonNum)
                    .length;
                final itemKey = _seasonKeys.putIfAbsent(seasonNum, () => GlobalKey());

                return KeyedSubtree(
                  key: itemKey,
                  child: GestureDetector(
                    onTap: () {
                      controller.selectSeason(seasonNum);
                      _scrollToSeason(seasonNum);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.fastOutSlowIn,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFF161822),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF2A2D3A),
                          width: 1.2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Text(
                          count > 0 ? 'Season $seasonNum ($count)' : 'Season $seasonNum',
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }),
        const SizedBox(height: 16),

        // Episodes List for Selected Season
        Obx(() {
          final episodes = controller.currentSeasonEpisodes;
          final currentPlayingId = controller.currentPlayingEpisode.value?.id;
          final isVideoActive = controller.isVideoActive.value;

          if (episodes.isEmpty) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF12141D),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2A2D3A)),
              ),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.movie_filter_outlined, color: Colors.white24, size: 40),
                    const SizedBox(height: 10),
                    Text(
                      'No episodes uploaded for Season ${controller.selectedSeasonNumber.value} yet',
                      style: const TextStyle(color: Colors.white60, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: episodes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final episode = episodes[index];
              final isCurrentPlaying =
                  currentPlayingId == episode.id && isVideoActive;

              return _buildEpisodeCard(context, controller, episode, isCurrentPlaying);
            },
          );
        }),
      ],
    );
  }

  // --- Individual Episode Card ---
  Widget _buildEpisodeCard(
    BuildContext context,
    SeriesDetailsController controller,
    EpisodeModel episode,
    bool isCurrentPlaying,
  ) {
    final stillImage = (episode.stillPath != null && episode.stillPath!.isNotEmpty)
        ? episode.stillPath!
        : ((controller.series.value?.backdropUrl != null &&
                controller.series.value!.backdropUrl!.isNotEmpty)
            ? controller.series.value!.backdropUrl!
            : widget.heroImageUrl);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          controller.playEpisode(episode);
          _scrollToTop();
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isCurrentPlaying
                ? const Color(0xFFF59E0B).withValues(alpha: 0.12)
                : const Color(0xFF12141D),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCurrentPlaying
                  ? const Color(0xFFF59E0B)
                  : const Color(0xFF252837),
              width: isCurrentPlaying ? 1.8 : 1.0,
            ),
            boxShadow: isCurrentPlaying
                ? [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 16:9 Thumbnail Image with duration and play button
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 128,
                  height: 76,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        stillImage,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: const Color(0xFF1B1E2B),
                          child: const Icon(Icons.tv_rounded, color: Colors.white24),
                        ),
                      ),
                      Container(
                        color: Colors.black.withValues(alpha: 0.35),
                      ),
                      Center(
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCurrentPlaying
                                ? const Color(0xFFF59E0B)
                                : Colors.black.withValues(alpha: 0.65),
                            border: Border.all(
                              color: isCurrentPlaying
                                  ? const Color(0xFFFBBF24)
                                  : Colors.white38,
                            ),
                          ),
                          child: Icon(
                            isCurrentPlaying && controller.isVideoPlaying.value
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: isCurrentPlaying ? Colors.black : Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      // Duration badge bottom-right
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            episode.formattedDuration,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Title, Episode Code, and Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isCurrentPlaying
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFF1F2333),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            episode.episodeCode,
                            style: TextStyle(
                              color: isCurrentPlaying ? Colors.black : const Color(0xFFFBBF24),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (isCurrentPlaying)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'NOW PLAYING',
                              style: TextStyle(
                                color: Color(0xFFFBBF24),
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      episode.title,
                      style: TextStyle(
                        color: isCurrentPlaying ? const Color(0xFFFBBF24) : Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      episode.overview != null && episode.overview!.isNotEmpty
                          ? episode.overview!
                          : 'Episode ${episode.episodeNumber} of Season ${episode.seasonNumber}',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Dynamic Video Quality Selection Bottom Sheet ---
  void _showQualitySelectionSheet(BuildContext context, SeriesDetailsController controller) {
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
                // Modal Handle
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
                            'EPISODE VIDEO QUALITY',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Select preferred streaming resolution for this episode',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 11.5,
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

                // Dynamic Qualities List parsed from current Episode's M3U Playlist
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
                          'Only standard quality available for this episode',
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

  Widget _buildGenresChips(String genres) {
    final list = genres.split(',').map((g) => g.trim()).where((g) => g.isNotEmpty).toList();
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: list.map((genre) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF161822),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF252837)),
          ),
          child: Text(
            genre,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }
}
