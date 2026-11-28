import 'package:flutter/material.dart';

import '../models/destination.dart';
import '../state/destination_list_controller.dart';

class DestinationFormDialog extends StatefulWidget {
  const DestinationFormDialog({
    super.key,
    this.destination,
    required this.onSave,
  });

  final Destination? destination;
  final Future<void> Function(Destination destination) onSave;

  @override
  State<DestinationFormDialog> createState() => _DestinationFormDialogState();
}

class _DestinationFormDialogState extends State<DestinationFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _openHoursController;
  late final TextEditingController _facilitiesController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _mapsUrlController;

  late String _selectedRegency;
  late String _selectedCategory;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final d = widget.destination;

    _nameController = TextEditingController(text: d?.name ?? '');
    _priceController = TextEditingController(
      text: d != null ? d.ticketPrice.toString() : '0',
    );
    _openHoursController = TextEditingController(
      text: d?.effectiveOpenHours ?? '08.00 - 17.00 WIB',
    );
    _facilitiesController = TextEditingController(
      text: d != null ? d.facilities.join(', ') : 'Parkir, Toilet, Gazebo',
    );
    _descriptionController = TextEditingController(text: d?.description ?? '');
    _imageUrlController = TextEditingController(text: d?.imageUrl ?? '');
    _mapsUrlController = TextEditingController(text: d?.effectiveMapsUrl ?? '');

    final existingRegency = d?.regency.trim() ?? '';
    _selectedRegency = DestinationListController.lampungRegencies.contains(existingRegency)
        ? existingRegency
        : DestinationListController.lampungRegencies.first;

    final existingCat = d?.category.trim() ?? '';
    final validCategories = DestinationListController.categories.where((c) => c != 'Semua').toList();
    _selectedCategory = validCategories.contains(existingCat)
        ? existingCat
        : validCategories.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _openHoursController.dispose();
    _facilitiesController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _mapsUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final facilitiesList = _facilitiesController.text
          .split(',')
          .map((f) => f.trim())
          .where((f) => f.isNotEmpty)
          .toList();

      final parsedPrice = int.tryParse(_priceController.text.trim()) ?? 0;

      final result = Destination(
        id: widget.destination?.id ?? '',
        name: _nameController.text.trim(),
        regency: _selectedRegency,
        category: _selectedCategory,
        ticketPrice: parsedPrice >= 0 ? parsedPrice : 0,
        openHours: _openHoursController.text.trim().isNotEmpty
            ? _openHoursController.text.trim()
            : '08.00 - 17.00 WIB',
        facilities: facilitiesList,
        description: _descriptionController.text.trim(),
        imageUrl: _imageUrlController.text.trim().isNotEmpty
            ? _imageUrlController.text.trim()
            : null,
        mapsUrl: _mapsUrlController.text.trim().isNotEmpty
            ? _mapsUrlController.text.trim()
            : null,
      );

      await widget.onSave(result);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.destination != null;
    final validCategories =
        DestinationListController.categories.where((c) => c != 'Semua').toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCCFBF1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isEdit ? Icons.edit_location_alt_rounded : Icons.add_location_alt_rounded,
                        color: const Color(0xFF0F766E),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isEdit ? 'Edit Destinasi Wisata' : 'Tambah Destinasi Baru',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Destinasi Wisata *',
                    hintText: 'Contoh: Pantai Marina Kalianda',
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Nama wisata wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedRegency,
                        decoration: const InputDecoration(
                          labelText: 'Kabupaten/Kota *',
                        ),
                        isExpanded: true,
                        items: DestinationListController.lampungRegencies
                            .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedRegency = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Kategori *',
                        ),
                        isExpanded: true,
                        items: validCategories
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCategory = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Tiket Masuk (Rp) *',
                          hintText: '0 = Gratis',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _openHoursController,
                        decoration: const InputDecoration(
                          labelText: 'Jam Operasional',
                          hintText: '08.00 - 17.00 WIB',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _facilitiesController,
                  decoration: const InputDecoration(
                    labelText: 'Fasilitas (pisahkan dengan koma)',
                    hintText: 'Parkir, Toilet, Gazebo, Warung Makan',
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi Wisata',
                    hintText: 'Ceritakan keindahan dan keunikan tempat wisata ini...',
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'URL Gambar (Opsional)',
                    hintText: 'Kosongkan untuk otomatis cari di Wikipedia',
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _mapsUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Link Google Maps (Opsional)',
                    hintText: 'https://maps.google.com/?q=...',
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0F766E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isEdit ? 'Perbarui Destinasi' : 'Simpan Destinasi',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
