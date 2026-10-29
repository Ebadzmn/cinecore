import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/community_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../screen/user_profile_screen.dart';
import 'report_dialog.dart';

class CommentsBottomSheet extends StatefulWidget {
  final String postId;

  const CommentsBottomSheet({super.key, required this.postId});

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final CommunityController _controller = Get.find<CommunityController>();
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController _commentTextController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _controller.loadComments(widget.postId);
  }

  @override
  void dispose() {
    _commentTextController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSendComment() async {
    final text = _commentTextController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    final success = await _controller.addComment(widget.postId, text);
    setState(() => _isSending = false);

    if (success) {
      _commentTextController.clear();
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final myUserId = _authController.userProfile.value.id;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Color(0xFF12141D),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(
                  () => Text(
                    'Comments (${_controller.comments.length})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white70,
                    size: 20,
                  ),
                  splashRadius: 20,
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF232734), height: 1),

          // Comments List
          Expanded(
            child: Obx(() {
              if (_controller.isLoadingComments.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFF59E0B)),
                );
              }

              if (_controller.comments.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: Colors.white30,
                        size: 48,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No comments yet',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Be the first to share your thoughts!',
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: _controller.comments.length,
                separatorBuilder: (_, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final comment = _controller.comments[index];
                  final isMyComment =
                      comment.author.id.isNotEmpty &&
                      comment.author.id == myUserId;

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF181B26),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF232734)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Clickable Avatar
                        GestureDetector(
                          onTap: () {
                            if (comment.author.id.isNotEmpty) {
                              Get.to(
                                () => UserProfileScreen(
                                  userId: comment.author.id,
                                  initialDisplayName: comment.author.displayName,
                                  initialAvatarUrl: comment.author.avatarUrl,
                                ),
                              );
                            }
                          },
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: const Color(0xFF2A2D3D),
                            backgroundImage: comment.author.avatarUrl.isNotEmpty
                                ? NetworkImage(comment.author.avatarUrl)
                                : null,
                            onBackgroundImageError: comment.author.avatarUrl.isNotEmpty
                                ? (exception, stackTrace) {}
                                : null,
                            child: comment.author.avatarUrl.isEmpty
                                ? const Icon(
                                    Icons.person_rounded,
                                    size: 18,
                                    color: Colors.white54,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Comment Body
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (comment.author.id.isNotEmpty) {
                                        Get.to(
                                          () => UserProfileScreen(
                                            userId: comment.author.id,
                                            initialDisplayName: comment.author.displayName,
                                            initialAvatarUrl: comment.author.avatarUrl,
                                          ),
                                        );
                                      }
                                    },
                                    child: Text(
                                      comment.author.displayName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (comment.author.isGuest) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2A2D3D),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'Guest',
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(width: 8),
                                  Text(
                                    comment.timeAgo,
                                    style: const TextStyle(
                                      color: Colors.white38,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                comment.content,
                                style: const TextStyle(
                                  color: Color(0xFFE2E8F0),
                                  fontSize: 13,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Options Menu (Delete for author, Report for others)
                        PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert_rounded,
                            size: 16,
                            color: Colors.white38,
                          ),
                          color: const Color(0xFF1E2230),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onSelected: (val) {
                            if (val == 'delete') {
                              _controller.deleteComment(
                                comment.id,
                                widget.postId,
                              );
                            } else if (val == 'report') {
                              Get.dialog(
                                ReportDialog(
                                  contentId: comment.id,
                                  contentType: 'COMMENT',
                                ),
                              );
                            }
                          },
                          itemBuilder: (ctx) => [
                            if (isMyComment)
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
                                      'Delete',
                                      style: TextStyle(
                                        color: Color(0xFFEF4444),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
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
                                      'Report',
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
                  );
                },
              );
            }),
          ),

          // Bottom Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF0D0F17),
              border: Border(top: BorderSide(color: Color(0xFF232734))),
            ),
            child: Row(
              children: [
                // Input TextField
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF181B26),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF2A2D3D)),
                    ),
                    child: TextField(
                      controller: _commentTextController,
                      focusNode: _focusNode,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'Add a comment...',
                        hintStyle: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Send Button
                InkWell(
                  onTap: _isSending ? null : _handleSendComment,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: Colors.black,
                            size: 18,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
