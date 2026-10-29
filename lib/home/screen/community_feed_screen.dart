import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/community_controller.dart';
import '../widget/community/post_card_widget.dart';
import '../widget/community/create_post_sheet.dart';
import 'my_reports_screen.dart';

class CommunityFeedScreen extends StatefulWidget {
  final bool showBackButton;

  const CommunityFeedScreen({
    super.key,
    this.showBackButton = false,
  });

  @override
  State<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends State<CommunityFeedScreen> {
  final CommunityController _controller = Get.put(CommunityController());
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      if (!_controller.isLoadingMore.value && _controller.hasMore.value) {
        _controller.loadFeed();
      }
    }
  }

  void _openCreatePost() {
    Get.bottomSheet(
      const CreatePostSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090A0E),
      body: Stack(
        children: [
          // Ambient Spotlight Radial Glow
          Positioned(
            top: -50,
            left: 0,
            right: 0,
            height: 220,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.6),
                    radius: 1.2,
                    colors: [
                      const Color(0xFFF59E0B).withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Main Screen Content
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top Custom Header Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                  child: Row(
                    children: [
                      if (widget.showBackButton) ...[
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                          splashRadius: 20,
                        ),
                        const SizedBox(width: 4),
                      ],

                      // Brand Icon
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.hub_rounded, color: Colors.black, size: 20),
                      ),
                      const SizedBox(width: 12),

                      // Title
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'CineCore Community',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          Text(
                            'Movie & Series Discussions',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // "My Reports" Action Button
                      IconButton(
                        onPressed: () => Get.to(() => const MyReportsScreen()),
                        tooltip: 'My Reports',
                        icon: const Icon(Icons.shield_outlined, color: Colors.white70, size: 21),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF1E2235),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // "+ Post" Header Action Button
                      InkWell(
                        onTap: _openCreatePost,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.edit_note_rounded, color: Colors.black, size: 18),
                              SizedBox(width: 4),
                              Text(
                                'Post',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(color: Color(0xFF1B1E2C), height: 1),

                // Feed Body
                Expanded(
                  child: Obx(() {
                    // Loading State
                    if (_controller.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFF59E0B),
                        ),
                      );
                    }

                    // Error State
                    if (_controller.errorMessage.value.isNotEmpty && _controller.posts.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.wifi_off_rounded, color: Colors.white38, size: 52),
                              const SizedBox(height: 14),
                              Text(
                                _controller.errorMessage.value,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                              const SizedBox(height: 18),
                              ElevatedButton.icon(
                                onPressed: () => _controller.loadFeed(refresh: true),
                                icon: const Icon(Icons.refresh_rounded, size: 18),
                                label: const Text('Retry'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF59E0B),
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Empty State
                    if (_controller.posts.isEmpty) {
                      return RefreshIndicator(
                        color: const Color(0xFFF59E0B),
                        backgroundColor: const Color(0xFF161822),
                        onRefresh: () => _controller.loadFeed(refresh: true),
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF181B26),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFF282C3D)),
                                    ),
                                    child: const Icon(Icons.forum_outlined, size: 38, color: Color(0xFFF59E0B)),
                                  ),
                                  const SizedBox(height: 18),
                                  const Text(
                                    'No Community Posts Yet',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 40),
                                    child: Text(
                                      'Be the first to share your thoughts, photos, and favorite movies with the community!',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.4),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton.icon(
                                    onPressed: _openCreatePost,
                                    icon: const Icon(Icons.add_rounded, size: 20),
                                    label: const Text('Create the First Post', style: TextStyle(fontWeight: FontWeight.bold)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFF59E0B),
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Active Posts List
                    return RefreshIndicator(
                      color: const Color(0xFFF59E0B),
                      backgroundColor: const Color(0xFF161822),
                      onRefresh: () => _controller.loadFeed(refresh: true),
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 8, bottom: 100),
                        itemCount: _controller.posts.length + (_controller.isLoadingMore.value ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _controller.posts.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Color(0xFFF59E0B),
                                  ),
                                ),
                              ),
                            );
                          }

                          final post = _controller.posts[index];
                          return PostCardWidget(post: post);
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

