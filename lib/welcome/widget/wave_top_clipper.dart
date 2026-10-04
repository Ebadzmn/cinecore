import 'package:flutter/material.dart';

/// A custom clipper matching the exact asymmetric sweeping curve shown in the reference image:
/// Sits with a shallower, gentle slope (kom nico) so the left shoulder is closer to the right crest,
/// creating a balanced and elegant wave.
class WaveTopClipper extends CustomClipper<Path> {
  const WaveTopClipper();

  @override
  Path getClip(Size size) {
    final path = Path();

    // 1. Start from bottom-left corner
    path.moveTo(0, size.height);

    // 2. Go up the left edge to the start of the left corner curve (y = 52)
    path.lineTo(0, 52);

    // 3. Rounded left shoulder curve (starts curving gently into the slope)
    path.quadraticBezierTo(0, 28, 28, 26);

    // 4. Smooth sweeping upward curve from left to top-right with gentler slope
    path.cubicTo(
      size.width * 0.38,
      22,
      size.width * 0.72,
      12,
      size.width - 28,
      3,
    );

    // 5. Rounded top-right shoulder curve
    path.quadraticBezierTo(size.width, 0, size.width, 24);

    // 6. Right edge going down to the bottom-right corner
    path.lineTo(size.width, size.height);

    // 7. Bottom edge
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// Draws the subtle glowing frosted border stroke along the exact top curved boundary
class WaveBorderPainter extends CustomPainter {
  final Color borderColor;
  final double borderWidth;

  const WaveBorderPainter({
    required this.borderColor,
    this.borderWidth = 1.2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final borderPath = Path();

    // Trace from the left shoulder
    borderPath.moveTo(0, 52);
    borderPath.quadraticBezierTo(0, 28, 28, 26);
    borderPath.cubicTo(
      size.width * 0.38,
      22,
      size.width * 0.72,
      12,
      size.width - 28,
      3,
    );
    borderPath.quadraticBezierTo(size.width, 0, size.width, 24);

    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(borderPath, paint);
  }

  @override
  bool shouldRepaint(covariant WaveBorderPainter oldDelegate) {
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth;
  }
}
