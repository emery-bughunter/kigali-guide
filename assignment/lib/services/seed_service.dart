import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';

// ---------------------------------------------------------------------------
// SeedService — writes curated Kigali places to Firestore once.
//
// A guard document `app_config/seed_status` is used so seeding only runs
// on the very first launch (or after a manual reset).  All seeded places are
// marked isVerified = true and createdBy = 'system'.
// ---------------------------------------------------------------------------

class SeedService {
  static final _db = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> get _places =>
      _db.collection(AppConstants.placesCollection);

  static DocumentReference<Map<String, dynamic>> get _seedFlag =>
      _db.collection('app_config').doc('seed_status');

  // ── Public entry point ──────────────────────────────────────────────────

  /// Seeds the curated Kigali places if it has not been done before.
  /// Safe to call on every app start — it exits immediately when already done.
  static Future<void> seedIfNeeded() async {
    final flag = await _seedFlag.get();
    if (flag.exists && (flag.data()?['seeded'] == true)) return;

    await _writePlaces();

    await _seedFlag.set({
      'seeded': true,
      'seededAt': FieldValue.serverTimestamp(),
      'count': _kigaliPlaces.length,
    });
  }

  // ── Seed data ────────────────────────────────────────────────────────────

  static Future<void> _writePlaces() async {
    // Split into batches of 500 (Firestore limit)
    const batchSize = 500;
    for (var i = 0; i < _kigaliPlaces.length; i += batchSize) {
      final batch = _db.batch();
      final chunk = _kigaliPlaces.sublist(
        i,
        (i + batchSize).clamp(0, _kigaliPlaces.length),
      );
      for (final p in chunk) {
        final ref = _places.doc(); // auto-generated ID
        batch.set(ref, p);
      }
      await batch.commit();
    }
  }

  static final _now = Timestamp.now();

  static Map<String, dynamic> _place({
    required String name,
    required String category,
    required String description,
    required String address,
    required String district,
    required double lat,
    required double lng,
    String? phone,
    String? openingHours,
  }) => {
    'name': name,
    'category': category,
    'description': description,
    'address': address,
    'district': district,
    'phone': phone,
    'website': null,
    'openingHours': openingHours,
    'rating': 0.0,
    'ratingCount': 0,
    'latitude': lat,
    'longitude': lng,
    'imageUrl': null,
    'isVerified': true,
    'createdBy': 'system',
    'createdByName': 'Kigali Guide',
    'createdAt': _now,
    'updatedAt': _now,
  };

