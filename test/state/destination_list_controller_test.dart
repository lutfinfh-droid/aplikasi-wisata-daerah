import 'package:flutter_test/flutter_test.dart';
import 'package:wisata_daerah/features/destinations/data/destination_repository.dart';
import 'package:wisata_daerah/features/destinations/models/destination.dart';
import 'package:wisata_daerah/features/destinations/state/destination_list_controller.dart';

class _FakeDestinationRepository implements DestinationRepository {
  _FakeDestinationRepository({this.items = const [], this.shouldThrow = false});

  final List<Destination> items;
  final bool shouldThrow;

  @override
  Future<List<Destination>> fetchDestinations() async {
    if (shouldThrow) {
      throw Exception('Network error');
    }
    return items;
  }
}

void main() {
  final sampleItems = [
    const Destination(
      id: '1',
      name: 'Pantai Melasti',
      category: 'Pantai',
      district: 'Kec. Kuta Selatan',
      address: 'Ungasan, Bali',
      description: 'Pantai tebing kapur.',
      ticketPrice: 10000,
      openingHours: '06.00 - 19.00',
      facilities: ['Parkir'],
      accessibilityVehicle: 'Motor & Mobil',
      accessibilityNotes: 'Jalan aspal lebar.',
      imageUrl: 'https://example.com/1.jpg',
    ),
    const Destination(
      id: '2',
      name: 'Museum Angkut',
      category: 'Edukasi',
      district: 'Kec. Batu',
      address: 'Kota Batu, Jawa Timur',
      description: 'Museum transportasi.',
      ticketPrice: 100000,
      openingHours: '12.00 - 20.00',
      facilities: ['Parkir', 'Toilet'],
      accessibilityVehicle: 'Motor, Mobil & Bus',
      accessibilityNotes: 'Akses jalan utama.',
      imageUrl: 'https://example.com/2.jpg',
    ),
  ];

  test('memuat destinasi dan memfilter berdasarkan kategori & pencarian',
      () async {
    final controller = DestinationListController(
      repository: _FakeDestinationRepository(items: sampleItems),
    );

    await controller.loadDestinations();
    expect(controller.filteredDestinations.length, 2);

    controller.setCategory('Pantai');
    expect(controller.filteredDestinations.length, 1);
    expect(controller.filteredDestinations.first.name, 'Pantai Melasti');

    controller.setCategory('Semua');
    controller.setSearchQuery('Batu');
    expect(controller.filteredDestinations.length, 1);
    expect(controller.filteredDestinations.first.name, 'Museum Angkut');

    controller.resetFilters();
    expect(controller.filteredDestinations.length, 2);
  });

  test('menangani error repository dengan pesan ramah pengguna', () async {
    final controller = DestinationListController(
      repository: _FakeDestinationRepository(shouldThrow: true),
    );

    await controller.loadDestinations();
    expect(controller.errorMessage, isNotNull);
    expect(controller.allDestinations, isEmpty);
  });
}
