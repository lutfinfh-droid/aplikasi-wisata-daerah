import 'package:flutter/material.dart';

import '../data/destination_repository.dart';
import '../models/destination.dart';
import '../state/destination_list_controller.dart';
import '../widgets/destination_card.dart';
import 'destination_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.repository});

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

  void _openDetail(Destination destination) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DestinationDetailScreen(destination: destination),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return RefreshIndicator(
            onRefresh: _controller.loadDestinations,
            color: const Color(0xFF0F766E),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeaderBanner()),
                SliverToBoxAdapter(child: _buildRegencyFilterBar()),
                ..._buildBodySlivers(),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderBanner() {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(20, topPadding + 20, 20, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF064E3B), // Emerald 900
            Color(0xFF0F766E), // Teal 700
          ],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.explore_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jelajah Wisata Lampung',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Eksplorasi destinasi terbaik di Bumi Ruwa Jurai',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFFCCFBF1),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _controller.setSearchQuery,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Cari nama wisata atau kabupaten...',
                hintStyle: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF0F766E),
                ),
                suffixIcon: _controller.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          _controller.setSearchQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegencyFilterBar() {
    final regencies = _controller.availableRegencies;
    return SizedBox(
      height: 58,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        scrollDirection: Axis.horizontal,
        itemCount: regencies.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final regency = regencies[index];
          final selected = _controller.selectedRegency == regency;
          return ChoiceChip(
            label: Text(regency),
            selected: selected,
            onSelected: (_) => _controller.setRegency(regency),
            showCheckmark: false,
            selectedColor: const Color(0xFF0F766E),
            backgroundColor: Colors.white,
            side: BorderSide(
              color: selected
                  ? const Color(0xFF0F766E)
                  : const Color(0xFFE2E8F0),
            ),
            labelStyle: TextStyle(
              color: selected ? Colors.white : const Color(0xFF334155),
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 13,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildBodySlivers() {
    if (_controller.isLoading && _controller.allDestinations.isEmpty) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: CircularProgressIndicator(color: Color(0xFF0F766E)),
          ),
        ),
      ];
    }

    if (_controller.errorMessage != null &&
        _controller.allDestinations.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.wifi_off_rounded,
                    size: 52,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _controller.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF475569)),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _controller.loadDestinations,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Coba Lagi'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0F766E),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ];
    }

    final filtered = _controller.filteredDestinations;
    if (filtered.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.search_off_rounded,
                    size: 52,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Destinasi tidak ditemukan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Coba ubah kata kunci pencarian atau pilih wilayah lain.',
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
          ),
        ),
      ];
    }

    // Jika "Semua Wilayah" aktif, tampilkan dikelompokkan per Kabupaten/Kota
    if (_controller.selectedRegency ==
        DestinationListController.allRegionsLabel) {
      final grouped = _controller.groupedDestinations;
      final slivers = <Widget>[];
      for (final entry in grouped.entries) {
        slivers.add(
          SliverToBoxAdapter(
            child: _RegencySectionHeader(
              regencyName: entry.key,
              count: entry.value.length,
            ),
          ),
        );
        slivers.add(
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList.builder(
              itemCount: entry.value.length,
              itemBuilder: (context, index) {
                final item = entry.value[index];
                return DestinationCard(
                  destination: item,
                  onTap: () => _openDetail(item),
                );
              },
            ),
          ),
        );
      }
      return slivers;
    }

    // Jika kabupaten tertentu dipilih, tampilkan daftar wisata kabupaten tersebut
    return [
      SliverToBoxAdapter(
        child: _RegencySectionHeader(
          regencyName: _controller.selectedRegency,
          count: filtered.length,
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverList.builder(
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final item = filtered[index];
            return DestinationCard(
              destination: item,
              onTap: () => _openDetail(item),
            );
          },
        ),
      ),
    ];
  }
}

class _RegencySectionHeader extends StatelessWidget {
  const _RegencySectionHeader({
    required this.regencyName,
    required this.count,
  });

  final String regencyName;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFCCFBF1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              size: 16,
              color: Color(0xFF0F766E),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              regencyName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count destinasi',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
