import 'package:flutter/material.dart';

class TopBlockbusterMovie {
  final String id;
  final String title;
  final String? topSmallTag;
  final String? topMainTag;
  final String? subDescription;
  final String rankTag;
  final String imageUrl;
  final double rating;
  final String duration;
  final String genres;

  const TopBlockbusterMovie({
    required this.id,
    required this.title,
    this.topSmallTag,
    this.topMainTag,
    this.subDescription,
    required this.rankTag,
    required this.imageUrl,
    required this.rating,
    required this.duration,
    required this.genres,
  });
}

class TopBlockbustersSection extends StatelessWidget {
  final ValueChanged<TopBlockbusterMovie>? onMovieTap;
  final VoidCallback? onSeeLeaderboard;
  final List<TopBlockbusterMovie>? movies;
  final String? title;
  final String? subtitle;

  const TopBlockbustersSection({
    super.key,
    this.onMovieTap,
    this.onSeeLeaderboard,
    this.movies,
    this.title,
    this.subtitle,
  });

  static const List<TopBlockbusterMovie> top10Movies = [
    TopBlockbusterMovie(
      id: 'top_1',
      title: 'OPPENHEIMER',
      topSmallTag: 'Cinematic Screening',
      topMainTag: 'THE DAY AFTER TOMORROW',
      subDescription: 'ATOMIC FEAR: SCIENTIFIC DISCOVERY THE ULTIMATE BURDEN',
      rankTag: '#1 IN ACTION 4K',
      imageUrl:
          'https://images.unsplash.com/photo-1534447677768-be436bb09401?q=80&w=600&auto=format&fit=crop',
      rating: 9.3,
      duration: '3h 00m',
      genres: 'Biography, Drama, History',
    ),
    TopBlockbusterMovie(
      id: 'top_2',
      title: 'DEAD RECKONING',
      topSmallTag: 'A THRILLER BY GARETH EDWARDS',
      topMainTag: 'NIGHTFALL RUN',
      subDescription: 'THE CLOCK IS TICKING. THE TRUTH IS BURIED.',
      rankTag: 'IMAX ULTIMATE',
      imageUrl:
          'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?q=80&w=600&auto=format&fit=crop',
      rating: 9.0,
      duration: '2h 43m',
      genres: 'Action, Adventure, Thriller',
    ),
    TopBlockbusterMovie(
      id: 'top_3',
      title: 'DUNE: PART TWO',
      topSmallTag: 'DENIS VILLENEUVE MASTERPIECE',
      topMainTag: 'ARRAKIS RISING',
      subDescription: 'DESTINY AWAITS IN THE DESERT OF DREAMS',
      rankTag: '#1 SCI-FI EPIC',
      imageUrl:
          'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?q=80&w=600&auto=format&fit=crop',
      rating: 9.4,
      duration: '2h 46m',
      genres: 'Sci-Fi, Adventure',
    ),
    TopBlockbusterMovie(
      id: 'top_4',
      title: 'GLADIATOR II',
      topSmallTag: 'RIDLEY SCOTT VISION',
      topMainTag: 'COLOSSEUM OF HONOR',
      subDescription: 'WHAT WE DO IN LIFE ECHOES IN ETERNITY',
      rankTag: 'DOLBY VISION 4K',
      imageUrl:
          'https://images.unsplash.com/photo-1579783902614-a3fb3927b675?q=80&w=600&auto=format&fit=crop',
      rating: 9.1,
      duration: '2h 28m',
      genres: 'Action, Drama',
    ),
    TopBlockbusterMovie(
      id: 'top_5',
      title: 'CYBERPUNK 2099',
      topSmallTag: 'WARNER BROS SPECIAL',
      topMainTag: 'NEON MATRIX CITY',
      subDescription: 'REBELLION IN THE SHADOWS OF DYSTOPIA',
      rankTag: 'EXCLUSIVE 4K UHD',
      imageUrl:
          'https://images.unsplash.com/photo-1514565131-fce0801e5785?q=80&w=600&auto=format&fit=crop',
      rating: 8.9,
      duration: '1h 58m',
      genres: 'Sci-Fi, Cyberpunk',
    ),
    TopBlockbusterMovie(
      id: 'top_6',
      title: 'INTERSTELLAR',
      topSmallTag: 'CHRISTOPHER NOLAN',
      topMainTag: 'BEYOND HORIZONS',
      subDescription: 'MANKIND WAS BORN ON EARTH NOT TO DIE HERE',
      rankTag: 'IMAX REMASTER',
      imageUrl:
          'https://images.unsplash.com/photo-1451187580459-43490279c0fa?q=80&w=600&auto=format&fit=crop',
      rating: 9.5,
      duration: '2h 49m',
      genres: 'Sci-Fi, Drama',
    ),
    TopBlockbusterMovie(
      id: 'top_7',
      title: 'THE BATMAN II',
      topSmallTag: 'MATT REEVES SAGA',
      topMainTag: 'GOTHAM SHADOWS',
      subDescription: 'UNMASK THE CITY OF CORRUPTION',
      rankTag: '#1 CRIME THRILLER',
      imageUrl:
          'https://images.unsplash.com/photo-1514306191717-452ec28c7814?q=80&w=600&auto=format&fit=crop',
      rating: 8.8,
      duration: '2h 35m',
      genres: 'Action, Crime, Mystery',
    ),
    TopBlockbusterMovie(
      id: 'top_8',
      title: 'AVATAR: FIRE & ASH',
      topSmallTag: 'JAMES CAMERON EPIC',
      topMainTag: 'PANDORA VOLCANO',
      subDescription: 'A NEW TRIBE RISES FROM THE ASHES',
      rankTag: '3D DOLBY ATMOS',
      imageUrl:
          'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?q=80&w=600&auto=format&fit=crop',
      rating: 9.2,
      duration: '3h 10m',
      genres: 'Sci-Fi, Fantasy, Action',
    ),
    TopBlockbusterMovie(
      id: 'top_9',
      title: 'BLADE RUNNER',
      topSmallTag: 'DENIS VILLENEUVE',
      topMainTag: 'MEMORY RUNNER',
      subDescription: 'MORE HUMAN THAN HUMAN ESSENCE',
      rankTag: 'DOLBY CINEMA',
      imageUrl:
          'https://images.unsplash.com/photo-1534447677768-be436bb09401?q=80&w=600&auto=format&fit=crop',
      rating: 9.0,
      duration: '2h 44m',
      genres: 'Sci-Fi, Mystery',
    ),
    TopBlockbusterMovie(
      id: 'top_10',
      title: 'KINGDOM OF APES',
      topSmallTag: '20TH CENTURY STUDIOS',
      topMainTag: 'PRIMAL REIGN',
      subDescription: 'THE DAWN OF A POWERFUL NEW ORDER',
      rankTag: '#1 GLOBAL HIT',
      imageUrl:
          'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?q=80&w=600&auto=format&fit=crop',
      rating: 8.7,
      duration: '2h 25m',
      genres: 'Action, Sci-Fi',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header: Top 10 Blockbusters Today + See Leaderboard
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left: Yellow vertical accent bar + Title
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 38,
                    margin: const EdgeInsets.only(right: 10, top: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.6),
                          blurRadius: 8,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (title ?? 'TOP 10 BLOCKBUSTERS').toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                          height: 1.15,
                        ),
                      ),
                      Text(
                        (subtitle ?? 'TODAY').toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Right: See Leaderboard >
              GestureDetector(
                onTap: onSeeLeaderboard,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        Text(
                          'SEE',
                          style: TextStyle(
                            color: Color(0xFFF59E0B),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            height: 1.1,
                          ),
                        ),
                        Text(
                          'LEADERBOARD',
                          style: TextStyle(
                            color: Color(0xFFF59E0B),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Color(0xFFF59E0B),
                      size: 11,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Horizontal Ranked Cards Scroll List
        Builder(
          builder: (context) {
            final displayList = (movies != null && movies!.isNotEmpty) ? movies! : top10Movies;
            return SizedBox(
              height: 255,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: displayList.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final item = displayList[index];
                  return _buildRankedCard(context, item, index);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRankedCard(
    BuildContext context,
    TopBlockbusterMovie item,
    int index,
  ) {
    return GestureDetector(
      onTap: () => onMovieTap?.call(item),
      child: SizedBox(
        width: 175,
        height: 250,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Main Poster Card with Amber Border
            Positioned(
              left: 14,
              right: 0,
              top: 0,
              bottom: 4,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFD97706).withValues(alpha: 0.75),
                    width: 1.6,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.55),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 1. Poster Image
                    Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: const Color(0xFF161822),
                      ),
                    ),

                    // 2. Cinematic Gradient Overlay (Top vignette + bottom dark fade)
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.55),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.4),
                            const Color(0xFF090A0E).withValues(alpha: 0.96),
                          ],
                          stops: const [0.0, 0.3, 0.6, 1.0],
                        ),
                      ),
                    ),

                    // 3. Top Header Branding inside Poster
                    Positioned(
                      top: 8,
                      left: 8,
                      right: 8,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (item.topSmallTag != null)
                            Text(
                              item.topSmallTag!,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: 7.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                              ),
                            ),
                          const SizedBox(height: 2),
                          if (item.topMainTag != null)
                            Text(
                              item.topMainTag!,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                                height: 1.1,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // 4. Bottom Info: Title, Subtitle, Rank Highlight Tag
                    Positioned(
                      left: 36, // Offset to not collide with overlapping rank number
                      right: 8,
                      bottom: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.4,
                            ),
                          ),
                          if (item.subDescription != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              item.subDescription!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.55),
                                fontSize: 7,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                          const SizedBox(height: 3),
                          Text(
                            item.rankTag,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFFBBF24),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Giant Glowing Amber Outline Rank Number (1, 2, 3...)
            Positioned(
              left: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Stack(
                  children: [
                    // Outer Amber Glow & Stroke
                    Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 82,
                        fontWeight: FontWeight.w900,
                        height: 0.95,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 4.2
                          ..color = const Color(0xFFF59E0B),
                        shadows: [
                          Shadow(
                            color:
                                const Color(0xFFF59E0B).withValues(alpha: 0.75),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                    ),
                    // Inner Fill
                    Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 82,
                        fontWeight: FontWeight.w900,
                        height: 0.95,
                        color: const Color(0xFF090A0E).withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
