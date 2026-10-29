import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../controllers/community_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/home_controller.dart';
import '../../../data/models/movie_model.dart';

class CreatePostSheet extends StatefulWidget {
  const CreatePostSheet({super.key});

  @override
  State<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<CreatePostSheet> {
  final CommunityController _controller = Get.find<CommunityController>();
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController _captionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  final List<File> _selectedImages = [];
  MovieModel? _attachedMovie;
  bool _isPublishing = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  // Pick multiple images
  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1600,
        maxHeight: 1600,
      );

      if (images.isNotEmpty) {
        setState(() {
          for (final img in images) {
            _selectedImages.add(File(img.path));
          }
        });
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
    }
  }

  // Movie Selector Modal
  void _openMovieSelector() {
    final homeController = Get.find<HomeController>();
    final allMovies = <MovieModel>[
      ...homeController.topBlockbusters,
      ...homeController.latestMovies,
      ...homeController.peacockPicks,
    ];

    final seen = <String>{};
    final uniqueMovies = allMovies.where((m) => seen.add(m.id)).toList();

    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xFF141722),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Movie or Series',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                itemCount: uniqueMovies.length,
                separatorBuilder: (_, index) => const SizedBox(height: 8),
                itemBuilder: (ctx, idx) {
                  final movie = uniqueMovies[idx];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    tileColor: const Color(0xFF1B1E2C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        movie.imageUrl,
                        width: 40,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 40,
                          height: 56,
                          color: Colors.white12,
                          child: const Icon(Icons.movie, color: Colors.white30),
                        ),
                      ),
                    ),
                    title: Text(
                      movie.title,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${movie.releaseYear ?? "Popular"} • ${movie.genres}',
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                    ),
                    trailing: const Icon(Icons.add_circle_outline, color: Color(0xFFF59E0B)),
                    onTap: () {
                      setState(() => _attachedMovie = movie);
                      Get.back();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // Handle Publish with clear loading, disabling, error handling, and auto modal close
  Future<void> _handlePublish() async {
    if (_isPublishing) return; // Prevent duplicate clicks

    final caption = _captionController.text.trim();
    if (caption.isEmpty && _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.info_outline_rounded, color: Colors.black, size: 20),
              SizedBox(width: 8),
              Text(
                'Please enter a caption or attach photos.',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFF59E0B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isPublishing = true);

    try {
      final success = await _controller.createPost(
        caption: caption.isEmpty ? 'Shared photos' : caption,
        localImages: _selectedImages,
        movieId: _attachedMovie?.id,
      );

      if (success) {
        if (mounted) {
          Navigator.of(context).pop(); // Close modal immediately
        }
        Get.snackbar(
          'Post Published',
          'Your post has been published to the community feed!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Failed to publish post. Please check connection.',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
      // Keep modal open on failure so user does not lose their typed text!
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Failed to publish: ${e.toString().replaceAll("Exception:", "").trim()}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPublishing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authController.userProfile.value;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 20,
        right: 20,
        top: 16,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF10121A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _isPublishing ? null : () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, color: Colors.white70),
              ),
              const Text(
                'Create Community Post',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                onPressed: _isPublishing ? null : _handlePublish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                  disabledForegroundColor: Colors.black45,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: _isPublishing
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                          ),
                          SizedBox(width: 8),
                          Text('Posting...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      )
                    : const Text('Publish', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // User Info
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF2A2D3D),
                backgroundImage: user.avatarUrl.isNotEmpty ? NetworkImage(user.avatarUrl) : null,
                child: user.avatarUrl.isEmpty
                    ? const Icon(Icons.person, color: Colors.white70, size: 20)
                    : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Posting publicly to CineCore Feed',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Caption TextField
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _captionController,
                    enabled: !_isPublishing,
                    maxLines: null,
                    style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                    decoration: const InputDecoration(
                      hintText: 'Share your thoughts on movies, recommendations, or reviews...',
                      hintStyle: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                      border: InputBorder.none,
                    ),
                  ),

                  // Selected Images Previews
                  if (_selectedImages.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 110,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length,
                        separatorBuilder: (_, index) => const SizedBox(width: 10),
                        itemBuilder: (context, idx) {
                          final file = _selectedImages[idx];
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  file,
                                  width: 110,
                                  height: 110,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              if (!_isPublishing)
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() => _selectedImages.removeAt(idx));
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.black87,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],

                  // Attached Movie Chip
                  if (_attachedMovie != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF191C28),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              _attachedMovie!.imageUrl,
                              width: 36,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.movie_filter_rounded, size: 14, color: Color(0xFFF59E0B)),
                                    const SizedBox(width: 6),
                                    Text(
                                      _attachedMovie!.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${_attachedMovie!.releaseYear ?? "Featured"} • ${_attachedMovie!.genres}',
                                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          if (!_isPublishing)
                            IconButton(
                              onPressed: () => setState(() => _attachedMovie = null),
                              icon: const Icon(Icons.close_rounded, size: 18, color: Colors.white54),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Uploading Status indicator
          Obx(
            () => _controller.isUploadingImages.value
                ? Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFF59E0B)),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _controller.uploadProgressText.value.isNotEmpty
                              ? _controller.uploadProgressText.value
                              : 'Uploading and compressing media...',
                          style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 12),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // Bottom Toolbar (Add Photos, Attach Movie)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFF232734))),
            ),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: _isPublishing ? null : _pickImages,
                  icon: const Icon(Icons.photo_library_outlined, color: Color(0xFF10B981), size: 20),
                  label: const Text('Add Photos', style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 13)),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF181B26),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 10),
                TextButton.icon(
                  onPressed: _isPublishing ? null : _openMovieSelector,
                  icon: const Icon(Icons.local_movies_outlined, color: Color(0xFFF59E0B), size: 20),
                  label: const Text('Attach Movie', style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 13)),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF181B26),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
