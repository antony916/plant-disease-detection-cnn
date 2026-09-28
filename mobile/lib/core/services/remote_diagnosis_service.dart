import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'diagnosis_service.dart';

class RemoteDiagnosisService implements DiagnosisService {
  static const Duration requestTimeout = Duration(seconds: 30);
  static const double lowConfidenceThreshold = 0.60;

  final String endpoint;
  final http.Client client;

  RemoteDiagnosisService({
    required this.endpoint,
    http.Client? client,
  }) : client = client ?? http.Client();

  @override
  Future<DiagnosisResult> diagnose({
    required String imagePath,
    String? plantHint,
  }) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      throw StateError('Selected image file no longer exists.');
    }

    final uri = Uri.tryParse(endpoint);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw StateError('Inference service endpoint is invalid.');
    }

    final request = http.MultipartRequest('POST', uri);

    if (plantHint != null && plantHint.trim().isNotEmpty) {
      request.fields['plant_hint'] = plantHint.trim();
    }

    request.fields['capability'] = 'disease';

    request.files.add(
      await http.MultipartFile.fromPath('image', imagePath),
    );

    final http.StreamedResponse streamed;
    try {
      streamed = await client.send(request).timeout(requestTimeout);
    } on TimeoutException {
      throw StateError('Inference service timed out. Please try again.');
    } on SocketException {
      throw StateError('Could not reach the inference service.');
    }

    final response = await http.Response.fromStream(streamed);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        'Inference service returned HTTP ${response.statusCode}.',
      );
    }

    if (response.body.trim().isEmpty) {
      throw const FormatException(
        'Inference service returned an empty response.',
      );
    }

    final dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw const FormatException(
        'Inference service returned invalid JSON.',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid inference response.');
    }

    final plantName = _requiredText(decoded, 'plant_name');
    final condition = _requiredText(decoded, 'condition');
    final explanation = _requiredText(decoded, 'explanation');

    final confidenceValue = decoded['confidence'];
    if (confidenceValue is! num) {
      throw const FormatException(
        'Inference confidence is missing or invalid.',
      );
    }

    final confidence = confidenceValue.toDouble();
    if (!confidence.isFinite || confidence < 0 || confidence > 1) {
      throw const FormatException(
        'Inference confidence must be between 0 and 1.',
      );
    }

    final needsExpertReviewValue = decoded['needs_expert_review'];
    final needsExpertReview = needsExpertReviewValue is bool
        ? needsExpertReviewValue
        : confidence < lowConfidenceThreshold;

    final modelVersion = decoded['model_version'];
    if (modelVersion is! String || modelVersion.trim().isEmpty) {
      throw const FormatException('Inference model version is missing.');
    }

    final capabilityValue = decoded['capability'];
    final capability =
        capabilityValue is String && capabilityValue.trim().isNotEmpty
            ? capabilityValue.trim()
            : 'disease';

    final modelIdValue = decoded['model_id'];
    final modelId =
        modelIdValue is String && modelIdValue.trim().isNotEmpty
            ? modelIdValue.trim()
            : 'unknown';

    return DiagnosisResult(
      plantName: plantName,
      condition: condition,
      confidence: confidence,
      explanation: explanation,
      needsExpertReview:
          needsExpertReview || confidence < lowConfidenceThreshold,
      modelVersion: modelVersion.trim(),
      capability: capability,
      modelId: modelId,
    );
  }

  String _requiredText(Map<String, dynamic> payload, String key) {
    final value = payload[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Inference field "$key" is missing or empty.');
    }
    return value.trim();
  }
}
