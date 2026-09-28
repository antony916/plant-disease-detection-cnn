import 'package:flutter_test/flutter_test.dart';
import 'package:plantcare_ai/core/services/plant_knowledge_service.dart';

void main() {
  const service = PlantKnowledgeService();
  test('starter knowledge contains core gardener categories', () {
    final categories = service.entries.map((entry) => entry.category).toSet();
    expect(categories,
        containsAll(['Vegetable', 'Fruit', 'Flower', 'Herb', 'Indoor']));
  });
  test('knowledge search is case insensitive', () {
    final results = service.search('tomato');
    expect(results.map((entry) => entry.title), contains('Tomato'));
  });
}
