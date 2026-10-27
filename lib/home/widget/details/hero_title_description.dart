import 'package:flutter/material.dart';

class HeroTitleDescription extends StatefulWidget {
  final String text;
  final int maxCollapsedLines;
  final bool? isExpanded;
  final VoidCallback? onToggleExpand;

  const HeroTitleDescription({
    super.key,
    required this.text,
    this.maxCollapsedLines = 3,
    this.isExpanded,
    this.onToggleExpand,
  });

  @override
  State<HeroTitleDescription> createState() => _HeroTitleDescriptionState();
}

class _HeroTitleDescriptionState extends State<HeroTitleDescription> {
  bool _internalExpanded = false;

  bool get _isExpanded => widget.isExpanded ?? _internalExpanded;

  void _handleToggle() {
    if (widget.onToggleExpand != null) {
      widget.onToggleExpand!();
    } else {
      setState(() {
        _internalExpanded = !_internalExpanded;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cleanText = widget.text.trim();
    if (cleanText.isEmpty) return const SizedBox.shrink();

    // If it's a short tagline (<= 65 characters and not multiple sentences)
    final isShortTagline = cleanText.length <= 65 && !cleanText.contains('\n');

    if (isShortTagline) {
      return Container(
        margin: const EdgeInsets.only(top: 8, bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFF59E0B).withValues(alpha: 0.12),
              const Color(0xFF161928).withValues(alpha: 0.4),
            ],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border(
            left: const BorderSide(color: Color(0xFFF59E0B), width: 3),
            top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
            right: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
            bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.format_quote_rounded,
              color: Color(0xFFFBBF24),
              size: 15,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                '“$cleanText”',
                style: const TextStyle(
                  color: Color(0xFFFEF3C7),
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.25,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Full Storyline / Description Paragraph Mode (e.g. Breaking Bad)
    final isLongText = cleanText.length > 120;

    return GestureDetector(
      onTap: isLongText ? _handleToggle : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(top: 10, bottom: 14),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF161928),
              Color(0xFF111422),
              Color(0xFF0D0F18),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF282D42),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar: Icon capsule + STORY OVERVIEW label + MORE/LESS toggle badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                      width: 0.9,
                    ),
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    color: Color(0xFFFBBF24),
                    size: 13,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'STORY OVERVIEW',
                  style: TextStyle(
                    color: Color(0xFFFBBF24),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                if (isLongText)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C2030),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isExpanded ? 'Less' : 'More',
                          style: const TextStyle(
                            color: Color(0xFFFBBF24),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: const Color(0xFFFBBF24),
                          size: 13,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 9),

            // Description text with smooth animation and high-legibility slate typography
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOutCubic,
              alignment: Alignment.topCenter,
              child: isLongText && !_isExpanded
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
                        cleanText,
                        style: const TextStyle(
                          color: Color(0xFFCBD5E1),
                          fontSize: 13,
                          height: 1.55,
                          letterSpacing: 0.15,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: widget.maxCollapsedLines,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  : Text(
                      cleanText,
                      style: const TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontSize: 13,
                        height: 1.55,
                        letterSpacing: 0.15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
