import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/place.dart';
import '../../providers/auth_provider.dart';
import '../../providers/places_provider.dart';
import '../../services/place_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';

class PlaceDetailScreen extends StatefulWidget {
  final String placeId;
  const PlaceDetailScreen({super.key, required this.placeId});

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  Place? _place;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPlace();
  }

  Future<void> _loadPlace() async {
    try {
      final p = await PlaceService().fetchById(widget.placeId);
      if (mounted) {
        setState(() {
          _place = p;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _openMap() async {
    if (_place == null) return;
    final lat = _place!.latitude;
    final lon = _place!.longitude;

    Uri uri;
    if (lat != null && lon != null) {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lon',
      );
    } else {
      final q = Uri.encodeComponent(
        '${_place!.name}, ${_place!.address}, Kigali',
      );
      uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$q');
    }
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open map.')));
      }
    }
  }

  Future<void> _callPhone() async {
    if (_place?.phone == null) return;
    final uri = Uri.parse('tel:${_place!.phone}');
    if (!await launchUrl(uri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open dialler.')),
        );
      }
    }
  }

  Future<void> _openWebsite() async {
    if (_place?.website == null) return;
    final raw = _place!.website!;
    final url = raw.startsWith('http') ? raw : 'https://$raw';
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open website.')),
        );
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Place'),
        content: Text(
          'Are you sure you want to delete "${_place!.name}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok == true && mounted) {
      final success = await context.read<PlacesProvider>().deletePlace(
        widget.placeId,
      );
      if (!mounted) return;
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Place deleted successfully.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
      );
    }

    if (_error != null || _place == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Place Details')),
        body: Center(
          child: Text(
            _error ?? 'Place not found.',
            style: const TextStyle(color: AppTheme.textSecondaryColor),
          ),
        ),
      );
    }

    final place = _place!;
    final cat = AppConstants.getCategoryById(place.category);
    final auth = context.watch<AuthProvider>();
    final isOwner = auth.user?.uid == place.createdBy;
    final distance = context.read<PlacesProvider>().distanceStringFor(place);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Hero image / app bar ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: place.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: place.imageUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _buildImagePlaceholder(cat),
                    )
                  : _buildImagePlaceholder(cat),
            ),
            actions: [
              if (isOwner) ...[
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit',
                  onPressed: () => Navigator.pushNamed(
                    context,
                    '/add-place',
                    arguments: {'place': place},
                  ).then((_) => _loadPlace()),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete',
                  onPressed: () => _confirmDelete(context),
                ),
              ],
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          place.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimaryColor,
                          ),
                        ),
                      ),
                      if (place.isVerified)
                        Tooltip(
                          message: 'Verified listing',
                          child: Icon(
                            Icons.verified,
                            color: AppTheme.primaryColor,
                            size: 22,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(
                        avatar: Icon(cat.icon, size: 14, color: cat.color),
                        label: Text(cat.name),
                        backgroundColor: cat.color.withOpacity(0.12),
                        labelStyle: TextStyle(
                          color: cat.color,
                          fontWeight: FontWeight.w600,
                        ),
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 0,
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                      if (distance != null)
                        Chip(
                          avatar: const Icon(
                            Icons.near_me_outlined,
                            size: 14,
                            color: AppTheme.primaryColor,
                          ),
                          label: Text(distance),
                          backgroundColor: AppTheme.primaryColor.withOpacity(
                            0.1,
                          ),
                          labelStyle: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                          side: BorderSide.none,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 0,
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ...List.generate(5, (i) {
                        final filled = i < place.rating.floor();
                        final half =
                            !filled &&
                            i < place.rating &&
                            place.rating - i >= 0.5;
                        return Icon(
                          half
                              ? Icons.star_half_rounded
                              : filled
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: Colors.amber[600],
                          size: 22,
                        );
                      }),
                      const SizedBox(width: 6),
                      Text(
                        '${place.rating.toStringAsFixed(1)} (${place.ratingCount} reviews)',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.map_outlined,
                          label: 'Directions',
                          color: AppTheme.primaryColor,
                          onTap: _openMap,
                        ),
                      ),
                      if (place.phone != null) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.phone_outlined,
                            label: 'Call',
                            color: Colors.green[700]!,
                            onTap: _callPhone,
                          ),
                        ),
                      ],
                      if (place.website != null) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.language,
                            label: 'Website',
                            color: Colors.blue[700]!,
                            onTap: _openWebsite,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Info rows ───────────────────────────────────────────
                  const Divider(),
                  const SizedBox(height: 12),

                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Address',
                    value:
                        '${place.address}${place.district.isNotEmpty ? ', ${place.district}' : ''}',
                  ),
                  if (place.phone != null) ...[
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.phone_outlined,
                      label: 'Phone',
                      value: place.phone!,
                    ),
                  ],
                  if (place.openingHours != null) ...[
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.access_time_outlined,
                      label: 'Hours',
                      value: place.openingHours!,
                    ),
                  ],
                  if (place.website != null) ...[
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.language,
                      label: 'Website',
                      value: place.website!,
                    ),
                  ],

                  if (place.description.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'About',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      place.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textPrimaryColor,
                        height: 1.6,
                      ),
                    ),
                  ],

                  // ── Embedded map ──────────────────────────────────────
                  if (place.latitude != null && place.longitude != null) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        height: 200,
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: LatLng(
                              place.latitude!,
                              place.longitude!,
                            ),
                            initialZoom: 15,
                            interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.none,
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.assignment',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: LatLng(
                                    place.latitude!,
                                    place.longitude!,
                                  ),
                                  width: 44,
                                  height: 44,
                                  child: CircleAvatar(
                                    backgroundColor: AppTheme.primaryColor,
                                    child: Icon(
                                      AppConstants.getCategoryById(
                                        place.category,
                                      ).icon,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),

                  Text(
                    'Added by ${place.createdByName.isNotEmpty ? place.createdByName : 'a user'}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder(PlaceCategory cat) {
    return Container(
      color: cat.color.withOpacity(0.1),
      child: Center(child: Icon(cat.icon, size: 64, color: cat.color)),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
