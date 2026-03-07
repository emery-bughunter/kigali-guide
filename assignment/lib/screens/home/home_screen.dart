import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/places_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/place_card.dart';
import '../../widgets/category_card.dart';

// ---------------------------------------------------------------------------
// Main home screen – search bar, category grid, recent listings
// ---------------------------------------------------------------------------

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  bool _searchActive = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _activateSearch() {
    setState(() => _searchActive = true);
    _searchFocus.requestFocus();
  }

  void _clearSearch() {
    _searchCtrl.clear();
    context.read<PlacesProvider>().setSearchQuery('');
    setState(() => _searchActive = false);
    _searchFocus.unfocus();
  }

  String _greeting(String name) {
    final h = DateTime.now().hour;
    final prefix = h < 12
        ? 'Good morning'
        : h < 17
        ? 'Good afternoon'
        : 'Good evening';
    final firstName = name.split(' ').first;
    return '$prefix, $firstName !';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final places = context.watch<PlacesProvider>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          // ── Hero image app bar ──────────────────────────────────────────
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
            child: SizedBox(
              height: 220,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background image
                  Image.asset('assets/hero img.jpeg', fit: BoxFit.cover),
                  // Dark navy overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppTheme.primaryDarkColor.withOpacity(0.88),
                          AppTheme.primaryColor.withOpacity(0.95),
                        ],
                      ),
                    ),
                  ),
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top bar
                          Row(
                            children: [
                              const Icon(
                                Icons.location_city,
                                color: Colors.white,
                                size: 26,
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Kigali Directory',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    Navigator.pushNamed(context, '/profile'),
                                child: CircleAvatar(
                                  radius: 19,
                                  backgroundColor: Colors.white.withOpacity(
                                    0.25,
                                  ),
                                  child: Text(
                                    auth.user?.initials ?? 'U',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Greeting
                          if (auth.user != null)
                            Text(
                              _greeting(auth.user!.displayName),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          const Spacer(),

                          // Search bar
                          Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppTheme.dividerColor,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 14),
                                const Icon(
                                  Icons.search,
                                  color: AppTheme.textSecondaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _searchCtrl,
                                    focusNode: _searchFocus,
                                    onTap: _activateSearch,
                                    onChanged: (q) {
                                      places.setSearchQuery(q);
                                      setState(() {});
                                    },
                                    decoration: const InputDecoration(
                                      hintText: 'Search places, services…',
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                      isDense: true,
                                      filled: false,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.textPrimaryColor,
                                    ),
                                  ),
                                ),
                                if (_searchActive ||
                                    _searchCtrl.text.isNotEmpty)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      size: 18,
                                      color: AppTheme.textSecondaryColor,
                                    ),
                                    onPressed: _clearSearch,
                                  )
                                else
                                  const SizedBox(width: 14),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Body ───────────────────────────────────────────────────────────
          Expanded(
            child: places.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                  )
                : _searchCtrl.text.isNotEmpty
                ? _SearchResults(places: places, query: _searchCtrl.text)
                : _HomeContent(places: places),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-place'),
        tooltip: 'Add a Place',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Default home content: category grid + recent listings
// ---------------------------------------------------------------------------

class _HomeContent extends StatelessWidget {
  final PlacesProvider places;
  const _HomeContent({required this.places});

  @override
  Widget build(BuildContext context) {
    final recents = places.allPlaces.take(10).toList();
    final totalPlaces = places.allPlaces.length;
    final totalCategories = AppConstants.categories.length;

    return CustomScrollView(
      slivers: [
        // ── Stats banner ───────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Row(
              children: [
                _StatChip(
                  icon: Icons.place_rounded,
                  value: '$totalPlaces',
                  label: 'Places',
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 12),
                _StatChip(
                  icon: Icons.category_rounded,
                  value: '$totalCategories',
                  label: 'Categories',
                  color: AppTheme.secondaryColor,
                ),
                const SizedBox(width: 12),
                _StatChip(
                  icon: Icons.location_city_rounded,
                  value: 'Kigali',
                  label: 'City',
                  color: const Color(0xFF7C3AED),
                ),
              ],
            ),
          ),
        ),

        // ── Category section ───────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Explore by Category',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/place-list'),
                  child: const Text('See All'),
                ),
              ],
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate((context, i) {
              final cat = AppConstants.categories[i];
              return CategoryCard(
                category: cat,
                placeCount: places.countForCategory(cat.id),
                onTap: () => Navigator.pushNamed(
                  context,
                  '/place-list',
                  arguments: {'categoryId': cat.id},
                ),
              );
            }, childCount: AppConstants.categories.length),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.78,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
          ),
        ),

        // ── Recent listings ────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Recently Added',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/place-list'),
                  child: const Text('See All'),
                ),
              ],
            ),
          ),
        ),

        if (recents.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'No places yet.\nTap + to add the first one!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSecondaryColor),
                ),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate((context, i) {
              final p = recents[i];
              return PlaceCard(
                place: p,
                distance: context.read<PlacesProvider>().distanceStringFor(p),
                onTap: () => Navigator.pushNamed(
                  context,
                  '/place-detail',
                  arguments: {'placeId': p.id},
                ),
              );
            }, childCount: recents.length),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 88)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Inline search results list
// ---------------------------------------------------------------------------

class _SearchResults extends StatelessWidget {
  final PlacesProvider places;
  final String query;
  const _SearchResults({required this.places, required this.query});

  @override
  Widget build(BuildContext context) {
    final results = places.filteredPlaces;

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 56,
              color: AppTheme.textSecondaryColor,
            ),
            const SizedBox(height: 12),
            Text(
              'No results for "$query"',
              style: const TextStyle(
                fontSize: 15,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 12, bottom: 88),
      itemCount: results.length,
      itemBuilder: (context, i) {
        final p = results[i];
        return PlaceCard(
          place: p,
          distance: places.distanceStringFor(p),
          onTap: () => Navigator.pushNamed(
            context,
            '/place-detail',
            arguments: {'placeId': p.id},
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Small stat chip for the home screen banner
// ---------------------------------------------------------------------------

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.09),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.18)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: color,
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
