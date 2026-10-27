import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/movie_model.dart';
import '../data/services/movie_api_service.dart';

class MovieSearchController extends GetxController {
  final MovieApiService _apiService = MovieApiService();
  final TextEditingController textController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  Timer? _debounceTimer;

  final RxString searchQuery = ''.obs;
  final RxInt selectedTypeIndex = 0.obs; // 0: All, 1: Movies, 2: Series
  final RxInt selectedGenreIndex = 0.obs;
  final RxString selectedSortBy = 'Relevance'.obs;
  final RxBool isGridView = true.obs;
  final RxBool isLoading = false.obs;

  final RxList<MovieModel> searchResults = <MovieModel>[].obs;
  final RxList<String> recentSearches = <String>[].obs;
  final RxList<String> genres = <String>['All'].obs;
  final RxList<String> trendingKeywords = <String>[].obs;

  final List<String> typeFilters = const ['All', 'Movies', 'Series'];
  final List<String> sortOptions = const ['Relevance', 'Rating', 'Newest', 'A-Z'];

  static const String _prefRecentKey = 'cinecore_recent_searches';

  @override
  void onInit() {
    super.onInit();
    _loadRecentSearches();
    _loadInitialData();
  }

  Future<void> _loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_prefRecentKey);
      if (saved != null && saved.isNotEmpty) {
        recentSearches.assignAll(saved);
      } else {
        recentSearches.assignAll([
          'Breaking Bad',
          'Dune',
          'Prison Break',
          'Diamonds Are Forever',
        ]);
      }
    } catch (_) {}
  }

  Future<void> _saveRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefRecentKey, recentSearches.toList());
    } catch (_) {}
  }

  Future<void> _loadInitialData() async {
    try {
      // 1. Fetch suggestions and genres in parallel
      final suggestionsFuture = _apiService.getSearchSuggestions();
      final genresFuture = _apiService.getGenres();

      final results = await Future.wait([suggestionsFuture, genresFuture]);
      final suggestions = results[0] as Map<String, List<String>>;
      final apiGenres = results[1] as List<dynamic>;

      if (suggestions['trendingKeywords'] != null && suggestions['trendingKeywords']!.isNotEmpty) {
        trendingKeywords.assignAll(suggestions['trendingKeywords']!);
      }

      final genreNames = <String>['All'];
      for (final g in apiGenres) {
        final name = g.name.toString();
        if (!genreNames.contains(name)) {
          genreNames.add(name);
        }
      }
      if (genreNames.length > 1) {
        genres.assignAll(genreNames);
      } else {
        genres.assignAll([
          'All',
          'Action',
          'Crime',
          'Drama',
          'Sci-Fi',
          'Adventure',
          'Thriller',
          'Comedy',
          'Horror',
        ]);
      }
    } catch (_) {
      genres.assignAll([
        'All',
        'Action',
        'Crime',
        'Drama',
        'Sci-Fi',
        'Adventure',
        'Thriller',
        'Comedy',
      ]);
    } finally {
      // Perform initial catalog load
      performSearch(isBackground: false);
    }
  }

  /// Real-time 350ms debounced typing search
  void onQueryChanged(String query) {
    searchQuery.value = query;
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      performSearch();
    } else {
      _debounceTimer = Timer(const Duration(milliseconds: 350), () {
        performSearch();
        addRecentSearch(query.trim());
      });
    }
  }

  void selectTrendingKeyword(String keyword) {
    textController.text = keyword;
    searchQuery.value = keyword;
    addRecentSearch(keyword);
    performSearch();
  }

  void selectRecentSearch(String keyword) {
    textController.text = keyword;
    searchQuery.value = keyword;
    performSearch();
  }

  void addRecentSearch(String term) {
    if (term.trim().isEmpty) return;
    recentSearches.remove(term);
    recentSearches.insert(0, term);
    if (recentSearches.length > 8) {
      recentSearches.removeLast();
    }
    _saveRecentSearches();
  }

  void removeRecentSearch(String term) {
    recentSearches.remove(term);
    _saveRecentSearches();
  }

  void clearRecentSearches() {
    recentSearches.clear();
    _saveRecentSearches();
  }

  void setTypeFilter(int index) {
    if (selectedTypeIndex.value == index) return;
    selectedTypeIndex.value = index;
    performSearch();
  }

  void setGenre(int index) {
    if (selectedGenreIndex.value == index) return;
    selectedGenreIndex.value = index;
    performSearch();
  }

  void setSortBy(String sortBy) {
    if (selectedSortBy.value == sortBy) return;
    selectedSortBy.value = sortBy;
    performSearch();
  }

  void toggleViewMode() {
    isGridView.value = !isGridView.value;
  }

  void clearAllFilters() {
    textController.clear();
    searchQuery.value = '';
    selectedTypeIndex.value = 0;
    selectedGenreIndex.value = 0;
    selectedSortBy.value = 'Relevance';
    performSearch();
  }

  Future<void> performSearch({bool isBackground = false}) async {
    try {
      if (!isBackground) {
        isLoading.value = true;
      }

      String? typeParam;
      if (selectedTypeIndex.value == 1) {
        typeParam = 'MOVIE';
      } else if (selectedTypeIndex.value == 2) {
        typeParam = 'SERIES';
      }

      final genreParam = selectedGenreIndex.value < genres.length
          ? genres[selectedGenreIndex.value]
          : null;

      final results = await _apiService.searchMovies(
        query: searchQuery.value,
        genre: genreParam,
        type: typeParam,
        sortBy: selectedSortBy.value,
        limit: 40,
      );

      searchResults.assignAll(results);
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    textController.dispose();
    focusNode.dispose();
    super.onClose();
  }
}
