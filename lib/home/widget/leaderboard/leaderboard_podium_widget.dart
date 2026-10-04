import 'package:flutter/material.dart';
import '../../../data/models/movie_model.dart';

class LeaderboardPodiumWidget extends StatelessWidget {
  final List<MovieModel> top3Movies;
  final ValueChanged<MovieModel>? onMovieTap;

  const LeaderboardPodiumWidget({
    super.key,
    required this.top3Movies,
    this.onMovieTap,
  });

  @override
  Widget build(BuildContext context) {
    if (top3Movies.length < 3) return const SizedBox.shrink();

    final rank2 = top3Movies[1];
    final rank1 = top3Movies[0];
    final rank3 = top3Movies[2];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // #2 Rank (Silver)
          Expanded(
            child: _buildPodiumColumn(
              movie: rank2,
              rank: 2,
              badgeColor: const Color(0xFF94A3B8),
              avatarSize: 74,
              podiumHeight: 90,
              onTap: () => onMovieTap?.call(rank2),
            ),
          ),
          const SizedBox(width: 8),

          // #1 Rank (Gold - Elevated)
          Expanded(
            child: _buildPodiumColumn(
              movie: rank1,
              rank: 1,
              badgeColor: const Color(0xFFF59E0B),
              avatarSize: 92,
              podiumHeight: 115,
              isFirst: true,
              onTap: () => onMovieTap?.call(rank1),
            ),
          ),
          const SizedBox(width: 8),

          // #3 Rank (Bronze)
          Expanded(
            child: _buildPodiumColumn(
              movie: rank3,
              rank: 3,
              badgeColor: const Color(0xFFD97706),
              avatarSize: 74,
              podiumHeight: 75,
              onTap: () => onMovieTap?.call(rank3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumColumn({
    required MovieModel movie,
    required int rank,
    required Color badgeColor,
    required double avatarSize,
    required double podiumHeight,
    bool isFirst = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Crown on Rank 1
          if (isFirst)
            const Icon(Icons.workspace_premium_rounded, color: Color(0xFFFBBF24), size: 26)
          else
            const SizedBox(height: 26),
          const SizedBox(height: 4),

          // Avatar Image with Glow
          Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              Container(
                width: avatarSize,
                height: avatarSize * 1.3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: badgeColor, width: isFirst ? 2.5 : 1.5),
                  boxShadow: [
                    if (isFirst)
                      BoxShadow(
                        color: badgeColor.withValues(alpha: 0.35),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                  ],
                  image: DecorationImage(
                    image: NetworkImage(movie.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: -10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Text(
                    '#$rank',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            movie.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            movie.boxOfficeOrStreams ?? '★ ${movie.rating.toStringAsFixed(1)}',
            style: const TextStyle(
              color: Color(0xFFFBBF24),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
