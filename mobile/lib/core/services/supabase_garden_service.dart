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

    final owned = await client
        .from('gardens')
        .select()
        .eq('owner_id', user.id)
        .order('created_at')
        .limit(1);

    if (owned.isNotEmpty) {
      return _fromRow(owned.first);
    }

    final memberships = await client
        .from('family_members')
        .select('garden_id')
        .eq('user_id', user.id)
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
