import '../models/diagnosis_record.dart';
import 'diagnosis_service.dart';

abstract interface class DiagnosisRepository {
  Future<DiagnosisResult> diagnose({
    required String imagePath,
    String? plantId,
    String? plantHint,
    String? imageReference,
  });

  Future<void> saveDiagnosis(DiagnosisRecord record);

  Future<List<DiagnosisRecord>> history({String? plantId});
}
