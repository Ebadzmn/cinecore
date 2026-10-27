import 'package:get/get.dart';
import '../../data/models/movie_model.dart';
import '../../home/screen/movie_details_screen.dart';
import '../../home/screen/series_details_screen.dart';

/// Centralized navigation helper to cleanly route to SeriesDetailsScreen or MovieDetailsScreen
/// based on the media type (Series vs Movie).
void navigateToMediaDetails({
  String? mediaId,
  MovieModel? media,
  String? title,
  String? subtitle,
  String? heroImageUrl,
}) {
  final isSeries = media?.isSeries ?? false;

  final effectiveTitle = title ?? media?.title ?? 'Details';
  final effectiveSubtitle = subtitle ?? media?.subtitle ?? media?.genres ?? '';
  final effectiveHeroImageUrl = heroImageUrl ?? media?.imageUrl ?? '';
  final effectiveId = mediaId ?? media?.id;

  if (isSeries) {
    Get.to(
      () => SeriesDetailsScreen(
        seriesId: effectiveId,
        series: media,
        title: effectiveTitle,
        subtitle: effectiveSubtitle,
        heroImageUrl: effectiveHeroImageUrl,
      ),
      transition: Transition.fadeIn,
    );
  } else {
    Get.to(
      () => MovieDetailsScreen(
        movieId: effectiveId,
        movie: media,
        title: effectiveTitle,
        subtitle: effectiveSubtitle,
        heroImageUrl: effectiveHeroImageUrl,
      ),
      transition: Transition.fadeIn,
    );
  }
}
