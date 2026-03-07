import 'package:cloud_firestore/cloud_firestore.dart';

// ---------------------------------------------------------------------------
// Represents a service or place listing in Kigali
// ---------------------------------------------------------------------------

class Place {
  final String id;
  final String name;
  final String category;
  final String description;
  final String address;
  final String district;
  final String? phone;
  final String? website;
  final String? openingHours;
  final double rating;
  final int ratingCount;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;
  final bool isVerified;
  final String createdBy;
  final String createdByName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Place({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.address,
    this.district = '',
    this.phone,
    this.website,
    this.openingHours,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.latitude,
    this.longitude,
    this.imageUrl,
    this.isVerified = false,
    required this.createdBy,
    this.createdByName = '',
    required this.createdAt,
    required this.updatedAt,
  });

  factory Place.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Place(
      id: doc.id,
      name: data['name'] as String? ?? '',
      category: data['category'] as String? ?? '',
      description: data['description'] as String? ?? '',
      address: data['address'] as String? ?? '',
      district: data['district'] as String? ?? '',
      phone: data['phone'] as String?,
      website: data['website'] as String?,
      openingHours: data['openingHours'] as String?,
      rating: (data['rating'] as num? ?? 0).toDouble(),
      ratingCount: data['ratingCount'] as int? ?? 0,
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      imageUrl: data['imageUrl'] as String?,
      isVerified: data['isVerified'] as bool? ?? false,
      createdBy: data['createdBy'] as String? ?? '',
      createdByName: data['createdByName'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'description': description,
      'address': address,
      'district': district,
      'phone': phone,
      'website': website,
      'openingHours': openingHours,
      'rating': rating,
      'ratingCount': ratingCount,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
      'isVerified': isVerified,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Place copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    String? address,
    String? district,
    String? phone,
    String? website,
    String? openingHours,
    double? rating,
    int? ratingCount,
    double? latitude,
    double? longitude,
    String? imageUrl,
    bool? isVerified,
    String? createdBy,
    String? createdByName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Place(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      address: address ?? this.address,
      district: district ?? this.district,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      openingHours: openingHours ?? this.openingHours,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      isVerified: isVerified ?? this.isVerified,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Place && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
