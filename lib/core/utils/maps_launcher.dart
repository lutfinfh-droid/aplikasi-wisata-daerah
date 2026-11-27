import 'package:url_launcher/url_launcher.dart';

import '../../features/destinations/models/destination.dart';

/// Membangun URI Google Maps dengan prioritas:
/// 1. `googleMapsUrl` jika tersedia dan valid
/// 2. Koordinat `latitude` & `longitude`
/// 3. Fallback pencarian nama destinasi + alamat
Uri buildGoogleMapsUri(Destination destination) {
  final customUrl = destination.googleMapsUrl?.trim();
  if (customUrl != null && customUrl.isNotEmpty) {
    final parsed = Uri.tryParse(customUrl);
    if (parsed != null && parsed.hasScheme) {
      return parsed;
    }
  }

  if (destination.latitude != null && destination.longitude != null) {
    final lat = destination.latitude!;
    final lng = destination.longitude!;
    return Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
  }

  final query = Uri.encodeComponent(
    '${destination.name}, ${destination.address}',
  );
  return Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
}

/// Membuka lokasi destinasi di aplikasi Google Maps eksternal (atau browser).
Future<bool> openInGoogleMaps(Destination destination) async {
  final uri = buildGoogleMapsUri(destination);
  return launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  );
}
