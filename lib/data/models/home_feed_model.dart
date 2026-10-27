import 'package:flutter/material.dart';
import 'movie_model.dart';
import '../../home/widget/spotlight_hero_card.dart';
import '../../home/widget/top_blockbusters_section.dart';

class HeroBannerModel {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String mediaType;
  final MovieModel? movie;
  final String? customImageUrl;
  final String badge;
  final String ctaText;
  final String ctaAction;
  final String? targetUrl;
  final int order;
  final bool isActive;

  const HeroBannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.mediaType,
    this.movie,
    this.customImageUrl,
    required this.badge,
    required this.ctaText,
    required this.ctaAction,
    this.targetUrl,
    required this.order,
    required this.isActive,
  });

  String get displayImageUrl {
    if (customImageUrl != null && customImageUrl!.trim().isNotEmpty) {
      return customImageUrl!;
    }
    if (movie != null) {
      if (movie!.backdropUrl != null && movie!.backdropUrl!.isNotEmpty) {
        return movie!.backdropUrl!;
      }
      return movie!.imageUrl;
    }
    return 'https://images.unsplash.com/photo-1534447677768-be436bb09401?q=80&w=1200&auto=format&fit=crop';
  }

  SpotlightMovieItem toSpotlightItem() {
    // Split title into prefix and highlight for cinematic typography
    final words = title.trim().split(' ');
    String prefix = title;
    String highlight = '';
    if (words.length > 1) {
      prefix = '${words.sublist(0, words.length - 1).join(' ')} ';
      highlight = words.last;
    }

    Color badgeBg = const Color(0xD978350F);
    Color badgeBorder = const Color(0x66F59E0B);
    final badgeUpper = badge.toUpperCase();
    if (badgeUpper.contains('PREMIERE') || badgeUpper.contains('EXCLUSIVE')) {
      badgeBg = const Color(0xD9312E81);
      badgeBorder = const Color(0x666366F1);
    } else if (badgeUpper.contains('TRENDING') || badgeUpper.contains('TOP')) {
      badgeBg = const Color(0xD978350F);
      badgeBorder = const Color(0x66F59E0B);
    } else if (badgeUpper.contains('SERIES') || badgeUpper.contains('SHOW')) {
      badgeBg = const Color(0xD9064E3B);
      badgeBorder = const Color(0x6610B981);
    }

    return SpotlightMovieItem(
      id: id,
      titlePrefix: prefix,
      titleHighlight: highlight,
      subtitle: subtitle.isNotEmpty ? subtitle : (movie?.tagline ?? movie?.subtitle ?? ''),
      fullTitle: title,
      imageUrl: displayImageUrl,
      rating: movie?.rating ?? 9.0,
      badgeText: badge.isNotEmpty ? badge.toUpperCase() : 'FEATURED',
      badgeBgColor: badgeBg,
      badgeBorderColor: badgeBorder,
      resolution: movie?.resolution.isNotEmpty == true ? movie!.resolution : '4K Ultra HD',
      duration: movie?.duration.isNotEmpty == true ? movie!.duration : '2h 15m',
      genres: movie?.genres.isNotEmpty == true ? movie!.genres : 'Action, Drama',
      ageRating: movie?.ageRating ?? '16+',
    );
  }

  factory HeroBannerModel.fromJson(Map<String, dynamic> json) {
    MovieModel? parsedMovie;
    final movieRaw = json['movie'] ?? json['movieId'];
    if (movieRaw != null && movieRaw is Map<String, dynamic>) {
      parsedMovie = MovieModel.fromJson(movieRaw);
    }

    return HeroBannerModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? parsedMovie?.title ?? 'Featured Title').toString(),
      subtitle: (json['subtitle'] ?? parsedMovie?.subtitle ?? '').toString(),
      description: (json['description'] ?? parsedMovie?.synopsis ?? '').toString(),
      mediaType: (json['mediaType'] ?? 'MOVIE').toString().toUpperCase(),
      movie: parsedMovie,
      customImageUrl: (json['customImageUrl'] ?? json['imageUrl'])?.toString(),
      badge: (json['badge'] ?? 'FEATURED').toString(),
      ctaText: (json['ctaText'] ?? 'WATCH NOW').toString(),
      ctaAction: (json['ctaAction'] ?? 'PLAY').toString().toUpperCase(),
      targetUrl: json['targetUrl']?.toString(),
      order: (json['order'] is num) ? (json['order'] as num).toInt() : 0,
      isActive: json['isActive'] is bool ? json['isActive'] as bool : true,
    );
  }
}

class HomeSectionItemModel {
  final MovieModel movie;
  final int order;
  final String? customTag;

