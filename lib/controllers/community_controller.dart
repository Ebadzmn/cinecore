import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/community_post_model.dart';
import '../data/models/post_comment_model.dart';
import '../data/models/user_report_model.dart';
import '../data/services/community_api_service.dart';
import 'auth_controller.dart';
import '../../auth/screen/login_screen.dart';

class CommunityController extends GetxController {
  final CommunityApiService _apiService = CommunityApiService();

  // Feed State
  final RxList<CommunityPostModel> posts = <CommunityPostModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxString errorMessage = ''.obs;
  int _currentPage = 1;
  static const int _pageSize = 15;

  // Creation & Upload State
  final RxBool isPosting = false.obs;
  final RxBool isUploadingImages = false.obs;
  final RxString uploadProgressText = ''.obs;

  // Comments State
  final RxList<PostCommentModel> comments = <PostCommentModel>[].obs;
  final RxBool isLoadingComments = false.obs;
  final RxString activeCommentPostId = ''.obs;

  // My Reports State (Requirement 2)
  final RxList<UserReportModel> myReports = <UserReportModel>[].obs;
  final RxBool isLoadingMyReports = false.obs;

  // My Posts State
  final RxList<CommunityPostModel> myPosts = <CommunityPostModel>[].obs;
  final RxBool isLoadingMyPosts = false.obs;
  final RxInt myTotalPostsCount = 0.obs;

