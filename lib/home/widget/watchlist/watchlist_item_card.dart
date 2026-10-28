import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/movie_model.dart';
import '../../../controllers/playback_progress_controller.dart';
import '../watch_progress_bar.dart';

class WatchlistItemCard extends StatelessWidget {
  final MovieModel movie;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final VoidCallback onPlay;

  const WatchlistItemCard({
    super.key,
    required this.movie,
    required this.onTap,
    required this.onRemove,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final progressController = PlaybackProgressController.to;

    return Obx(() {
      final info = progressController.getProgress(movie.id);
      final double progress = (movie.watchProgress != null && movie.watchProgress! > 0)
          ? movie.watchProgress!
          : (info?.progressRatio ?? 0.0);

      final bool isCompleted = movie.isCompleted ||
          (info?.isCompleted ?? false) ||
          movie.status == 'COMPLETED' ||
          progress >= 0.90;

      final bool inProgress = progress > 0.0 && !isCompleted;
      final String remainingText = isCompleted
          ? 'Completed'
          : (movie.remainingTime ?? info?.remainingTime ?? '${(progress * 100).toInt()}% watched');

      final isSeries = movie.isSeries || movie.type?.toUpperCase() == 'SERIES';

      return GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF161822),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: inProgress
                  ? const Color(0xFFF59E0B).withValues(alpha: 0.35)
                  : isCompleted
                      ? const Color(0xFF10B981).withValues(alpha: 0.35)
                      : const Color(0xFF2A2D3A),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Poster with Play Overlay, Type Badge, and Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 88,
                      height: 125,
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        image: movie.imageUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(movie.imageUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: movie.imageUrl.isEmpty
                          ? const Center(
                              child: Icon(Icons.movie_creation_outlined, color: Colors.white24, size: 28),
                            )
                          : null,
                    ),

                    // Top-Left Content Type Badge: "MOVIE" or "SERIES"
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSeries
                              ? const Color(0xFF6366F1).withValues(alpha: 0.9) // Indigo for Series
                              : Colors.black.withValues(alpha: 0.8),          // Dark for Movie
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isSeries ? const Color(0xFFA5B4FC) : Colors.white24,
                            width: 0.6,
                          ),
                        ),
                        child: Text(
                          isSeries ? 'SERIES' : 'MOVIE',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                    // Center Play / Replay Overlay Button
                    GestureDetector(
                      onTap: onPlay,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFE50914).withValues(alpha: 0.95),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE50914).withValues(alpha: 0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isCompleted ? Icons.replay_rounded : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),

                    // Pinned bottom progress bar on the poster
                    if (progress > 0.0 || isCompleted)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: WatchProgressBar(
                          movieId: movie.id,
                          explicitProgress: isCompleted ? 1.0 : progress,
                          height: 3.5,
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Metadata & Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Remove Action
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            movie.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.bookmark_remove_rounded, color: Colors.white38, size: 20),
                          onPressed: onRemove,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: 'Remove from Watchlist',
                        ),
                      ],
                    ),

                    if (movie.subtitle != null && movie.subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        movie.subtitle!,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),

                    // Badges Row: Rating + Status Badge (COMPLETED / IN PROGRESS / SAVED)
                    Row(
                      children: [
                        // Rating
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 12),
                              const SizedBox(width: 3),
                              Text(
                                movie.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Color(0xFFFBBF24),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Viewing Status Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? const Color(0xFF10B981).withValues(alpha: 0.15)
                                : inProgress
                                    ? const Color(0xFFF59E0B).withValues(alpha: 0.15)
                                    : Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isCompleted
                                  ? const Color(0xFF10B981).withValues(alpha: 0.4)
                                  : inProgress
                                      ? const Color(0xFFF59E0B).withValues(alpha: 0.4)
                                      : Colors.white12,
                              width: 0.7,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isCompleted
                                    ? Icons.check_circle_rounded
                                    : inProgress
                                        ? Icons.timelapse_rounded
                                        : Icons.bookmark_added_rounded,
                                color: isCompleted
                                    ? const Color(0xFF34D399)
                                    : inProgress
                                        ? const Color(0xFFFBBF24)
                                        : Colors.white60,
                                size: 10,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                isCompleted
                                    ? 'COMPLETED'
                                    : inProgress
                                        ? 'IN PROGRESS'
                                        : 'SAVED',
                                style: TextStyle(
                                  color: isCompleted
                                      ? const Color(0xFF34D399)
                                      : inProgress
                                          ? const Color(0xFFFBBF24)
                                          : Colors.white70,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${movie.releaseYear ?? '2024'} • ${movie.duration}',
                            style: const TextStyle(color: Colors.white54, fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    // Progress section if in progress or completed
                    if (progress > 0.0 || isCompleted) ...[
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: isCompleted ? 1.0 : progress.clamp(0.0, 1.0),
                          backgroundColor: Colors.white12,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFE50914),
                          ),
                          minHeight: 4,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            remainingText,
                            style: const TextStyle(
                              color: Color(0xFFFF5252),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            isCompleted ? '100%' : '${(progress * 100).toInt()}%',
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
