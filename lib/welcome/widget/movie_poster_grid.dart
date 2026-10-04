import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class PosterItem {
  final String imageUrl;
  final List<Color> gradientColors;
  final String title;
  final IconData icon;

  const PosterItem({
    required this.imageUrl,
    required this.gradientColors,
    required this.title,
    required this.icon,
  });
}

class MoviePosterGrid extends StatefulWidget {
  const MoviePosterGrid({super.key});

  @override
  State<MoviePosterGrid> createState() => _MoviePosterGridState();
}

class _MoviePosterGridState extends State<MoviePosterGrid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _animation;

  static const List<PosterItem> col1Items = [
    PosterItem(
      imageUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?q=80&w=600&auto=format&fit=crop',
      gradientColors: [Color(0xFF6B21A8), Color(0xFF1E1035)],
      title: 'DARK REALM',
      icon: Icons.movie_outlined,
    ),
    PosterItem(
      imageUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?q=80&w=600&auto=format&fit=crop',
      gradientColors: [Color(0xFF991B1B), Color(0xFF2B0B0B)],
      title: 'BLOOD MOON',
      icon: Icons.local_fire_department_rounded,
    ),
    PosterItem(
      imageUrl: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?q=80&w=600&auto=format&fit=crop',
      gradientColors: [Color(0xFF1E3A8A), Color(0xFF0C142E)],
      title: 'ODYSSEY',
      icon: Icons.rocket_launch_rounded,
    ),
    PosterItem(
      imageUrl: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?q=80&w=600&auto=format&fit=crop',
      gradientColors: [Color(0xFFD97706), Color(0xFF381A04)],
      title: 'VALKYRIE',
      icon: Icons.shield_rounded,
    ),
  ];

  static const List<PosterItem> col2Items = [
    PosterItem(
      imageUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?q=80&w=600&auto=format&fit=crop',
      gradientColors: [Color(0xFF0284C7), Color(0xFF052238)],
      title: 'ATLANTIS',
      icon: Icons.water_rounded,
    ),
    PosterItem(
      imageUrl: 'https://images.unsplash.com/photo-1514565131-fce0801e5785?q=80&w=600&auto=format&fit=crop',
      gradientColors: [Color(0xFFC026D3), Color(0xFF3B0744)],
      title: 'CYBER 2099',
      icon: Icons.memory_rounded,
    ),
    PosterItem(
      imageUrl: 'https://images.unsplash.com/photo-1514306191717-452ec28c7814?q=80&w=600&auto=format&fit=crop',
      gradientColors: [Color(0xFFB91C1C), Color(0xFF380808)],
      title: 'OUTLAW',
      icon: Icons.sports_martial_arts_rounded,
    ),
    PosterItem(
      imageUrl: 'https://images.unsplash.com/photo-1536440136628-849c177e76a1?q=80&w=600&auto=format&fit=crop',
      gradientColors: [Color(0xFF4338CA), Color(0xFF131038)],
      title: 'DIRECTOR CUT',
      icon: Icons.videocam_rounded,
    ),
  ];

  static const List<PosterItem> col3Items = [
    PosterItem(
      imageUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?q=80&w=600&auto=format&fit=crop',
      gradientColors: [Color(0xFFEA580C), Color(0xFF3D1603)],
      title: 'INFERNO',
      icon: Icons.whatshot_rounded,
    ),
    PosterItem(
      imageUrl: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?q=80&w=600&auto=format&fit=crop',
      gradientColors: [Color(0xFF2563EB), Color(0xFF091C4A)],
      title: 'STARDUST',
      icon: Icons.auto_awesome_rounded,
    ),
    PosterItem(
      imageUrl: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?q=80&w=600&auto=format&fit=crop',
      gradientColors: [Color(0xFF7C3AED), Color(0xFF210847)],
      title: 'KINGDOM',
      icon: Icons.fort_rounded,
    ),
    PosterItem(
      imageUrl: 'https://images.unsplash.com/photo-1478760329108-5c3ed9d495a0?q=80&w=600&auto=format&fit=crop',
      gradientColors: [Color(0xFFDC2626), Color(0xFF3B0606)],
      title: 'GOTHAM',
      icon: Icons.location_city_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Smooth, noticeable 3.5s cycle where ALL images move up and down in unison
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOutSine,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const cardHeight = 210.0;
    const itemSpacing = 14.0;

    return Stack(
      children: [
        // Base dark cinema surface
        Container(
          color: AppColors.neutral,
        ),

        // Animated Poster Grid: All images move up and down together as a single unified layer
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              // Exact vertical shift (0px to -90px) moving ALL columns simultaneously
              final verticalShift = _animation.value * -90.0;

              return Transform.translate(
                offset: Offset(0, verticalShift),
                child: child,
              );
            },
            child: Transform.rotate(
              angle: -0.05,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Col 1
                    Expanded(
                      child: _buildColumn(col1Items, cardHeight, itemSpacing, -10),
                    ),
                    const SizedBox(width: itemSpacing),

                    // Col 2
                    Expanded(
                      child: _buildColumn(col2Items, cardHeight, itemSpacing, -60),
                    ),
                    const SizedBox(width: itemSpacing),

                    // Col 3
                    Expanded(
                      child: _buildColumn(col3Items, cardHeight, itemSpacing, -25),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Subtle gradient at the bottom so posters smoothly slide behind the glass card
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 280,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.neutral.withValues(alpha: 0.5),
                    AppColors.neutral.withValues(alpha: 0.85),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColumn(
    List<PosterItem> items,
    double cardHeight,
    double itemSpacing,
    double topOffset,
  ) {
    return Transform.translate(
      offset: Offset(0, topOffset),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: items
              .map((item) => _buildPosterCard(item, cardHeight, itemSpacing))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildPosterCard(
    PosterItem item,
    double cardHeight,
    double itemSpacing,
  ) {
    return Container(
      height: cardHeight,
      margin: EdgeInsets.only(bottom: itemSpacing),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: const Color(0xFF1E2028),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.65),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: item.gradientColors.first.withValues(alpha: 0.2),
            blurRadius: 14,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Instant vibrant poster gradient canvas
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: item.gradientColors,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    item.icon,
                    size: 42,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                Positioned(
                  left: 10,
                  bottom: 10,
                  right: 10,
                  child: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // High quality image
          Image.network(
            item.imageUrl,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),

          // Subtle poster sheen
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.08),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.35),
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),

          // Glass rim outline
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                    width: 0.8,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
