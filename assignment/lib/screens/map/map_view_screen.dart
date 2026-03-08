import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:provider/provider.dart';
import '../../providers/places_provider.dart';
import '../../services/seed_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';

// Tile-layer presets
enum _MapStyle {
  street('Street', 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
  detailed(
    'Detailed',
    'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
  );

  const _MapStyle(this.label, this.urlTemplate);
  final String label;
  final String urlTemplate;
}

// ---------------------------------------------------------------------------
// MapViewScreen
// ---------------------------------------------------------------------------
class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  static const _kigali = LatLng(-1.9441, 30.0619);

  String? _selectedCategory;
  _MapStyle _mapStyle = _MapStyle.street;

  @override
  void initState() {
    super.initState();
    // Seed curated Kigali places to Firestore on first run (no-op if already done)
    SeedService.seedIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    final places = context.watch<PlacesProvider>();

    // Filter to only the 3 targeted categories on this map view
    const mapCategories = {'hospital', 'police', 'restaurant'};
    final filtered = places.allPlaces.where((p) {
      final inCategory = mapCategories.contains(p.category);
      final matchesFilter =
          _selectedCategory == null || p.category == _selectedCategory;
      return inCategory && matchesFilter;
    }).toList();

    final markers = filtered
        .where((p) => p.latitude != null && p.longitude != null)
        .map((p) {
          final cat = AppConstants.getCategoryById(p.category);
          return Marker(
            point: LatLng(p.latitude!, p.longitude!),
            width: 46,
            height: 46,
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(
                context,
                '/place-detail',
                arguments: {'placeId': p.id},
              ),
              child: _MapPin(icon: cat.icon, color: cat.color),
            ),
          );
        })
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kigali Map${markers.isNotEmpty ? ' (${markers.length})' : ''}',
        ),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: () => setState(() {
                _mapStyle = _mapStyle == _MapStyle.street
                    ? _MapStyle.detailed
                    : _MapStyle.street;
              }),
              icon: Icon(
                _mapStyle == _MapStyle.street ? Icons.map : Icons.layers,
                size: 18,
                color: AppTheme.accentColor,
              ),
              label: Text(
                _mapStyle == _MapStyle.street ? 'Detailed' : 'Street',
                style: const TextStyle(
                  color: AppTheme.accentColor,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: _FilterBar(
            selected: _selectedCategory,
            onSelected: (id) => setState(() => _selectedCategory = id),
          ),
        ),
      ),
      body: places.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.accentColor),
            )
          : Stack(
              children: [
                FlutterMap(
                  options: const MapOptions(
                    initialCenter: _kigali,
                    initialZoom: 13,
                    maxZoom: 18,
                    minZoom: 10,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: _mapStyle.urlTemplate,
                      subdomains: _mapStyle == _MapStyle.detailed
                          ? const ['a', 'b', 'c', 'd']
                          : const [],
                      userAgentPackageName: 'com.example.assignment',
                    ),
                    MarkerLayer(markers: markers),
                  ],
                ),
                Positioned(bottom: 16, left: 12, child: const _Legend()),
              ],
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Custom pin-shaped marker widget
// ---------------------------------------------------------------------------
class _MapPin extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _MapPin({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.5), blurRadius: 6),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 17),
        ),
        CustomPaint(
          size: const Size(10, 6),
          painter: _PinTailPainter(color: color),
        ),
      ],
    );
  }
}

class _PinTailPainter extends CustomPainter {
  final Color color;
  _PinTailPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_PinTailPainter old) => old.color != color;
}

// ---------------------------------------------------------------------------
// Map legend overlay
// ---------------------------------------------------------------------------
class _Legend extends StatelessWidget {
  static const _items = [
    ('Hospitals', Icons.local_hospital, Color(0xFFE53935)),
    ('Police Stations', Icons.local_police, Color(0xFF1565C0)),
    ('Restaurants', Icons.restaurant, Color(0xFFF9A825)),
  ];

  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.88),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _items.map((item) {
          final (label, icon, color) = item;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 9,
                  backgroundColor: color,
                  child: Icon(icon, color: Colors.white, size: 10),
                ),
                const SizedBox(width: 7),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Horizontal scrollable filter chip row
// ---------------------------------------------------------------------------

// Only show the 3 targeted categories in the filter bar
const _mapFilterCategories = ['hospital', 'police', 'restaurant'];

class _FilterBar extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onSelected;

  const _FilterBar({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final displayCategories = AppConstants.categories
        .where((c) => _mapFilterCategories.contains(c.id))
        .toList();

    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          _Chip(
            label: 'All',
            icon: Icons.layers_rounded,
            color: AppTheme.accentColor,
            selected: selected == null,
            onTap: () => onSelected(null),
          ),
          const SizedBox(width: 8),
          ...displayCategories.map((cat) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _Chip(
                label: cat.name,
                icon: cat.icon,
                color: cat.color,
                selected: selected == cat.id,
                onTap: () => onSelected(cat.id),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? color : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : AppTheme.dividerColor,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: selected ? Colors.white : color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppTheme.textPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
