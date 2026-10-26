import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final String slug;
  final String icon;
  final String? description;
  final int order;
  final bool isActive;
  final int? movieCount;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.icon = 'movie',
    this.description,
    this.order = 0,
    this.isActive = true,
    this.movieCount,
  });

  /// Dynamically maps icon key or slug to Flutter Material IconData
  IconData get iconData {
    final key = (icon.isNotEmpty ? icon : slug).toLowerCase().trim();

    switch (key) {
      case 'sports':
      case 'sport':
        return Icons.sports_soccer_rounded;
      case 'tv':
      case 'tv-shows':
      case 'tv_shows':
      case 'tvshows':
        return Icons.tv_rounded;
      case 'series':
      case 'shows':
        return Icons.video_library_rounded;
      case 'documentary':
      case 'documentaries':
      case 'doc':
        return Icons.movie_filter_rounded;
      case 'movie':
      case 'movies':
      case 'film':
      case 'cinema':
        return Icons.local_activity_rounded;
      case 'action':
      case 'flame':
        return Icons.local_fire_department_rounded;
      case 'anime':
      case 'animation':
        return Icons.animation_rounded;
      case 'kids':
      case 'children':
        return Icons.child_care_rounded;
      case 'music':
        return Icons.music_note_rounded;
      case 'gaming':
      case 'games':
        return Icons.sports_esports_rounded;
      case 'trending':
      case 'star':
        return Icons.auto_awesome_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      icon: json['icon']?.toString() ?? 'movie',
      description: json['description']?.toString(),
      order: (json['order'] is num) ? (json['order'] as num).toInt() : 0,
      isActive: json['isActive'] is bool ? json['isActive'] as bool : true,
      movieCount: json['movieCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'icon': icon,
      'description': description,
      'order': order,
      'isActive': isActive,
      'movieCount': movieCount,
    };
  }

  /// Default fallback categories if API is loading or offline
  static const List<CategoryModel> defaultCategories = [
    CategoryModel(id: '1', name: 'Movies', slug: 'movies', icon: 'movie', order: 1),
    CategoryModel(id: '2', name: 'Sports', slug: 'sports', icon: 'sports', order: 2),
    CategoryModel(id: '3', name: 'TV Shows', slug: 'tv-shows', icon: 'tv', order: 3),
    CategoryModel(id: '4', name: 'Series', slug: 'series', icon: 'series', order: 4),
    CategoryModel(id: '5', name: 'Documentary', slug: 'documentary', icon: 'documentary', order: 5),
  ];
}
