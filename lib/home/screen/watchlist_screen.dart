import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/watchlist_controller.dart';
import '../../data/models/movie_model.dart';
import '../widget/watchlist/watchlist_empty_view.dart';
import '../widget/watchlist/watchlist_item_card.dart';
import '../../core/utils/navigation_utils.dart';
import 'movie_player_screen.dart';

class WatchlistScreen extends StatelessWidget {
  final VoidCallback? onExploreMore;

  const WatchlistScreen({
    super.key,
    this.onExploreMore,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WatchlistController());

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: const Color(0xFF090A0E),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF090A0E),
        body: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // 1. Header & Stats
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            'MY WATCHLIST',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      Obx(
                        () => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${controller.watchlist.length} SAVED',
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
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // 2. Category Filter Pills
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 38,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: controller.categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      return Obx(() {
                        final isSelected = controller.selectedCategoryIndex.value == index;
                        return GestureDetector(
                          onTap: () => controller.selectedCategoryIndex.value = index,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFF161822),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFF2A2D3A),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                controller.categories[index],
                                style: TextStyle(
                                  color: isSelected ? Colors.black : Colors.white70,
                                  fontSize: 12.5,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      });
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // 3. Watchlist Items or Empty State
              SliverToBoxAdapter(
                child: Obx(() {
                  final items = controller.filteredWatchlist;

                  if (items.isEmpty) {
                    return WatchlistEmptyView(onExploreMore: onExploreMore);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final movie = items[index];
                      return WatchlistItemCard(
                        movie: movie,
                        onTap: () => _navigateToDetails(movie),
                        onRemove: () => controller.removeMovie(movie.id),
                        onPlay: () => _navigateToPlayer(movie),
                      );
                    },
                  );
                }),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 95)),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetails(MovieModel movie) {
    navigateToMediaDetails(media: movie);
  }

  void _navigateToPlayer(MovieModel movie) {
    Get.to(
      () => MoviePlayerScreen(
        title: movie.title,
        subtitle: movie.subtitle ?? movie.duration,
        heroImageUrl: movie.imageUrl,
      ),
      transition: Transition.fadeIn,
    );
  }
}
