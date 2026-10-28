class WatchHistoryModel {
  final String id;
  final String movieId;
  final String? movieSlug;
  final String movieType; // 'MOVIE' | 'SERIES'
  final String title;
  final String poster;
  final String backdrop;
  final int? seasonNumber;
  final int? episodeNumber;
  final String? episodeTitle;
  final double positionSeconds;
  final double durationSeconds;
  final double progressPercentage;
  final String status; // 'NOT_COMPLETED' | 'IN_PROGRESS' | 'COMPLETED'
  final String? lastAction;
  final DateTime? lastWatchedAt;
  final String? releaseYear;
  final double rating;
  final List<String> genres;

  const WatchHistoryModel({
    required this.id,
    required this.movieId,
    this.movieSlug,
    this.movieType = 'MOVIE',
    required this.title,
    this.poster = '',
    this.backdrop = '',
    this.seasonNumber,
    this.episodeNumber,
    this.episodeTitle,
    this.positionSeconds = 0.0,
    this.durationSeconds = 0.0,
    this.progressPercentage = 0.0,
    this.status = 'IN_PROGRESS',
    this.lastAction,
    this.lastWatchedAt,
    this.releaseYear,
    this.rating = 8.5,
    this.genres = const [],
  });

  factory WatchHistoryModel.fromJson(Map<String, dynamic> json) {
    final rawPos = (json['positionSeconds'] is num)
        ? (json['positionSeconds'] as num).toDouble()
        : 0.0;
    final rawDur = (json['durationSeconds'] is num)
        ? (json['durationSeconds'] as num).toDouble()
        : 0.0;
    final rawPct = (json['progressPercentage'] is num)
        ? (json['progressPercentage'] as num).toDouble()
        : (rawDur > 0 ? (rawPos / rawDur) * 100 : 0.0);

    List<String> parsedGenres = [];
    if (json['genres'] is List) {
      parsedGenres = (json['genres'] as List).map((e) => e.toString()).toList();
    } else if (json['genres'] is String) {
      parsedGenres = (json['genres'] as String)
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return WatchHistoryModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      movieId: json['movieId']?.toString() ?? json['id']?.toString() ?? '',
      movieSlug: json['movieSlug']?.toString(),
      movieType: json['movieType']?.toString() ?? 'MOVIE',
      title: json['title']?.toString() ?? 'Untitled',
      poster: json['poster']?.toString() ?? '',
      backdrop: json['backdrop']?.toString() ?? '',
      seasonNumber: json['seasonNumber'] is num ? (json['seasonNumber'] as num).toInt() : null,
      episodeNumber: json['episodeNumber'] is num ? (json['episodeNumber'] as num).toInt() : null,
      episodeTitle: json['episodeTitle']?.toString(),
      positionSeconds: rawPos,
      durationSeconds: rawDur,
      progressPercentage: rawPct.clamp(0.0, 100.0),
      status: json['status']?.toString() ?? 'IN_PROGRESS',
      lastAction: json['lastAction']?.toString(),
      lastWatchedAt: json['lastWatchedAt'] != null
          ? DateTime.tryParse(json['lastWatchedAt'].toString())
          : null,
      releaseYear: json['releaseYear']?.toString(),
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : 8.5,
      genres: parsedGenres,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'movieId': movieId,
      'movieSlug': movieSlug,
      'movieType': movieType,
      'title': title,
      'poster': poster,
      'backdrop': backdrop,
      'seasonNumber': seasonNumber,
      'episodeNumber': episodeNumber,
      'episodeTitle': episodeTitle,
      'positionSeconds': positionSeconds,
      'durationSeconds': durationSeconds,
      'progressPercentage': progressPercentage,
      'status': status,
      'lastAction': lastAction,
      'lastWatchedAt': lastWatchedAt?.toIso8601String(),
      'releaseYear': releaseYear,
      'rating': rating,
      'genres': genres,
    };
  }

  bool get isSeries => movieType == 'SERIES' || (seasonNumber != null && seasonNumber! > 0);
  bool get isCompleted => status == 'COMPLETED';
  bool get isInProgress => status == 'IN_PROGRESS';

  double get progressRatio {
    if (durationSeconds > 0) {
      return (positionSeconds / durationSeconds).clamp(0.0, 1.0);
    }
    return (progressPercentage / 100.0).clamp(0.0, 1.0);
  }

  String get formattedPosition => _formatDuration(positionSeconds);
  String get formattedDuration => _formatDuration(durationSeconds);

  String get formattedRemainingTime {
    final remainingSec = (durationSeconds - positionSeconds).clamp(0.0, durationSeconds);
    return '${_formatDuration(remainingSec)} left';
  }

  String get episodeSubtitle {
    if (isSeries) {
      final s = seasonNumber ?? 1;
      final e = episodeNumber ?? 1;
      if (episodeTitle != null && episodeTitle!.trim().isNotEmpty) {
        return 'S$s : E$e • $episodeTitle';
      }
      return 'Season $s • Episode $e';
    }
    return genres.isNotEmpty ? genres.take(2).join(' • ') : 'Movie';
  }

  String get formattedWatchedDate {
    if (lastWatchedAt == null) return 'Recently';
    final now = DateTime.now();
    final diff = now.difference(lastWatchedAt!);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';

    return '${lastWatchedAt!.day}/${lastWatchedAt!.month}/${lastWatchedAt!.year}';
  }

  static String _formatDuration(double totalSec) {
    if (totalSec <= 0) return '00:00';
    final int hours = totalSec ~/ 3600;
    final int minutes = (totalSec % 3600) ~/ 60;
    final int seconds = (totalSec % 60).toInt();

    final String mStr = minutes.toString().padLeft(2, '0');
    final String sStr = seconds.toString().padLeft(2, '0');

    if (hours > 0) {
      return '$hours:$mStr:$sStr';
    }
    return '$mStr:$sStr';
  }
}
