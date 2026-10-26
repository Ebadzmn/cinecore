import 'package:get/get.dart';
import '../data/models/category_model.dart';
import '../data/models/continue_watching_model.dart';
import '../data/models/genre_model.dart';
import '../data/models/movie_model.dart';
import '../data/services/movie_api_service.dart';

class HomeController extends GetxController {
  final MovieApiService _apiService = MovieApiService();

  final RxInt selectedNavIndex = 0.obs;
  final RxInt selectedCategoryIndex = 0.obs;
  final RxInt spotlightCarouselIndex = 0.obs;

  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<GenreModel> genres = <GenreModel>[].obs;
  final RxList<MovieModel> spotlightMovies = <MovieModel>[].obs;
  final RxList<MovieModel> topBlockbusters = <MovieModel>[].obs;
  final RxList<MovieModel> latestMovies = <MovieModel>[].obs;
  final RxList<MovieModel> peacockPicks = <MovieModel>[].obs;
  final RxList<ContinueWatchingModel> continueWatching = <ContinueWatchingModel>[].obs;

  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Pre-populate with defaults so UI never blinks or shows empty
    categories.assignAll(CategoryModel.defaultCategories);
    genres.assignAll(MovieApiService.defaultGenres);
    loadHomeData();
  }

  Future<void> loadHomeData() async {
    try {
      isLoading.value = true;
      final categoriesFuture = _apiService.getCategories();
      final genresFuture = _apiService.getGenres();
      final spotlightFuture = _apiService.getSpotlightMovies();
      final blockbustersFuture = _apiService.getTopBlockbusters();
      final latestFuture = _apiService.getLatestMovies(limit: 10);
      final peacockFuture = _apiService.getPeacockPicks();
      final continueFuture = _apiService.getContinueWatching();

      final results = await Future.wait([
        categoriesFuture,
        genresFuture,
        spotlightFuture,
        blockbustersFuture,
        latestFuture,
        peacockFuture,
        continueFuture,
      ]);

      categories.assignAll(results[0] as List<CategoryModel>);
      genres.assignAll(results[1] as List<GenreModel>);
      spotlightMovies.assignAll(results[2] as List<MovieModel>);
      topBlockbusters.assignAll(results[3] as List<MovieModel>);
      latestMovies.assignAll(results[4] as List<MovieModel>);
      peacockPicks.assignAll(results[5] as List<MovieModel>);
      continueWatching.assignAll(results[6] as List<ContinueWatchingModel>);
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
