import 'package:flutter/material.dart';
import '../utils/constants.dart';

// ---------------------------------------------------------------------------
// Square card for the category grid on the home screen
// ---------------------------------------------------------------------------

class CategoryCard extends StatelessWidget {
  final PlaceCategory category;
  final int placeCount;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.placeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: category.color.withOpacity(0.35),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Layer 1: background ──────────────────────────────────────
            if (category.imagePath != null)
              Image.asset(category.imagePath!, fit: BoxFit.cover)
            else
              Container(color: category.color),

            // ── Layer 2: gradient overlay ────────────────────────────────
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: category.imagePath != null
                      ? [
                          Colors.black.withOpacity(0.08),
                          category.color.withOpacity(0.72),
                        ]
                      : [category.color.withOpacity(0.75), category.color],
                ),
              ),
            ),

            // ── Layer 3: content ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(category.icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    category.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.28),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$placeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Layer 4: ink ripple on top ───────────────────────────────
            Material(
              color: Colors.transparent,
              child: InkWell(onTap: onTap),
            ),
          ],
        ),
      ),
    );
  }
}
