/// Model data destinasi wisata yang dipetakan dari tabel `destinations` Supabase.
class Destination {
  const Destination({
    required this.id,
    required this.name,
    required this.regency,
    required this.category,
    this.ticketPrice = 0,
    this.openHours = '08.00 - 17.00 WIB',
    this.facilities = const <String>[],
    this.description = '',
    this.imageUrl,
    this.mapsUrl,
    this.createdAt,
    // Kompatibilitas mundur
    this.district,
    this.address,
    this.ticketNotes,
    this.openingHours,
    this.accessibilityVehicle,
    this.accessibilityNotes,
    this.latitude,
    this.longitude,
    this.googleMapsUrl,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String regency;
  final String category;
  final int ticketPrice;
  final String openHours;
  final List<String> facilities;
  final String description;
  final String? imageUrl;
  final String? mapsUrl;
  final DateTime? createdAt;

  // Field getter pendukung kompatibilitas
  final String? district;
  final String? address;
  final String? ticketNotes;
  final String? openingHours;
  final String? accessibilityVehicle;
  final String? accessibilityNotes;
  final double? latitude;
  final double? longitude;
  final String? googleMapsUrl;
  final bool isActive;

  /// Helper untuk mengambil jam buka yang konsisten
  String get effectiveOpenHours {
    if (openHours.trim().isNotEmpty) return openHours;
    if (openingHours != null && openingHours!.trim().isNotEmpty) {
      return openingHours!;
    }
    return '08.00 - 17.00 WIB';
  }

  /// Helper untuk mengambil URL maps
  String? get effectiveMapsUrl {
    if (mapsUrl != null && mapsUrl!.trim().isNotEmpty) return mapsUrl;
    if (googleMapsUrl != null && googleMapsUrl!.trim().isNotEmpty) {
      return googleMapsUrl;
    }
    return null;
  }

  factory Destination.fromJson(Map<String, dynamic> json) {
    final rawFacilities = json['facilities'];
    final parsedFacilities = rawFacilities is List
        ? rawFacilities.map((item) => item.toString()).toList()
        : const <String>[];

    final parsedRegency = (json['regency'] ?? json['district'] ?? '').toString();
    final parsedHours = (json['open_hours'] ?? json['opening_hours'] ?? '08.00 - 17.00 WIB').toString();
    final parsedMapsUrl = (json['maps_url'] ?? json['google_maps_url'])?.toString();
    final parsedCreatedAt = json['created_at'] != null
        ? DateTime.tryParse(json['created_at'].toString())
        : null;

    return Destination(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      regency: parsedRegency,
      category: (json['category'] ?? '').toString(),
      ticketPrice: (json['ticket_price'] as num?)?.toInt() ?? 0,
      openHours: parsedHours,
      facilities: parsedFacilities,
      description: (json['description'] ?? '').toString(),
      imageUrl: json['image_url']?.toString(),
      mapsUrl: parsedMapsUrl,
      createdAt: parsedCreatedAt,
      // Kompatibilitas
      district: (json['district'] ?? parsedRegency).toString(),
      address: json['address']?.toString() ?? parsedRegency,
      ticketNotes: json['ticket_notes']?.toString(),
      openingHours: parsedHours,
      accessibilityVehicle: json['accessibility_vehicle']?.toString() ?? 'Motor & Mobil',
      accessibilityNotes: json['accessibility_notes']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      googleMapsUrl: parsedMapsUrl,
      isActive: (json['is_active'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'name': name.trim(),
      'regency': regency.trim(),
      'category': category.trim(),
      'ticket_price': ticketPrice,
      'open_hours': openHours.trim(),
      'facilities': facilities,
      'description': description.trim(),
      'image_url': (imageUrl != null && imageUrl!.trim().isNotEmpty) ? imageUrl!.trim() : null,
      'maps_url': (mapsUrl != null && mapsUrl!.trim().isNotEmpty) ? mapsUrl!.trim() : null,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return toInsertJson();
  }

  Destination copyWith({
    String? id,
    String? name,
    String? regency,
    String? category,
    int? ticketPrice,
    String? openHours,
    List<String>? facilities,
    String? description,
    String? imageUrl,
    String? mapsUrl,
    DateTime? createdAt,
  }) {
    return Destination(
      id: id ?? this.id,
      name: name ?? this.name,
      regency: regency ?? this.regency,
      category: category ?? this.category,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      openHours: openHours ?? this.openHours,
      facilities: facilities ?? this.facilities,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      mapsUrl: mapsUrl ?? this.mapsUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
