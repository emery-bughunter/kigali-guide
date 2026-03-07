import 'dart:async';
import 'package:flutter/material.dart';
import '../models/place.dart';
import '../services/place_service.dart';
import '../services/location_service.dart';

// ---------------------------------------------------------------------------
// Sort options available on the place list screen
// ---------------------------------------------------------------------------

enum SortOption {
  newest('Newest First'),
  nameAZ('Name A–Z'),
  ratingDesc('Highest Rated'),
  distanceAsc('Nearest First');

  const SortOption(this.label);
  final String label;
}

// ---------------------------------------------------------------------------
// ChangeNotifier managing the full places collection with filtering, search,
// and location-aware sorting
// ---------------------------------------------------------------------------

class PlacesProvider extends ChangeNotifier {
  final PlaceService _service = PlaceService();

  List<Place> _allPlaces = [];
  List<Place> _filteredPlaces = [];
  String _selectedCategory = '';
  String _searchQuery = '';
  SortOption _sortOption = SortOption.newest;
  bool _isLoading = true;
  String? _error;
  double? _userLat;
  double? _userLon;

  StreamSubscription<List<Place>>? _sub;

  // ── Getters ───────────────────────────────────────────────────────────────

  List<Place> get filteredPlaces => _filteredPlaces;
  List<Place> get allPlaces => _allPlaces;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  SortOption get sortOption => _sortOption;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasLocation => _userLat != null && _userLon != null;

  int countForCategory(String categoryId) =>
      _allPlaces.where((p) => p.category == categoryId).length;

  // ── Initialisation ────────────────────────────────────────────────────────

  PlacesProvider() {
    _subscribeAll();
    _resolveLocation();
  }

  void _subscribeAll() {
    _isLoading = true;
    _sub?.cancel();
    _sub = _service.streamAll().listen(
      (places) {
        _allPlaces = places;
        _applyFilters();
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _error = 'Failed to load places: $e';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> _resolveLocation() async {
    final pos = await LocationService.getCurrentPosition();
    if (pos != null) {
      _userLat = pos.latitude;
      _userLon = pos.longitude;
      _applyFilters();
    }
  }

  // ── Public filter / sort controls ─────────────────────────────────────────

  void filterByCategory(String category) {
    _selectedCategory = _selectedCategory == category ? '' : category;
    _applyFilters();
  }

  void clearCategoryFilter() {
    _selectedCategory = '';
    _applyFilters();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void setSortOption(SortOption option) {
    _sortOption = option;
    _applyFilters();
  }

  // ── CRUD forwarding ───────────────────────────────────────────────────────

  Future<bool> addPlace(Place place) async {
    try {
      await _service.add(place);
      return true;
    } catch (e) {
      _error = 'Failed to add place: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePlace(Place place) async {
    try {
      await _service.update(place);
      return true;
    } catch (e) {
      _error = 'Failed to update place: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePlace(String id) async {
    try {
      await _service.delete(id);
      return true;
    } catch (e) {
      _error = 'Failed to delete place: $e';
      notifyListeners();
      return false;
    }
  }

  /// Formatted distance from the current user to [place], or null.
  String? distanceStringFor(Place place) {
    if (!hasLocation) return null;
    if (place.latitude == null || place.longitude == null) return null;
    final km = LocationService.distanceKm(
      _userLat!,
      _userLon!,
      place.latitude!,
      place.longitude!,
    );
    return LocationService.formatDistance(km);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ── Internal filtering ────────────────────────────────────────────────────

  void _applyFilters() {
    List<Place> result = List.from(_allPlaces);

    if (_selectedCategory.isNotEmpty) {
      result = result.where((p) => p.category == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where(
            (p) =>
                p.name.toLowerCase().contains(q) ||
                p.description.toLowerCase().contains(q) ||
                p.address.toLowerCase().contains(q) ||
                p.district.toLowerCase().contains(q),
          )
          .toList();
    }

    switch (_sortOption) {
      case SortOption.newest:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case SortOption.nameAZ:
        result.sort((a, b) => a.name.compareTo(b.name));
      case SortOption.ratingDesc:
        result.sort((a, b) => b.rating.compareTo(a.rating));
      case SortOption.distanceAsc:
        if (hasLocation) {
          result.sort((a, b) {
            if (a.latitude == null || a.longitude == null) return 1;
            if (b.latitude == null || b.longitude == null) return -1;
            final dA = LocationService.distanceKm(
              _userLat!,
              _userLon!,
              a.latitude!,
              a.longitude!,
            );
            final dB = LocationService.distanceKm(
              _userLat!,
              _userLon!,
              b.latitude!,
              b.longitude!,
            );
            return dA.compareTo(dB);
          });
        }
    }

    _filteredPlaces = result;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
