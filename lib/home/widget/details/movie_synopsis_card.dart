import 'package:flutter/material.dart';

class MovieSynopsisCard extends StatelessWidget {
  final String? synopsis;
  final String? subtitle;
  final String? tagline;
  final String? director;
  final String? studio;
  final String? audioCodec;
  final String? videoCodec;
  final String? releaseYear;
  final String? category;
  final bool isExpanded;
  final VoidCallback onToggleExpand;

  const MovieSynopsisCard({
    super.key,
    required this.synopsis,
    this.subtitle,
    this.tagline,
    this.director,
    this.studio,
    this.audioCodec,
    this.videoCodec,
    this.releaseYear,
    this.category,
    required this.isExpanded,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    final cleanSynopsis = (synopsis != null && synopsis!.trim().isNotEmpty)
        ? synopsis!.trim()
        : ((subtitle != null && subtitle!.trim().isNotEmpty)
            ? subtitle!.trim()
            : 'No storyline overview is currently available for this title.');

    // Choose tagline: priority to tagline, fallback to subtitle if different from cleanSynopsis
    String? displayTagline;
    if (tagline != null && tagline!.trim().isNotEmpty) {
      displayTagline = tagline!.trim();
    } else if (subtitle != null &&
        subtitle!.trim().isNotEmpty &&
        subtitle!.trim().toLowerCase() != cleanSynopsis.toLowerCase() &&
        subtitle!.trim().length < 90) {
      displayTagline = subtitle!.trim();
    }

    // Estimate reading time in minutes (avg 180 wpm)
    final wordCount = cleanSynopsis.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    final readingTime = (wordCount / 160).ceil().clamp(1, 10);

    final isLongText = cleanSynopsis.length > 130;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF161926),
            Color(0xFF11131E),
            Color(0xFF0E1018),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF262A3B),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Bar: Icon Pill + STORYLINE Label + Reading Time Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  color: Color(0xFFFBBF24),
                  size: 15,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'STORYLINE & OVERVIEW',
                style: TextStyle(
                  color: Color(0xFFFBBF24),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.9,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1E2D),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2C3145)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.schedule_rounded, color: Colors.white54, size: 11),
                    const SizedBox(width: 4),
                    Text(
                      '$readingTime min read',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 2. Cinematic Tagline Quote Banner (if available)
          if (displayTagline != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFF59E0B).withValues(alpha: 0.10),
                    const Color(0xFF1A1D2B).withValues(alpha: 0.4),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border(
                  left: const BorderSide(color: Color(0xFFF59E0B), width: 3.5),
                  top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                  right: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                  bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.format_quote_rounded,
                    color: Color(0xFFFBBF24),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '“$displayTagline”',
                      style: const TextStyle(
                        color: Color(0xFFFEF3C7),
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          // 3. Animated Storyline Body Text
          GestureDetector(
            onTap: isLongText ? onToggleExpand : null,
            behavior: HitTestBehavior.opaque,
            child: AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOutCubic,
              alignment: Alignment.topCenter,
              child: isLongText && !isExpanded
                  ? ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white,
                            Colors.white,
                            Colors.white.withValues(alpha: 0.2),
                          ],
                          stops: const [0.0, 0.65, 1.0],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.dstIn,
                      child: Text(
                        cleanSynopsis,
                        style: const TextStyle(
                          color: Color(0xFFD1D5DB),
                          fontSize: 13.5,
                          height: 1.62,
                          letterSpacing: 0.2,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  : Text(
                      cleanSynopsis,
                      style: const TextStyle(
                        color: Color(0xFFD1D5DB),
                        fontSize: 13.5,
                        height: 1.62,
                        letterSpacing: 0.2,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
            ),
          ),

          // 4. "Read Full Story" / "Show Less" Interactive Button
          if (isLongText) ...[
            const SizedBox(height: 12),
            Center(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onToggleExpand,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B1E2D),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isExpanded ? 'Show Less' : 'Read Full Story',
                          style: const TextStyle(
                            color: Color(0xFFFBBF24),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(width: 6),
                        AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0.0,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          child: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Color(0xFFFBBF24),
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],

          // 5. Quick Key Production Highlights Strip (if available)
          if (_hasAnyHighlights) ...[
            const SizedBox(height: 14),
            Divider(
              color: const Color(0xFF262A3B).withValues(alpha: 0.8),
              height: 1,
              thickness: 1,
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (director != null && director!.trim().isNotEmpty)
                  _buildHighlightBadge(
                    icon: Icons.movie_filter_outlined,
                    label: 'Director',
                    value: director!.trim(),
                  ),
                if (studio != null && studio!.trim().isNotEmpty)
                  _buildHighlightBadge(
                    icon: Icons.business_outlined,
                    label: 'Studio',
                    value: studio!.trim(),
                  ),
                if (category != null && category!.trim().isNotEmpty)
                  _buildHighlightBadge(
                    icon: Icons.category_outlined,
                    label: 'Category',
                    value: category!.trim(),
                  ),
                if (audioCodec != null && audioCodec!.trim().isNotEmpty)
                  _buildHighlightBadge(
                    icon: Icons.surround_sound_rounded,
                    label: 'Audio',
                    value: audioCodec!.trim().toUpperCase(),
                    isAmber: true,
                  ),
                if (videoCodec != null && videoCodec!.trim().isNotEmpty)
                  _buildHighlightBadge(
                    icon: Icons.videocam_outlined,
                    label: 'Codec',
                    value: videoCodec!.trim().toUpperCase(),
                  ),
                if (releaseYear != null && releaseYear!.trim().isNotEmpty)
                  _buildHighlightBadge(
                    icon: Icons.calendar_today_outlined,
                    label: 'Year',
                    value: releaseYear!.trim(),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  bool get _hasAnyHighlights =>
      (director != null && director!.trim().isNotEmpty) ||
      (studio != null && studio!.trim().isNotEmpty) ||
      (category != null && category!.trim().isNotEmpty) ||
      (audioCodec != null && audioCodec!.trim().isNotEmpty) ||
      (videoCodec != null && videoCodec!.trim().isNotEmpty) ||
      (releaseYear != null && releaseYear!.trim().isNotEmpty);

  Widget _buildHighlightBadge({
    required IconData icon,
    required String label,
    required String value,
    bool isAmber = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isAmber
            ? const Color(0xFFF59E0B).withValues(alpha: 0.12)
            : const Color(0xFF171A27),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isAmber
              ? const Color(0xFFF59E0B).withValues(alpha: 0.35)
              : const Color(0xFF282D40),
          width: 0.9,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isAmber ? const Color(0xFFFBBF24) : Colors.white60,
            size: 13,
          ),
          const SizedBox(width: 5),
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: Text(
              value,
              style: TextStyle(
                color: isAmber ? const Color(0xFFFBBF24) : Colors.white,
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
