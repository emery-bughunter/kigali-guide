import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/place.dart';
import '../utils/constants.dart';
import '../utils/app_theme.dart';

// ---------------------------------------------------------------------------
// Place listing card used in list and search results
// ---------------------------------------------------------------------------

class PlaceCard extends StatelessWidget {
  final Place place;
  final String? distance;
  final VoidCallback onTap;

  const PlaceCard({
    super.key,
    required this.place,
    this.distance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cat = AppConstants.getCategoryById(place.category);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail ──────────────────────────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: SizedBox(
                width: 96,
                height: 96,
                child: place.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: place.imageUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                            _buildImagePlaceholder(cat),
                      )
                    : _buildImagePlaceholder(cat),
              ),
            ),

            // Info ───────────────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + verified badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            place.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppTheme.textPrimaryColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (place.isVerified) ...[
                          const SizedBox(width: 4),
                          const Tooltip(
                            message: 'Verified',
                            child: Icon(
                              Icons.verified,
                              size: 15,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Category chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: cat.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        cat.name,
                        style: TextStyle(
                          fontSize: 11,
                          color: cat.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Address
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            place.address,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Rating + distance
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: Colors.amber[600],
                        ),
                        const SizedBox(width: 2),
                        Text(
                          place.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimaryColor,
                          ),
                        ),
                        Text(
                          ' (${place.ratingCount})',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                        const Spacer(),
                        if (distance != null) ...[
                          const Icon(
                            Icons.near_me_outlined,
                            size: 12,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            distance!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(PlaceCategory cat) {
    return Container(
      color: cat.color.withOpacity(0.1),
      child: Center(child: Icon(cat.icon, size: 36, color: cat.color)),
    );
  }
}
