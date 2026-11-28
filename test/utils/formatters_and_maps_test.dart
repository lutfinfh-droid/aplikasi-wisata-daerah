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
      String? mapsUrl,
      double? latitude,
      double? longitude,
    }) {
      return Destination(
        id: '1',
        name: 'Pantai Gigi Hiu',
        regency: 'Tanggamus',
        category: 'Pantai',
        ticketPrice: 20000,
        openHours: '06.00 - 18.00 WIB',
        facilities: const ['Parkir'],
        description: 'Batu karang runcing tajam.',
        latitude: latitude,
        longitude: longitude,
        mapsUrl: mapsUrl,
      );
    }

    test('memprioritaskan mapsUrl jika tersedia', () {
      final uri = buildGoogleMapsUri(
        baseDestination(
          mapsUrl: 'https://maps.google.com/?q=Gigi+Hiu',
          latitude: -5.75,
          longitude: 104.90,
        ),
      );

      expect(uri.toString(), 'https://maps.google.com/?q=Gigi+Hiu');
    });

    test('menggunakan koordinat jika mapsUrl null', () {
      final uri = buildGoogleMapsUri(
        baseDestination(
          latitude: -5.75,
          longitude: 104.90,
        ),
      );

      expect(
        uri.toString(),
        'https://www.google.com/maps/search/?api=1&query=-5.75,104.9',
      );
    });

    test('fallback ke query pencarian jika mapsUrl dan koordinat null', () {
      final uri = buildGoogleMapsUri(baseDestination());

      expect(uri.toString(), contains('Pantai%20Gigi%20Hiu'));
      expect(uri.toString(), contains('Tanggamus'));
      expect(uri.toString(), contains('Lampung'));
    });
  });
}
