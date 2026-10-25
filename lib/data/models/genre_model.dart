import 'package:flutter/material.dart';

class GenreModel {
  final String name;
  final int count;

  const GenreModel({
    required this.name,
    this.count = 0,
  });

  factory GenreModel.fromJson(Map<String, dynamic> json) {
    return GenreModel(
      name: json['name']?.toString() ?? '',
      count: (json['count'] is num) ? (json['count'] as num).toInt() : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'count': count,
    };
  }

  /// Curated iconography for genre cards
  IconData get icon {
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

  /// Rich modern gradient accents tailored for each genre
  List<Color> get gradientColors {
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
    return [const Color(0xFFF59E0B), const Color(0xFFD97706)];
  }
}
