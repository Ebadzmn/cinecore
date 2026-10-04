class MovieModel {
  final String id;
  final String title;
  final String? subtitle;
  final String imageUrl;
  final double rating;
  final String? badge;
  final String? releaseYear;
  final String? genres;
  final String? duration;
  final String? resolution;
  final String? ageRating;

  const MovieModel({
    required this.id,
    required this.title,
    this.subtitle,
    required this.imageUrl,
    required this.rating,
    this.badge,
    this.releaseYear,
    this.genres,
    this.duration,
    this.resolution,
    this.ageRating,
  });
}

class ContinueWatchingModel {
  final String id;
  final String title;
  final String episodeInfo;
  final String remainingTime;
  final String qualityInfo;
  final String audioInfo;
  final String imageUrl;
  final double progress; // 0.0 to 1.0

  const ContinueWatchingModel({
    required this.id,
    required this.title,
    required this.episodeInfo,
    required this.remainingTime,
    required this.qualityInfo,
    required this.audioInfo,
    required this.imageUrl,
    required this.progress,
  });
}

class StudioProviderModel {
  final String name;
  final String iconType; // 'max', 'paramount', 'disney', 'netflix'

  const StudioProviderModel({required this.name, required this.iconType});
}
