import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/diagnosis_record.dart';
import 'diagnosis_repository.dart';
import 'diagnosis_service.dart';
import 'garden_repository.dart';

class SupabaseDiagnosisRepository implements DiagnosisRepository {
  final SupabaseClient client;
  final DiagnosisService service;
  final GardenRepository garden;

  SupabaseDiagnosisRepository({
    required this.client,
    required this.service,
    required this.garden,
  });

  @override
  Future<DiagnosisResult> diagnose({
    required String imagePath,
    String? plantId,
    String? plantHint,
    String? imageReference,
  }) async {
    final result = await service.diagnose(
      imagePath: imagePath,
      plantHint: plantHint,
    );

    final resolvedPlantId =
        plantId ?? await _plantIdForName(result.plantName);

    if (resolvedPlantId != null) {
      await saveDiagnosis(
        DiagnosisRecord(
          id: 'local-diagnosis-\${DateTime.now().microsecondsSinceEpoch}',
          plantId: resolvedPlantId,
          imagePath: imagePath,
          imageReference: imageReference,
          result: result,
          createdAt: DateTime.now(),
        ),
      );
    }

    return result;
  }

  @override
  Future<void> saveDiagnosis(DiagnosisRecord record) async {
    final user = client.auth.currentUser;
    if (user == null) {
      throw const AuthException('Sign in required.');
    }

    await client.from('diagnoses').insert({
      'plant_id': record.plantId,
      'owner_id': user.id,
      'image_url': record.imageReference ?? (record.imagePath.isEmpty ? null : record.imagePath),
      'plant_name': record.result.plantName,
      'condition': record.result.condition,
      'confidence': record.result.confidence,
      'explanation': record.result.explanation,
      'needs_expert_review': record.result.needsExpertReview,
      'model_version': 'mobile-demo-service',
      'created_at': record.createdAt.toIso8601String(),
    });
  }

  @override
  Future<List<DiagnosisRecord>> history({String? plantId}) async {
    final user = client.auth.currentUser;
    if (user == null) {
      throw const AuthException('Sign in required.');
    }

    var query = client
        .from('diagnoses')
        .select()
        .eq('owner_id', user.id);

    if (plantId != null) {
      query = query.eq('plant_id', plantId);
    }

    final rows = await query.order('created_at', ascending: false);
    return rows.map(_fromRow).toList();
  }

  Future<String?> _plantIdForName(String plantName) async {
    final normalized = plantName.trim().toLowerCase();
    final plants = await garden.getPlants();

    for (final plant in plants) {
      if (plant.name.trim().toLowerCase() == normalized ||
          plant.species.trim().toLowerCase() == normalized) {
        return plant.id;
      }
    }

    return null;
  }

  DiagnosisRecord _fromRow(Map<String, dynamic> row) {
    return DiagnosisRecord(
      id: row['id'].toString(),
      plantId: row['plant_id'].toString(),
      imagePath: row['image_url'] as String? ?? '',
      result: DiagnosisResult(
        plantName: row['plant_name'] as String? ?? 'Unknown plant',
        condition: row['condition'] as String,
        confidence: (row['confidence'] as num).toDouble(),
        explanation: row['explanation'] as String? ?? '',
        needsExpertReview: row['needs_expert_review'] as bool? ?? false,
      ),
      createdAt:
          DateTime.tryParse(row['created_at'].toString()) ?? DateTime.now(),
    );
  }
}
