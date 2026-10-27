import 'package:get/get.dart';
import '../data/models/category_model.dart';
import '../data/models/continue_watching_model.dart';
import '../data/models/genre_model.dart';
import '../data/models/home_feed_model.dart';
import '../data/models/movie_model.dart';
import '../data/services/movie_api_service.dart';

class HomeController extends GetxController {
  final MovieApiService _apiService = MovieApiService();

  final RxInt selectedNavIndex = 0.obs;
  final RxInt selectedCategoryIndex = 0.obs;
  final RxInt spotlightCarouselIndex = 0.obs;

  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<GenreModel> genres = <GenreModel>[].obs;
  final RxList<HeroBannerModel> heroBanners = <HeroBannerModel>[].obs;
  final RxList<HomeSectionModel> homeSections = <HomeSectionModel>[].obs;
  final RxList<MovieModel> spotlightMovies = <MovieModel>[].obs;
  final RxList<MovieModel> topBlockbusters = <MovieModel>[].obs;
  final RxList<MovieModel> latestMovies = <MovieModel>[].obs;
  final RxList<MovieModel> peacockPicks = <MovieModel>[].obs;
  final RxList<MovieModel> popularSeries = <MovieModel>[].obs;
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

      // 1. Trigger CMS Feed and secondary feeds in parallel
      final homeFeedFuture = _apiService.getHomeFeed();
      final categoriesFuture = _apiService.getCategories();
      final genresFuture = _apiService.getGenres();
      final continueFuture = _apiService.getContinueWatching();

      final results = await Future.wait([
        homeFeedFuture,
        categoriesFuture,
        genresFuture,
        continueFuture,
      ]);

      final feed = results[0] as HomeFeedModel?;
      categories.assignAll(results[1] as List<CategoryModel>);
      genres.assignAll(results[2] as List<GenreModel>);
      continueWatching.assignAll(results[3] as List<ContinueWatchingModel>);

      if (feed != null && (feed.banners.isNotEmpty || feed.sections.isNotEmpty)) {
        // Dynamic CMS banners from Admin Dashboard
        if (feed.banners.isNotEmpty) {
          heroBanners.assignAll(feed.banners);
          spotlightMovies.assignAll(
            feed.banners.where((b) => b.movie != null).map((b) => b.movie!).toList(),
          );
        }

        // Dynamic CMS sections from Admin Dashboard
        if (feed.sections.isNotEmpty) {
          homeSections.assignAll(feed.sections);

          // Update Top 10 Blockbusters from CMS section
          final blockbusterSec = feed.getSection('top_10_blockbusters');
          if (blockbusterSec != null && blockbusterSec.items.isNotEmpty) {
            topBlockbusters.assignAll(blockbusterSec.movies);
          }

          // Update Latest Series from CMS section
          final seriesSec = feed.getSection('latest_series') ?? feed.getSection('top_series');
          if (seriesSec != null && seriesSec.items.isNotEmpty) {
            popularSeries.assignAll(seriesSec.movies.take(12));
          }

          // Update Latest Movies from CMS section
          final latestMoviesSec = feed.getSection('latest_movies') ?? feed.getSection('trending_movies');
          if (latestMoviesSec != null && latestMoviesSec.items.isNotEmpty) {
            latestMovies.assignAll(latestMoviesSec.movies.take(12));
          }

          // Update Peacock Picks / Featured from CMS section
          final peacockSec = feed.getSection('peacock_picks');
          if (peacockSec != null && peacockSec.items.isNotEmpty) {
            peacockPicks.assignAll(peacockSec.movies);
          }
        }
      } else {
        // Fallback to legacy individual endpoints if CMS feed returns null/empty
        await _loadFallbackCatalog();
      }
    } catch (_) {
      await _loadFallbackCatalog();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadFallbackCatalog() async {
    try {
      final spotlightFuture = _apiService.getSpotlightMovies();
      final blockbustersFuture = _apiService.getTopBlockbusters();
      final latestFuture = _apiService.getLatestMovies(limit: 10);
      final peacockFuture = _apiService.getPeacockPicks();
      final seriesFuture = _apiService.getSeriesList(limit: 10);

      final fallbackRes = await Future.wait([
        spotlightFuture,
        blockbustersFuture,
        latestFuture,
        peacockFuture,
        seriesFuture,
      ]);

      spotlightMovies.assignAll(fallbackRes[0]);
      topBlockbusters.assignAll(fallbackRes[1]);
      latestMovies.assignAll(fallbackRes[2]);
      peacockPicks.assignAll(fallbackRes[3]);
      popularSeries.assignAll(fallbackRes[4]);
    } catch (_) {}
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
