import 'package:flutter_test/flutter_test.dart';
import 'package:wisata_daerah/core/utils/formatters.dart';
import 'package:wisata_daerah/core/utils/maps_launcher.dart';
import 'package:wisata_daerah/features/destinations/models/destination.dart';

void main() {
  group('formatTicketPrice', () {
    test('mengembalikan Gratis jika harga 0 atau negatif', () {
      expect(formatTicketPrice(0), 'Gratis');
      expect(formatTicketPrice(-500), 'Gratis');
    });

    test('memformat harga positif ke Rupiah Indonesia', () {
      expect(formatTicketPrice(15000), 'Rp 15.000');
    });
  });

  group('buildGoogleMapsUri', () {
    Destination baseDestination({
      String? googleMapsUrl,
      double? latitude,
      double? longitude,
    }) {
      return Destination(
        id: '1',
        name: 'Bukit Mangunan',
        category: 'Alam/Bukit',
        district: 'Kec. Dlingo',
        address: 'Mangunan, Bantul, DIY',
        description: 'Gardu pandang.',
        ticketPrice: 5000,
        openingHours: '05.00 - 18.00 WIB',
        facilities: const ['Parkir'],
        accessibilityVehicle: 'Motor & Mobil',
        accessibilityNotes: 'Jalan menanjak.',
        imageUrl: 'https://example.com/bukit.jpg',
        latitude: latitude,
        longitude: longitude,
        googleMapsUrl: googleMapsUrl,
      );
    }

    test('memprioritaskan googleMapsUrl jika tersedia', () {
      final uri = buildGoogleMapsUri(
        baseDestination(
          googleMapsUrl: 'https://maps.app.goo.gl/contoh123',
          latitude: -7.94,
          longitude: 110.42,
        ),
      );
      expect(uri.toString(), 'https://maps.app.goo.gl/contoh123');
    });

    test('menggunakan koordinat jika googleMapsUrl kosong', () {
      final uri = buildGoogleMapsUri(
        baseDestination(latitude: -7.94, longitude: 110.42),
      );
      expect(
        uri.toString(),
        'https://www.google.com/maps/search/?api=1&query=-7.94,110.42',
      );
    });

    test('fallback ke pencarian nama dan alamat jika koordinat null', () {
      final uri = buildGoogleMapsUri(baseDestination());
      expect(
        uri.toString(),
        contains('https://www.google.com/maps/search/?api=1&query='),
      );
      expect(uri.toString(), contains('Bukit'));
    });
  });
}
