import '../../core/network/api_constants.dart';

class PostAuthorModel {
  final String id;
  final String displayName;
  final String avatarUrl;
  final bool isGuest;

  PostAuthorModel({
    required this.id,
    required this.displayName,
    this.avatarUrl = '',
    this.isGuest = false,
  });

  factory PostAuthorModel.fromJson(Map<String, dynamic> json) {
    return PostAuthorModel(
      id: (json['_id'] ?? json['id'] ?? json['userId'])?.toString() ?? '',
      displayName: (json['displayName'] ?? json['name'] ?? json['username'])?.toString() ?? 'Cinephile',
      avatarUrl: ApiConstants.resolveImageUrl(
        (json['avatarUrl'] ?? json['avatar'] ?? json['profileImage'])?.toString() ?? '',
      ),
      isGuest: json['isGuest'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'displayName': displayName,
    'avatarUrl': avatarUrl,
    'isGuest': isGuest,
  };
}

class AttachedMovieModel {
  final String id;
  final String title;
  final String poster;
  final String type;
  final int? releaseYear;

  AttachedMovieModel({
    required this.id,
    required this.title,
    this.poster = '',
    this.type = 'MOVIE',
    this.releaseYear,
  });

  factory AttachedMovieModel.fromJson(Map<String, dynamic> json) {
    return AttachedMovieModel(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      title: (json['title'] ?? json['name'])?.toString() ?? '',
      poster: ApiConstants.resolveImageUrl(
        (json['poster'] ?? json['posterUrl'] ?? json['imageUrl'] ?? json['backdrop'])?.toString() ?? '',
      ),
      type: json['type']?.toString() ?? 'MOVIE',
      releaseYear: json['releaseYear'] != null
          ? int.tryParse(json['releaseYear'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'title': title,
    'poster': poster,
    'type': type,
    'releaseYear': releaseYear,
  };
}

class CommunityPostModel {
  final String id;
  final PostAuthorModel author;
  String caption;
  final List<String> images;
  final AttachedMovieModel? movie;
  int likesCount;
  int commentsCount;
  int reportsCount;
  bool isLikedByMe;
  final bool isOwner;
  final DateTime createdAt;

  CommunityPostModel({
    required this.id,
    required this.author,
    required this.caption,
    this.images = const [],
    this.movie,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.reportsCount = 0,
    this.isLikedByMe = false,
    this.isOwner = false,
    required this.createdAt,
  });

  factory CommunityPostModel.fromJson(Map<String, dynamic> json) {
    // Parse author
    PostAuthorModel authorObj;
    final rawAuthor = json['authorId'] ?? json['author'] ?? json['user'];
    if (rawAuthor is Map<String, dynamic>) {
      authorObj = PostAuthorModel.fromJson(rawAuthor);
    } else {
      authorObj = PostAuthorModel(
        id: rawAuthor?.toString() ?? '',
        displayName: json['authorName']?.toString() ?? 'Cinephile',
      );
    }

    // Parse movie
    AttachedMovieModel? movieObj;
    final rawMovie = json['movieId'] ?? json['movie'];
    if (rawMovie is Map<String, dynamic>) {
      movieObj = AttachedMovieModel.fromJson(rawMovie);
    }

    // Parse images
    final List<String> imageList = [];
    if (json['images'] is List) {
      for (final img in json['images']) {
        if (img != null) {
          final resolved = ApiConstants.resolveImageUrl(img.toString()).trim();
          if (resolved.isNotEmpty) {
            imageList.add(resolved);
          }
        }
      }
    }

    DateTime parsedDate;
    try {
      parsedDate = json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString()).toLocal()
          : DateTime.now();
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return CommunityPostModel(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      author: authorObj,
      caption: json['caption']?.toString() ?? '',
      images: imageList,
      movie: movieObj,
      likesCount: int.tryParse(json['likesCount']?.toString() ?? '0') ?? 0,
      commentsCount: int.tryParse(json['commentsCount']?.toString() ?? '0') ?? 0,
      reportsCount: int.tryParse(json['reportsCount']?.toString() ?? '0') ?? 0,
      isLikedByMe: json['isLikedByMe'] == true,
      isOwner: json['isOwner'] == true,
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'authorId': author.toJson(),
    'caption': caption,
    'images': images,
    'movieId': movie?.toJson(),
    'likesCount': likesCount,
    'commentsCount': commentsCount,
    'reportsCount': reportsCount,
    'isLikedByMe': isLikedByMe,
    'isOwner': isOwner,
    'createdAt': createdAt.toIso8601String(),
  };

  CommunityPostModel copyWith({
    String? id,
    PostAuthorModel? author,
    String? caption,
    List<String>? images,
    AttachedMovieModel? movie,
    int? likesCount,
    int? commentsCount,
    int? reportsCount,
    bool? isLikedByMe,
    bool? isOwner,
    DateTime? createdAt,
  }) {
    return CommunityPostModel(
      id: id ?? this.id,
      author: author ?? this.author,
      caption: caption ?? this.caption,
      images: images ?? this.images,
      movie: movie ?? this.movie,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      reportsCount: reportsCount ?? this.reportsCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      isOwner: isOwner ?? this.isOwner,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }
}

