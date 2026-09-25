import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/garden.dart';

class SupabaseGardenService {
  final SupabaseClient client;

  const SupabaseGardenService(this.client);

  Future<Garden> getOrCreateDefaultGarden() async {
    final user = client.auth.currentUser;
    if (user == null) {
      throw const AuthException('Sign in required.');
    }

    final existing = await client
        .from('gardens')
        .select()
        .eq('owner_id', user.id)
        .order('created_at')
        .limit(1);

    if (existing.isNotEmpty) {
      return _fromRow(existing.first);
    }

    final created = await client
        .from('gardens')
        .insert({
          'owner_id': user.id,
          'name': 'My Garden',
        })
        .select()
        .single();

    return _fromRow(created);
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
