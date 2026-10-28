import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/continue_watching_model.dart';
import '../data/models/watch_history_model.dart';
import '../data/services/playback_service.dart';
import '../home/screen/movie_player_screen.dart';
import 'playback_progress_controller.dart';

class WatchHistoryController extends GetxController {
  final PlaybackService _playbackService = PlaybackService();

  final RxList<WatchHistoryModel> historyList = <WatchHistoryModel>[].obs;
  final RxList<ContinueWatchingModel> continueWatchingList = <ContinueWatchingModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedFilter = 'All History'.obs;

  final List<String> filterCategories = const [
    'All History',
    'In Progress',
    'Completed',
  ];

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    await Future.wait([
      fetchWatchHistory(),
      fetchContinueWatching(),
    ]);
    isLoading.value = false;
  }

  Future<void> fetchWatchHistory() async {
    try {
      final items = await _playbackService.getWatchHistory(limit: 50);
      historyList.assignAll(items);
      for (final item in items) {
        PlaybackProgressController.to.updateProgress(
          movieId: item.movieId,
          movieType: item.movieType,
          movieTitle: item.title,
          positionSeconds: item.positionSeconds,
          durationSeconds: item.durationSeconds,
          seasonNumber: item.seasonNumber,
          episodeNumber: item.episodeNumber,
          episodeTitle: item.episodeTitle,
          status: item.status,
        );
      }
    } catch (_) {}
  }

  Future<void> fetchContinueWatching() async {
    try {
      final items = await _playbackService.getContinueWatching();
      continueWatchingList.assignAll(items);
    } catch (_) {}
  }

  void changeFilter(String filter) {
    selectedFilter.value = filter;
  }

  List<WatchHistoryModel> get filteredList {
    if (selectedFilter.value == 'In Progress') {
      return historyList.where((item) => item.isInProgress).toList();
    } else if (selectedFilter.value == 'Completed') {
      return historyList.where((item) => item.isCompleted).toList();
    }
    return historyList.toList();
  }

  int get inProgressCount => historyList.where((item) => item.isInProgress).length;
  int get completedCount => historyList.where((item) => item.isCompleted).length;

  Future<void> deleteHistoryItem(WatchHistoryModel item) async {
    final prevHistory = List<WatchHistoryModel>.from(historyList);
    final prevContinue = List<ContinueWatchingModel>.from(continueWatchingList);

    historyList.removeWhere((h) => h.id == item.id);
    continueWatchingList.removeWhere((c) => c.id == item.id || c.movieId == item.movieId);

    final success = await _playbackService.deleteHistoryItem(item.id);
    if (!success) {
      // Revert if failed
      historyList.assignAll(prevHistory);
      continueWatchingList.assignAll(prevContinue);
      Get.snackbar(
        'Error',
        'Could not remove item from history',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1F1212),
        colorText: Colors.redAccent,
      );
    } else {
      Get.snackbar(
        'Removed',
        '${item.title} removed from watch history',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF161822),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> clearAllHistory() async {
    final success = await _playbackService.clearAllHistory();
    if (success) {
      historyList.clear();
      continueWatchingList.clear();
      Get.snackbar(
        'History Cleared',
        'All your viewing history has been cleared',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF161822),
        colorText: const Color(0xFFFBBF24),
        icon: const Icon(Icons.delete_sweep_rounded, color: Color(0xFFF59E0B)),
      );
    }
  }

  /// Resume playback directly from the exact saved position
  void resumeItem(WatchHistoryModel item, {bool fromBeginning = false}) {
    final resumePos = fromBeginning ? 0.0 : item.positionSeconds;

    Get.to(
      () => MoviePlayerScreen(
        movieId: item.movieId,
        movieType: item.movieType,
        seasonNumber: item.seasonNumber,
        episodeNumber: item.episodeNumber,
        episodeTitle: item.episodeTitle,
        initialPositionSeconds: resumePos,
        title: item.title,
        subtitle: item.episodeSubtitle,
        heroImageUrl: item.backdrop.isNotEmpty ? item.backdrop : item.poster,
      ),
      transition: Transition.fadeIn,
    );
  }

  /// Resume from a ContinueWatchingModel
  void resumeContinueWatching(ContinueWatchingModel item, {bool fromBeginning = false}) {
    final resumePos = fromBeginning ? 0.0 : item.positionSeconds;

    Get.to(
      () => MoviePlayerScreen(
        movieId: item.movieId ?? item.id,
        movieType: item.movieType ?? 'MOVIE',
        seasonNumber: item.seasonNumber,
        episodeNumber: item.episodeNumber,
        episodeTitle: item.episodeTitle,
        initialPositionSeconds: resumePos,
        title: item.title,
        subtitle: item.episodeInfo,
        heroImageUrl: item.imageUrl,
      ),
      transition: Transition.fadeIn,
    );
  }
}
