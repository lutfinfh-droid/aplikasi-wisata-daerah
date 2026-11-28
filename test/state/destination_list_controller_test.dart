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
  final sampleItems = [
    const Destination(
      id: '1',
      name: 'Pantai Pasir Putih',
      regency: 'Bandar Lampung',
      category: 'Pantai',
      ticketPrice: 15000,
      openHours: '07.00 - 18.00 WIB',
      facilities: ['Parkir', 'Gazebo'],
      description: 'Pantai pasir putih indah.',
    ),
    const Destination(
      id: '2',
      name: 'Pulau Pahawang',
      regency: 'Pesawaran',
      category: 'Bahari',
      ticketPrice: 30000,
      openHours: '24 Jam',
      facilities: ['Snorkeling', 'Perahu'],
      description: 'Snorkeling terumbu karang.',
    ),
    const Destination(
      id: '3',
      name: 'Menara Siger',
      regency: 'Lampung Selatan',
      category: 'Budaya & Sejarah',
      ticketPrice: 10000,
      openHours: '06.00 - 20.00 WIB',
      facilities: ['Parkir Luas', 'Museum Mini'],
      description: 'Monumen mahkota Lampung.',
    ),
  ];

  group('DestinationListController', () {
    test('berhasil memuat data destinasi dari repository', () async {
      final repo = _FakeDestinationRepository(items: sampleItems);
      final controller = DestinationListController(repository: repo);

      expect(controller.isLoading, isFalse);
      expect(controller.allDestinations, isEmpty);

      final future = controller.loadDestinations();
      expect(controller.isLoading, isTrue);

      await future;
      expect(controller.isLoading, isFalse);
      expect(controller.allDestinations.length, 3);
      expect(controller.errorMessage, isNull);
    });

    test('memfilter berdasarkan regency (kabupaten/kota)', () async {
      final repo = _FakeDestinationRepository(items: sampleItems);
      final controller = DestinationListController(repository: repo);
      await controller.loadDestinations();

      controller.setRegency('Pesawaran');
      expect(controller.filteredDestinations.length, 1);
      expect(controller.filteredDestinations.first.name, 'Pulau Pahawang');

      controller.setRegency('Semua Wilayah');
      expect(controller.filteredDestinations.length, 3);
    });

    test('memfilter berdasarkan pencarian teks dan kategori', () async {
      final repo = _FakeDestinationRepository(items: sampleItems);
      final controller = DestinationListController(repository: repo);
      await controller.loadDestinations();

      controller.setSearchQuery('siger');
      expect(controller.filteredDestinations.length, 1);
      expect(controller.filteredDestinations.first.name, 'Menara Siger');

      controller.setSearchQuery('');
      controller.setCategory('Pantai');
      expect(controller.filteredDestinations.length, 1);
      expect(controller.filteredDestinations.first.name, 'Pantai Pasir Putih');
    });

    test('mengelompokkan destinasi berdasarkan kabupaten saat Semua Wilayah aktif', () async {
      final repo = _FakeDestinationRepository(items: sampleItems);
      final controller = DestinationListController(repository: repo);
      await controller.loadDestinations();

      final grouped = controller.groupedDestinations;
      expect(grouped.containsKey('Bandar Lampung'), isTrue);
      expect(grouped.containsKey('Pesawaran'), isTrue);
      expect(grouped.containsKey('Lampung Selatan'), isTrue);
      expect(grouped['Bandar Lampung']!.length, 1);
    });
  });
}