  const HomeSectionItemModel({
    required this.movie,
    required this.order,
    this.customTag,
  });

  TopBlockbusterMovie toTopBlockbusterMovie(int rankIndex) {
    final rank = rankIndex + 1;
    final tag = customTag != null && customTag!.isNotEmpty
        ? customTag!
        : '#$rank BLOCKBUSTER';

    return TopBlockbusterMovie(
      id: movie.id,
      title: movie.title,
      topSmallTag: movie.studio ?? 'CINEMATIC SCREENING',
      topMainTag: movie.tagline ?? movie.title.toUpperCase(),
      subDescription: movie.subtitle ?? movie.synopsis ?? 'POPULAR BLOCKBUSTER STREAMING',
      rankTag: tag,
      imageUrl: movie.imageUrl,
      rating: movie.rating,
      duration: movie.duration,
      genres: movie.genres,
    );
  }

  factory HomeSectionItemModel.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('title') && (json.containsKey('id') || json.containsKey('_id'))) {
      final orderVal = (json['order'] is num)
          ? (json['order'] as num).toInt()
          : ((json['rank'] is num) ? (json['rank'] as num).toInt() : 0);
      return HomeSectionItemModel(
        movie: MovieModel.fromJson(json),
        order: orderVal,
        customTag: json['rankTag']?.toString() ?? json['customTag']?.toString(),
      );
    }
    final movieData = (json['movie'] ?? json['movieId']) as Map<String, dynamic>? ?? {};
    return HomeSectionItemModel(
      movie: MovieModel.fromJson(movieData),
      order: (json['order'] is num) ? (json['order'] as num).toInt() : 0,
      customTag: json['customTag']?.toString() ?? json['rankTag']?.toString(),
    );
  }
}

class HomeSectionModel {
  final String id;
  final String key;
  final String title;
  final String subtitle;
  final String sectionType;
  final String contentType;
  final List<HomeSectionItemModel> items;
  final int maxItems;
  final int order;
  final bool isActive;
  final bool isSystem;

  const HomeSectionModel({
    required this.id,
    required this.key,
    required this.title,
    required this.subtitle,
    required this.sectionType,
    required this.contentType,
    required this.items,
    required this.maxItems,
    required this.order,
    required this.isActive,
    required this.isSystem,
  });

  List<MovieModel> get movies => items.map((e) => e.movie).toList();

  factory HomeSectionModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final List<HomeSectionItemModel> parsedItems = [];
    if (rawItems is List) {
      for (final raw in rawItems) {
        if (raw is Map<String, dynamic>) {
          if (raw['movie'] != null || raw['movieId'] != null || raw['title'] != null) {
            parsedItems.add(HomeSectionItemModel.fromJson(raw));
          }
        }
      }
    }

    return HomeSectionModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      key: (json['key'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      sectionType: (json['sectionType'] ?? 'MOVIE_ROW').toString().toUpperCase(),
      contentType: (json['contentType'] ?? 'MOVIE').toString().toUpperCase(),
      items: parsedItems,
      maxItems: (json['maxItems'] is num) ? (json['maxItems'] as num).toInt() : 20,
      order: (json['order'] is num) ? (json['order'] as num).toInt() : 0,
      isActive: json['isActive'] is bool ? json['isActive'] as bool : true,
      isSystem: json['isSystem'] is bool ? json['isSystem'] as bool : false,
    );
  }
}

class HomeFeedModel {
  final List<HeroBannerModel> banners;
  final List<HomeSectionModel> sections;

  const HomeFeedModel({
    required this.banners,
    required this.sections,
  });

  HomeSectionModel? getSection(String key) {
    try {
      return sections.firstWhere((s) => s.key == key && s.isActive);
    } catch (_) {
      return null;
    }
  }

  factory HomeFeedModel.fromJson(Map<String, dynamic> json) {
    final rawBanners = json['heroBanners'] ?? json['banners'];
    final List<HeroBannerModel> parsedBanners = [];
    if (rawBanners is List) {
      for (final b in rawBanners) {
        if (b is Map<String, dynamic>) {
          parsedBanners.add(HeroBannerModel.fromJson(b));
        }
      }
    }

    final rawSections = json['sections'];
    final List<HomeSectionModel> parsedSections = [];
    if (rawSections is List) {
      for (final s in rawSections) {
        if (s is Map<String, dynamic>) {
          parsedSections.add(HomeSectionModel.fromJson(s));
        }
      }
    }

    return HomeFeedModel(
      banners: parsedBanners,
      sections: parsedSections,
    );
  }
}
