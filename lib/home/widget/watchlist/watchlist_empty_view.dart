import 'package:flutter/material.dart';

class WatchlistEmptyView extends StatelessWidget {
  final VoidCallback? onExploreMore;

  const WatchlistEmptyView({
    super.key,
    this.onExploreMore,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF161822),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.bookmark_border_rounded,
                color: Color(0xFFFBBF24),
                size: 38,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Your Watchlist is Empty',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Save movies and shows you want to watch later by tapping the bookmark button on any title.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            if (onExploreMore != null)
              ElevatedButton.icon(
                onPressed: onExploreMore,
                icon: const Icon(Icons.explore_rounded, color: Colors.black, size: 18),
                label: const Text(
                  'Explore Top Movies',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
