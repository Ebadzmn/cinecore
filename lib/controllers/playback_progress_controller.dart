import 'package:get/get.dart';
import '../data/services/playback_service.dart';

class MovieProgressData {
  final String movieId;
  final String? movieSlug;
  final String? movieTitle;
  final String? movieType;
  final double positionSeconds;
  final double durationSeconds;
  final double progressRatio; // 0.0 to 1.0
  final double progressPercentage; // 0 to 100
  final String status; // 'NOT_COMPLETED', 'IN_PROGRESS', 'COMPLETED'
  final bool isCompleted;
  final int? seasonNumber;
  final int? episodeNumber;
  final String? episodeTitle;
  final String? remainingTime;
  final DateTime? lastWatchedAt;

  const MovieProgressData({
    required this.movieId,
    this.movieSlug,
    this.movieTitle,
    this.movieType,
    required this.positionSeconds,
    required this.durationSeconds,
    required this.progressRatio,
    required this.progressPercentage,
    required this.status,
    required this.isCompleted,
    this.seasonNumber,
    this.episodeNumber,
    this.episodeTitle,
    this.remainingTime,
    this.lastWatchedAt,
  });

  factory MovieProgressData.fromJson(Map<String, dynamic> json) {
    final pos = (json['positionSeconds'] as num?)?.toDouble() ?? 0.0;
    var dur = (json['durationSeconds'] as num?)?.toDouble() ?? 0.0;
    final isSeries = json['movieType']?.toString().toUpperCase() == 'SERIES';
    if (dur <= 0) {
      dur = isSeries ? 2700.0 : 7200.0;
    }

    final ratio = (json['progressRatio'] as num?)?.toDouble() ??
        (dur > 0 ? (pos / dur).clamp(0.0, 1.0) : 0.0);
    final percentage = (json['progressPercentage'] as num?)?.toDouble() ?? (ratio * 100);
    final statusStr = json['status']?.toString() ?? 'IN_PROGRESS';
    final isDone = json['isCompleted'] == true || statusStr == 'COMPLETED' || ratio >= 0.90;

    String? remainingText = json['remainingTime']?.toString();
    if (remainingText == null || remainingText.isEmpty || remainingText.contains('left')) {
      if (isDone) {
        remainingText = 'Completed';
      } else {
        final remainingSec = (dur - pos).clamp(0.0, double.infinity);
        String formattedLeft;
        if (remainingSec < 60) {
          formattedLeft = '${remainingSec.toInt()}s left';
        } else {
          final remainingHours = remainingSec ~/ 3600;
          final remainingMin = ((remainingSec % 3600) / 60).ceil();
          formattedLeft = remainingHours > 0
              ? '${remainingHours}h ${remainingMin}m left'
              : '${remainingMin}m left';
        }
        final epNum = (json['episodeNumber'] as num?)?.toInt();
        final sNum = (json['seasonNumber'] as num?)?.toInt() ?? 1;
        remainingText = isSeries && epNum != null
            ? 'S$sNum:E$epNum • $formattedLeft'
            : formattedLeft;
      }
    }

    return MovieProgressData(
      movieId: json['movieId']?.toString() ?? '',
      movieSlug: json['movieSlug']?.toString(),
      movieTitle: json['movieTitle']?.toString(),
      movieType: json['movieType']?.toString(),
      positionSeconds: pos,
      durationSeconds: dur,
      progressRatio: isDone ? 1.0 : ratio,
      progressPercentage: percentage,
      status: isDone ? 'COMPLETED' : statusStr,
      isCompleted: isDone,
      seasonNumber: (json['seasonNumber'] as num?)?.toInt(),
      episodeNumber: (json['episodeNumber'] as num?)?.toInt(),
      episodeTitle: json['episodeTitle']?.toString(),
      remainingTime: remainingText,
      lastWatchedAt: json['lastWatchedAt'] != null
          ? DateTime.tryParse(json['lastWatchedAt'].toString())
          : null,
    );
  }
}

class PlaybackProgressController extends GetxController {
  static PlaybackProgressController get to {
    if (Get.isRegistered<PlaybackProgressController>()) {
      return Get.find<PlaybackProgressController>();
    }
    return Get.put(PlaybackProgressController(), permanent: true);
  }

