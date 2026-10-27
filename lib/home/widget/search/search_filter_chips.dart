import 'package:flutter/material.dart';

class SearchFilterChips extends StatelessWidget {
  final List<String> typeFilters;
  final int selectedTypeIndex;
  final ValueChanged<int> onTypeSelected;

  final List<String> genres;
  final int selectedGenreIndex;
  final ValueChanged<int> onGenreSelected;

  final String selectedSortBy;
  final List<String> sortOptions;
  final ValueChanged<String> onSortChanged;

  final bool isGridView;
  final VoidCallback onToggleView;

  const SearchFilterChips({
    super.key,
    required this.typeFilters,
    required this.selectedTypeIndex,
    required this.onTypeSelected,
    required this.genres,
    required this.selectedGenreIndex,
    required this.onGenreSelected,
    required this.selectedSortBy,
    required this.sortOptions,
    required this.onSortChanged,
    required this.isGridView,
    required this.onToggleView,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Top Row: Media Type Filter Tabs (All / Movies / Series) + Grid/List View Toggle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Media Type Capsule Bar
              Container(
                height: 36,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFF13151F),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF232738)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(typeFilters.length, (index) {
                    final isSelected = selectedTypeIndex == index;
                    String label = typeFilters[index];
                    IconData? icon;
                    if (label.toLowerCase() == 'movies') {
                      icon = Icons.movie_outlined;
                    } else if (label.toLowerCase() == 'series') {
                      icon = Icons.tv_rounded;
                    }

                    return GestureDetector(
                      onTap: () => onTypeSelected(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? const LinearGradient(
                                  colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                                )
                              : null,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (icon != null) ...[
                              Icon(
                                icon,
                                size: 13,
                                color: isSelected ? Colors.black : Colors.white60,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              label,
                              style: TextStyle(
                                color: isSelected ? Colors.black : Colors.white70,
                                fontSize: 11.5,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // Right side: Sort Menu & View Mode Toggle
              Row(
                children: [
                  // Sort Popup Menu
                  PopupMenuButton<String>(
                    onSelected: onSortChanged,
                    color: const Color(0xFF161822),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFF2A2D3A)),
                    ),
                    itemBuilder: (context) {
                      return sortOptions.map((opt) {
                        final isSelected = opt.toLowerCase() == selectedSortBy.toLowerCase();
                        return PopupMenuItem<String>(
                          value: opt,
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                                color: isSelected ? const Color(0xFFF59E0B) : Colors.white30,
                                size: 14,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                opt,
                                style: TextStyle(
                                  color: isSelected ? const Color(0xFFF59E0B) : Colors.white,
                                  fontSize: 12.5,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList();
                    },
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF13151F),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF232738)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.sort_rounded, color: Color(0xFFF59E0B), size: 14),
                          const SizedBox(width: 5),
                          Text(
                            selectedSortBy,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(Icons.arrow_drop_down_rounded, color: Colors.white54, size: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // View Mode Toggle (Grid vs List)
                  GestureDetector(
                    onTap: onToggleView,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF13151F),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF232738)),
                      ),
                      child: Icon(
                        isGridView ? Icons.view_agenda_outlined : Icons.grid_view_rounded,
                        color: const Color(0xFFF59E0B),
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 2. Horizontal Genre Scroll Chips
        SizedBox(
          height: 32,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: genres.length,
            separatorBuilder: (_, _) => const SizedBox(width: 7),
            itemBuilder: (context, index) {
              final isSelected = selectedGenreIndex == index;
              return GestureDetector(
                onTap: () => onGenreSelected(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF13151F),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFF232738),
                      width: 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      genres[index],
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white70,
                        fontSize: 11.5,
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
