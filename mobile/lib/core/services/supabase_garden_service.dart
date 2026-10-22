import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/garden.dart';
import 'in_flight_request.dart';

class SupabaseGardenService {
  final SupabaseClient client;
  final InFlightRequest<Garden> _gardenRequests = InFlightRequest<Garden>();

  SupabaseGardenService(this.client);

  Future<Garden> getOrCreateDefaultGarden() async {
    final user = client.auth.currentUser;
    if (user == null) {
      throw const AuthException('Sign in required.');
    }

    return _gardenRequests.run(
      user.id,
      () => _loadOrCreateDefaultGarden(user.id),
    );
  }

  Future<Garden> _loadOrCreateDefaultGarden(String userId) async {
    final owned = await _loadOwnedDefaultGarden(userId);
    if (owned != null) {
      return owned;
    }

    final memberships = await client
        .from('family_members')
        .select('garden_id')
        .eq('user_id', userId)
        .eq('status', 'active')
        .order('created_at')
        .limit(1);

    if (memberships.isNotEmpty) {
      final garden = await client
          .from('gardens')
          .select()
          .eq('id', memberships.first['garden_id'].toString())
          .single();
      return _fromRow(garden);
    }

    try {
      final created = await client
          .from('gardens')
          .insert({
            'owner_id': userId,
            'is_default': true,
            'name': 'My Garden',
          })
          .select()
          .single();

      return _fromRow(created);
    } on PostgrestException catch (error) {
      if (error.code != '23505') rethrow;

      // A different device may have inserted the default garden after our
      // first query. The partial unique index makes that insert the winner.
      final raced = await _loadOwnedDefaultGarden(userId);
      if (raced != null) return raced;
      rethrow;
    }
  }

  Future<Garden?> _loadOwnedDefaultGarden(String userId) async {
    final rows = await client
        .from('gardens')
        .select()
        .eq('owner_id', userId)
        .eq('is_default', true)
        .limit(1);

    return rows.isEmpty ? null : _fromRow(rows.first);
  }

  Garden _fromRow(Map<String, dynamic> row) {
    return Garden(
      id: row['id'].toString(),
      ownerId: row['owner_id'].toString(),
      name: row['name'] as String? ?? 'My Garden',
      locationEnabled: row['location_enabled'] as bool? ?? false,
      latitude: (row['latitude'] as num?)?.toDouble(),
      longitude: (row['longitude'] as num?)?.toDouble(),
    );
  }
}
