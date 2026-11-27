/// Model data destinasi wisata yang dipetakan dari tabel `destinations` Supabase.
class Destination {
  const Destination({
    required this.id,
    required this.name,
    required this.category,
    this.regency = '',
    required this.district,
    required this.address,
    required this.description,
    required this.ticketPrice,
    this.ticketNotes,
    required this.openingHours,
    required this.facilities,
    required this.accessibilityVehicle,
    required this.accessibilityNotes,
    required this.imageUrl,
    this.latitude,
    this.longitude,
    this.googleMapsUrl,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String category;
  final String regency;
  final String district;
  final String address;
  final String description;
  final int ticketPrice;
  final String? ticketNotes;
  final String openingHours;
  final List<String> facilities;
  final String accessibilityVehicle;
  final String accessibilityNotes;
  final String imageUrl;
  final double? latitude;
  final double? longitude;
  final String? googleMapsUrl;
  final bool isActive;

  factory Destination.fromJson(Map<String, dynamic> json) {
    final rawFacilities = json['facilities'];
    final parsedFacilities = rawFacilities is List
        ? rawFacilities.map((item) => item.toString()).toList()
        : const <String>[];

    final parsedRegency = (json['regency'] ?? json['district'] ?? '').toString();

    return Destination(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      regency: parsedRegency,
      district: (json['district'] ?? parsedRegency).toString(),
      address: (json['address'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      ticketPrice: (json['ticket_price'] as num?)?.toInt() ?? 0,
      ticketNotes: json['ticket_notes']?.toString(),
      openingHours: (json['opening_hours'] ?? '').toString(),
      facilities: parsedFacilities,
      accessibilityVehicle: (json['accessibility_vehicle'] ?? '').toString(),
      accessibilityNotes: (json['accessibility_notes'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? '').toString(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      googleMapsUrl: json['google_maps_url']?.toString(),
      isActive: (json['is_active'] as bool?) ?? true,
    );
  }
}
