import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/movie_model.dart';
import '../data/services/movie_api_service.dart';

class LeaderboardController extends GetxController {
  final MovieApiService _apiService = MovieApiService();
  final TextEditingController searchController = TextEditingController();

  final RxInt selectedTimeFrameIndex = 0.obs;
  final RxInt selectedCategoryIndex = 0.obs;
  final RxBool isSearchExpanded = false.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;

  final RxList<MovieModel> leaderboardMovies = <MovieModel>[].obs;

  final List<String> timeFrames = const ['Today', 'This Week', 'This Month', 'All Time'];
  final List<String> categories = const [
    '🔥 Top 10 Today',
    '⚡ IMAX & 4K',
    '🚀 Sci-Fi & Action',
    '💰 Box Office Global',
    '⭐ Critics Rating',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchLeaderboard();
  }

  void setTimeFrame(int index) {
    selectedTimeFrameIndex.value = index;
    fetchLeaderboard();
  }

  void setCategory(int index) {
    selectedCategoryIndex.value = index;
    fetchLeaderboard();
  }

  void toggleSearch() {
    isSearchExpanded.value = !isSearchExpanded.value;
    if (!isSearchExpanded.value) {
      searchController.clear();
      searchQuery.value = '';
    }
  }

  Future<void> fetchLeaderboard() async {
    try {
      isLoading.value = true;
      final results = await _apiService.getLeaderboard(
        timeframe: timeFrames[selectedTimeFrameIndex.value],
        category: categories[selectedCategoryIndex.value],
      );
      leaderboardMovies.assignAll(results);
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  List<MovieModel> get filteredLeaderboard {
    if (searchQuery.value.isEmpty) {
      return leaderboardMovies;
    }
    return leaderboardMovies
        .where((m) =>
            m.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            (m.tagline?.toLowerCase().contains(searchQuery.value.toLowerCase()) ?? false) ||
            m.genres.toLowerCase().contains(searchQuery.value.toLowerCase()))
        .toList();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
