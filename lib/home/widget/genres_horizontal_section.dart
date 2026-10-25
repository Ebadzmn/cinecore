import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/genre_model.dart';
import '../../data/services/movie_api_service.dart';
import '../screen/genre_movies_screen.dart';

class GenresHorizontalSection extends StatefulWidget {
  final ValueChanged<GenreModel>? onGenreSelected;

  const GenresHorizontalSection({
    super.key,
    this.onGenreSelected,
  });

  @override
  State<GenresHorizontalSection> createState() => _GenresHorizontalSectionState();
}

class _GenresHorizontalSectionState extends State<GenresHorizontalSection> {
  final MovieApiService _movieApiService = MovieApiService();
  List<GenreModel> _genres = MovieApiService.defaultGenres;

  @override
  void initState() {
    super.initState();
    _fetchGenres();
  }

  Future<void> _fetchGenres() async {
    try {
      final fetched = await _movieApiService.getGenres();
      if (mounted && fetched.isNotEmpty) {
        setState(() {
          _genres = fetched;
        });
      }
    } catch (_) {}
  }

  void _navigateToGenre(GenreModel genre) {
    if (widget.onGenreSelected != null) {
      widget.onGenreSelected!(genre);
    } else {
      Get.to(() => GenreMoviesScreen(genreName: genre.name));
    }
  }

  void _showAllGenresSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F111A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'All Genres',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Grid of Genres
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _genres.map((genre) {
                        final gradient = genre.gradientColors;
                        return InkWell(
                          onTap: () {
                            Navigator.pop(ctx);
                            _navigateToGenre(genre);
                          },
                          borderRadius: BorderRadius.circular(100),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF161824),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  genre.icon,
                                  size: 14,
                                  color: gradient.first,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  genre.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header: Simple & Premium
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Explore by Genre',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              GestureDetector(
                onTap: () => _showAllGenresSheet(context),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    Text(
                      'See All',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white.withValues(alpha: 0.55),
                      size: 10.5,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Horizontal Sleek Genre Pills
        SizedBox(
          height: 42,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _genres.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final genre = _genres[index];
              final gradient = genre.gradientColors;

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _navigateToGenre(genre),
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141622),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Soft Icon Container
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: gradient.first.withValues(alpha: 0.14),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              genre.icon,
                              size: 12,
                              color: gradient.first,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Genre Name
                        Text(
                          genre.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
