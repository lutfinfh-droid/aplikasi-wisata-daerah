import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/destination.dart';

/// Kontrak repository untuk mengelola data destinasi wisata.
abstract class DestinationRepository {
  Future<List<Destination>> fetchDestinations();
  Future<Destination> createDestination(Destination destination);
  Future<Destination> updateDestination(Destination destination);
  Future<void> deleteDestination(String id);
}

/// Implementasi repository berbasis Supabase dengan dukungan CRUD penuh.
class SupabaseDestinationRepository implements DestinationRepository {
  SupabaseDestinationRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<List<Destination>> fetchDestinations() async {
    final response = await _client
        .from('destinations')
        .select()
        .order('regency', ascending: true)
        .order('name', ascending: true);

    final rows = List<Map<String, dynamic>>.from(response as List);
    return rows.map(Destination.fromJson).toList();
  }

  @override
  Future<Destination> createDestination(Destination destination) async {
    final response = await _client
        .from('destinations')
        .insert(destination.toInsertJson())
        .select()
        .single();

    return Destination.fromJson(response);
  }

  @override
  Future<Destination> updateDestination(Destination destination) async {
    final dynamic idVal = int.tryParse(destination.id) ?? destination.id;
    final response = await _client
        .from('destinations')
        .update(destination.toUpdateJson())
        .eq('id', idVal)
        .select()
        .single();

    return Destination.fromJson(response);
  }

  @override
  Future<void> deleteDestination(String id) async {
    final dynamic idVal = int.tryParse(id) ?? id;
    await _client.from('destinations').delete().eq('id', idVal);
  }
}
