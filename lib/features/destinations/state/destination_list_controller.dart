import 'package:flutter/foundation.dart';

import '../data/destination_repository.dart';
import '../models/destination.dart';

/// Controller state untuk halaman Beranda (daftar, pencarian, dan filter wilayah/kabupaten).
class DestinationListController extends ChangeNotifier {
  DestinationListController({required DestinationRepository repository})
      : _repository = repository;

  final DestinationRepository _repository;

  static const String allRegionsLabel = 'Semua Wilayah';

  static const List<String> knownRegencies = [
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
    'Mesuji',
  ];

  static const List<String> defaultCategories = [
    'Semua',
    'Pantai',
    'Alam/Bukit',
    'Edukasi',
    'Kuliner',
    'Budaya',
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

  String _regencyOf(Destination item) {
    final value = item.regency.trim().isNotEmpty
        ? item.regency.trim()
        : item.district.trim();
    return value.isEmpty ? 'Lainnya' : value;
  }

  /// Daftar wilayah yang tersedia di database, diawali "Semua Wilayah".
  List<String> get availableRegencies {
    final present = _allDestinations.map(_regencyOf).toSet();
    final ordered = <String>[allRegionsLabel];

    for (final regency in knownRegencies) {
      if (present.contains(regency)) {
        ordered.add(regency);
      }
    }

    final extras = present
        .where((r) => !knownRegencies.contains(r))
        .toList()
      ..sort();
    ordered.addAll(extras);

    return ordered;
  }

  List<Destination> get filteredDestinations {
    final query = _searchQuery.trim().toLowerCase();
    return _allDestinations.where((item) {
      final regency = _regencyOf(item);
      final matchesRegency =
          _selectedRegency == allRegionsLabel || regency == _selectedRegency;
      if (!matchesRegency) return false;

      final matchesCategory =
          _selectedCategory == 'Semua' || item.category == _selectedCategory;
      if (!matchesCategory) return false;

      if (query.isEmpty) return true;

      return item.name.toLowerCase().contains(query) ||
          regency.toLowerCase().contains(query) ||
          item.district.toLowerCase().contains(query) ||
          item.address.toLowerCase().contains(query);
    }).toList();
  }

  /// Mengelompokkan destinasi hasil filter berdasarkan Kabupaten/Kota.
  Map<String, List<Destination>> get groupedDestinations {
    final grouped = <String, List<Destination>>{};
    for (final item in filteredDestinations) {
      final key = _regencyOf(item);
      grouped.putIfAbsent(key, () => []).add(item);
    }

    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        final idxA = knownRegencies.indexOf(a);
        final idxB = knownRegencies.indexOf(b);
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
