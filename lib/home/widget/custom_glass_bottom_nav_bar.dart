import 'dart:ui';
import 'package:flutter/material.dart';

class NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class CustomGlassBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomGlassBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<NavItemData> items = [
    NavItemData(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    NavItemData(
      icon: Icons.search_rounded,
      activeIcon: Icons.saved_search_rounded,
      label: 'Search',
    ),
    NavItemData(
      icon: Icons.bookmark_border_rounded,
      activeIcon: Icons.bookmark_rounded,
      label: 'Watchlist',
    ),
    NavItemData(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        bottomPadding > 0 ? (bottomPadding * 0.5) : 0,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              color: const Color(0xFF141620).withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(36),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.14),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.05),
                  blurRadius: 18,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = constraints.maxWidth / items.length;
                const pillWidth = 52.0;
                const pillHeight = 32.0;

                return Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // 1. Sliding Elegant Frosted Pill Indicator (Clean & Minimal)
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeInOutCubic,
                      left: currentIndex * itemWidth + (itemWidth - pillWidth) / 2,
                      top: 9,
                      width: pillWidth,
                      height: pillHeight,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white.withValues(alpha: 0.12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 2. Interactive Navigation Items
                    Row(
                      children: List.generate(items.length, (index) {
                        final item = items[index];
                        final isSelected = index == currentIndex;

                        return Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => onTap(index),
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              borderRadius: BorderRadius.circular(36),
                              child: SizedBox(
                                height: double.infinity,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Icon area with fixed height aligned to the pill
                                    SizedBox(
                                      height: pillHeight,
                                      child: Center(
                                        child: AnimatedScale(
                                          scale: isSelected ? 1.06 : 1.0,
                                          duration: const Duration(milliseconds: 200),
                                          curve: Curves.easeOutBack,
                                          child: Icon(
                                            isSelected ? item.activeIcon : item.icon,
                                            color: isSelected
                                                ? const Color(0xFFFBBF24)
                                                : Colors.white.withValues(alpha: 0.45),
                                            size: 22,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 3),

                                    // Label aligned under the pill
                                    AnimatedDefaultTextStyle(
                                      duration: const Duration(milliseconds: 200),
                                      style: TextStyle(
                                        color: isSelected
                                            ? const Color(0xFFFBBF24)
                                            : Colors.white.withValues(alpha: 0.45),
                                        fontSize: 10.5,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        letterSpacing: 0.1,
                                      ),
                                      child: Text(item.label),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
