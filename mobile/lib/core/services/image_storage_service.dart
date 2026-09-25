import 'dart:io';

abstract interface class ImageStorageService {
  Future<String> uploadPlantImage({
    required String filePath,
    required String userId,
  });
}

class DemoImageStorageService implements ImageStorageService {
  @override
  Future<String> uploadPlantImage({
    required String filePath,
    required String userId,
  }) async {
    return filePath;
  }
}
