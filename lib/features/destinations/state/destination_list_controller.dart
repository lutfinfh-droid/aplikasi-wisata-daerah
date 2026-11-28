import 'package:flutter/foundation.dart';

import '../data/destination_repository.dart';
import '../models/destination.dart';

/// Controller state untuk halaman Beranda Jelajah Wisata Lampung.
class DestinationListController extends ChangeNotifier {
  DestinationListController({required DestinationRepository repository})
      : _repository = repository;

  final DestinationRepository _repository;

  static const String allRegionsLabel = 'Semua Wilayah';

  static const List<String> lampungRegencies = [
    'Bandar Lampung',
    'Pesawaran',
    'Lampung Selatan',
    'Tanggamus',
    'Pesisir Barat',
    'Lampung Timur',
    'Lampung Barat',
    'Way Kanan',
    'Pringsewu',
    'Lampung Tengah',
    'Metro',
    'Lampung Utara',
    'Tulang Bawang',
    'Tulang Bawang Barat',
    'Mesuji',
  ];

  static const List<String> categories = [
    'Semua',
    'Pantai',
    'Bahari',
    'Air Terjun',
    'Gunung & Bukit',
    'Taman & Edukasi',
    'Budaya & Sejarah',
    'Kuliner & Kota',
  ];

  List<Destination> _allDestinations = const [];
  String _searchQuery = '';
  String _selectedRegency = allRegionsLabel;
  String _selectedCategory = 'Semua';
  bool _isLoading = false;
  String? _errorMessage;

  List<Destination> get allDestinations => _allDestinations;
  String get searchQuery => _searchQuery;
  String get selectedRegency => _selectedRegency;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String _cleanRegency(Destination item) {
    final reg = item.regency.trim();
    if (reg.isNotEmpty) return reg;
    final dist = item.district?.trim() ?? '';
    return dist.isNotEmpty ? dist : 'Lainnya';
  }

  /// Daftar pilihan wilayah horizontal: "Semua Wilayah" lalu 15 Kabupaten/Kota.
  List<String> get availableRegencies {
    final list = <String>[allRegionsLabel];
    list.addAll(lampungRegencies);

    // Tambahkan regency lain jika ada di database tapi belum masuk lampungRegencies
    final presentOther = _allDestinations
        .map(_cleanRegency)
        .where((r) => !lampungRegencies.contains(r) && r != 'Lainnya')
        .toSet()
        .toList()
      ..sort();

    list.addAll(presentOther);
    return list;
  }

  List<Destination> get filteredDestinations {
    final query = _searchQuery.trim().toLowerCase();
    return _allDestinations.where((item) {
      final regency = _cleanRegency(item);

      // Filter wilayah
      final matchesRegency =
          _selectedRegency == allRegionsLabel || regency == _selectedRegency;
      if (!matchesRegency) return false;

      // Filter kategori
      final matchesCategory =
          _selectedCategory == 'Semua' || item.category == _selectedCategory;
      if (!matchesCategory) return false;

      if (query.isEmpty) return true;

      // Search query mencocokkan nama, kabupaten, kategori, atau deskripsi
      return item.name.toLowerCase().contains(query) ||
          regency.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query);
    }).toList();
  }

  /// Mengelompokkan destinasi berdasarkan Kabupaten/Kota secara terurut rapi.
  Map<String, List<Destination>> get groupedDestinations {
    final grouped = <String, List<Destination>>{};
    for (final item in filteredDestinations) {
      final reg = _cleanRegency(item);
      grouped.putIfAbsent(reg, () => []).add(item);
    }

    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        final idxA = lampungRegencies.indexOf(a);
        final idxB = lampungRegencies.indexOf(b);
        if (idxA != -1 && idxB != -1) return idxA.compareTo(idxB);
        if (idxA != -1) return -1;
        if (idxB != -1) return 1;
        return a.compareTo(b);
      });

    return {for (final key in sortedKeys) key: grouped[key]!};
  }

  Future<void> loadDestinations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allDestinations = await _repository.fetchDestinations();
    } catch (e) {
      _errorMessage =
          'Gagal memuat data destinasi. Periksa koneksi internet Anda.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addDestination(Destination destination) async {
    final created = await _repository.createDestination(destination);
    _allDestinations = [created, ..._allDestinations];
    notifyListeners();
  }

  Future<void> updateDestination(Destination destination) async {
    final updated = await _repository.updateDestination(destination);
    _allDestinations = _allDestinations
        .map((item) => item.id == updated.id ? updated : item)
        .toList();
    notifyListeners();
  }

  Future<void> deleteDestination(String id) async {
    await _repository.deleteDestination(id);
    _allDestinations =
        _allDestinations.where((item) => item.id != id).toList();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    notifyListeners();
  }

  void setRegency(String regency) {
    if (_selectedRegency == regency) return;
    _selectedRegency = regency;
    notifyListeners();
  }

  void setCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = '';
    _selectedRegency = allRegionsLabel;
    _selectedCategory = 'Semua';
    notifyListeners();
  }
}
