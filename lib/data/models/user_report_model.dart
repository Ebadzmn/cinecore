import '../../core/network/api_constants.dart';

class UserReportModel {
  final String id;
  final String reportedContentType;
  final String contentId;
  final String reason;
  final String? details;
  final String status;
  final String actionTaken;
  final String userNotification;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? postCaption;
  final String? authorName;
  final List<String> postImages;

  UserReportModel({
    required this.id,
    required this.reportedContentType,
    required this.contentId,
    required this.reason,
    this.details,
    required this.status,
    required this.actionTaken,
    required this.userNotification,
    required this.createdAt,
    required this.updatedAt,
    this.postCaption,
    this.authorName,
    this.postImages = const [],
  });

  factory UserReportModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic d) {
      if (d == null) return DateTime.now();
      try {
        return DateTime.parse(d.toString()).toLocal();
      } catch (_) {
        return DateTime.now();
      }
    }

    final postMap = json['post'] is Map<String, dynamic>
        ? json['post'] as Map<String, dynamic>
        : (json['postId'] is Map<String, dynamic> ? json['postId'] as Map<String, dynamic> : null);
    final List<String> imgList = [];
    if (postMap != null && postMap['images'] is List) {
      for (final img in postMap['images']) {
        if (img != null && img.toString().trim().isNotEmpty) {
          imgList.add(ApiConstants.resolveImageUrl(img.toString()));
        }
      }
    }

    return UserReportModel(
      id: json['_id']?.toString() ?? '',
      reportedContentType: json['reportedContentType']?.toString() ?? 'POST',
      contentId: json['contentId']?.toString() ?? '',
      reason: json['reason']?.toString() ?? 'OTHER',
      details: json['details']?.toString(),
      status: json['status']?.toString() ?? 'PENDING',
      actionTaken: json['actionTaken']?.toString() ?? 'NONE',
      userNotification: json['userNotification']?.toString() ?? 'Report received and queued for review.',
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
      postCaption: postMap?['caption']?.toString(),
      authorName: postMap?['authorName']?.toString() ?? (postMap?['authorId'] is Map ? (postMap?['authorId'] as Map)['displayName']?.toString() : null),
      postImages: imgList,
    );
  }

  String get formattedStatus {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Submitted';
      case 'UNDER_REVIEW':
        return 'Under Review';
      case 'ACTION_TAKEN':
        return 'Action Taken';
      case 'REJECTED':
      case 'DISMISSED':
        return 'Rejected';
      case 'RESOLVED':
        return 'Resolved';
      default:
        return status;
    }
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

