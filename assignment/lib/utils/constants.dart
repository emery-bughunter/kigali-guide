import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// App-wide constants and category definitions
// ---------------------------------------------------------------------------

class AppConstants {
  static const String appName = 'Kigali Directory';
  static const String appTagline = 'Services & Places';

  // Firestore collection names
  static const String placesCollection = 'places';
  static const String usersCollection = 'users';

  // Kigali districts
  static const List<String> districts = ['Gasabo', 'Kicukiro', 'Nyarugenge'];

  // Place categories
  static const List<PlaceCategory> categories = [
    PlaceCategory(
      id: 'hospital',
      name: 'Hospitals',
      icon: Icons.local_hospital,
      color: Color(0xFFE53935),
    ),
    PlaceCategory(
      id: 'police',
      name: 'Police Stations',
      icon: Icons.local_police,
      color: Color(0xFF1565C0),
    ),
    PlaceCategory(
      id: 'library',
      name: 'Libraries',
      icon: Icons.local_library,
      color: Color(0xFF6A1B9A),
    ),
    PlaceCategory(
      id: 'utility',
      name: 'Utility Offices',
      icon: Icons.business,
      color: Color(0xFFE65100),
    ),
    PlaceCategory(
      id: 'restaurant',
      name: 'Restaurants',
      icon: Icons.restaurant,
      color: Color(0xFFF9A825),
    ),
    PlaceCategory(
      id: 'cafe',
      name: 'Cafés',
      icon: Icons.local_cafe,
      color: Color(0xFF4E342E),
    ),
    PlaceCategory(
      id: 'park',
      name: 'Parks',
      icon: Icons.park,
      color: Color(0xFF2E7D32),
    ),
    PlaceCategory(
      id: 'attraction',
      name: 'Tourist Attractions',
      icon: Icons.attractions,
      color: Color(0xFF00838F),
    ),
  ];

  static PlaceCategory getCategoryById(String id) {
    return categories.firstWhere(
      (c) => c.id == id,
      orElse: () => categories.first,
    );
  }
}

class PlaceCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const PlaceCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}
