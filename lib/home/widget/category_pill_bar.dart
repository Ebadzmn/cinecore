import 'package:flutter/material.dart';
import '../../data/models/category_model.dart';

class CategoryItem {
  final String title;
  final IconData icon;

  const CategoryItem({required this.title, required this.icon});
}

class CategoryPillBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onCategorySelected;
  final List<CategoryModel>? categories;

  const CategoryPillBar({
    super.key,
    required this.selectedIndex,
    required this.onCategorySelected,
    this.categories,
  });

  static const List<CategoryItem> defaultStaticCategories = [
    CategoryItem(title: 'Movies', icon: Icons.local_activity_rounded),
    CategoryItem(title: 'Sports', icon: Icons.sports_soccer_rounded),
    CategoryItem(title: 'TV Shows', icon: Icons.tv_rounded),
    CategoryItem(title: 'Series', icon: Icons.video_library_rounded),
    CategoryItem(title: 'Documentary', icon: Icons.movie_filter_rounded),
  ];

  @override
  State<CategoryPillBar> createState() => _CategoryPillBarState();
}

class _CategoryPillBarState extends State<CategoryPillBar> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _itemKeys = {};

  int get _itemCount {
    if (widget.categories != null && widget.categories!.isNotEmpty) {
      return widget.categories!.length;
    }
    return CategoryPillBar.defaultStaticCategories.length;
  }

  @override
  void initState() {
    super.initState();
    _rebuildKeys();
  }

  @override
  void didUpdateWidget(covariant CategoryPillBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categories?.length != widget.categories?.length) {
      _rebuildKeys();
    }
  }

  void _rebuildKeys() {
    _itemKeys.clear();
    for (int i = 0; i < _itemCount; i++) {
      _itemKeys[i] = GlobalKey();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelected(int index) {
    final key = _itemKeys[index];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
        alignment: 0.35,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasDynamic = widget.categories != null && widget.categories!.isNotEmpty;
    final count = _itemCount;

    return SizedBox(
      height: 44,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: count,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final String title;
          final IconData icon;

          if (hasDynamic && index < widget.categories!.length) {
            final cat = widget.categories![index];
            title = cat.name;
            icon = cat.iconData;
          } else if (index < CategoryPillBar.defaultStaticCategories.length) {
            final item = CategoryPillBar.defaultStaticCategories[index];
            title = item.title;
            icon = item.icon;
          } else {
            title = 'Category';
            icon = Icons.category_rounded;
          }

          final isSelected = index == widget.selectedIndex;

          // Ensure key exists
          final key = _itemKeys.putIfAbsent(index, () => GlobalKey());

          return KeyedSubtree(
            key: key,
            child: GestureDetector(
              onTap: () {
                widget.onCategorySelected(index);
                _scrollToSelected(index);
              },
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 320),
                curve: Curves.fastOutSlowIn,
                padding: EdgeInsets.symmetric(
                  horizontal: isSelected ? 20 : 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: isSelected ? null : const Color(0xFF141620),
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [
                            Color(0xFFFBBF24),
                            Color(0xFFF97316),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFFBBF24).withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.08),
                    width: 1.2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFFF97316).withValues(alpha: 0.38),
                            blurRadius: 16,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated Icon scaling and fade
                    AnimatedScale(
                      scale: isSelected ? 1.12 : 1.0,
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutBack,
                      child: Icon(
                        icon,
                        size: 17,
                        color: isSelected
                            ? const Color(0xFF0C0D11)
                            : Colors.white.withValues(alpha: 0.55),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Animated Text
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeInOut,
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFF0C0D11)
                            : Colors.white.withValues(alpha: 0.65),
                        fontSize: 13.5,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w500,
                        letterSpacing: isSelected ? 0.2 : 0.0,
                      ),
                      child: Text(title),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
