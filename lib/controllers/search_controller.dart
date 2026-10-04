import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/movie_model.dart';
import '../data/services/movie_api_service.dart';

class MovieSearchController extends GetxController {
  final MovieApiService _apiService = MovieApiService();
  final TextEditingController textController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  final RxString searchQuery = ''.obs;
  final RxInt selectedGenreIndex = 0.obs;
  final RxInt selectedStudioIndex = 0.obs;
  final RxBool isGridView = true.obs;
  final RxString selectedSortBy = 'Relevance'.obs;
  final RxBool isLoading = false.obs;

  final RxList<MovieModel> searchResults = <MovieModel>[].obs;

  final List<String> recentSearches = <String>[
    'Oppenheimer',
    'Dune Part Two',
    'Cyberpunk 2099',
    'Interstellar 4K',
  ].obs;

  final List<String> genres = const [
    'All',
    'Action',
    'Sci-Fi',
    'Drama',
    'Horror',
    'Thriller',
    'Adventure',
    'Fantasy',
  ];

  final List<String> studios = const [
    'All Studios',
    'Warner Bros.',
    'Universal',
    'Paramount',
    'Max',
    'Disney+',
    'Netflix',
  ];

  final List<String> trendingKeywords = const [
    'Scream VII',
    'Gladiator II',
    'Dead Reckoning',
    'Avatar 3',
    'Batman II',
  ];

  @override
  void onInit() {
    super.onInit();
    performSearch();
  }

  void onQueryChanged(String query) {
    searchQuery.value = query;
    performSearch();
  }

  void selectTrendingKeyword(String keyword) {
    textController.text = keyword;
    searchQuery.value = keyword;
    addRecentSearch(keyword);
    performSearch();
  }

  void addRecentSearch(String term) {
    if (term.trim().isEmpty) return;
    recentSearches.remove(term);
    recentSearches.insert(0, term);
    if (recentSearches.length > 8) {
      recentSearches.removeLast();
    }
  }

  void removeRecentSearch(String term) {
    recentSearches.remove(term);
  }

  void clearRecentSearches() {
    recentSearches.clear();
  }

  void setGenre(int index) {
    selectedGenreIndex.value = index;
    performSearch();
  }

  void setStudio(int index) {
    selectedStudioIndex.value = index;
    performSearch();
  }

  void setSortBy(String sortBy) {
    selectedSortBy.value = sortBy;
    performSearch();
  }

  Future<void> performSearch() async {
    try {
      isLoading.value = true;
      final results = await _apiService.searchMovies(
        query: searchQuery.value,
        genre: genres[selectedGenreIndex.value],
        studio: studios[selectedStudioIndex.value],
        sortBy: selectedSortBy.value,
      );
      searchResults.assignAll(results);
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    textController.dispose();
    focusNode.dispose();
    super.onClose();
  }
}
