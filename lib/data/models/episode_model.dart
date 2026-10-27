class EpisodeModel {
  final String id;
  final int seasonNumber;
  final int episodeNumber;
  final String title;
  final String? overview;
  final String? stillPath;
  final double? duration; // in seconds
  final String? airDate;
  final double? rating;
  final String? status;
  final String? watchUrl;
  final String? playbackUrl;
  final String? proxyUrl;
  final String? sourceUrl;
  final String? resolution;
  final List<String> screenshots;

  const EpisodeModel({
    required this.id,
    required this.seasonNumber,
    required this.episodeNumber,
    required this.title,
    this.overview,
    this.stillPath,
    this.duration,
    this.airDate,
    this.rating,
    this.status,
    this.watchUrl,
    this.playbackUrl,
    this.proxyUrl,
    this.sourceUrl,
    this.resolution,
    this.screenshots = const [],
  });

  String get formattedDuration {
    if (duration == null || duration! <= 0) return '45m';
    final int sec = duration!.toInt();
    if (sec > 300) {
      final int minutes = sec ~/ 60;
      final int h = minutes ~/ 60;
      final int m = minutes % 60;
      if (h > 0) return '${h}h ${m}m';
      return '${m}m';
    }
    return '${sec}s';
  }

  String get episodeCode =>
      'S${seasonNumber.toString().padLeft(2, '0')}E${episodeNumber.toString().padLeft(2, '0')}';

  factory EpisodeModel.fromJson(Map<String, dynamic> json) {
    // Determine thumbnail / still image
    final String? still = json['stillPath']?.toString() ??
        json['still_path']?.toString() ??
        json['thumbnail']?.toString() ??
        json['image']?.toString();

    // Determine watch URL
    final String? resolvedWatchUrl = json['watchUrl']?.toString() ??
        json['playbackUrl']?.toString() ??
        (json['playback'] is Map ? json['playback']['url']?.toString() : null) ??
        json['sourceUrl']?.toString();

    List<String> parsedScreenshots = [];
    if (json['screenshots'] is List) {
      parsedScreenshots = (json['screenshots'] as List)
          .map((s) => s?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }

    return EpisodeModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      seasonNumber: (json['seasonNumber'] is num)
          ? (json['seasonNumber'] as num).toInt()
          : (int.tryParse(json['seasonNumber']?.toString() ?? '') ?? 1),
      episodeNumber: (json['episodeNumber'] is num)
          ? (json['episodeNumber'] as num).toInt()
          : (int.tryParse(json['episodeNumber']?.toString() ?? '') ?? 1),
      title: json['title']?.toString() ?? json['name']?.toString() ?? 'Episode',
      overview: json['overview']?.toString() ?? json['description']?.toString(),
      stillPath: still,
      duration: (json['duration'] is num) ? (json['duration'] as num).toDouble() : null,
      airDate: json['airDate']?.toString() ?? json['air_date']?.toString(),
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : null,
      status: json['status']?.toString(),
      watchUrl: resolvedWatchUrl,
      playbackUrl: json['playbackUrl']?.toString() ?? resolvedWatchUrl,
      proxyUrl: json['proxyUrl']?.toString(),
      sourceUrl: json['sourceUrl']?.toString(),
      resolution: json['resolution']?.toString() ?? '1080p',
      screenshots: parsedScreenshots,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'seasonNumber': seasonNumber,
        'episodeNumber': episodeNumber,
        'title': title,
        'overview': overview,
        'stillPath': stillPath,
        'duration': duration,
        'airDate': airDate,
        'rating': rating,
        'status': status,
        'watchUrl': watchUrl,
        'playbackUrl': playbackUrl,
        'proxyUrl': proxyUrl,
        'sourceUrl': sourceUrl,
        'resolution': resolution,
        'screenshots': screenshots,
      };
}
