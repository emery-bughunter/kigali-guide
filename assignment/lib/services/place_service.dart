import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/place.dart';
import '../utils/constants.dart';

// ---------------------------------------------------------------------------
// All Firestore CRUD operations for Place listings with real-time streams
// ---------------------------------------------------------------------------

class PlaceService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(AppConstants.placesCollection);

  // ── Read ──────────────────────────────────────────────────────────────────

  /// Real-time stream of every place, newest first.
  Stream<List<Place>> streamAll() =>
      _col.orderBy('createdAt', descending: true).snapshots().map(_docsToList);

  /// Real-time stream filtered to a single category.
  Stream<List<Place>> streamByCategory(String category) => _col
      .where('category', isEqualTo: category)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(_docsToList);

  /// Real-time stream of places created by a specific user.
  Stream<List<Place>> streamByUser(String userId) => _col
      .where('createdBy', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(_docsToList);

  /// Fetch a single place document by its ID.
  Future<Place?> fetchById(String id) async {
    final doc = await _col.doc(id).get();
    return doc.exists ? Place.fromFirestore(doc) : null;
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  /// Add a new place and return the generated document ID.
  Future<String> add(Place place) async {
    final ref = await _col.add(place.toMap());
    return ref.id;
  }

  /// Overwrite mutable fields on an existing place.
  Future<void> update(Place place) async {
    final data = place.toMap();
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _col.doc(place.id).update(data);
  }

  /// Permanently delete a place document.
  Future<void> delete(String id) => _col.doc(id).delete();

  // ── Search ────────────────────────────────────────────────────────────────

  /// Client-side text search across name, description, address, district.
  Future<List<Place>> search(String query) async {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return [];
    final snapshot = await _col.get();
    return snapshot.docs
        .map(Place.fromFirestore)
        .where(
          (p) =>
              p.name.toLowerCase().contains(q) ||
              p.description.toLowerCase().contains(q) ||
              p.address.toLowerCase().contains(q) ||
              p.district.toLowerCase().contains(q),
        )
        .toList();
  }

  // ── Helper ────────────────────────────────────────────────────────────────

  List<Place> _docsToList(QuerySnapshot snapshot) =>
      snapshot.docs.map(Place.fromFirestore).toList();
}
