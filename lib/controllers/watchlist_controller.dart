import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/movie_model.dart';
import '../data/services/movie_api_service.dart';

class WatchlistController extends GetxController {
  final MovieApiService _apiService = MovieApiService();

  final RxList<MovieModel> watchlist = <MovieModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt selectedCategoryIndex = 0.obs;
  final RxBool isGridView = false.obs;
  final RxString selectedSortBy = 'Recently Added'.obs;

  final List<String> categories = const [
    'All Saved',
    'In Progress',
    'Downloaded',
    '4K Ultra HD',
    'Action & Sci-Fi',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchWatchlist();
  }

  Future<void> fetchWatchlist() async {
    try {
      isLoading.value = true;
      final items = await _apiService.getWatchlist();
      watchlist.assignAll(items);
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  bool isMovieInWatchlist(String movieId) {
    return watchlist.any((m) => m.id == movieId || m.title.toLowerCase() == movieId.toLowerCase());
  }

  void toggleWatchlist(MovieModel movie) {
    final existingIndex = watchlist.indexWhere(
      (m) => m.id == movie.id || m.title.toLowerCase() == movie.title.toLowerCase(),
    );

    if (existingIndex >= 0) {
      watchlist.removeAt(existingIndex);
      _apiService.removeFromWatchlist(movie.id);
      Get.snackbar(
        'Removed from Watchlist',
        '${movie.title} was removed from your watchlist',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF161822),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );
    } else {
      watchlist.insert(0, movie);
      _apiService.addToWatchlist(movie.id);
      Get.snackbar(
        'Added to Watchlist',
        '${movie.title} has been added to your watchlist',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF161822),
        colorText: const Color(0xFFFBBF24),
        icon: const Icon(Icons.bookmark_added_rounded, color: Color(0xFFF59E0B)),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void removeMovie(String movieId) {
    watchlist.removeWhere((m) => m.id == movieId);
    _apiService.removeFromWatchlist(movieId);
  }

  List<MovieModel> get filteredWatchlist {
    final cat = categories[selectedCategoryIndex.value];
    List<MovieModel> list = watchlist.toList();

    if (cat == 'In Progress') {
      list = list.where((m) => (m.watchProgress ?? 0) > 0 && (m.watchProgress ?? 0) < 1.0).toList();
    } else if (cat == 'Downloaded') {
      list = list.where((m) => m.isDownloaded).toList();
    } else if (cat == '4K Ultra HD') {
      list = list.where((m) => m.resolution.contains('4K') || m.resolution.contains('IMAX') || m.resolution.contains('DOLBY')).toList();
    } else if (cat == 'Action & Sci-Fi') {
      list = list.where((m) => m.genres.contains('Action') || m.genres.contains('Sci-Fi')).toList();
    }

    if (selectedSortBy.value == 'Rating') {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (selectedSortBy.value == 'Release Year') {
      list.sort((a, b) => (b.releaseYear ?? '').compareTo(a.releaseYear ?? ''));
    }

    return list;
  }
}
