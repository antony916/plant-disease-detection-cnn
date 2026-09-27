import 'package:flutter_test/flutter_test.dart';

import 'package:plantcare_ai/core/services/plant_care_guidance_service.dart';

void main() {
  const service = PlantCareGuidanceService();

  test('provides targeted guidance for common disease classes', () {
    final guidance = service.forCondition('Tomato___Early blight');

    expect(guidance.summary, contains('Early blight'));
    expect(guidance.actions, isNotEmpty);
    expect(guidance.prevention, isNotEmpty);
  });

  test('normalizes class naming separators', () {
    final guidance = service.forCondition('Cherry - Powdery mildew');

    expect(guidance.summary, contains('Powdery mildew'));
  });

  test('uses a safe generic fallback for unknown conditions', () {
    final guidance = service.forCondition('Unseen condition');

    expect(guidance.summary, contains('model classification'));
    expect(guidance.actions, contains(
      'If symptoms are spreading or severe, seek qualified local horticultural advice.',
    ));
  });

  test('healthy results do not prescribe disease treatment', () {
    final guidance = service.forCondition('Tomato___healthy');

    expect(guidance.summary, contains('No disease is indicated'));
    expect(guidance.actions.join(' '), isNot(contains('pesticide')));
  });
}
