import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../providers/places_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';

// ---------------------------------------------------------------------------
// Full-screen interactive map showing all listed places as markers
// ---------------------------------------------------------------------------

class MapViewScreen extends StatelessWidget {
  const MapViewScreen({super.key});

  // Kigali city centre
  static const _kigali = LatLng(-1.9441, 30.0619);

  @override
  Widget build(BuildContext context) {
    final places = context.watch<PlacesProvider>();

    final markers = places.allPlaces
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
      ),
      body: places.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
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
