import 'watch_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/genre_model.dart';
import '../../data/models/movie_model.dart';
import '../../data/services/movie_api_service.dart';
import '../screen/genre_movies_screen.dart';
import '../screen/movie_player_screen.dart';
import '../../core/utils/navigation_utils.dart';

class GenreMovieRowSection extends StatefulWidget {
  final String genreName;
  final String? title;
  final String? subtitle;
  final List<MovieModel>? movies;
  final ValueChanged<MovieModel>? onMovieTap;

  const GenreMovieRowSection({
    super.key,
    required this.genreName,
    this.title,
    this.subtitle,
    this.movies,
    this.onMovieTap,
  });

  @override
  State<GenreMovieRowSection> createState() => _GenreMovieRowSectionState();
}

class _GenreMovieRowSectionState extends State<GenreMovieRowSection> {
  final MovieApiService _movieApiService = MovieApiService();
  List<MovieModel> _movies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.movies != null && widget.movies!.isNotEmpty) {
      _movies = widget.movies!;
      _isLoading = false;
    } else {
      _fetchMovies();
    }
  }

  @override
  void didUpdateWidget(covariant GenreMovieRowSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.movies != null) {
      setState(() {
        _movies = widget.movies!;
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchMovies() async {
    try {
      final list = await _movieApiService.getMoviesByGenre(widget.genreName, limit: 10);
      if (mounted) {
        setState(() {
          _movies = list.take(10).toList();
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToDetails(MovieModel movie) {
    if (widget.onMovieTap != null) {
      widget.onMovieTap!(movie);
    } else {
      navigateToMediaDetails(media: movie);
    }
  }

  @override
  Widget build(BuildContext context) {
    final genreModel = GenreModel(name: widget.genreName);
    final gradient = genreModel.gradientColors;
    final displayTitle = widget.title ?? '${widget.genreName} Movies';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header: Title + 'See All >'
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 3.5,
                    height: 16,
                    decoration: BoxDecoration(
                      color: gradient.first,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: gradient.first.withValues(alpha: 0.5),
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 9),
                  Text(
                    displayTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Get.to(() => GenreMoviesScreen(genreName: widget.genreName)),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    Text(
                      'See All',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white.withValues(alpha: 0.6),
                      size: 11,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 10 Movie Horizontal Cards Scroll
        SizedBox(
          height: 255,
          child: _isLoading
              ? _buildLoadingShimmer()
              : _movies.isEmpty
                  ? const SizedBox.shrink()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _movies.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final movie = _movies[index];
                        return _buildMovieCard(movie, gradient);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      separatorBuilder: (context, index) => const SizedBox(width: 14),
      itemBuilder: (context, index) {
        return Container(
          width: 148,
          decoration: BoxDecoration(
            color: const Color(0xFF141622),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMovieCard(MovieModel movie, List<Color> gradient) {
    return SizedBox(
      width: 146,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToDetails(movie),
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poster Container
              Container(
                height: 195,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Image
                      Image.network(
                        movie.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                gradient.first.withValues(alpha: 0.25),
                                const Color(0xFF161822),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.movie_filter_rounded,
                              size: 36,
                              color: Colors.white.withValues(alpha: 0.35),
                            ),
                          ),
                        ),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: const Color(0xFF141622),
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFFF59E0B),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      // Top Rating Badge
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6.5,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 12,
                                color: Color(0xFFF59E0B),
                              ),
                              const SizedBox(width: 2.5),
                              Text(
                                movie.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // In-Poster Bottom Vignette & Resolution Pill
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 55,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.85),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        bottom: 8,
                        left: 8,
                        right: 8,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                movie.resolution,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            const Spacer(),
                            // Quick Play Icon
                            GestureDetector(
                              onTap: () {
                                Get.to(
                                  () => MoviePlayerScreen(
                                    movieId: movie.id,
                                    title: movie.title,
                                    subtitle: movie.subtitle ?? movie.genres,
                                    heroImageUrl: movie.imageUrl,
                                    watchUrl: movie.watchUrl ?? movie.playbackUrl,
                                  ),
                                );
                              },
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF59E0B),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                                      blurRadius: 6,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  size: 15,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Pinned bottom progress bar
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: WatchProgressBar(
                          movieId: movie.id,
                          explicitProgress: movie.watchProgress,
                          height: 3.5,
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      // Border overlay
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.08),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Title
              Text(
                movie.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 2),

              // Meta (Year • Duration or Genre)
              Text(
                '${movie.releaseYear ?? '2024'} • ${movie.duration}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
