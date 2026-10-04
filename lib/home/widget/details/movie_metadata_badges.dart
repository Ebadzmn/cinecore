import 'package:flutter/material.dart';

class MovieMetadataBadges extends StatelessWidget {
  final double rating;
  final String? releaseYear;
  final String? duration;
  final String? resolution;
  final String? ageRating;

  const MovieMetadataBadges({
    super.key,
    required this.rating,
    this.releaseYear = '2025',
    this.duration = '2h 14m',
    this.resolution = '4K Ultra HD',
    this.ageRating = 'R',
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Star Rating Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 14),
              const SizedBox(width: 4),
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  color: Color(0xFFFBBF24),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),

        // Year Badge
        if (releaseYear != null) _buildBadge(releaseYear!),

        // Age Rating Badge
        if (ageRating != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF222530),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white24, width: 0.8),
            ),
            child: Text(
              ageRating!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

        // Duration Badge
        if (duration != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.access_time_rounded, color: Colors.white60, size: 13),
              const SizedBox(width: 4),
              Text(
                duration!,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),

        // Resolution Tag
        if (resolution != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD97706), Color(0xFFB45309)],
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              resolution!,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.4,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: const Color(0xFF161822),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF2A2D3A)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
