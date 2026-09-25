import '../services/diagnosis_service.dart';

class DiagnosisRecord {
  final String id;
  final String plantId;
  final String imagePath;
  final DiagnosisResult result;
  final DateTime createdAt;

  const DiagnosisRecord({
    required this.id,
    required this.plantId,
    required this.imagePath,
    required this.result,
    required this.createdAt,
  });
}
