import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/destination.dart';

/// Kontrak repository untuk mengambil daftar destinasi wisata.
abstract class DestinationRepository {
  Future<List<Destination>> fetchDestinations();
}

/// Implementasi repository berbasis Supabase (Read-Only).
class SupabaseDestinationRepository implements DestinationRepository {
  SupabaseDestinationRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<List<Destination>> fetchDestinations() async {
    final response = await _client
        .from('destinations')
        .select()
        .eq('is_active', true)
        .order('name', ascending: true);

    final rows = List<Map<String, dynamic>>.from(response as List);
    return rows.map(Destination.fromJson).toList();
  }
}
