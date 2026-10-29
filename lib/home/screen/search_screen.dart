import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/search_controller.dart';
import '../../data/models/movie_model.dart';
import '../widget/search/search_filter_chips.dart';
import '../widget/search/search_input_header.dart';
import '../widget/search/search_movies_grid.dart';
import '../../core/utils/navigation_utils.dart';

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
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xFF090A0E),
        body: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            color: const Color(0xFFF59E0B),
            backgroundColor: const Color(0xFF161822),
            onRefresh: () => controller.performSearch(),
            child: CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
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
                const SliverToBoxAdapter(child: SizedBox(height: 14)),

                // 2. Filter Pills & Controls (Media Type + Genres + Sort + View toggle)
                SliverToBoxAdapter(
                  child: Obx(
                    () => SearchFilterChips(
                      typeFilters: controller.typeFilters,
                      selectedTypeIndex: controller.selectedTypeIndex.value,
                      onTypeSelected: (idx) => controller.setTypeFilter(idx),
                      genres: controller.genres.toList(),
                      selectedGenreIndex: controller.selectedGenreIndex.value,
                      onGenreSelected: (idx) => controller.setGenre(idx),
                      selectedSortBy: controller.selectedSortBy.value,
                      sortOptions: controller.sortOptions,
                      onSortChanged: (sort) => controller.setSortBy(sort),
                      isGridView: controller.isGridView.value,
                      onToggleView: () => controller.toggleViewMode(),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // 3. Discovery Sections (Recent Searches & Trending Keywords when search bar is idle)
                SliverToBoxAdapter(
                  child: Obx(() {
                    if (controller.searchQuery.value.isNotEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (controller.recentSearches.isNotEmpty)
                          _buildRecentSearches(controller),
                        if (controller.trendingKeywords.isNotEmpty)
                          _buildTrendingKeywords(controller),
                      ],
                    );
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
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: 3,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF59E0B),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    controller.searchQuery.value.isEmpty
                                        ? 'EXPLORE CATALOG'
                                        : 'RESULTS FOR "${controller.searchQuery.value.toUpperCase()}"',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (controller.isLoading.value) ...[
                                const SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(Color(0xFFF59E0B)),
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],
                              Text(
                                '${controller.searchResults.length} Titles',
                                style: const TextStyle(
                                  color: Color(0xFFFBBF24),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 5. Grid or List View of Movies/Series
                SliverToBoxAdapter(
                  child: Obx(
                    () => SearchMoviesGrid(
                      movies: controller.searchResults.toList(),
                      isLoading: controller.isLoading.value,
                      isGridView: controller.isGridView.value,
                      onMovieTap: (movie) => _navigateToDetails(movie),
                      onClearFilters: () => controller.clearAllFilters(),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 95)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSearches(MovieSearchController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.history_rounded, color: Color(0xFFF59E0B), size: 15),
                  SizedBox(width: 6),
                  Text(
                    'RECENT SEARCHES',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => controller.clearRecentSearches(),
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.recentSearches.map((term) {
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF13151F),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF232738)),
                ),
                child: InkWell(
                  onTap: () => controller.selectRecentSearch(term),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            term,
                            style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => controller.removeRecentSearch(term),
                          child: Icon(
                            Icons.close_rounded,
                            size: 13,
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
        ],
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
              Icon(Icons.local_fire_department_rounded, color: Color(0xFFF59E0B), size: 15),
              SizedBox(width: 6),
              Text(
                'TRENDING DISCOVERIES',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
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
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFF59E0B).withValues(alpha: 0.12),
                      const Color(0xFF161822),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                  ),
                ),
                child: InkWell(
                  onTap: () => controller.selectTrendingKeyword(keyword),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.trending_up_rounded, color: Color(0xFFF59E0B), size: 13),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            keyword,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  void _navigateToDetails(MovieModel movie) {
    navigateToMediaDetails(media: movie);
  }
}
