import 'dart:async';
import 'package:flutter/material.dart';

class SpotlightMovieItem {
  final String id;
  final String titlePrefix;
  final String titleHighlight;
  final String subtitle;
  final String fullTitle;
  final String imageUrl;
  final double rating;
  final String badgeText;
  final Color badgeBgColor;
  final Color badgeBorderColor;
  final String resolution;
  final String duration;
  final String genres;
  final String ageRating;

  const SpotlightMovieItem({
    required this.id,
    required this.titlePrefix,
    required this.titleHighlight,
    required this.subtitle,
    required this.fullTitle,
    required this.imageUrl,
    required this.rating,
    required this.badgeText,
    required this.badgeBgColor,
    required this.badgeBorderColor,
    required this.resolution,
    required this.duration,
    required this.genres,
    required this.ageRating,
  });
}

class SpotlightHeroCard extends StatefulWidget {
  final void Function(SpotlightMovieItem item)? onMovieTap;
  final void Function(SpotlightMovieItem item)? onWatchNow;
  final void Function(SpotlightMovieItem item)? onAddToList;
  final List<SpotlightMovieItem>? items;

  const SpotlightHeroCard({
    super.key,
    this.onMovieTap,
    this.onWatchNow,
    this.onAddToList,
    this.items,
  });

  @override
  State<SpotlightHeroCard> createState() => _SpotlightHeroCardState();
}

class _SpotlightHeroCardState extends State<SpotlightHeroCard> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _autoPlayTimer;

  static const List<SpotlightMovieItem> defaultItems = [
    SpotlightMovieItem(
      id: 'spotlight_1',
      titlePrefix: 'SCREAM ',
      titleHighlight: 'VII',
      subtitle: 'The Bloodline Returns',
      fullTitle: 'SCREAM VII',
      imageUrl:
          'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?q=80&w=1200&auto=format&fit=crop',
      rating: 8.9,
      badgeText: 'SPOTLIGHT PREMIERE',
      badgeBgColor: Color(0xD97C2D37),
      badgeBorderColor: Color(0x59E11D48),
      resolution: '4K Ultra HD',
      duration: '2h 14m',
      genres: 'Horror, Thriller',
      ageRating: '18+',
    ),
    SpotlightMovieItem(
      id: 'spotlight_2',
      titlePrefix: 'DUNE ',
      titleHighlight: 'PART TWO',
      subtitle: 'Long Live the Fighters',
      fullTitle: 'Dune: Part Two',
      imageUrl:
          'https://images.unsplash.com/photo-1534447677768-be436bb09401?q=80&w=1200&auto=format&fit=crop',
      rating: 9.4,
      badgeText: 'IMAX EXCLUSIVE',
      badgeBgColor: Color(0xD9312E81),
      badgeBorderColor: Color(0x666366F1),
      resolution: '4K IMAX',
      duration: '2h 46m',
      genres: 'Sci-Fi, Adventure',
      ageRating: '13+',
    ),
    SpotlightMovieItem(
      id: 'spotlight_3',
      titlePrefix: 'GLADIATOR ',
      titleHighlight: 'II',
      subtitle: 'Enter the Colosseum',
      fullTitle: 'Gladiator II',
      imageUrl:
          'https://images.unsplash.com/photo-1579783902614-a3fb3927b675?q=80&w=1200&auto=format&fit=crop',
      rating: 9.1,
      badgeText: 'TOP TRENDING #1',
      badgeBgColor: Color(0xD978350F),
      badgeBorderColor: Color(0x66F59E0B),
      resolution: 'Dolby Atmos',
      duration: '2h 28m',
      genres: 'Action, Drama',
      ageRating: '16+',
    ),
    SpotlightMovieItem(
      id: 'spotlight_4',
      titlePrefix: 'CYBERPUNK ',
      titleHighlight: '2099',
      subtitle: 'Neon Nights & Rebel Souls',
      fullTitle: 'Cyberpunk 2099',
      imageUrl:
          'https://images.unsplash.com/photo-1514565131-fce0801e5785?q=80&w=1200&auto=format&fit=crop',
      rating: 9.0,
      badgeText: 'ORIGINAL SERIES',
      badgeBgColor: Color(0xD9064E3B),
      badgeBorderColor: Color(0x6610B981),
      resolution: '4K UHD',
      duration: '1h 58m',
      genres: 'Sci-Fi, Action',
      ageRating: '18+',
    ),
  ];

  List<SpotlightMovieItem> get _items => widget.items ?? defaultItems;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || _items.isEmpty || !_pageController.hasClients) return;
      final nextIndex = (_currentPage + 1) % _items.length;
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
  }

  @override
  void dispose() {
    _stopAutoPlay();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Carousel Viewport
        SizedBox(
          height: 380,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _items.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final item = _items[index];
              return _buildSpotlightCard(item);
            },
          ),
        ),
        const SizedBox(height: 12),

        // Carousel Dynamic Indicator Pills
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_items.length, (index) {
            final isActive = index == _currentPage;
            return GestureDetector(
              onTap: () {
                _stopAutoPlay();
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                );
                _startAutoPlay();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 3.5),
                width: isActive ? 22 : 6,
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: isActive
                      ? const Color(0xFFF97316)
                      : Colors.white.withValues(alpha: 0.22),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color:
                                const Color(0xFFF97316).withValues(alpha: 0.55),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSpotlightCard(SpotlightMovieItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => widget.onMovieTap?.call(item),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: const Color(0xFF161822),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 26,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Hero Poster Image
              Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: const Color(0xFF261014),
                ),
              ),

              // 2. Cinematic Gradient Overlay (Darkening top for tags, bottom for title & action button)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.5),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.65),
                      const Color(0xFF0A0C11).withValues(alpha: 0.96),
                    ],
                    stops: const [0.0, 0.35, 0.65, 1.0],
                  ),
                ),
              ),

              // 3. Top Badges: Rating and Spotlight Tag
              Positioned(
                top: 18,
                left: 18,
                right: 18,
                child: Row(
                  children: [
                    // Star Rating Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFFBBF24),
                            size: 15,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Spotlight Badge
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: item.badgeBgColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: item.badgeBorderColor,
                          ),
                        ),
                        child: Text(
                          item.badgeText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 4. Center-Bottom Content: Title, Metadata, Buttons
              Positioned(
                left: 18,
                right: 18,
                bottom: 20,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title with colored accent
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: item.titlePrefix,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                          TextSpan(
                            text: item.titleHighlight,
                            style: const TextStyle(
                              color: Color(0xFFF97316),
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Metadata: Resolution • Duration • Genres
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.resolution,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        _buildDot(),
                        Text(
                          item.duration,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        _buildDot(),
                        Flexible(
                          child: Text(
                            item.genres,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Age Rating Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Text(
                        item.ageRating,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Actions: Big "Watch Now" Button + "+" Add to list Button
                    Row(
                      children: [
                        // Watch Now (Amber-Orange Pill with Soft Glow)
                        Expanded(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFFBBF24),
                                  Color(0xFFF97316),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFF97316)
                                      .withValues(alpha: 0.45),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => widget.onWatchNow?.call(item),
                                borderRadius: BorderRadius.circular(25),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.play_arrow_rounded,
                                      color: Color(0xFF0C0D11),
                                      size: 24,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Watch Now',
                                      style: TextStyle(
                                        color: Color(0xFF0C0D11),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // "+" Button
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF222430),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => widget.onAddToList?.call(item),
                              borderRadius: BorderRadius.circular(25),
                              child: const Center(
                                child: Icon(
                                  Icons.add_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        '•',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 14,
        ),
      ),
    );
  }
}
