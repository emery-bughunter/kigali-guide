import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/places_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/place_card.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  Future<void> _confirmDelete(
    BuildContext context,
    PlacesProvider prov,
    String id,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete listing?'),
        content: const Text(
          'This will permanently remove the listing for everyone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await prov.deletePlace(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final prov = context.watch<PlacesProvider>();

    final myPlaces = user == null
        ? []
        : prov.allPlaces.where((p) => p.createdBy == user.uid).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
        automaticallyImplyLeading: false,
      ),
      body: user == null
          ? const Center(child: Text('Please sign in to view your listings.'))
          : prov.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            )
          : myPlaces.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.add_location_alt_outlined,
                      size: 64,
                      color: AppTheme.textSecondaryColor,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No listings yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Add places and services to share with the Kigali community.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textSecondaryColor),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/add-place'),
                      icon: const Icon(Icons.add),
                      label: const Text('Add a Place'),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 88),
              itemCount: myPlaces.length,
              itemBuilder: (context, i) {
                final p = myPlaces[i];
                return Stack(
                  children: [
                    PlaceCard(
                      place: p,
                      distance: prov.distanceStringFor(p),
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/place-detail',
                        arguments: {'placeId': p.id},
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Material(
                        color: Colors.white.withOpacity(0.85),
                        shape: const CircleBorder(),
                        child: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: AppTheme.errorColor,
                          ),
                          tooltip: 'Delete listing',
                          onPressed: () => _confirmDelete(context, prov, p.id),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-place'),
        tooltip: 'Add Place',
        child: const Icon(Icons.add),
      ),
    );
  }
}
