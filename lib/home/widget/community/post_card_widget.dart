import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../controllers/community_controller.dart';
import '../../../data/models/community_post_model.dart';
import '../../screen/movie_details_screen.dart';
import '../../screen/series_details_screen.dart';
import '../../screen/user_profile_screen.dart';
import '../../../core/network/api_constants.dart';
import 'full_screen_image_viewer.dart';
import 'comments_bottom_sheet.dart';
import 'report_dialog.dart';

class PostCardWidget extends StatefulWidget {
  final CommunityPostModel post;
  final VoidCallback? onPostDeleted;

  const PostCardWidget({
    super.key,
    required this.post,
    this.onPostDeleted,
  });

  @override
  State<PostCardWidget> createState() => _PostCardWidgetState();
}

class _PostCardWidgetState extends State<PostCardWidget> {
  final CommunityController _controller = Get.find<CommunityController>();
  bool _isExpanded = false;
  bool _isLiking = false;

  @override
  void didUpdateWidget(covariant PostCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {});
  }

  Future<void> _handleToggleLike() async {
    if (_isLiking) return;
    _isLiking = true;
    setState(() {});

    try {
      await _controller.toggleLike(widget.post);
    } finally {
      if (mounted) {
        setState(() {
          _isLiking = false;
        });
      }
    }
  }

  Future<void> _openComments() async {
    await Get.bottomSheet(
      CommentsBottomSheet(postId: widget.post.id),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
    if (mounted) {
      setState(() {});
    }
  }

  void _sharePost() {
    final textToShare = widget.post.caption.isNotEmpty
        ? '${widget.post.author.displayName} on CineCore:\n"${widget.post.caption}"'
        : '${widget.post.author.displayName} shared ${widget.post.movie != null ? 'about "${widget.post.movie!.title}"' : 'a moment'} on CineCore!';

    Clipboard.setData(ClipboardData(text: textToShare));
    Get.snackbar(
      'Copied to Clipboard',
      'Post content copied. You can now share it anywhere!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1E293B),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void _openUserProfile() {
    if (widget.post.author.id.isEmpty) return;
    Get.to(
      () => UserProfileScreen(
        userId: widget.post.author.id,
        initialDisplayName: widget.post.author.displayName,
        initialAvatarUrl: ApiConstants.resolveImageUrl(widget.post.author.avatarUrl),
      ),
    );
  }

  void _openAttachedMovie() {
    final movie = widget.post.movie;
    if (movie == null || movie.id.isEmpty) return;

    final resolvedPoster = ApiConstants.resolveImageUrl(movie.poster);

    if (movie.type.toUpperCase() == 'SERIES') {
      Get.to(
        () => SeriesDetailsScreen(
          seriesId: movie.id,
          title: movie.title,
          heroImageUrl: resolvedPoster,
        ),
      );
    } else {
      Get.to(
        () => MovieDetailsScreen(
          movieId: movie.id,
          title: movie.title,
          heroImageUrl: resolvedPoster,
        ),
      );
    }
  }

  void _openEditPostDialog() {
    final textController = TextEditingController(text: widget.post.caption);
    bool isSaving = false;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF161822),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFF2A2D3D)),
            ),
            title: const Row(
              children: [
                Icon(Icons.edit_note_rounded, color: Color(0xFFF59E0B)),
                SizedBox(width: 8),
                Text(
                  'Edit Post',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: textController,
                  maxLines: 4,
                  enabled: !isSaving,
                  style: const TextStyle(color: Colors.white, fontSize: 13.5),
                  decoration: InputDecoration(
                    hintText: 'Write your caption...',
                    hintStyle: const TextStyle(color: Color(0xFF64748B)),
                    filled: true,
                    fillColor: const Color(0xFF0F1117),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF2A2D3D)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF2A2D3D)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFF59E0B)),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Get.back(),
                child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
              ),
              ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        final newCaption = textController.text.trim();
                        if (newCaption.isEmpty && widget.post.images.isEmpty) {
                          Get.snackbar(
                            'Empty Post',
                            'Post caption cannot be empty when there are no images.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: const Color(0xFFF59E0B),
                            colorText: Colors.black,
                          );
                          return;
                        }

                        setDialogState(() => isSaving = true);
                        final success = await _controller.updatePost(
                          postId: widget.post.id,
                          caption: newCaption,
                        );

                        if (success) {
                          widget.post.caption = newCaption;
                          if (mounted) setState(() {});
                          Get.back();
                        } else {
                          setDialogState(() => isSaving = false);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeletePost() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF161822),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2A2D3D)),
        ),
        title: const Text(
          'Delete Post',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to permanently delete this post?',
          style: TextStyle(color: Color(0xFF94A3B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _controller.deletePost(widget.post.id);
              widget.onPostDeleted?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final resolvedAvatar = ApiConstants.resolveImageUrl(post.author.avatarUrl);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF141622),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF222638)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
            child: Row(
              children: [
                // Clickable Author Details
                Expanded(
                  child: GestureDetector(
                    onTap: _openUserProfile,
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 19,
                          backgroundColor: const Color(0xFF232738),
                          backgroundImage: resolvedAvatar.isNotEmpty
                              ? NetworkImage(resolvedAvatar)
                              : null,
                          onBackgroundImageError: resolvedAvatar.isNotEmpty
                              ? (exception, stackTrace) {}
                              : null,
                          child: resolvedAvatar.isEmpty
                              ? Text(
                                  post.author.displayName.isNotEmpty
                                      ? post.author.displayName[0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    color: Color(0xFFFBBF24),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),

                        // Name and Time
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      post.author.displayName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (post.author.isGuest) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 1.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2A2D3D),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'Guest',
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                post.timeAgo,
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Options Menu (Edit & Delete for Owner, Report for Others)
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_horiz_rounded,
                    color: Colors.white54,
                  ),
                  color: const Color(0xFF1E2232),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  onSelected: (val) {
                    if (val == 'edit') {
                      _openEditPostDialog();
                    } else if (val == 'delete') {
                      _confirmDeletePost();
                    } else if (val == 'report') {
                      if (!_controller.requireAuth(actionName: 'report content')) return;
                      Get.dialog(
                        ReportDialog(contentId: post.id, contentType: 'POST'),
                      );
                    }
                  },
                  itemBuilder: (ctx) => [
                    if (post.isOwner) ...[
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              color: Color(0xFFFBBF24),
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Edit Post',
                              style: TextStyle(
                                color: Color(0xFFFBBF24),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline_rounded,
                              color: Color(0xFFEF4444),
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Delete Post',
                              style: TextStyle(
                                color: Color(0xFFEF4444),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else
                      const PopupMenuItem(
                        value: 'report',
                        child: Row(
                          children: [
                            Icon(
                              Icons.flag_outlined,
                              color: Colors.white70,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Report Post',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Caption with "See more" / "See less"
          if (post.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.caption,
                    maxLines: _isExpanded ? null : 3,
                    overflow: _isExpanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFE2E8F0),
                      fontSize: 13.5,
                      height: 1.4,
                    ),
                  ),
                  if (post.caption.length > 120)
                    GestureDetector(
                      onTap: () => setState(() => _isExpanded = !_isExpanded),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _isExpanded ? 'See less' : 'See more',
                          style: const TextStyle(
                            color: Color(0xFFF59E0B),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

          // Images Gallery Grid
          if (post.images.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildImageGallery(context, post.images),
          ],

          // Attached Movie / Series Pill
          if (post.movie != null && post.movie!.title.isNotEmpty) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: InkWell(
                onTap: _openAttachedMovie,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D0F17),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF282C3E)),
                  ),
                  child: Row(
                    children: [
                      // Poster thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: post.movie!.poster.isNotEmpty
                            ? Image.network(
                                ApiConstants.resolveImageUrl(post.movie!.poster),
                                width: 38,
                                height: 52,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      width: 38,
                                      height: 52,
                                      color: Colors.white10,
                                      child: const Icon(
                                        Icons.movie,
                                        size: 20,
                                        color: Colors.white30,
                                      ),
                                    ),
                              )
                            : Container(
                                width: 38,
                                height: 52,
                                color: Colors.white10,
                                child: const Icon(
                                  Icons.movie,
                                  size: 20,
                                  color: Colors.white30,
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),

                      // Movie Title & Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.movie!.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${post.movie!.type} • ${post.movie!.releaseYear ?? "Featured"}',
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Play / View action tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFF59E0B,
                          ).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(
                              0xFFF59E0B,
                            ).withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.play_arrow_rounded,
                              color: Color(0xFFF59E0B),
                              size: 16,
                            ),
                            SizedBox(width: 2),
                            Text(
                              'Watch',
                              style: TextStyle(
                                color: Color(0xFFF59E0B),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 10),

          // Action Toolbar (Like, Comment, Share)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                // Like Button
                InkWell(
                  onTap: _handleToggleLike,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          post.isLikedByMe
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: post.isLikedByMe
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF94A3B8),
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${post.likesCount}',
                          style: TextStyle(
                            color: post.isLikedByMe
                                ? const Color(0xFFEF4444)
                                : const Color(0xFFCBD5E1),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 4),

                // Comment Button
                InkWell(
                  onTap: _openComments,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline_rounded,
                          color: Color(0xFF94A3B8),
                          size: 19,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${post.commentsCount}',
                          style: const TextStyle(
                            color: Color(0xFFCBD5E1),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Share Button
                IconButton(
                  onPressed: _sharePost,
                  icon: const Icon(
                    Icons.share_outlined,
                    color: Color(0xFF94A3B8),
                    size: 19,
                  ),
                  splashRadius: 20,
                  tooltip: 'Share post',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Image Gallery Builder with Smooth Rounded Clipping & URL Resolution
  Widget _buildImageGallery(BuildContext context, List<String> images) {
    final resolvedImages = images
        .map((img) => ApiConstants.resolveImageUrl(img))
        .where((img) => img.trim().isNotEmpty)
        .toList();

    if (resolvedImages.isEmpty) return const SizedBox.shrink();

    // 1 Image
    if (resolvedImages.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: GestureDetector(
          onTap: () {
            Get.to(() => FullScreenImageViewer(images: resolvedImages, initialIndex: 0));
          },
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              resolvedImages[0],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFF1F2436),
                child: const Icon(Icons.broken_image_rounded, color: Colors.white30, size: 28),
              ),
            ),
          ),
        ),
      );
    }

    // 2 Images
    if (resolvedImages.length == 2) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 180,
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Get.to(
                      () => FullScreenImageViewer(images: resolvedImages, initialIndex: 0),
                    );
                  },
                  child: Image.network(
                    resolvedImages[0],
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFF1F2436),
                      child: const Icon(Icons.broken_image_rounded, color: Colors.white30, size: 24),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 3),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Get.to(
                      () => FullScreenImageViewer(images: resolvedImages, initialIndex: 1),
                    );
                  },
                  child: Image.network(
                    resolvedImages[1],
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFF1F2436),
                      child: const Icon(Icons.broken_image_rounded, color: Colors.white30, size: 24),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 4 Images: Clean 2x2 Grid
    if (resolvedImages.length == 4) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 220,
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Get.to(() => FullScreenImageViewer(images: resolvedImages, initialIndex: 0)),
                        child: Image.network(
                          resolvedImages[0],
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, st) => Container(color: const Color(0xFF1F2436)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Get.to(() => FullScreenImageViewer(images: resolvedImages, initialIndex: 1)),
                        child: Image.network(
                          resolvedImages[1],
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, st) => Container(color: const Color(0xFF1F2436)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 3),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Get.to(() => FullScreenImageViewer(images: resolvedImages, initialIndex: 2)),
                        child: Image.network(
                          resolvedImages[2],
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, st) => Container(color: const Color(0xFF1F2436)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Get.to(() => FullScreenImageViewer(images: resolvedImages, initialIndex: 3)),
                        child: Image.network(
                          resolvedImages[3],
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, st) => Container(color: const Color(0xFF1F2436)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 3 or 5+ images: 1 large on left, 2 stacked on right
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 200,
        child: Row(
          children: [
            Expanded(
              flex: 6,
              child: GestureDetector(
                onTap: () {
                  Get.to(
                    () => FullScreenImageViewer(images: resolvedImages, initialIndex: 0),
                  );
                },
                child: Image.network(
                  resolvedImages[0],
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFF1F2436),
                    child: const Icon(Icons.broken_image_rounded, color: Colors.white30, size: 28),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 3),
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Get.to(
                          () => FullScreenImageViewer(
                            images: resolvedImages,
                            initialIndex: 1,
                          ),
                        );
                      },
                      child: Image.network(
                        resolvedImages[1],
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF1F2436),
                          child: const Icon(Icons.broken_image_rounded, color: Colors.white30, size: 20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Get.to(
                          () => FullScreenImageViewer(
                            images: resolvedImages,
                            initialIndex: 2,
                          ),
                        );
                      },
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            resolvedImages[2],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: const Color(0xFF1F2436),
                              child: const Icon(Icons.broken_image_rounded, color: Colors.white30, size: 20),
                            ),
                          ),
                          if (resolvedImages.length > 3)
                            Container(
                              color: Colors.black.withValues(alpha: 0.65),
                              alignment: Alignment.center,
                              child: Text(
                                '+${resolvedImages.length - 3}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
