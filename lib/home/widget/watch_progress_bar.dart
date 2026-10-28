import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/playback_progress_controller.dart';

class WatchProgressBar extends StatelessWidget {
  final String? movieId;
  final double? explicitProgress;
  final double height;
  final BorderRadius? borderRadius;
  final Color backgroundColor;
  final List<Color> gradientColors;
  final bool showRemainingBadge;

  const WatchProgressBar({
    super.key,
    this.movieId,
    this.explicitProgress,
    this.height = 3.5,
    this.borderRadius,
    this.backgroundColor = const Color(0x33FFFFFF),
    this.gradientColors = const [
      Color(0xFFE50914),
      Color(0xFFFF3B30),
    ],
    this.showRemainingBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    // If PlaybackProgressController is not registered, register it lazily
    final controller = PlaybackProgressController.to;

    return Obx(() {
      final info = controller.getProgress(movieId);
      final double progress = (explicitProgress != null && explicitProgress! > 0)
          ? explicitProgress!
          : (info?.progressRatio ?? 0.0);

      // Do NOT show for content never played
      if (progress <= 0.0 && !(info?.isCompleted ?? false)) {
        return const SizedBox.shrink();
      }

      final effectiveProgress = (info?.isCompleted ?? false) ? 1.0 : progress.clamp(0.05, 1.0);
      final br = borderRadius ?? BorderRadius.circular(height / 2);

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress track & fill
          Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: br,
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: effectiveProgress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                  ),
                  borderRadius: br,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE50914).withValues(alpha: 0.85),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Optional remaining time / status badge below bar
          if (showRemainingBadge && info?.remainingTime != null) ...[
            const SizedBox(height: 3),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (info?.isCompleted ?? false)
                  const Padding(
                    padding: EdgeInsets.only(right: 3),
                    child: Icon(Icons.check_circle_rounded,
                        color: Color(0xFFFF5252), size: 10),
                  ),
                Text(
                  info!.remainingTime!,
                  style: TextStyle(
                    color: (info.isCompleted)
                        ? const Color(0xFFFF5252)
                        : const Color(0xFFFF7B7B),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ],
      );
    });
  }
}
