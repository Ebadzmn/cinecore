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
  final bool isDownloaded;

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
    this.isDownloaded = false,
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
    bool? isDownloaded,
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
      isDownloaded: isDownloaded ?? this.isDownloaded,
    );
  }

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString(),
      tagline: json['tagline']?.toString(),
      synopsis: json['synopsis']?.toString(),
      imageUrl: json['imageUrl']?.toString() ?? json['poster_url']?.toString() ?? '',
      backdropUrl: json['backdropUrl']?.toString() ?? json['backdrop_url']?.toString(),
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : 0.0,
      badge: json['badge']?.toString(),
      releaseYear: json['releaseYear']?.toString() ?? json['release_year']?.toString(),
      genres: (json['genres'] is List)
          ? (json['genres'] as List).join(', ')
          : (json['genres']?.toString() ?? 'Action'),
      duration: json['duration']?.toString() ?? '2h 00m',
      resolution: json['resolution']?.toString() ?? '4K Ultra HD',
      ageRating: json['ageRating']?.toString() ?? json['age_rating']?.toString(),
      studio: (json['studio'] is Map)
          ? json['studio']['name']?.toString()
          : json['studio']?.toString(),
      rank: json['rank'] as int?,
      trend: json['trend']?.toString(),
      boxOfficeOrStreams: json['boxOfficeOrStreams']?.toString(),
      topSmallTag: json['topSmallTag']?.toString(),
      topMainTag: json['topMainTag']?.toString(),
      subDescription: json['subDescription']?.toString(),
      rankTag: json['rankTag']?.toString(),
      watchProgress: (json['watchProgress'] is num) ? (json['watchProgress'] as num).toDouble() : null,
      remainingTime: json['remainingTime']?.toString(),
      isDownloaded: json['isDownloaded'] == true,
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
    };
  }
}
