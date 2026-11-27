import 'package:flutter/foundation.dart';

import '../data/destination_repository.dart';
import '../models/destination.dart';

/// Controller state untuk halaman Beranda (daftar, pencarian, dan filter kategori).
class DestinationListController extends ChangeNotifier {
  DestinationListController({required DestinationRepository repository})
      : _repository = repository;

  final DestinationRepository _repository;

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
  String _selectedCategory = 'Semua';
  bool _isLoading = false;
  String? _errorMessage;

  List<Destination> get allDestinations => _allDestinations;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Destination> get filteredDestinations {
    final query = _searchQuery.trim().toLowerCase();
    return _allDestinations.where((item) {
      final matchesCategory =
          _selectedCategory == 'Semua' || item.category == _selectedCategory;
      if (!matchesCategory) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      return item.name.toLowerCase().contains(query) ||
          item.district.toLowerCase().contains(query) ||
          item.address.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> loadDestinations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allDestinations = await _repository.fetchDestinations();
    } catch (e) {
      _errorMessage = 'Gagal memuat data destinasi. Periksa koneksi internet Anda.';
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

  void setCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = '';
    _selectedCategory = 'Semua';
    notifyListeners();
  }
}
