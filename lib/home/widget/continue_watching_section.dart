import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/watch_history_controller.dart';
import '../../data/models/continue_watching_model.dart';
import '../screen/watch_history_screen.dart';
import '../../controllers/playback_progress_controller.dart';

class ContinueWatchingSection extends StatelessWidget {
  final List<ContinueWatchingModel>? items;
  final ValueChanged<ContinueWatchingModel>? onItemTap;
  final VoidCallback? onSeeAll;

  const ContinueWatchingSection({
    super.key,
    this.items,
    this.onItemTap,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    if (items != null) {
      final filtered = items!.where((item) {
        final progress = item.progress;
        final isDone = item.status.toUpperCase() == 'COMPLETED' ||
            progress >= 0.90 ||
            PlaybackProgressController.to.isCompleted(item.movieId);
        return !isDone && progress > 0.0;
      }).toList();
      if (filtered.isEmpty) return const SizedBox.shrink();
      filtered.sort((a, b) => (b.lastWatchedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
          .compareTo(a.lastWatchedAt ?? DateTime.fromMillisecondsSinceEpoch(0)));
      return _buildContent(context, filtered);
    }

    // Bind to HomeController.continueWatching if registered
    if (Get.isRegistered<HomeController>()) {
      return Obx(() {
        final homeController = Get.find<HomeController>();
        final list = homeController.continueWatching;
        final filtered = list.where((item) {
          final progress = item.progress;
          final isDone = item.status.toUpperCase() == 'COMPLETED' ||
              progress >= 0.90 ||
              PlaybackProgressController.to.isCompleted(item.movieId);
          return !isDone && progress > 0.0;
        }).toList();
        if (filtered.isEmpty) return const SizedBox.shrink();
        filtered.sort((a, b) => (b.lastWatchedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
            .compareTo(a.lastWatchedAt ?? DateTime.fromMillisecondsSinceEpoch(0)));
        return _buildContent(context, filtered);
      });
    }

    return const SizedBox.shrink();
  }

  Widget _buildContent(BuildContext context, List<ContinueWatchingModel> displayItems) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header: "Continue Watching" + "Active Count" + "See All"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Text(
                    'Continue Watching',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      '${displayItems.length} Active',
                      style: const TextStyle(
                        color: Color(0xFFFBBF24),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),

              // "See All" Action to Watch History
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onSeeAll ?? () => Get.to(() => const WatchHistoryScreen()),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'History',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 11,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // List of Continue Watching Cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: displayItems.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: GestureDetector(
                  onTap: () => onItemTap?.call(item),
                  child: Container(
                    height: 104,
                    decoration: BoxDecoration(
                      color: const Color(0xFF13151E),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        // Thumbnail with Play Button & Glowing Progress Bar
                        SizedBox(
                          width: 130,
                          height: double.infinity,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: item.imageUrl.isNotEmpty
                                    ? Image.network(
                                        item.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => Container(
                                          color: const Color(0xFF202330),
                                          child: const Icon(Icons.movie, color: Colors.white24),
                                        ),
                                      )
                                    : Container(
                                        color: const Color(0xFF202330),
                                        child: const Icon(Icons.movie, color: Colors.white24),
                                      ),
                              ),

                              // Cinematic dark gradient on thumbnail
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.65),
                                    ],
                                  ),
                                ),
                              ),

                              // Center Glassmorphic Play Disc
                              Center(
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFBBF24),
                                        Color(0xFFF97316),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFF97316).withValues(alpha: 0.5),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow_rounded,
                                    color: Colors.black,
                                    size: 20,
                                  ),
                                ),
                              ),

                              // Bottom Glowing Gradient Progress Bar
                              Positioned(
                                left: 8,
                                right: 8,
                                bottom: 8,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Container(
                                    height: 4,
                                    color: Colors.white.withValues(alpha: 0.2),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: FractionallySizedBox(
                                        widthFactor: item.progress.clamp(0.0, 1.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFFE50914),
                                                Color(0xFFFF3B30),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(4),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFFE50914).withValues(alpha: 0.8),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Title, Episode info, Remaining time, Sound/Quality
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.episodeInfo,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFFFBBF24),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  if (item.remainingTime.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        item.remainingTime,
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.7),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 1.5,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        width: 0.6,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      item.qualityInfo,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    item.audioInfo,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.45),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Trailing Popup Menu Button (Replay or Remove)
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert_rounded,
                            color: Colors.white.withValues(alpha: 0.45),
                            size: 19,
                          ),
                          color: const Color(0xFF1B1E2D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                          ),
                          onSelected: (value) {
                            if (value == 'replay') {
                              if (Get.isRegistered<WatchHistoryController>()) {
                                Get.find<WatchHistoryController>()
                                    .resumeContinueWatching(item, fromBeginning: true);
                              } else {
                                onItemTap?.call(item);
                              }
                            } else if (value == 'remove') {
                              if (Get.isRegistered<WatchHistoryController>()) {
                                final controller = Get.find<WatchHistoryController>();
                                final found = controller.historyList
                                    .firstWhereOrNull((h) => h.id == item.id || h.movieId == item.movieId);
                                if (found != null) {
                                  controller.deleteHistoryItem(found);
                                }
                              }
                              if (Get.isRegistered<HomeController>()) {
                                Get.find<HomeController>()
                                    .continueWatching
                                    .removeWhere((c) => c.id == item.id);
                              }
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'replay',
                              child: Row(
                                children: [
                                  Icon(Icons.replay_rounded, color: Color(0xFFFBBF24), size: 16),
                                  SizedBox(width: 8),
                                  Text(
                                    'Play from Beginning',
                                    style: TextStyle(color: Colors.white, fontSize: 12.5),
                                  ),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'remove',
                              child: Row(
                                children: [
                                  Icon(Icons.close_rounded, color: Colors.redAccent, size: 16),
                                  SizedBox(width: 8),
                                  Text(
                                    'Remove from List',
                                    style: TextStyle(color: Colors.redAccent, fontSize: 12.5),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
