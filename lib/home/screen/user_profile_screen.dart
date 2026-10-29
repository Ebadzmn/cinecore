import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/community_controller.dart';
import '../../data/models/community_post_model.dart';
import '../widget/community/post_card_widget.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  final String? initialDisplayName;
  final String? initialAvatarUrl;

  const UserProfileScreen({
    super.key,
    required this.userId,
    this.initialDisplayName,
    this.initialAvatarUrl,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final CommunityController _controller = Get.find<CommunityController>();

  bool _isLoading = true;
  String? _errorMessage;

  String _displayName = 'User';
  String _avatarUrl = '';
  bool _isGuest = false;
  String _status = 'ACTIVE';
  DateTime? _createdAt;
  int _totalPosts = 0;
  List<CommunityPostModel> _userPosts = [];

  @override
  void initState() {
    super.initState();
    _displayName = widget.initialDisplayName ?? 'User';
    _avatarUrl = widget.initialAvatarUrl ?? '';
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _controller.getUserProfile(widget.userId);
      final userMap = data['user'] as Map<String, dynamic>? ?? {};
      final postsRaw = data['posts'] as List<dynamic>? ?? [];

      final postsList = postsRaw
          .map((p) => CommunityPostModel.fromJson(p as Map<String, dynamic>))
          .toList();

      DateTime? parseDate(dynamic d) {
        if (d == null) return null;
        try {
          return DateTime.parse(d.toString()).toLocal();
        } catch (_) {
          return null;
        }
      }

      if (mounted) {
        setState(() {
          _displayName = userMap['displayName']?.toString() ?? _displayName;
          _avatarUrl = userMap['avatarUrl']?.toString() ?? _avatarUrl;
          _isGuest = userMap['isGuest'] == true;
          _status = userMap['status']?.toString() ?? 'ACTIVE';
          _createdAt = parseDate(userMap['createdAt']);
          _totalPosts = (data['totalPosts'] as num?)?.toInt() ?? postsList.length;
          _userPosts = postsList;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not load user profile. Tap to retry.';
          _isLoading = false;
        });
      }
    }
  }

  String _formatJoinDate(DateTime? date) {
    if (date == null) return 'Member';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return 'Joined ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090A0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141622),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          _displayName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchProfile,
        color: const Color(0xFFF59E0B),
        backgroundColor: const Color(0xFF161822),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // User Header Profile Card
            SliverToBoxAdapter(
              child: _buildHeaderCard(),
            ),

            // Section Header: "Posts"
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Posts',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2235),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$_totalPosts',
                        style: const TextStyle(
                          color: Color(0xFFF59E0B),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Loading / Error / Empty / Posts content
            if (_isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFFF59E0B)),
                ),
              )
            else if (_errorMessage != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 48),
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _fetchProfile,
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
              )
            else if (_userPosts.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF141622),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF222638)),
                        ),
                        child: const Icon(
                          Icons.feed_outlined,
                          size: 48,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No Posts Yet',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$_displayName hasn\'t shared any posts yet.',
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final post = _userPosts[index];
                    return PostCardWidget(post: post);
                  },
                  childCount: _userPosts.length,
                ),
              ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 40),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141622),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF222638)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Large Avatar with Glow
          Center(
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 42,
                backgroundColor: const Color(0xFF1F2333),
                backgroundImage:
                    _avatarUrl.isNotEmpty ? NetworkImage(_avatarUrl) : null,
                onBackgroundImageError: _avatarUrl.isNotEmpty
                    ? (exception, stackTrace) {}
                    : null,
                child: _avatarUrl.isEmpty
                    ? const Icon(Icons.person_rounded, size: 44, color: Colors.white70)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Display Name
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  _displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_isGuest) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2D3D),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Guest',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),

          // Metadata row (Join Date + Status)
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 6,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 13, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 5),
                  Text(
                    _formatJoinDate(_createdAt),
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _status == 'ACTIVE'
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _status == 'ACTIVE' ? 'Community Member' : 'Suspended',
                    style: TextStyle(
                      color: _status == 'ACTIVE'
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Stats Bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF181B26),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF222638)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Posts', '$_totalPosts'),
                Container(width: 1, height: 26, color: const Color(0xFF282C3D)),
                _buildStatItem(
                  'Likes',
                  '${_userPosts.fold<int>(0, (sum, p) => sum + p.likesCount)}',
                ),
                Container(width: 1, height: 26, color: const Color(0xFF282C3D)),
                _buildStatItem(
                  'Comments',
                  '${_userPosts.fold<int>(0, (sum, p) => sum + p.commentsCount)}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