  final PlaybackService _playbackService = PlaybackService();
  final RxMap<String, MovieProgressData> progressMap = <String, MovieProgressData>{}.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProgressSummary();
  }

  Future<void> fetchProgressSummary() async {
    try {
      isLoading.value = true;
      final summary = await _playbackService.getPlaybackSummary();
      final map = <String, MovieProgressData>{};
      summary.forEach((key, val) {
        if (val is Map) {
          map[key] = MovieProgressData.fromJson(Map<String, dynamic>.from(val));
        }
      });
      progressMap.assignAll(map);
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  MovieProgressData? getProgress(String? movieId) {
    if (movieId == null || movieId.isEmpty) return null;
    final direct = progressMap[movieId] ?? progressMap[movieId.toLowerCase()];
    if (direct != null) return direct;
    final lower = movieId.toLowerCase();
    for (final entry in progressMap.values) {
      if (entry.movieId.toLowerCase() == lower ||
          (entry.movieSlug != null && entry.movieSlug!.toLowerCase() == lower) ||
          (entry.movieTitle != null && entry.movieTitle!.toLowerCase() == lower)) {
        return entry;
      }
    }
    return null;
  }

  double getProgressRatio(String? movieId, {double? fallback}) {
    if (movieId == null || movieId.isEmpty) return fallback ?? 0.0;
    final item = getProgress(movieId);
    if (item != null) return item.progressRatio;
    return fallback ?? 0.0;
  }

  bool isCompleted(String? movieId) {
    final item = getProgress(movieId);
    return item?.isCompleted ?? false;
  }

  bool hasProgress(String? movieId, {double? fallback}) {
    if (fallback != null && fallback > 0.0) return true;
    final item = getProgress(movieId);
    return item != null && item.progressRatio > 0.0;
  }

  void updateProgress({
    required String movieId,
    String? movieSlug,
    String? movieTitle,
    String? movieType,
    required double positionSeconds,
    required double durationSeconds,
    int? seasonNumber,
    int? episodeNumber,
    String? episodeTitle,
    String? status,
  }) {
    double duration = durationSeconds;
    if (duration <= 0) {
      final existing = progressMap[movieId];
      if (existing != null && existing.durationSeconds > 0) {
        duration = existing.durationSeconds;
      } else {
        duration = (movieType?.toUpperCase() == 'SERIES') ? 2700.0 : 7200.0;
      }
    }

    final pos = positionSeconds.clamp(0.0, duration);
    final ratio = (pos / duration).clamp(0.0, 1.0);
    final percentage = (ratio * 100).roundToDouble();
    final completed = status == 'COMPLETED' || ratio >= 0.90;

    final remainingSec = (duration - pos).clamp(0.0, double.infinity);
    String remainingFormatted;
    if (remainingSec < 60) {
      remainingFormatted = '${remainingSec.toInt()}s left';
    } else {
      final remainingHours = remainingSec ~/ 3600;
      final remainingMin = ((remainingSec % 3600) / 60).ceil();
      remainingFormatted = remainingHours > 0
          ? '${remainingHours}h ${remainingMin}m left'
          : '${remainingMin}m left';
    }

    final remainingText = completed
        ? 'Completed'
        : (movieType?.toUpperCase() == 'SERIES' && episodeNumber != null
            ? 'S${seasonNumber ?? 1}:E$episodeNumber • $remainingFormatted'
            : remainingFormatted);

    final data = MovieProgressData(
      movieId: movieId,
      movieSlug: movieSlug,
      movieTitle: movieTitle,
      movieType: movieType,
      positionSeconds: pos,
      durationSeconds: duration,
      progressRatio: completed ? 1.0 : ratio,
      progressPercentage: percentage,
      status: completed ? 'COMPLETED' : (status ?? 'IN_PROGRESS'),
      isCompleted: completed,
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
      episodeTitle: episodeTitle,
      remainingTime: remainingText,
      lastWatchedAt: DateTime.now(),
    );

    progressMap[movieId] = data;
    if (movieSlug != null && movieSlug.isNotEmpty) {
      progressMap[movieSlug.toLowerCase()] = data;
    }
  }
}
