import 'cast_member_model.dart';
import 'episode_model.dart';

class MovieModel {
  final String id;
  final String title;
  final String? subtitle;
  final String? tagline;
  final String? synopsis;
  final String imageUrl;
  final String? backdropUrl;
  final double rating;
  final String? badge;
  final String? releaseYear;
  final String genres;
  final String duration;
  final String resolution;
  final String? ageRating;
  final String? studio;
  final int? rank;
  final String? trend;
  final String? boxOfficeOrStreams;
  final String? topSmallTag;
  final String? topMainTag;
  final String? subDescription;
  final String? rankTag;
  final double? watchProgress;
  final String? remainingTime;
  final double? positionSeconds;
  final double? durationSeconds;
  final String? status;
  final bool isCompleted;
  final bool isBookmarked;
  final int? seasonNumber;
  final int? episodeNumber;
  final String? episodeTitle;
  final DateTime? lastWatchedAt;
  final bool isDownloaded;
  final bool isPinned;

  // Extended Media & Details Attributes
  final String? watchUrl;
  final String? playbackUrl;
  final String? director;
  final String? trailerUrl;
  final String? type;
  final String? category;
  final String? audioCodec;
  final String? videoCodec;
  final int totalSeasons;
  final List<EpisodeModel>? episodes;
  final List<CastMemberModel>? cast;
  final List<MovieScreenshotModel>? screenshots;
  final List<MovieModel>? moreLikeThis;

  bool get isSeries =>
      (type?.toUpperCase() == 'SERIES') ||
      (totalSeasons > 1) ||
      (episodes != null && episodes!.isNotEmpty);

  const MovieModel({
    required this.id,
    required this.title,
    this.subtitle,
    this.tagline,
    this.synopsis,
    required this.imageUrl,
    this.backdropUrl,
    required this.rating,
    this.badge,
    this.releaseYear,
    this.genres = 'Action, Thriller',
    this.duration = '2h 15m',
    this.resolution = '4K IMAX',
    this.ageRating = 'PG-13',
    this.studio = 'Universal',
    this.rank,
    this.trend,
    this.boxOfficeOrStreams,
    this.topSmallTag,
    this.topMainTag,
    this.subDescription,
    this.rankTag,
    this.watchProgress,
    this.remainingTime,
    this.positionSeconds,
    this.durationSeconds,
    this.status,
    this.isCompleted = false,
    this.isBookmarked = false,
    this.seasonNumber,
    this.episodeNumber,
    this.episodeTitle,
    this.lastWatchedAt,
    this.isDownloaded = false,
    this.isPinned = false,
    this.watchUrl,
    this.playbackUrl,
    this.director,
    this.trailerUrl,
    this.type,
    this.category,
    this.audioCodec,
    this.videoCodec,
    this.totalSeasons = 1,
    this.episodes,
    this.cast,
    this.screenshots,
    this.moreLikeThis,
  });

  MovieModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? tagline,
    String? synopsis,
    String? imageUrl,
    String? backdropUrl,
    double? rating,
    String? badge,
    String? releaseYear,
    String? genres,
    String? duration,
    String? resolution,
    String? ageRating,
    String? studio,
    int? rank,
    String? trend,
    String? boxOfficeOrStreams,
    String? topSmallTag,
    String? topMainTag,
    String? subDescription,
    String? rankTag,
    double? watchProgress,
    String? remainingTime,
    double? positionSeconds,
    double? durationSeconds,
    String? status,
    bool? isCompleted,
    bool? isBookmarked,
    int? seasonNumber,
    int? episodeNumber,
    String? episodeTitle,
    DateTime? lastWatchedAt,
    bool? isDownloaded,
    bool? isPinned,
    String? watchUrl,
    String? playbackUrl,
    String? director,
    String? trailerUrl,
    String? type,
    String? category,
    String? audioCodec,
    String? videoCodec,
    int? totalSeasons,
    List<EpisodeModel>? episodes,
    List<CastMemberModel>? cast,
    List<MovieScreenshotModel>? screenshots,
    List<MovieModel>? moreLikeThis,
  }) {
    return MovieModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      tagline: tagline ?? this.tagline,
      synopsis: synopsis ?? this.synopsis,
      imageUrl: imageUrl ?? this.imageUrl,
      backdropUrl: backdropUrl ?? this.backdropUrl,
      rating: rating ?? this.rating,
      badge: badge ?? this.badge,
      releaseYear: releaseYear ?? this.releaseYear,
      genres: genres ?? this.genres,
      duration: duration ?? this.duration,
      resolution: resolution ?? this.resolution,
      ageRating: ageRating ?? this.ageRating,
      studio: studio ?? this.studio,
      rank: rank ?? this.rank,
      trend: trend ?? this.trend,
      boxOfficeOrStreams: boxOfficeOrStreams ?? this.boxOfficeOrStreams,
      topSmallTag: topSmallTag ?? this.topSmallTag,
      topMainTag: topMainTag ?? this.topMainTag,
      subDescription: subDescription ?? this.subDescription,
      rankTag: rankTag ?? this.rankTag,
      watchProgress: watchProgress ?? this.watchProgress,
      remainingTime: remainingTime ?? this.remainingTime,
      positionSeconds: positionSeconds ?? this.positionSeconds,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      status: status ?? this.status,
      isCompleted: isCompleted ?? this.isCompleted,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      seasonNumber: seasonNumber ?? this.seasonNumber,
      episodeNumber: episodeNumber ?? this.episodeNumber,
      episodeTitle: episodeTitle ?? this.episodeTitle,
      lastWatchedAt: lastWatchedAt ?? this.lastWatchedAt,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      isPinned: isPinned ?? this.isPinned,
      watchUrl: watchUrl ?? this.watchUrl,
      playbackUrl: playbackUrl ?? this.playbackUrl,
      director: director ?? this.director,
      trailerUrl: trailerUrl ?? this.trailerUrl,
      type: type ?? this.type,
      category: category ?? this.category,
      audioCodec: audioCodec ?? this.audioCodec,
      videoCodec: videoCodec ?? this.videoCodec,
      totalSeasons: totalSeasons ?? this.totalSeasons,
      episodes: episodes ?? this.episodes,
      cast: cast ?? this.cast,
      screenshots: screenshots ?? this.screenshots,
      moreLikeThis: moreLikeThis ?? this.moreLikeThis,
    );
  }

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    // Format duration smartly
    String formattedDuration = '2h 00m';
    if (json['duration'] is num) {
      final num d = json['duration'] as num;
      if (d >= 3600) {
        final int totalMins = (d / 60).round();
        final int h = totalMins ~/ 60;
        final int m = totalMins % 60;
        formattedDuration = h > 0 ? '${h}h ${m}m' : '${m}m';
      } else if (d >= 60) {
        final int m = d ~/ 60;
        final int s = (d % 60).toInt();
        formattedDuration = s > 0 ? '${m}m ${s}s' : '${m}m';
      } else if (d > 0) {
        formattedDuration = '${d.toInt()}s';
      }
    } else if (json['duration'] != null && json['duration'].toString().isNotEmpty) {
      formattedDuration = json['duration'].toString();
    }

    // Parse Genres
    String formattedGenres = 'Cinema';
    if (json['genres'] is List) {
      final list = (json['genres'] as List).map((g) => g?.toString()).where((g) => g != null && g.isNotEmpty).toList();
      formattedGenres = list.isNotEmpty ? list.join(', ') : 'Cinema';
    } else if (json['genres'] != null && json['genres'].toString().isNotEmpty) {
      formattedGenres = json['genres'].toString();
    }

    // Cast parsing
    List<CastMemberModel>? parsedCast;
    if (json['cast'] is List) {
      parsedCast = (json['cast'] as List)
          .whereType<Map<String, dynamic>>()
          .map((c) => CastMemberModel.fromJson(c))
          .toList();
    }

    // Screenshots parsing
    List<MovieScreenshotModel>? parsedScreenshots;
    if (json['screenshots'] is List) {
      parsedScreenshots = (json['screenshots'] as List).map((s) {
        if (s is Map<String, dynamic>) {
          return MovieScreenshotModel.fromJson(s);
        }
        return MovieScreenshotModel(
          title: 'Scene Stills',
          imageUrl: s.toString(),
          tag: json['resolution']?.toString() ?? '4K Ultra HD',
        );
      }).toList();
    }

    // More Like This parsing
    List<MovieModel>? parsedMoreLikeThis;
    final rawMore = json['moreLikeThis'] ?? json['relatedMovies'];
    if (rawMore is List) {
      parsedMoreLikeThis = rawMore
          .whereType<Map<String, dynamic>>()
          .map((m) => MovieModel.fromJson(m))
          .toList();
    }

    // Episodes parsing for Series
    List<EpisodeModel>? parsedEpisodes;
    if (json['episodes'] is List) {
      parsedEpisodes = (json['episodes'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => EpisodeModel.fromJson(e))
          .toList();
    }

    final int totalSeasons = (json['totalSeasons'] is num)
        ? (json['totalSeasons'] as num).toInt()
        : (int.tryParse(json['totalSeasons']?.toString() ?? '') ??
            (parsedEpisodes != null && parsedEpisodes.isNotEmpty
                ? parsedEpisodes.map((e) => e.seasonNumber).fold<int>(1, (max, s) => s > max ? s : max)
                : 1));

    // Watch link resolution
    String? resolvedWatchUrl = json['watchUrl']?.toString() ??
        json['playbackUrl']?.toString() ??
        (json['playback'] is Map ? json['playback']['url']?.toString() : null) ??
        json['sourceUrl']?.toString();

    // If series without top-level watchUrl, use first available episode watchUrl
    if ((resolvedWatchUrl == null || resolvedWatchUrl.isEmpty) &&
        parsedEpisodes != null &&
        parsedEpisodes.isNotEmpty) {
      for (final ep in parsedEpisodes) {
        if (ep.watchUrl != null && ep.watchUrl!.isNotEmpty) {
          resolvedWatchUrl = ep.watchUrl;
          break;
        }
      }
    }

    // Poster and backdrop resolution
    final String posterImg = json['imageUrl']?.toString() ??
        json['poster']?.toString() ??
        json['poster_url']?.toString() ??
        json['backdrop']?.toString() ??
        '';

    final String? backdropImg = json['backdropUrl']?.toString() ??
        json['backdrop']?.toString() ??
        json['backdrop_url']?.toString() ??
        (posterImg.isNotEmpty ? posterImg : null);

    return MovieModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? json['description']?.toString(),
      tagline: json['tagline']?.toString(),
      synopsis: json['synopsis']?.toString() ?? json['description']?.toString(),
      imageUrl: posterImg,
      backdropUrl: backdropImg,
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : 0.0,
      badge: json['badge']?.toString(),
      releaseYear: json['releaseYear']?.toString() ?? json['release_year']?.toString(),
      genres: formattedGenres,
      duration: formattedDuration,
      resolution: json['resolution']?.toString() ?? '4K Ultra HD',
      ageRating: json['ageRating']?.toString() ?? json['age_rating']?.toString(),
      studio: (json['studio'] is Map)
          ? json['studio']['name']?.toString()
          : (json['studio']?.toString() ??
              (json['category'] is Map ? json['category']['name']?.toString() : json['category']?.toString())),
      rank: json['rank'] as int?,
      trend: json['trend']?.toString(),
      boxOfficeOrStreams: json['boxOfficeOrStreams']?.toString(),
      topSmallTag: json['topSmallTag']?.toString(),
      topMainTag: json['topMainTag']?.toString(),
      subDescription: json['subDescription']?.toString(),
      rankTag: json['rankTag']?.toString(),
      watchProgress: (json['watchProgress'] is num) ? (json['watchProgress'] as num).toDouble() : null,
      remainingTime: json['remainingTime']?.toString(),
      positionSeconds: (json['positionSeconds'] is num) ? (json['positionSeconds'] as num).toDouble() : null,
      durationSeconds: (json['durationSeconds'] is num) ? (json['durationSeconds'] as num).toDouble() : null,
      status: json['status']?.toString(),
      isCompleted: json['isCompleted'] == true ||
          json['status'] == 'COMPLETED' ||
          ((json['watchProgress'] as num?)?.toDouble() ?? 0.0) >= 0.90,
      isBookmarked: json['isBookmarked'] == true,
      seasonNumber: (json['seasonNumber'] is num) ? (json['seasonNumber'] as num).toInt() : null,
      episodeNumber: (json['episodeNumber'] is num) ? (json['episodeNumber'] as num).toInt() : null,
      episodeTitle: json['episodeTitle']?.toString(),
      lastWatchedAt: json['lastWatchedAt'] != null
          ? DateTime.tryParse(json['lastWatchedAt'].toString())
          : null,
      isDownloaded: json['isDownloaded'] == true,
      isPinned: json['isPinned'] == true,
      watchUrl: resolvedWatchUrl,
      playbackUrl: json['playbackUrl']?.toString() ?? resolvedWatchUrl,
      director: json['director']?.toString(),
      trailerUrl: json['trailerUrl']?.toString(),
      type: json['type']?.toString(),
      category: (json['category'] is Map)
          ? json['category']['name']?.toString()
          : (json['category']?.toString() ??
              (json['categoryId'] is Map ? json['categoryId']['name']?.toString() : null)),
      audioCodec: json['audioCodec']?.toString(),
      videoCodec: json['videoCodec']?.toString(),
      totalSeasons: totalSeasons,
      episodes: parsedEpisodes,
      cast: parsedCast,
      screenshots: parsedScreenshots,
      moreLikeThis: parsedMoreLikeThis,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'tagline': tagline,
      'synopsis': synopsis,
      'imageUrl': imageUrl,
      'backdropUrl': backdropUrl,
      'rating': rating,
      'badge': badge,
      'releaseYear': releaseYear,
      'genres': genres,
      'duration': duration,
      'resolution': resolution,
      'ageRating': ageRating,
      'studio': studio,
      'rank': rank,
      'trend': trend,
      'boxOfficeOrStreams': boxOfficeOrStreams,
      'topSmallTag': topSmallTag,
      'topMainTag': topMainTag,
      'subDescription': subDescription,
      'rankTag': rankTag,
      'watchProgress': watchProgress,
      'remainingTime': remainingTime,
      'isDownloaded': isDownloaded,
      'isPinned': isPinned,
      'watchUrl': watchUrl,
      'playbackUrl': playbackUrl,
      'director': director,
      'trailerUrl': trailerUrl,
      'type': type,
      'category': category,
      'audioCodec': audioCodec,
      'videoCodec': videoCodec,
      'totalSeasons': totalSeasons,
      'episodes': episodes?.map((e) => e.toJson()).toList(),
      'cast': cast?.map((c) => c.toJson()).toList(),
      'screenshots': screenshots?.map((s) => s.toJson()).toList(),
      'moreLikeThis': moreLikeThis?.map((m) => m.toJson()).toList(),
    };
  }
}

