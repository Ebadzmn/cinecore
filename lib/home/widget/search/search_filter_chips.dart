import 'package:flutter/material.dart';

class SearchFilterChips extends StatelessWidget {
  final List<String> genres;
  final int selectedGenreIndex;
  final ValueChanged<int> onGenreSelected;

  const SearchFilterChips({
    super.key,
    required this.genres,
    required this.selectedGenreIndex,
    required this.onGenreSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: genres.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = selectedGenreIndex == index;
          return GestureDetector(
            onTap: () => onGenreSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFF161822),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFF2A2D3A),
                ),
              ),
              child: Center(
                child: Text(
                  genres[index],
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white70,
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
