import 'package:flutter/material.dart';
import '../model/home_models.dart';
import 'premium_movie_card.dart';

class PeacockPicksSection extends StatelessWidget {
  final ValueChanged<MovieModel>? onMovieTap;
  final VoidCallback? onSeeAll;

  const PeacockPicksSection({
    super.key,
    this.onMovieTap,
    this.onSeeAll,
  });

  static const List<MovieModel> picks = [
    MovieModel(
      id: '1',
      title: 'Wicked: Eldritch',
      subtitle: '2024 • Fantasy, Sci-Fi',
      imageUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?q=80&w=600&auto=format&fit=crop',
      rating: 9.2,
      releaseYear: '2024',
      genres: 'Fantasy, Sci-Fi',
      resolution: '4K HDR',
      duration: '2h 18m',
      ageRating: '13+',
    ),
    MovieModel(
      id: '2',
      title: 'Undead Avengers',
      subtitle: '2024 • Action, Horror',
      imageUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?q=80&w=600&auto=format&fit=crop',
      rating: 8.8,
      badge: 'NEW',
      releaseYear: '2024',
      genres: 'Action, Horror',
      resolution: 'IMAX',
      duration: '1h 56m',
      ageRating: '18+',
    ),
    MovieModel(
      id: '3',
      title: 'The Raven Realm',
      subtitle: '2023 • Mystery, Drama',
      imageUrl: 'https://images.unsplash.com/photo-1514306191717-452ec28c7814?q=80&w=600&auto=format&fit=crop',
      rating: 8.7,
      releaseYear: '2023',
      genres: 'Mystery, Drama',
      resolution: '4K UHD',
      duration: '2h 05m',
      ageRating: '16+',
    ),
    MovieModel(
      id: '4',
      title: 'Cyberpunk 2099',
      subtitle: '2024 • Cyberpunk, Action',
      imageUrl: 'https://images.unsplash.com/photo-1514565131-fce0801e5785?q=80&w=600&auto=format&fit=crop',
      rating: 9.0,
      releaseYear: '2024',
      genres: 'Cyberpunk, Action',
      resolution: 'DOLBY',
      duration: '2h 12m',
      ageRating: '18+',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header: "Peacock Picks" + "See All >"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Peacock Picks',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              GestureDetector(
                onTap: onSeeAll,
                child: Row(
                  children: [
                    Text(
                      'See All',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 13,
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

        // Horizontal Poster Scroll
        SizedBox(
          height: 285,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: picks.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final movie = picks[index];

              return PremiumMovieCard(
                movie: movie,
                width: 152,
                height: 220,
                onTap: () => onMovieTap?.call(movie),
                onBookmarkTap: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Updated watchlist for ${movie.title}'),
                      backgroundColor: const Color(0xFF161822),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
