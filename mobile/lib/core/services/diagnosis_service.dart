class DiagnosisResult {
  final String plantName;
  final String condition;
  final double confidence;
  final String explanation;
  final bool needsExpertReview;

  const DiagnosisResult({
    required this.plantName,
    required this.condition,
    required this.confidence,
    required this.explanation,
    required this.needsExpertReview,
  });
}

abstract interface class DiagnosisService {
  Future<DiagnosisResult> diagnose({
    required String imagePath,
    String? plantHint,
  });
}

/// Temporary development implementation.
///
/// This is intentionally isolated from the UI. The production implementation
/// will call the deployed PlantCare inference service or a converted mobile
/// model. No production diagnosis is fabricated by the UI.
class DemoDiagnosisService implements DiagnosisService {
  @override
  Future<DiagnosisResult> diagnose({
    required String imagePath,
    String? plantHint,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    return const DiagnosisResult(
      plantName: 'Tomato',
      condition: 'Early blight',
      confidence: 0.94,
      explanation: 'Development placeholder only. Connect this service to the evaluated PlantCare model before production diagnosis.',
      needsExpertReview: false,
    );
  }
}
