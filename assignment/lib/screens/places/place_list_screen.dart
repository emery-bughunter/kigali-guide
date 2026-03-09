import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/places_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/place_card.dart';
import '../../models/place.dart';

class PlaceListScreen extends StatefulWidget {
  final String? categoryId;

  const PlaceListScreen({super.key, this.categoryId});

  @override
  State<PlaceListScreen> createState() => _PlaceListScreenState();
}

class _PlaceListScreenState extends State<PlaceListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<PlacesProvider>();
      if (widget.categoryId != null) {
        prov.filterByCategory(widget.categoryId!);
      } else {
        prov.clearCategoryFilter();
      }
      prov.setSearchQuery('');
      _searchCtrl.clear();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openSort(BuildContext ctx) {
    final prov = ctx.read<PlacesProvider>();
    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, ss) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sort By',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...SortOption.values.map((opt) {
                    final selected = prov.sortOption == opt;
                    return ListTile(
                      leading: Icon(
                        selected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: selected
                            ? AppTheme.primaryColor
                            : AppTheme.textSecondaryColor,
                      ),
                      title: Text(opt.label),
                      onTap: () {
                        prov.setSortOption(opt);
                        Navigator.pop(context);
                      },
                      contentPadding: EdgeInsets.zero,
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cat = widget.categoryId != null
        ? AppConstants.getCategoryById(widget.categoryId!)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(cat?.name ?? 'All Places'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort_rounded),
            tooltip: 'Sort',
            onPressed: () => _openSort(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search bar ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (q) =>
                  context.read<PlacesProvider>().setSearchQuery(q),
              decoration: InputDecoration(
                hintText: 'Search in ${cat?.name ?? 'all places'}…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          context.read<PlacesProvider>().setSearchQuery('');
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // ── Category chips row ─────────────────────────────────────────────
          _CategoryFilterRow(selectedId: widget.categoryId),

          // ── Results ────────────────────────────────────────────────────────
          Expanded(child: _PlacesList(categoryId: widget.categoryId)),
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
// Horizontal scrolling category chips
// ---------------------------------------------------------------------------

class _CategoryFilterRow extends StatelessWidget {
  final String? selectedId;
  const _CategoryFilterRow({this.selectedId});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<PlacesProvider>();
    return SizedBox(
      height: 44,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        children: [
          // "All" chip
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: const Text('All'),
              selected: prov.selectedCategory.isEmpty,
              onSelected: (_) => prov.clearCategoryFilter(),
              selectedColor: AppTheme.primaryColor.withOpacity(0.15),
              checkmarkColor: AppTheme.primaryColor,
            ),
          ),
          ...AppConstants.categories.map((cat) {
            final selected = prov.selectedCategory == cat.id;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FilterChip(
                avatar: Icon(cat.icon, size: 16, color: cat.color),
                label: Text(cat.name),
                selected: selected,
                onSelected: (_) => prov.filterByCategory(cat.id),
                selectedColor: cat.color.withOpacity(0.15),
                checkmarkColor: cat.color,
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// The scrollable list of place cards
// ---------------------------------------------------------------------------

class _PlacesList extends StatelessWidget {
  final String? categoryId;
  const _PlacesList({this.categoryId});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<PlacesProvider>();
    final List<Place> items = prov.filteredPlaces;

    if (prov.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_off_rounded,
              size: 56,
              color: AppTheme.textSecondaryColor,
            ),
            const SizedBox(height: 12),
            Text(
              prov.searchQuery.isNotEmpty
                  ? 'No results for "${prov.searchQuery}"'
                  : 'No places found in this category yet.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/add-place'),
              icon: const Icon(Icons.add),
              label: const Text('Add a Place'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 88),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final p = items[i];
        return PlaceCard(
          place: p,
          distance: prov.distanceStringFor(p),
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
