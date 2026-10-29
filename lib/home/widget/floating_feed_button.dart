import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FloatingFeedButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isSelected;

  const FloatingFeedButton({
    super.key,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  State<FloatingFeedButton> createState() => _FloatingFeedButtonState();
}

class _FloatingFeedButtonState extends State<FloatingFeedButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.93 : 1.0,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutBack,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onTap();
          },
          onHighlightChanged: (pressed) {
            setState(() => _isPressed = pressed);
          },
          borderRadius: BorderRadius.circular(26),
          splashColor: const Color(0xFFF59E0B).withValues(alpha: 0.15),
          highlightColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF141622).withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: widget.isSelected
                        ? const Color(0xFFF59E0B).withValues(alpha: 0.55)
                        : Colors.white.withValues(alpha: 0.15),
                    width: 1.1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(
                        alpha: widget.isSelected ? 0.25 : 0.1,
                      ),
                      blurRadius: 12,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Glowing Icon Pill
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFBBF24),
                            Color(0xFFF59E0B),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.dynamic_feed_rounded,
                          color: Color(0xFF090A0E),
                          size: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // "Feed" Label
                    const Text(
                      'Feed',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),

                    const SizedBox(width: 6),

                    // Small Glowing Live Pulse Indicator Dot
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFBBF24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFBBF24).withValues(alpha: 0.8),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
