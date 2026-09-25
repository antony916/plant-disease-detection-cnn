import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'image_storage_service.dart';

class SupabaseImageStorageService implements ImageStorageService {
  final SupabaseClient client;
  static const bucket = 'plant-images';

  const SupabaseImageStorageService(this.client);

  @override
  Future<String> uploadPlantImage({
    required String filePath,
    required String userId,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw StateError('Selected image file no longer exists.');
    }

    final extension = _extension(filePath);
    final path =
        '$userId/plants/${DateTime.now().microsecondsSinceEpoch}.$extension';

    await client.storage.from(bucket).upload(
      path,
      file,
      fileOptions: const FileOptions(
        upsert: false,
        cacheControl: '3600',
      ),
    );

    return path;
  }

  String _extension(String filePath) {
    final name = filePath.split(RegExp(r'[\\/]')).last;
    final dot = name.lastIndexOf('.');
    if (dot < 0 || dot == name.length - 1) return 'jpg';
    final value = name.substring(dot + 1).toLowerCase();
    const allowed = {'jpg', 'jpeg', 'png', 'webp', 'heic', 'heif'};
    return allowed.contains(value) ? value : 'jpg';
  }
}
