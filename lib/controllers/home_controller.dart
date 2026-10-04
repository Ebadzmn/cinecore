import 'package:get/get.dart';
import '../data/models/continue_watching_model.dart';
import '../data/models/movie_model.dart';
import '../data/services/movie_api_service.dart';

class HomeController extends GetxController {
  final MovieApiService _apiService = MovieApiService();

  final RxInt selectedNavIndex = 0.obs;
  final RxInt selectedCategoryIndex = 0.obs;
  final RxInt spotlightCarouselIndex = 0.obs;

  final RxList<MovieModel> spotlightMovies = <MovieModel>[].obs;
  final RxList<MovieModel> topBlockbusters = <MovieModel>[].obs;
  final RxList<MovieModel> peacockPicks = <MovieModel>[].obs;
  final RxList<ContinueWatchingModel> continueWatching = <ContinueWatchingModel>[].obs;

  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadHomeData();
  }

  Future<void> loadHomeData() async {
    try {
      isLoading.value = true;
      final spotlightFuture = _apiService.getSpotlightMovies();
      final blockbustersFuture = _apiService.getTopBlockbusters();
      final peacockFuture = _apiService.getPeacockPicks();
      final continueFuture = _apiService.getContinueWatching();

      final results = await Future.wait([
        spotlightFuture,
        blockbustersFuture,
        peacockFuture,
        continueFuture,
      ]);

      spotlightMovies.assignAll(results[0] as List<MovieModel>);
      topBlockbusters.assignAll(results[1] as List<MovieModel>);
      peacockPicks.assignAll(results[2] as List<MovieModel>);
      continueWatching.assignAll(results[3] as List<ContinueWatchingModel>);
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  void changeNavIndex(int index) {
    selectedNavIndex.value = index;
  }

  void changeCategory(int index) {
    selectedCategoryIndex.value = index;
  }

  void updateSpotlightIndex(int index) {
    spotlightCarouselIndex.value = index;
  }
}
