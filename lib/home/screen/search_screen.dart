import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/search_controller.dart';
import '../../data/models/movie_model.dart';
import '../widget/search/search_filter_chips.dart';
import '../widget/search/search_input_header.dart';
import '../widget/search/search_movies_grid.dart';
import 'movie_details_screen.dart';

class SearchScreen extends StatelessWidget {
  final bool showBackButton;

  const SearchScreen({
    super.key,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MovieSearchController());

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

              // 1. Search Bar Header
              SliverToBoxAdapter(
                child: SearchInputHeader(
                  controller: controller.textController,
                  focusNode: controller.focusNode,
                  showBackButton: showBackButton,
                  onChanged: (val) => controller.onQueryChanged(val),
                  onClear: () {
                    controller.textController.clear();
                    controller.onQueryChanged('');
                  },
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // 2. Genre Filter Pills
              SliverToBoxAdapter(
                child: Obx(
                  () => SearchFilterChips(
                    genres: controller.genres,
                    selectedGenreIndex: controller.selectedGenreIndex.value,
                    onGenreSelected: (idx) => controller.setGenre(idx),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // 3. Trending Keywords (Shown when query is empty)
              SliverToBoxAdapter(
                child: Obx(() {
                  if (controller.searchQuery.value.isNotEmpty) {
                    return const SizedBox.shrink();
                  }
                  return _buildTrendingKeywords(controller);
                }),
              ),

              // 4. Search Results Header / Count
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          controller.searchQuery.value.isEmpty
                              ? 'EXPLORE POPULAR'
                              : 'RESULTS FOR "${controller.searchQuery.value.toUpperCase()}"',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                        Text(
                          '${controller.searchResults.length} Titles',
                          style: const TextStyle(
                            color: Color(0xFFFBBF24),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 5. Grid View of Movies
              SliverToBoxAdapter(
                child: Obx(
                  () => SearchMoviesGrid(
                    movies: controller.searchResults.toList(),
                    onMovieTap: (movie) => _navigateToDetails(movie),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 95)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingKeywords(MovieSearchController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.local_fire_department_rounded, color: Color(0xFFF59E0B), size: 16),
              SizedBox(width: 6),
              Text(
                'TRENDING SEARCHES',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.trendingKeywords.map((keyword) {
              return ActionChip(
                label: Text(
                  keyword,
                  style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                ),
                backgroundColor: const Color(0xFF161822),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Color(0xFF2A2D3A)),
                ),
                onPressed: () => controller.selectTrendingKeyword(keyword),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  void _navigateToDetails(MovieModel movie) {
    Get.to(
      () => MovieDetailsScreen(
        title: movie.title,
        subtitle: movie.subtitle ?? movie.genres,
        heroImageUrl: movie.imageUrl,
      ),
      transition: Transition.fadeIn,
    );
  }
}
