import 'package:flutter_test/flutter_test.dart';

import 'package:plantcare_ai/core/services/diagnosis_service.dart';

void main() {
  group('DiagnosisResult', () {
    test('keeps the supplied model version', () {
      const result = DiagnosisResult(
        plantName: 'Tomato',
        condition: 'Early blight',
        confidence: 0.94,
        explanation: 'Test result',
        needsExpertReview: false,
        modelVersion: 'plantvillage-mobilenetv3-38-class',
      );

      expect(result.modelVersion, 'plantvillage-mobilenetv3-38-class');
      expect(result.confidence, inInclusiveRange(0, 1));
    });

    test('uses unknown when a caller does not provide a model version', () {
      const result = DiagnosisResult(
        plantName: 'Tomato',
        condition: 'Healthy',
        confidence: 0.91,
        explanation: 'Test result',
        needsExpertReview: false,
      );

      expect(result.modelVersion, 'unknown');
    });
  });
}
