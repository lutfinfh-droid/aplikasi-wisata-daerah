import 'package:flutter/material.dart';

import '../data/destination_repository.dart';
import '../state/destination_list_controller.dart';
import '../widgets/destination_card.dart';
import 'destination_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.repository,
  });

  final DestinationRepository repository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final DestinationListController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = DestinationListController(repository: widget.repository);
    _controller.loadDestinations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Direktori Wisata Daerah',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
            ),
            Text(
              'Temukan destinasi & rute tercepat',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: _controller.setSearchQuery,
                      decoration: InputDecoration(
                        hintText: 'Cari nama wisata atau kecamatan...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _controller.searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  _controller.setSearchQuery('');
                                },
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount:
                            DestinationListController.defaultCategories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final category =
                              DestinationListController.defaultCategories[index];
                          final isSelected =
                              _controller.selectedCategory == category;
                          return ChoiceChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (_) => _controller.setCategory(category),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: _buildBody()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading && _controller.allDestinations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.errorMessage != null &&
        _controller.allDestinations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 52, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                _controller.errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _controller.loadDestinations,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final items = _controller.filteredDestinations;
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off_rounded, size: 52, color: Colors.grey),
              const SizedBox(height: 12),
              const Text(
                'Destinasi tidak ditemukan.',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 6),
              const Text(
                'Coba ubah kata kunci pencarian atau pilih kategori lain.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  _searchController.clear();
                  _controller.resetFilters();
                },
                child: const Text('Reset Filter'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _controller.loadDestinations,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final destination = items[index];
          return DestinationCard(
            destination: destination,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      DestinationDetailScreen(destination: destination),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
