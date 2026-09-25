import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'diagnosis_service.dart';

class RemoteDiagnosisService implements DiagnosisService {
  final String endpoint;
  final http.Client client;

  const RemoteDiagnosisService({
    required this.endpoint,
    this.client = const http.Client(),
  });

  @override
  Future<DiagnosisResult> diagnose({
    required String imagePath,
    String? plantHint,
  }) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      throw StateError('Selected image file no longer exists.');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(endpoint),
    );

    if (plantHint != null && plantHint.trim().isNotEmpty) {
      request.fields['plant_hint'] = plantHint.trim();
    }

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imagePath,
      ),
    );

    final streamed = await client.send(request);
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        'Inference service returned HTTP ${response.statusCode}.',
      );
    }

    final payload = jsonDecode(response.body);
    if (payload is! Map<String, dynamic>) {
      throw const FormatException('Invalid inference response.');
    }

    final plantName = payload['plant_name'] as String? ?? 'Unknown plant';
    final condition = payload['condition'] as String? ?? 'Unknown condition';
    final confidence = (payload['confidence'] as num?)?.toDouble() ?? 0;
    final explanation =
        payload['explanation'] as String? ?? 'Model inference completed.';
    final needsExpertReview =
        payload['needs_expert_review'] as bool? ?? confidence < 0.60;

    return DiagnosisResult(
      plantName: plantName,
      condition: condition,
      confidence: confidence,
      explanation: explanation,
      needsExpertReview: needsExpertReview,
    );
  }
}
