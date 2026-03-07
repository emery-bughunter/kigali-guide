import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/place.dart';
import '../../providers/auth_provider.dart';
import '../../providers/places_provider.dart';
import '../../services/place_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/place_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('Not signed in.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          TextButton.icon(
            onPressed: () async {
              await auth.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (_) => false,
                );
              }
            },
            icon: const Icon(Icons.logout, color: Colors.white, size: 18),
            label: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              color: AppTheme.primaryColor,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white.withOpacity(0.22),
                    child: Text(
                      user.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  const Text(
                    'My Listings',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/add-place'),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add New'),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: StreamBuilder<List<Place>>(
              stream: PlaceService().streamByUser(user.uid),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  );
                }

                final places = snap.data ?? [];

                if (places.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 32,
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.add_location_alt_outlined,
                          size: 56,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'You haven\'t added any places yet.',
                          style: TextStyle(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/add-place'),
                          icon: const Icon(Icons.add),
                          label: const Text('Add a Place'),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: places
                      .map(
                        (p) => PlaceCard(
                          place: p,
                          distance: context
                              .read<PlacesProvider>()
                              .distanceStringFor(p),
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/place-detail',
                            arguments: {'placeId': p.id},
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}
