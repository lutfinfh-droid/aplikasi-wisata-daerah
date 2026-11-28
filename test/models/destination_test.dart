import 'package:flutter_test/flutter_test.dart';
import 'package:wisata_daerah/features/destinations/models/destination.dart';

void main() {
  group('Destination.fromJson', () {
    test('memetakan seluruh field tabel destinations Supabase dengan benar', () {
      final json = {
        'id': 101,
        'name': 'Pantai Pasir Putih Lampung',
        'regency': 'Bandar Lampung',
        'category': 'Pantai',
        'ticket_price': 15000,
        'open_hours': '07.00 - 18.00 WIB',
        'facilities': ['Parkir', 'Toilet', 'Gazebo', 'Warung Makan'],
        'description': 'Pantai pasir putih dekat pusat kota.',
        'image_url': 'https://example.com/pantai.jpg',
        'maps_url': 'https://maps.google.com/?q=Pasir+Putih',
        'created_at': '2026-11-28T10:00:00.000Z',
      };

      final destination = Destination.fromJson(json);

      expect(destination.id, '101');
      expect(destination.name, 'Pantai Pasir Putih Lampung');
      expect(destination.regency, 'Bandar Lampung');
      expect(destination.category, 'Pantai');
      expect(destination.ticketPrice, 15000);
      expect(destination.effectiveOpenHours, '07.00 - 18.00 WIB');
      expect(destination.facilities, ['Parkir', 'Toilet', 'Gazebo', 'Warung Makan']);
      expect(destination.description, 'Pantai pasir putih dekat pusat kota.');
      expect(destination.imageUrl, 'https://example.com/pantai.jpg');
      expect(destination.effectiveMapsUrl, 'https://maps.google.com/?q=Pasir+Putih');
      expect(destination.createdAt, isNotNull);
    });
  });
}
