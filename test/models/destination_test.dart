import 'package:flutter_test/flutter_test.dart';
import 'package:wisata_daerah/features/destinations/models/destination.dart';

void main() {
  group('Destination.fromJson', () {
    test('memetakan seluruh field dari Supabase dengan benar', () {
      final json = {
        'id': '123',
        'name': 'Pantai Tanjung Tinggi',
        'category': 'Pantai',
        'district': 'Kec. Sijuk',
        'address': 'Desa Keciput, Kab. Belitung',
        'description': 'Pantai berbatu granit.',
        'ticket_price': 15000,
        'ticket_notes': 'Parkir motor Rp 3.000',
        'opening_hours': '06.00 - 18.00 WIB',
        'facilities': ['Parkir', 'Toilet', 'Mushola'],
        'accessibility_vehicle': 'Motor & Mobil',
        'accessibility_notes': 'Jalan beraspal mulus.',
        'image_url': 'https://example.com/pantai.jpg',
        'latitude': -2.5536,
        'longitude': 107.7097,
        'google_maps_url': null,
        'is_active': true,
      };

      final destination = Destination.fromJson(json);

      expect(destination.id, '123');
      expect(destination.name, 'Pantai Tanjung Tinggi');
      expect(destination.ticketPrice, 15000);
      expect(destination.facilities, ['Parkir', 'Toilet', 'Mushola']);
      expect(destination.latitude, -2.5536);
      expect(destination.longitude, 107.7097);
      expect(destination.googleMapsUrl, isNull);
      expect(destination.isActive, isTrue);
    });
  });
}
