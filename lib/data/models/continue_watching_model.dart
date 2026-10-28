class ContinueWatchingModel {
  final String id;
  final String? movieId;
  final String? movieSlug;
  final String? movieType; // "MOVIE" | "SERIES"
  final String title;
  final String episodeInfo;
  final String remainingTime;
  final String qualityInfo;
  final String audioInfo;
  final String imageUrl;
  final double progress; // 0.0 to 1.0
  final double progressPercentage;
  final double positionSeconds;
  final double durationSeconds;
  final int? seasonNumber;
  final int? episodeNumber;
  final String? episodeTitle;
  final String status;
  final DateTime? lastWatchedAt;

  const ContinueWatchingModel({
    required this.id,
    this.movieId,
    this.movieSlug,
    this.movieType,
    required this.title,
    required this.episodeInfo,
    required this.remainingTime,
    required this.qualityInfo,
    required this.audioInfo,
    required this.imageUrl,
    required this.progress,
    this.progressPercentage = 0.0,
    this.positionSeconds = 0.0,
    this.durationSeconds = 0.0,
    this.seasonNumber,
    this.episodeNumber,
    this.episodeTitle,
    this.status = 'IN_PROGRESS',
    this.lastWatchedAt,
  });

  factory ContinueWatchingModel.fromJson(Map<String, dynamic> json) {
    final double rawProgress = (json['progress'] is num)
        ? (json['progress'] as num).toDouble()
        : 0.0;
    final double rawPos = (json['positionSeconds'] is num)
        ? (json['positionSeconds'] as num).toDouble()
        : 0.0;
    final double rawDur = (json['durationSeconds'] is num)
        ? (json['durationSeconds'] as num).toDouble()
        : 0.0;

    return ContinueWatchingModel(
      id: json['id']?.toString() ?? json['movieId']?.toString() ?? '',
      movieId: json['movieId']?.toString() ?? json['id']?.toString(),
      movieSlug: json['movieSlug']?.toString(),
      movieType: json['movieType']?.toString() ?? 'MOVIE',
      title: json['title']?.toString() ?? '',
      episodeInfo: json['episodeInfo']?.toString() ?? '',
      remainingTime: json['remainingTime']?.toString() ?? '',
      qualityInfo: json['qualityInfo']?.toString() ?? '4K UHD',
      audioInfo: json['audioInfo']?.toString() ?? 'Dolby Atmos',
      imageUrl: json['imageUrl']?.toString() ?? json['poster']?.toString() ?? '',
      progress: rawProgress.clamp(0.0, 1.0),
      progressPercentage: (json['progressPercentage'] is num)
          ? (json['progressPercentage'] as num).toDouble()
          : (rawProgress * 100).clamp(0.0, 100.0),
      positionSeconds: rawPos,
      durationSeconds: rawDur,
      seasonNumber: json['seasonNumber'] is num ? (json['seasonNumber'] as num).toInt() : null,
      episodeNumber: json['episodeNumber'] is num ? (json['episodeNumber'] as num).toInt() : null,
      episodeTitle: json['episodeTitle']?.toString(),
      status: json['status']?.toString() ?? 'IN_PROGRESS',
      lastWatchedAt: json['lastWatchedAt'] != null
          ? DateTime.tryParse(json['lastWatchedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'movieId': movieId,
      'movieSlug': movieSlug,
      'movieType': movieType,
      'title': title,
      'episodeInfo': episodeInfo,
      'remainingTime': remainingTime,
      'qualityInfo': qualityInfo,
      'audioInfo': audioInfo,
      'imageUrl': imageUrl,
      'progress': progress,
      'progressPercentage': progressPercentage,
      'positionSeconds': positionSeconds,
      'durationSeconds': durationSeconds,
      'seasonNumber': seasonNumber,
      'episodeNumber': episodeNumber,
      'episodeTitle': episodeTitle,
      'status': status,
      'lastWatchedAt': lastWatchedAt?.toIso8601String(),
    };
  }

  bool get isSeries => movieType == 'SERIES' || (seasonNumber != null && seasonNumber! > 0);
}
