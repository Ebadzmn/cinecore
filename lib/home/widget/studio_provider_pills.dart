import 'package:flutter/material.dart';
import 'custom_studio_icon.dart';

class StudioProviderPills extends StatelessWidget {
  final ValueChanged<String>? onProviderSelected;

  const StudioProviderPills({
    super.key,
    this.onProviderSelected,
  });

  static const List<Map<String, String>> studios = [
    {'name': 'Max', 'icon': 'max'},
    {'name': 'Paramount', 'icon': 'paramount'},
    {'name': 'Disney+', 'icon': 'disney'},
    {'name': 'Netflix', 'icon': 'netflix'},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: studios.map((studio) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () => onProviderSelected?.call(studio['name']!),
                child: Container(
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFF161822),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomStudioIcon(
                        iconType: studio['icon']!,
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        studio['name']!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
