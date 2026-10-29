import 'community_post_model.dart';

class PostCommentModel {
  final String id;
  final String postId;
  final PostAuthorModel author;
  final String content;
  final DateTime createdAt;

  PostCommentModel({
    required this.id,
    required this.postId,
    required this.author,
    required this.content,
    required this.createdAt,
  });

  factory PostCommentModel.fromJson(Map<String, dynamic> json) {
    PostAuthorModel authorObj;
    if (json['authorId'] is Map<String, dynamic>) {
      authorObj = PostAuthorModel.fromJson(json['authorId'] as Map<String, dynamic>);
    } else {
      authorObj = PostAuthorModel(id: json['authorId']?.toString() ?? '', displayName: 'User');
    }

    DateTime parsedDate;
    try {
      parsedDate = json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString()).toLocal()
          : DateTime.now();
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return PostCommentModel(
      id: json['_id']?.toString() ?? '',
      postId: json['postId']?.toString() ?? '',
      author: authorObj,
      content: json['content']?.toString() ?? '',
      createdAt: parsedDate,
    );
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }
}

