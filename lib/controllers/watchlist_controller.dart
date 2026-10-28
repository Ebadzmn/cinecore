import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/movie_model.dart';
import '../data/services/movie_api_service.dart';
import 'playback_progress_controller.dart';

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
    'Completed',
    'Movies',
    'Series',
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

      // Hydrate global PlaybackProgressController with watched items
      for (final m in items) {
        if (m.positionSeconds != null && m.durationSeconds != null && m.durationSeconds! > 0) {
          PlaybackProgressController.to.updateProgress(
            movieId: m.id,
            movieTitle: m.title,
            movieType: m.type,
            positionSeconds: m.positionSeconds!,
            durationSeconds: m.durationSeconds!,
            seasonNumber: m.seasonNumber,
            episodeNumber: m.episodeNumber,
            episodeTitle: m.episodeTitle,
            status: m.status,
          );
        }
      }
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
      final updatedMovie = movie.copyWith(isBookmarked: true);
      watchlist.insert(0, updatedMovie);
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
      list = list.where((m) {
        final progress = m.watchProgress ?? PlaybackProgressController.to.getProgressRatio(m.id);
        final status = m.status ?? PlaybackProgressController.to.getProgress(m.id)?.status;
        final isDone = m.isCompleted || status == 'COMPLETED' || progress >= 0.9;
        return progress > 0 && !isDone;
      }).toList();
    } else if (cat == 'Completed') {
      list = list.where((m) {
        final progress = m.watchProgress ?? PlaybackProgressController.to.getProgressRatio(m.id);
        final status = m.status ?? PlaybackProgressController.to.getProgress(m.id)?.status;
        return m.isCompleted || status == 'COMPLETED' || progress >= 0.9;
      }).toList();
    } else if (cat == 'Movies') {
      list = list.where((m) => !m.isSeries && m.type?.toUpperCase() != 'SERIES').toList();
    } else if (cat == 'Series') {
      list = list.where((m) => m.isSeries || m.type?.toUpperCase() == 'SERIES').toList();
    }

    if (selectedSortBy.value == 'Rating') {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (selectedSortBy.value == 'Release Year') {
      list.sort((a, b) => (b.releaseYear ?? '').compareTo(a.releaseYear ?? ''));
    }

    return list;
  }
}
