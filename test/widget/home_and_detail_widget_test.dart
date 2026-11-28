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
        name: 'Pantai Pasir Putih Lampung',
        regency: 'Bandar Lampung',
        category: 'Pantai',
        ticketPrice: 0,
        openHours: '07.00 - 18.00 WIB',
        facilities: ['Parkir', 'Gazebo'],
        description: 'Pantai pasir putih dekat kota.',
      ),
    ];
  }

  @override
  Future<Destination> createDestination(Destination destination) async {
    return destination;
  }

  @override
  Future<Destination> updateDestination(Destination destination) async {
    return destination;
  }

  @override
  Future<void> deleteDestination(String id) async {}
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

    expect(find.text('Jelajah Wisata Lampung'), findsOneWidget);
    expect(find.text('Pantai Pasir Putih Lampung'), findsOneWidget);
    expect(find.text('Gratis'), findsOneWidget);

    await tester.tap(find.text('Pantai Pasir Putih Lampung'));
    await tester.pumpAndSettle();

    expect(find.text('Bandar Lampung, Provinsi Lampung'), findsOneWidget);
    expect(find.text('07.00 - 18.00 WIB'), findsOneWidget);
    expect(find.text('Parkir'), findsOneWidget);
    expect(find.text('Buka Rute di Google Maps'), findsOneWidget);
  });
}