  // Active Movie Filter
  final RxnString selectedMovieFilter = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadFeed();
    loadMyPosts();
  }

  /// Ensure the user is authenticated (not guest) before protected actions
  bool requireAuth({required String actionName}) {
    final authController = Get.find<AuthController>();
    final isGuest = authController.userProfile.value.isGuest;
    final isLoggedIn = authController.isLoggedIn.value;

    if (!isLoggedIn || isGuest) {
      Get.dialog(
        AlertDialog(
          backgroundColor: const Color(0xFF161822),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFF2A2D3D)),
          ),
          title: Row(
            children: const [
              Icon(Icons.lock_outline_rounded, color: Color(0xFFF59E0B)),
              SizedBox(width: 10),
              Text(
                'Sign In Required',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'You need an active account to $actionName. Sign in to share and interact with the CineCore community.',
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.to(() => const LoginScreen());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
      return false;
    }
    return true;
  }

  /// Load or Refresh Feed
  Future<void> loadFeed({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      hasMore.value = true;
    }

    if (_currentPage == 1) {
      isLoading.value = true;
      errorMessage.value = '';
    } else {
      if (!hasMore.value || isLoadingMore.value) return;
      isLoadingMore.value = true;
    }

    try {
      final fetchedPosts = await _apiService.getFeed(
        page: _currentPage,
        limit: _pageSize,
        movieId: selectedMovieFilter.value,
      );

      if (_currentPage == 1) {
        posts.assignAll(fetchedPosts);
      } else {
        posts.addAll(fetchedPosts);
      }

      if (fetchedPosts.length < _pageSize) {
        hasMore.value = false;
      } else {
        _currentPage++;
      }
    } catch (e) {
      if (_currentPage == 1) {
        errorMessage.value = 'Failed to load community feed. Tap to retry.';
      }
      debugPrint('Error loading community feed: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// Like / Unlike with Optimistic UI Update
  Future<void> toggleLike(CommunityPostModel post) async {
    if (!requireAuth(actionName: 'like posts')) return;

    final originalIsLiked = post.isLikedByMe;
    final originalCount = post.likesCount;

    // Optimistic update
    post.isLikedByMe = !originalIsLiked;
    post.likesCount += post.isLikedByMe ? 1 : -1;
    if (post.likesCount < 0) post.likesCount = 0;
    posts.refresh();
    myPosts.refresh();

    try {
      final res = await _apiService.toggleLike(post.id);
      if (res['likesCount'] != null) {
        post.likesCount = int.tryParse(res['likesCount'].toString()) ?? post.likesCount;
        post.isLikedByMe = res['isLiked'] == true;
        posts.refresh();
        myPosts.refresh();
      }
    } catch (e) {
      // Rollback on failure
      post.isLikedByMe = originalIsLiked;
      post.likesCount = originalCount;
      posts.refresh();
      myPosts.refresh();
      Get.snackbar(
        'Action Failed',
        'Could not update like. Please check connection.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    }
  }

  /// Create and Publish a Post (Prevents duplicate calls, handles upload progress)
  Future<bool> createPost({
    required String caption,
    List<File>? localImages,
    String? movieId,
  }) async {
    if (isPosting.value) return false;
    if (!requireAuth(actionName: 'publish posts')) return false;

    if (caption.trim().isEmpty && (localImages == null || localImages.isEmpty)) {
      Get.snackbar(
        'Empty Post',
        'Please enter a caption or select photos.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFF59E0B),
        colorText: Colors.black,
      );
      return false;
    }

    isPosting.value = true;
    try {
      List<String> uploadedUrls = [];
      if (localImages != null && localImages.isNotEmpty) {
        isUploadingImages.value = true;
        uploadedUrls = await _apiService.uploadImages(
          localImages,
          onProgress: (current, total) {
            uploadProgressText.value = 'Uploading media $current of $total...';
          },
        );
        isUploadingImages.value = false;
      }

      final createdPost = await _apiService.createPost(
        caption: caption.trim().isEmpty ? 'Shared photos' : caption.trim(),
        images: uploadedUrls,
        movieId: movieId,
      );

      posts.insert(0, createdPost);
      myPosts.insert(0, createdPost);
      myTotalPostsCount.value++;
      return true;
    } catch (e) {
      debugPrint('Error publishing post: $e');
      rethrow;
    } finally {
      isPosting.value = false;
      isUploadingImages.value = false;
      uploadProgressText.value = '';
    }
  }

  /// Update an existing Post caption
  Future<bool> updatePost({
    required String postId,
    required String caption,
  }) async {
    try {
      final updated = await _apiService.updatePost(
        postId: postId,
        caption: caption,
      );

      final idx = posts.indexWhere((p) => p.id == postId);
      if (idx != -1) {
        posts[idx] = updated;
        posts.refresh();
      }

      final myIdx = myPosts.indexWhere((p) => p.id == postId);
      if (myIdx != -1) {
        myPosts[myIdx] = updated;
        myPosts.refresh();
      }

      Get.snackbar(
        'Post Updated',
        'Your post has been updated.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not update post.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
      return false;
    }
  }

  /// Delete Post
  Future<void> deletePost(String postId) async {
    try {
      await _apiService.deletePost(postId);
      posts.removeWhere((p) => p.id == postId);
      myPosts.removeWhere((p) => p.id == postId);
      if (myTotalPostsCount.value > 0) {
        myTotalPostsCount.value--;
      }
      Get.snackbar(
        'Post Deleted',
        'Your post has been removed.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF334155),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not delete post.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
    }
  }

  /// Comments Management
  Future<void> loadComments(String postId) async {
    activeCommentPostId.value = postId;
    isLoadingComments.value = true;
    comments.clear();

    try {
      final fetched = await _apiService.getComments(postId);
      comments.assignAll(fetched);
    } catch (e) {
      debugPrint('Error loading comments: $e');
    } finally {
      isLoadingComments.value = false;
    }
  }

  Future<bool> addComment(String postId, String content) async {
    if (!requireAuth(actionName: 'comment on posts')) return false;

    if (content.trim().isEmpty) return false;

    try {
      final newComment = await _apiService.addComment(postId, content);
      comments.add(newComment);

      final post = posts.firstWhereOrNull((p) => p.id == postId) ??
          myPosts.firstWhereOrNull((p) => p.id == postId);
      if (post != null) {
        post.commentsCount++;
        posts.refresh();
        myPosts.refresh();
      }
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add comment.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
      return false;
    }
  }

  Future<void> deleteComment(String commentId, String postId) async {
    try {
      await _apiService.deleteComment(commentId);
      comments.removeWhere((c) => c.id == commentId);

      final post = posts.firstWhereOrNull((p) => p.id == postId) ??
          myPosts.firstWhereOrNull((p) => p.id == postId);
      if (post != null && post.commentsCount > 0) {
        post.commentsCount--;
        posts.refresh();
        myPosts.refresh();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not delete comment.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
    }
  }

  /// Submit Report
  Future<bool> submitReport({
    required String contentId,
    required String reportedContentType,
    required String reason,
    String? details,
  }) async {
    if (!requireAuth(actionName: 'report content')) return false;

    try {
      await _apiService.reportContent(
        contentId: contentId,
        reportedContentType: reportedContentType,
        reason: reason,
        details: details,
      );
      // Refresh reports list if loaded
      loadMyReports();
      return true;
    } catch (e) {
      debugPrint('Report error: $e');
      rethrow;
    }
  }

  /// Load My Reports (Requirement 2)
  Future<void> loadMyReports() async {
    final authController = Get.find<AuthController>();
    if (!authController.isLoggedIn.value || authController.userProfile.value.isGuest) {
      myReports.clear();
      return;
    }

    isLoadingMyReports.value = true;
    try {
      final fetched = await _apiService.getMyReports();
      myReports.assignAll(fetched);
    } catch (e) {
      debugPrint('Error loading my reports: $e');
    } finally {
      isLoadingMyReports.value = false;
    }
  }

  /// Load My Posts for authenticated user
  Future<void> loadMyPosts() async {
    final authController = Get.find<AuthController>();
    final profile = authController.userProfile.value;
    if (!authController.isLoggedIn.value || profile.isGuest || profile.id.isEmpty) {
      myPosts.clear();
      myTotalPostsCount.value = 0;
      return;
    }

    isLoadingMyPosts.value = true;
    try {
      final data = await _apiService.getUserProfile(profile.id);
      final postsRaw = data['posts'] as List<dynamic>? ?? [];
      final parsed = postsRaw
          .map((p) => CommunityPostModel.fromJson(p as Map<String, dynamic>))
          .toList();
      myPosts.assignAll(parsed);
      myTotalPostsCount.value = (data['totalPosts'] as num?)?.toInt() ?? parsed.length;
    } catch (e) {
      debugPrint('Error loading my posts: $e');
    } finally {
      isLoadingMyPosts.value = false;
    }
  }

  /// Fetch User Profile Data
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    return await _apiService.getUserProfile(userId);
  }
}
