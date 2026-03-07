import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../providers/places_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  // Kigali city centre
  static const _kigali = LatLng(-1.9441, 30.0619);

  // null = "All"
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final places = context.watch<PlacesProvider>();

    // Filter places by selected category
    final filtered = _selectedCategory == null
        ? places.allPlaces
        : places.allPlaces
              .where((p) => p.category == _selectedCategory)
              .toList();

    final markers = filtered
        .where((p) => p.latitude != null && p.longitude != null)
        .map((p) {
          final cat = AppConstants.getCategoryById(p.category);
          return Marker(
            point: LatLng(p.latitude!, p.longitude!),
            width: 44,
            height: 44,
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(
                context,
                '/place-detail',
                arguments: {'placeId': p.id},
              ),
              child: Tooltip(
                message: p.name,
                child: CircleAvatar(
                  backgroundColor: cat.color,
                  child: Icon(cat.icon, color: Colors.white, size: 20),
                ),
              ),
            ),
          );
        })
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Map View${markers.isNotEmpty ? ' (${markers.length})' : ''}',
        ),
        automaticallyImplyLeading: false,
        // Filter chip bar pinned below the title
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
          : FlutterMap(
              options: const MapOptions(
                initialCenter: _kigali,
                initialZoom: 13,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.assignment',
                ),
                MarkerLayer(markers: markers),
              ],
            ),
      floatingActionButton: markers.isEmpty && !places.isLoading
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, '/add-place'),
              icon: const Icon(Icons.add_location_alt),
              label: const Text('Add Place with Location'),
            )
          : null,
    );
  }
}

// ---------------------------------------------------------------------------
// Horizontal scrollable filter chip row
// ---------------------------------------------------------------------------
class _FilterBar extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onSelected;

  const _FilterBar({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          // "All" chip
          _Chip(
            label: 'All',
            icon: Icons.layers_rounded,
            color: AppTheme.accentColor,
            selected: selected == null,
            onTap: () => onSelected(null),
          ),
          const SizedBox(width: 8),
          // One chip per category
          ...AppConstants.categories.map((cat) {
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
