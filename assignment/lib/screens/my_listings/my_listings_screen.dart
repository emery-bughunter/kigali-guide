import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/place.dart';
import '../../providers/auth_provider.dart';
import '../../providers/places_provider.dart';
import '../../services/place_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/place_card.dart';

// ---------------------------------------------------------------------------
// Shows only the listings created by the authenticated user
// ---------------------------------------------------------------------------

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
        automaticallyImplyLeading: false,
      ),
      body: user == null
          ? const Center(child: Text('Please sign in to view your listings.'))
          : StreamBuilder<List<Place>>(
              stream: PlaceService().streamByUser(user.uid),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                  );
                }

                final places = snap.data ?? [];

                if (places.isEmpty) {
                  return Center(
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
                            style: TextStyle(
                              color: AppTheme.textSecondaryColor,
                            ),
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
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 88),
                  itemCount: places.length,
                  itemBuilder: (context, i) {
                    final p = places[i];
                    return PlaceCard(
                      place: p,
                      distance: context
                          .read<PlacesProvider>()
                          .distanceStringFor(p),
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/place-detail',
                        arguments: {'placeId': p.id},
                      ),
                    );
                  },
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
