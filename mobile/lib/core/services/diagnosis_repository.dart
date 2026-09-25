import 'diagnosis_service.dart';

abstract interface class DiagnosisRepository {
  Future<DiagnosisResult> diagnose({
    required String imagePath,
    String? plantId,
    String? plantHint,
  });

  Future<List<DiagnosisResult>> history({String? plantId});
}
