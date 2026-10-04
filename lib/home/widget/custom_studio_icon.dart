import 'package:flutter/material.dart';

class CustomStudioIcon extends StatelessWidget {
  final String iconType;
  final double size;

  const CustomStudioIcon({
    super.key,
    required this.iconType,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    switch (iconType) {
      case 'max':
        return Icon(
          Icons.movie_filter_rounded,
          color: Colors.white,
          size: size,
        );
      case 'paramount':
        return Icon(
          Icons.hub_rounded,
          color: const Color(0xFFF59E0B),
          size: size,
        );
      case 'disney':
        return Icon(
          Icons.auto_awesome_rounded,
          color: const Color(0xFFFF80AB),
          size: size,
        );
      case 'netflix':
      default:
        return Icon(
          Icons.play_circle_fill_rounded,
          color: const Color(0xFFE50914),
          size: size,
        );
    }
  }
}
