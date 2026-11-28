import 'package:flutter/material.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/utils/maps_launcher.dart';
import '../models/destination.dart';
import '../widgets/destination_form_dialog.dart';
import '../widgets/smart_destination_image.dart';

class DestinationDetailScreen extends StatefulWidget {
  const DestinationDetailScreen({
    super.key,
    required this.destination,
    this.onUpdate,
    this.onDelete,
  });

  final Destination destination;
  final Future<void> Function(Destination destination)? onUpdate;
  final Future<void> Function(String id)? onDelete;

  @override
  State<DestinationDetailScreen> createState() => _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  late Destination _currentDestination;

  @override
  void initState() {
    super.initState();
    _currentDestination = widget.destination;
  }

  Future<void> _openMaps() async {
    final launched = await openInGoogleMaps(_currentDestination);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat membuka Google Maps di perangkat ini.'),
        ),
      );
    }
  }

  Future<void> _handleEdit() async {
    await showDialog<bool>(
      context: context,
      builder: (_) => DestinationFormDialog(
        destination: _currentDestination,
        onSave: (updated) async {
          if (widget.onUpdate != null) {
            await widget.onUpdate!(updated);
          }
          if (mounted) {
            setState(() => _currentDestination = updated);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Destinasi berhasil diperbarui')),
            );
          }
        },
      ),
    );
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Destinasi?'),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${_currentDestination.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      if (widget.onDelete != null) {
        await widget.onDelete!(_currentDestination.id);
      }
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Destinasi berhasil dihapus')),
        );
      }
    }
  }

  IconData _facilityIcon(String facility) {
    final lower = facility.toLowerCase();
    if (lower.contains('parkir')) return Icons.local_parking_rounded;
    if (lower.contains('toilet') || lower.contains('wc')) {
      return Icons.wc_rounded;
    }
    if (lower.contains('mushola') || lower.contains('masjid')) {
      return Icons.mosque_rounded;
    }
    if (lower.contains('warung') ||
        lower.contains('kuliner') ||
        lower.contains('kafe') ||
        lower.contains('makan')) {
      return Icons.restaurant_rounded;
    }
    if (lower.contains('wifi')) return Icons.wifi_rounded;
    if (lower.contains('penginapan') || lower.contains('hotel') || lower.contains('camp')) {
      return Icons.hotel_rounded;
    }
    if (lower.contains('foto') || lower.contains('spot')) {
      return Icons.camera_alt_rounded;
    }
    if (lower.contains('perahu') || lower.contains('kano') || lower.contains('snorkeling') || lower.contains('selancar')) {
      return Icons.sailing_rounded;
    }
    if (lower.contains('gazebo') || lower.contains('saung')) {
      return Icons.deck_rounded;
    }
    return Icons.check_circle_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final regencyText = _currentDestination.regency.trim().isNotEmpty
        ? _currentDestination.regency.trim()
        : (_currentDestination.district?.trim() ?? 'Lampung');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF0F766E),
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                tooltip: 'Edit Destinasi',
                icon: const Icon(Icons.edit_outlined),
                onPressed: _handleEdit,
              ),
              IconButton(
                tooltip: 'Hapus Destinasi',
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: _handleDelete,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  SmartDestinationImage(
                    imageUrl: _currentDestination.imageUrl,
                    destinationName: _currentDestination.name,
                    regency: regencyText,
                    fit: BoxFit.cover,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.35),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                  if (_currentDestination.category.isNotEmpty)
                    Positioned(
                      left: 16,
                      bottom: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F766E),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _currentDestination.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentDestination.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 18,
                        color: Color(0xFF0F766E),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '$regencyText, Provinsi Lampung',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475569),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Kartu ringkasan harga tiket & jam operasional berdampingan
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryInfoCard(
                          icon: Icons.confirmation_number_rounded,
                          iconColor: const Color(0xFF059669),
                          label: 'Harga Tiket',
                          value: formatTicketPrice(
                            _currentDestination.ticketPrice,
                          ),
                          subtitle: _currentDestination.ticketNotes,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryInfoCard(
                          icon: Icons.schedule_rounded,
                          iconColor: const Color(0xFF0F766E),
                          label: 'Jam Operasional',
                          value: _currentDestination.effectiveOpenHours,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Tentang Destinasi',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentDestination.description.isEmpty
                        ? 'Destinasi wisata unggulan di $regencyText, Provinsi Lampung.'
                        : _currentDestination.description,
                    style: const TextStyle(
                      fontSize: 14.5,
                      color: Color(0xFF334155),
                      height: 1.6,
                    ),
                  ),
                  if (_currentDestination.facilities.isNotEmpty) ...[
                    const SizedBox(height: 22),
                    const Text(
                      'Fasilitas Tersedia',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _currentDestination.facilities.map((facility) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _facilityIcon(facility),
                                size: 16,
                                color: const Color(0xFF0F766E),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                facility,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: _openMaps,
              icon: const Icon(Icons.directions_rounded),
              label: const Text(
                'Buka Rute di Google Maps',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryInfoCard extends StatelessWidget {
  const _SummaryInfoCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