  static final List<Map<String, dynamic>> _kigaliPlaces = [
    // ── Hospitals ──────────────────────────────────────────────────────────
    _place(
      name: 'King Faisal Hospital',
      category: 'hospital',
      description:
          'One of Rwanda\'s leading referral hospitals, offering specialist '
          'and emergency medical care for Kigali residents and beyond.',
      address: 'KG 544 St, Kacyiru',
      district: 'Gasabo',
      lat: -1.9416,
      lng: 30.0930,
      phone: '+250 252 582 421',
      openingHours: 'Open 24 hours',
    ),
    _place(
      name: 'Rwanda Military Hospital',
      category: 'hospital',
      description:
          'A major public hospital providing military and civilian medical '
          'services including surgery, maternity, and emergency care.',
      address: 'KK 15 Rd, Kicukiro',
      district: 'Kicukiro',
      lat: -1.9567,
      lng: 30.0834,
      phone: '+250 252 586 800',
      openingHours: 'Open 24 hours',
    ),
    _place(
      name: 'CHUK – University Teaching Hospital',
      category: 'hospital',
      description:
          'Centre Hospitalier Universitaire de Kigali — the national teaching '
          'hospital and primary emergency centre in Kigali city.',
      address: 'KN 4 Ave, Nyarugenge',
      district: 'Nyarugenge',
      lat: -1.9498,
      lng: 30.0612,
      phone: '+250 252 575 555',
      openingHours: 'Open 24 hours',
    ),
    _place(
      name: 'Kibagabaga District Hospital',
      category: 'hospital',
      description:
          'District-level hospital serving the Gasabo sector, providing '
          'general outpatient, inpatient, and maternity services.',
      address: 'KG 13 Ave, Kibagabaga, Gasabo',
      district: 'Gasabo',
      lat: -1.9219,
      lng: 30.1058,
      phone: '+250 252 580 487',
      openingHours: 'Open 24 hours',
    ),
    _place(
      name: 'Masaka District Hospital',
      category: 'hospital',
      description:
          'Public hospital in southern Kigali offering general medicine, '
          'surgery, paediatrics, and maternity services.',
      address: 'KK 686 St, Masaka, Kicukiro',
      district: 'Kicukiro',
      lat: -1.9989,
      lng: 30.0961,
      phone: '+250 252 583 005',
      openingHours: 'Open 24 hours',
    ),
    // ── Police Stations ────────────────────────────────────────────────────
    _place(
      name: 'Rwanda National Police Headquarters',
      category: 'police',
      description:
          'Main headquarters of the Rwanda National Police, coordinating '
          'national law enforcement operations across the country.',
      address: 'KN 4 Ave, Kacyiru',
      district: 'Gasabo',
      lat: -1.9447,
      lng: 30.0618,
      phone: '+250 788 311 155',
      openingHours: 'Open 24 hours',
    ),
    _place(
      name: 'Kacyiru Police Station',
      category: 'police',
      description:
          'Sector-level police post serving the Kacyiru and surrounding '
          'Gasabo neighbourhoods, handling local security matters.',
      address: 'KG 7 Ave, Kacyiru, Gasabo',
      district: 'Gasabo',
      lat: -1.9327,
      lng: 30.0946,
      phone: '+250 788 311 155',
      openingHours: 'Open 24 hours',
    ),
    _place(
      name: 'Remera Police Station',
      category: 'police',
      description:
          'Police post covering the busy Remera commercial and residential '
          'area, close to Kigali International Airport.',
      address: 'KG 11 Ave, Remera, Gasabo',
      district: 'Gasabo',
      lat: -1.9534,
      lng: 30.1048,
      phone: '+250 788 311 155',
      openingHours: 'Open 24 hours',
    ),
    _place(
      name: 'Nyarugenge Police Station',
      category: 'police',
      description:
          'Central police post for Nyarugenge district, serving the city '
          'centre and surrounding neighbourhoods.',
      address: 'KN 3 Ave, Nyarugenge',
      district: 'Nyarugenge',
      lat: -1.9570,
      lng: 30.0587,
      phone: '+250 788 311 155',
      openingHours: 'Open 24 hours',
    ),
    _place(
      name: 'Kicukiro Police Station',
      category: 'police',
      description:
          'District police station covering Kicukiro and its sectors, '
          'providing community policing and emergency response.',
      address: 'KK 5 Ave, Kicukiro',
      district: 'Kicukiro',
      lat: -1.9836,
      lng: 30.0903,
      phone: '+250 788 311 155',
      openingHours: 'Open 24 hours',
    ),
    // ── Restaurants ────────────────────────────────────────────────────────
    _place(
      name: 'Heaven Restaurant',
      category: 'restaurant',
      description:
          'Award-winning rooftop restaurant known for its international and '
          'Rwandan cuisine with panoramic views of Kigali\'s hills.',
      address: 'KG 7 Ave, Kiyovu, Nyarugenge',
      district: 'Nyarugenge',
      lat: -1.9500,
      lng: 30.0946,
      phone: '+250 788 188 488',
      openingHours: 'Mon–Sun: 07:00 – 22:00',
    ),
    _place(
      name: 'Repub Lounge',
      category: 'restaurant',
      description:
          'Popular gastropub and restaurant offering Rwandan and international '
          'dishes, craft beers, and live music on weekends.',
      address: 'KG 9 Ave, Kimihurura, Gasabo',
      district: 'Gasabo',
      lat: -1.9516,
      lng: 30.0916,
      phone: '+250 788 303 030',
      openingHours: 'Mon–Sun: 11:00 – 23:00',
    ),
    _place(
      name: 'Zen Restaurant',
      category: 'restaurant',
      description:
          'Relaxed fine-dining restaurant serving Asian-fusion and pan-African '
          'cuisine in a serene garden setting.',
      address: 'KG 5 Ave, Kimihurura, Gasabo',
      district: 'Gasabo',
      lat: -1.9543,
      lng: 30.0877,
      phone: '+250 788 850 852',
      openingHours: 'Tue–Sun: 12:00 – 22:00',
    ),
    _place(
      name: 'Poivre Noir',
      category: 'restaurant',
      description:
          'Elegant French-inspired restaurant in the city centre, renowned '
          'for its classic European dishes and extensive wine list.',
      address: 'KN 71 St, Centre Ville, Nyarugenge',
      district: 'Nyarugenge',
      lat: -1.9438,
      lng: 30.0895,
      phone: '+250 788 385 385',
      openingHours: 'Mon–Sat: 12:00 – 22:30',
    ),
    _place(
      name: 'The Hut Restaurant',
      category: 'restaurant',
      description:
          'Casual local restaurant serving authentic Rwandan dishes including '
          'brochettes, ugali, and fresh tilapia at affordable prices.',
      address: 'KN 1 Rd, Nyarugenge',
      district: 'Nyarugenge',
      lat: -1.9548,
      lng: 30.0630,
      phone: '+250 788 123 456',
      openingHours: 'Mon–Sun: 08:00 – 21:00',
    ),
    _place(
      name: 'Meze Fresh',
      category: 'restaurant',
      description:
          'Fast-casual restaurant offering healthy fresh bowls, wraps, and '
          'Mediterranean-inspired meals popular with Kigali\'s expat community.',
      address: 'KG 9 Ave, Kacyiru, Gasabo',
      district: 'Gasabo',
      lat: -1.9390,
      lng: 30.0880,
      phone: '+250 788 200 200',
      openingHours: 'Mon–Sat: 09:00 – 20:00',
    ),
    _place(
      name: 'Tam Tam Restaurant',
      category: 'restaurant',
      description:
          'Vibrant African restaurant celebrating diverse continental cuisines '
          'with live drumming performances and a festive atmosphere.',
      address: 'KK 15 Rd, Kicukiro',
      district: 'Kicukiro',
      lat: -1.9655,
      lng: 30.0868,
      phone: '+250 788 456 789',
      openingHours: 'Tue–Sun: 12:00 – 23:00',
    ),
  ];
}
