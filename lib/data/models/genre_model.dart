import 'package:flutter/material.dart';

class GenreModel {
  final String id;
  final String name;
  final String slug;
  final String? iconName;
  final String? gradientStart;
  final String? gradientEnd;
  final String? description;
  final int count;
  final int order;
  final bool isActive;

  const GenreModel({
    this.id = '',
    required this.name,
    this.slug = '',
    this.iconName,
    this.gradientStart,
    this.gradientEnd,
    this.description,
    this.count = 0,
    this.order = 0,
    this.isActive = true,
  });

  factory GenreModel.fromJson(Map<String, dynamic> json) {
    return GenreModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      iconName: json['icon']?.toString(),
      gradientStart: json['gradientStart']?.toString(),
      gradientEnd: json['gradientEnd']?.toString(),
      description: json['description']?.toString(),
      count: (json['count'] is num) ? (json['count'] as num).toInt() : 0,
      order: (json['order'] is num) ? (json['order'] as num).toInt() : 0,
      isActive: json['isActive'] is bool ? json['isActive'] as bool : true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'icon': iconName,
      'gradientStart': gradientStart,
      'gradientEnd': gradientEnd,
      'description': description,
      'count': count,
      'order': order,
      'isActive': isActive,
    };
  }

  GenreModel copyWith({
    String? id,
    String? name,
    String? slug,
    String? iconName,
    String? gradientStart,
    String? gradientEnd,
    String? description,
    int? count,
    int? order,
    bool? isActive,
  }) {
    return GenreModel(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      iconName: iconName ?? this.iconName,
      gradientStart: gradientStart ?? this.gradientStart,
      gradientEnd: gradientEnd ?? this.gradientEnd,
      description: description ?? this.description,
      count: count ?? this.count,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
    );
  }

  static Color? _parseHexColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return null;
    try {
      var hex = hexString.replaceAll('#', '').trim();
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return null;
    }
  }

  /// Curated iconography for genre cards (dynamic from database or name fallback)
  IconData get icon {
    if (iconName != null && iconName!.isNotEmpty) {
      final i = iconName!.toLowerCase();
      if (i == 'flame' || i == 'fire') return Icons.local_fire_department_rounded;
      if (i == 'sparkles' || i == 'stars') return Icons.auto_awesome_rounded;
      if (i == 'rocket') return Icons.rocket_launch_rounded;
      if (i == 'smile' || i == 'laugh') return Icons.sentiment_very_satisfied_rounded;
      if (i == 'zap' || i == 'bolt') return Icons.bolt_rounded;
      if (i == 'ghost' || i == 'skull') return Icons.nightlight_round;
      if (i == 'clapperboard' || i == 'film') return Icons.movie_filter_rounded;
      if (i == 'heart') return Icons.favorite_rounded;
      if (i == 'compass') return Icons.explore_rounded;
      if (i == 'eye' || i == 'search') return Icons.visibility_rounded;
      if (i == 'theater' || i == 'masks') return Icons.theater_comedy_rounded;
    }

    final lower = name.toLowerCase();
    if (lower.contains('action')) return Icons.local_fire_department_rounded;
    if (lower.contains('comedy')) return Icons.sentiment_very_satisfied_rounded;
    if (lower.contains('thrill')) return Icons.bolt_rounded;
    if (lower.contains('horror')) return Icons.nightlight_round;
    if (lower.contains('sci-fi') || lower.contains('science')) return Icons.rocket_launch_rounded;
    if (lower.contains('drama')) return Icons.theater_comedy_rounded;
    if (lower.contains('animat')) return Icons.auto_awesome_rounded;
    if (lower.contains('romanc')) return Icons.favorite_rounded;
    if (lower.contains('adventur')) return Icons.explore_rounded;
    if (lower.contains('crime')) return Icons.fingerprint_rounded;
    if (lower.contains('fantasy')) return Icons.stars_rounded;
    if (lower.contains('myster')) return Icons.visibility_rounded;
    return Icons.movie_filter_rounded;
  }

  /// Rich modern gradient accents tailored for each genre (supports database hex gradients)
  List<Color> get gradientColors {
    final start = _parseHexColor(gradientStart);
    final end = _parseHexColor(gradientEnd);
    if (start != null && end != null) {
      return [start, end];
    } else if (start != null) {
      return [start, start.withValues(alpha: 0.8)];
    }

    final lower = name.toLowerCase();
    if (lower.contains('action')) {
      return [const Color(0xFFFF5722), const Color(0xFFF59E0B)];
    }
    if (lower.contains('comedy')) {
      return [const Color(0xFFFBBF24), const Color(0xFFD97706)];
    }
    if (lower.contains('thrill')) {
      return [const Color(0xFF8B5CF6), const Color(0xFFEC4899)];
    }
    if (lower.contains('horror')) {
      return [const Color(0xFFEF4444), const Color(0xFF7F1D1D)];
    }
    if (lower.contains('sci-fi') || lower.contains('science')) {
      return [const Color(0xFF06B6D4), const Color(0xFF3B82F6)];
    }
    if (lower.contains('drama')) {
      return [const Color(0xFF6366F1), const Color(0xFF4F46E5)];
    }
    if (lower.contains('animat')) {
      return [const Color(0xFF10B981), const Color(0xFF06B6D4)];
    }
    if (lower.contains('romanc')) {
      return [const Color(0xFFF43F5E), const Color(0xFFFB7185)];
    }
    if (lower.contains('adventur')) {
      return [const Color(0xFF14B8A6), const Color(0xFF0D9488)];
    }
    if (lower.contains('crime')) {
      return [const Color(0xFF64748B), const Color(0xFFDC2626)];
    }
    if (lower.contains('fantasy')) {
      return [const Color(0xFFA855F7), const Color(0xFF7C3AED)];
    }
    if (lower.contains('myster')) {
      return [const Color(0xFF0D9488), const Color(0xFF0284C7)];
    }
    return [const Color(0xFFF59E0B), const Color(0xFFD97706)];
  }
}
