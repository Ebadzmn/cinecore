import 'package:get/get.dart';
import '../data/models/cast_member_model.dart';
import '../data/models/movie_model.dart';
import '../data/services/movie_api_service.dart';

class MovieDetailsController extends GetxController {
  final String movieId;
  final MovieApiService _apiService = MovieApiService();

  MovieDetailsController({required this.movieId});

  final RxBool isSynopsisExpanded = false.obs;
  final RxBool isPlaying = false.obs;
  final RxBool isLoading = false.obs;

  final RxList<CastMemberModel> castMembers = <CastMemberModel>[].obs;
  final RxList<MovieScreenshotModel> screenshots = <MovieScreenshotModel>[].obs;
  final RxList<MovieModel> relatedMovies = <MovieModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadMovieDetails();
  }

  void toggleSynopsis() {
    isSynopsisExpanded.value = !isSynopsisExpanded.value;
  }

  Future<void> loadMovieDetails() async {
    try {
      isLoading.value = true;
      final castFuture = _apiService.getCastMembers(movieId);
      final shotsFuture = _apiService.getScreenshots(movieId);
      final relatedFuture = _apiService.getRelatedMovies(movieId);

      final results = await Future.wait([castFuture, shotsFuture, relatedFuture]);
      castMembers.assignAll(results[0] as List<CastMemberModel>);
      screenshots.assignAll(results[1] as List<MovieScreenshotModel>);
      relatedMovies.assignAll(results[2] as List<MovieModel>);
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }
}
