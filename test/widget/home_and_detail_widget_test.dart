import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wisata_daerah/features/destinations/data/destination_repository.dart';
import 'package:wisata_daerah/features/destinations/models/destination.dart';
import 'package:wisata_daerah/features/destinations/screens/home_screen.dart';

class _FakeRepo implements DestinationRepository {
  @override
  Future<List<Destination>> fetchDestinations() async {
    return const [
      Destination(
        id: '1',
        name: 'Pantai Tanjung Tinggi',
        category: 'Pantai',
        district: 'Kec. Sijuk',
        address: 'Desa Keciput, Kab. Belitung',
        description: 'Pantai berpasir putih dengan batu granit.',
        ticketPrice: 0,
        openingHours: '06.00 - 18.00 WIB',
        facilities: ['Parkir Luas', 'Toilet'],
        accessibilityVehicle: 'Motor, Mobil & Bus',
        accessibilityNotes: 'Jalan beraspal mulus.',
        imageUrl: 'https://example.com/pantai.jpg',
      ),
    ];
  }
}

void main() {
  testWidgets('HomeScreen menampilkan destinasi dan membuka halaman detail',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(repository: _FakeRepo()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Pantai Tanjung Tinggi'), findsOneWidget);
    expect(find.text('Gratis'), findsOneWidget);

    await tester.tap(find.text('Pantai Tanjung Tinggi'));
    await tester.pumpAndSettle();

    expect(find.text('Desa Keciput, Kab. Belitung'), findsOneWidget);
    expect(find.text('06.00 - 18.00 WIB'), findsOneWidget);
    expect(find.text('Parkir Luas'), findsOneWidget);
    expect(find.text('Motor, Mobil & Bus'), findsOneWidget);
    expect(find.text('Buka di Google Maps'), findsOneWidget);
  });
}
