import 'dart:convert';
import 'dart:io';
import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
import '../models/community_post_model.dart';
import '../models/post_comment_model.dart';
import '../models/user_report_model.dart';

class CommunityApiService {
  final ApiClient _apiClient = ApiClient();

  /// Retrieve paginated Community Feed
  Future<List<CommunityPostModel>> getFeed({
    int page = 1,
    int limit = 15,
    String? movieId,
    String? authorId,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (movieId != null && movieId.isNotEmpty) queryParams['movieId'] = movieId;
    if (authorId != null && authorId.isNotEmpty) queryParams['authorId'] = authorId;

    final response = await _apiClient.get(
      ApiConstants.communityFeed,
      queryParameters: queryParams,
    );

    final responseData = response.data as Map<String, dynamic>;
    final dataList = (responseData['data'] as List<dynamic>?) ?? [];

    return dataList
        .map((item) => CommunityPostModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Create a new post
  Future<CommunityPostModel> createPost({
    required String caption,
    List<String>? images,
    String? movieId,
  }) async {
    final payload = <String, dynamic>{
      'caption': caption.trim(),
    };
    if (images != null && images.isNotEmpty) payload['images'] = images;
    if (movieId != null && movieId.isNotEmpty) payload['movieId'] = movieId;

    final response = await _apiClient.post(
      ApiConstants.communityPosts,
      data: payload,
    );

    final responseData = response.data as Map<String, dynamic>;
    return CommunityPostModel.fromJson(responseData['data'] as Map<String, dynamic>);
  }

  /// Update an existing post
  Future<CommunityPostModel> updatePost({
    required String postId,
    String? caption,
    List<String>? images,
    String? movieId,
  }) async {
    final payload = <String, dynamic>{};
    if (caption != null) payload['caption'] = caption.trim();
    if (images != null) payload['images'] = images;
    if (movieId != null) payload['movieId'] = movieId;

    final response = await _apiClient.put(
      '${ApiConstants.communityPosts}/$postId',
      data: payload,
    );

    final responseData = response.data as Map<String, dynamic>;
    return CommunityPostModel.fromJson(responseData['data'] as Map<String, dynamic>);
  }

  /// Delete a post
  Future<void> deletePost(String postId) async {
    await _apiClient.delete('${ApiConstants.communityPosts}/$postId');
  }

  /// Toggle Like on a post
  Future<Map<String, dynamic>> toggleLike(String postId) async {
    final response = await _apiClient.post('${ApiConstants.communityPosts}/$postId/like');
    final responseData = response.data as Map<String, dynamic>;
    return (responseData['data'] as Map<String, dynamic>?) ?? {};
  }

  /// Get Comments for a post
  Future<List<PostCommentModel>> getComments(String postId, {int page = 1, int limit = 50}) async {
    final response = await _apiClient.get(
      '${ApiConstants.communityPosts}/$postId/comments',
      queryParameters: {'page': page, 'limit': limit},
    );

    final responseData = response.data as Map<String, dynamic>;
    final dataList = (responseData['data'] as List<dynamic>?) ?? [];

    return dataList
        .map((item) => PostCommentModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Add Comment to a post
  Future<PostCommentModel> addComment(String postId, String content) async {
    final response = await _apiClient.post(
      '${ApiConstants.communityPosts}/$postId/comments',
      data: {'content': content.trim()},
    );

    final responseData = response.data as Map<String, dynamic>;
    return PostCommentModel.fromJson(responseData['data'] as Map<String, dynamic>);
  }

  /// Delete Comment
  Future<void> deleteComment(String commentId) async {
    await _apiClient.delete('/community/comments/$commentId');
  }

  /// Submit Report
  Future<void> reportContent({
    required String contentId,
    required String reportedContentType,
    required String reason,
    String? details,
  }) async {
    await _apiClient.post(
      ApiConstants.communityReports,
      data: {
        'contentId': contentId,
        'reportedContentType': reportedContentType,
        'reason': reason,
        if (details != null && details.trim().isNotEmpty) 'details': details.trim(),
      },
    );
  }

  /// Get My Reports (for reporting user to track submission status)
  Future<List<UserReportModel>> getMyReports() async {
    final response = await _apiClient.get('/community/my-reports');
    final responseData = response.data as Map<String, dynamic>;
    final dataList = (responseData['data'] as List<dynamic>?) ?? [];

    return dataList
        .map((item) => UserReportModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Get User Public Profile & Posts
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    final response = await _apiClient.get('/community/users/$userId');
    final responseData = response.data as Map<String, dynamic>;
    return (responseData['data'] as Map<String, dynamic>?) ?? {};
  }

  /// Upload Images with progress tracking
  Future<List<String>> uploadImages(
    List<File> imageFiles, {
    void Function(int current, int total)? onProgress,
  }) async {
    if (imageFiles.isEmpty) return [];

    final List<Map<String, String>> filePayloads = [];
    for (int i = 0; i < imageFiles.length; i++) {
      onProgress?.call(i + 1, imageFiles.length);
      final file = imageFiles[i];
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);
      final filename = file.path.split(Platform.pathSeparator).last;
      final ext = filename.split('.').last.toLowerCase();
      final mimeType = ext == 'png' ? 'image/png' : ext == 'webp' ? 'image/webp' : 'image/jpeg';

      filePayloads.add({
        'data': 'data:$mimeType;base64,$base64String',
        'mimeType': mimeType,
        'fileName': filename,
      });
    }

    final response = await _apiClient.post(
      ApiConstants.communityUpload,
      data: {'images': filePayloads},
    );

    final responseData = response.data as Map<String, dynamic>;
    final dataMap = (responseData['data'] as Map<String, dynamic>?) ?? {};
    final urls = (dataMap['urls'] as List<dynamic>?) ?? [];

    return urls.map((u) => u.toString()).toList();
  }
}
