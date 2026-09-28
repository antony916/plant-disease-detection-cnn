import '../models/plant.dart';
import 'care_service.dart';

class AssistantReply {
  final String message;
  final List<String> followUps;
  const AssistantReply({required this.message, this.followUps = const []});
}

class PlantAssistantService {
  final CareService careService;
  const PlantAssistantService(this.careService);

  Future<AssistantReply> answer({required String question, required List<Plant> plants}) async {
    final q = question.trim().toLowerCase();
    if (q.isEmpty) return const AssistantReply(message: 'Tell me what you are seeing on the plant and I will help you narrow it down.');
    if (plants.isEmpty) return const AssistantReply(message: 'Your garden is empty right now. Add a plant first, then I can use its saved watering, light and soil details.', followUps: ['Add a plant', 'How often should I water?']);
    if (q.contains('water') || q.contains('watering')) {
      final lines = <String>[];
      for (final plant in plants.take(3)) {
        final recommendation = await careService.wateringRecommendation(plant);
        lines.add('${plant.name}: ${recommendation.title}. ${recommendation.message}');
      }
      return AssistantReply(message: lines.join('\n\n'), followUps: ['Why is my plant yellow?', 'How much sunlight does it need?']);
    }
    if (q.contains('yellow') || q.contains('wilting') || q.contains('droop')) return const AssistantReply(message: 'Yellowing or wilting can have several causes, including watering stress, root problems, light changes, nutrient issues or disease. Check soil moisture first, then inspect the roots, light exposure and recent changes in care. A clear photo of the affected leaves can help PlantCare narrow the possibilities.', followUps: ['Scan the affected leaf', 'What should I check in the soil?']);
    if (q.contains('pest') || q.contains('insect') || q.contains('bug')) return const AssistantReply(message: 'Inspect the underside of leaves, new growth and stems for insects, eggs, sticky residue or fine webbing. Isolate a suspicious potted plant when practical and avoid using a pesticide until the pest and product label are confirmed.', followUps: ['Scan the plant', 'How do I isolate a plant?']);
    if (q.contains('sun') || q.contains('light')) {
      final plant = plants.first;
      return AssistantReply(message: '${plant.name} is saved with the light preference “${plant.sunlight}”. Keep that as the starting point, then watch for stretched growth, scorch or persistent shade-related decline.', followUps: ['Why are the leaves yellow?', 'What should I water today?']);
    }
    final plantNames = plants.take(3).map((plant) => plant.name).join(', ');
    return AssistantReply(message: 'I can help with watering, light, visible symptoms, pests and your saved garden. I currently know about: $plantNames. For a photo-based problem, use the AI Scanner so the result can be linked to a garden plant.', followUps: ['What should I water today?', 'Why are my leaves yellow?', 'Help me identify a pest']);
  }
}