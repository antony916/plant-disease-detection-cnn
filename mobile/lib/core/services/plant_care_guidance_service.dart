import '../models/plant.dart';

class PlantCareGuidance {
  final String summary;
  final List<String> actions;
  final List<String> prevention;

  const PlantCareGuidance({
    required this.summary,
    required this.actions,
    required this.prevention,
  });
}

class PlantCareGuidanceService {
  const PlantCareGuidanceService();

  PlantCareGuidance forCondition(String condition) {
    final key = _normalize(condition);

    if (key.contains('healthy')) {
      return const PlantCareGuidance(
        summary: 'No disease is indicated by this model class. Continue normal observation and care.',
        actions: [
          'Keep the plant in its suitable light and soil conditions.',
          'Water according to the plant schedule and check soil moisture before watering.',
          'Inspect new growth regularly for changes, pests, or unusual leaf symptoms.',
        ],
        prevention: [
          'Avoid prolonged leaf wetness and standing water.',
          'Remove dead or damaged plant material promptly.',
        ],
      );
    }

    if (key.contains('spider mite')) {
      return const PlantCareGuidance(
        summary: 'The model class is associated with spider-mite damage. Confirm the symptoms on the plant before treating.',
        actions: [
          'Inspect leaf undersides and new growth for mites or fine webbing.',
          'Isolate an affected potted plant from nearby plants when practical.',
          'Wash foliage gently with water if the plant tolerates it and improve airflow.',
        ],
        prevention: [
          'Check plants regularly, especially during hot and dry conditions.',
          'Avoid unnecessary broad-spectrum pesticide use that can disrupt beneficial insects.',
        ],
      );
    }

    if (key.contains('powdery mildew')) {
      return const PlantCareGuidance(
        summary: 'Powdery mildew commonly appears as a pale, powder-like coating on leaf surfaces.',
        actions: [
          'Remove severely affected leaves and dispose of them away from healthy plants.',
          'Improve airflow around the plant and avoid crowding.',
          'Water the soil rather than repeatedly wetting foliage.',
        ],
        prevention: [
          'Give plants suitable spacing and light.',
          'Monitor new growth for returning powdery patches.',
        ],
      );
    }

    if (key.contains('late blight')) {
      return const PlantCareGuidance(
        summary: 'Late blight can progress quickly, so confirm the symptoms and act promptly.',
        actions: [
          'Separate visibly affected plants from healthy plants when practical.',
          'Remove heavily affected foliage and keep infected plant debris out of the growing area.',
          'Avoid overhead watering and prolonged leaf wetness.',
        ],
        prevention: [
          'Improve airflow and avoid dense foliage.',
          'Monitor nearby plants frequently for new lesions.',
        ],
      );
    }

    if (key.contains('early blight')) {
      return const PlantCareGuidance(
        summary: 'Early blight is associated with dark leaf lesions that can expand over time.',
        actions: [
          'Remove severely affected leaves and fallen infected debris.',
          'Water at soil level and avoid unnecessary foliage wetting.',
          'Keep foliage dry and improve airflow around the plant.',
        ],
        prevention: [
          'Remove plant debris after the growing season.',
          'Avoid working with wet foliage when moving between plants.',
        ],
      );
    }

    if (key.contains('bacterial spot')) {
      return const PlantCareGuidance(
        summary: 'Bacterial spot can cause small dark lesions on leaves or fruit. Confirm the symptoms before treatment.',
        actions: [
          'Remove severely affected leaves and dispose of infected debris safely.',
          'Avoid splashing water from affected foliage onto healthy plants.',
          'Sanitize reusable pruning tools after working on affected tissue.',
        ],
        prevention: [
          'Use clean planting material and avoid handling plants while wet.',
          'Maintain spacing and airflow to reduce prolonged leaf moisture.',
        ],
      );
    }

    if (key.contains('leaf mold')) {
      return const PlantCareGuidance(
        summary: 'Leaf mold is favored by humid conditions and commonly affects tomato foliage.',
        actions: [
          'Remove severely affected leaves and improve airflow.',
          'Avoid unnecessary overhead irrigation.',
          'Keep affected plant material away from healthy foliage.',
        ],
        prevention: [
          'Reduce excessive humidity around foliage where possible.',
          'Provide adequate spacing and ventilation.',
        ],
      );
    }

    if (key.contains('septoria')) {
      return const PlantCareGuidance(
        summary: 'Septoria leaf spot produces small lesions and can spread through infected plant debris and moisture.',
        actions: [
          'Remove severely affected lower leaves and fallen debris.',
          'Water at soil level rather than wetting leaves.',
          'Improve airflow around the plant.',
        ],
        prevention: [
          'Keep the growing area clean of infected debris.',
          'Avoid handling plants when foliage is wet.',
        ],
      );
    }

    if (key.contains('target spot')) {
      return const PlantCareGuidance(
        summary: 'Target spot can produce expanding leaf lesions. Confirm the pattern before taking treatment decisions.',
        actions: [
          'Remove heavily affected leaves where practical.',
          'Improve airflow and avoid prolonged leaf wetness.',
          'Keep infected plant debris away from healthy plants.',
        ],
        prevention: [
          'Maintain suitable plant spacing.',
          'Inspect lower leaves regularly for new lesions.',
        ],
      );
    }

    if (key.contains('leaf scorch')) {
      return const PlantCareGuidance(
        summary: 'Leaf scorch can have several causes, so also check watering, heat, sunlight, and root conditions.',
        actions: [
          'Check soil moisture before changing the watering schedule.',
          'Look for heat or excessive direct-sun exposure that matches the plant’s needs.',
          'Inspect roots and soil drainage if symptoms continue despite suitable watering.',
        ],
        prevention: [
          'Keep watering consistent rather than alternating between very dry and saturated soil.',
          'Match light exposure to the plant’s normal requirements.',
        ],
      );
    }

    if (key.contains('huanglongbing') || key.contains('citrus greening')) {
      return const PlantCareGuidance(
        summary: 'Citrus greening is a serious citrus disease. A model result should be confirmed by qualified local plant-health guidance.',
        actions: [
          'Do not rely on a photo diagnosis alone for a management decision.',
          'Separate a suspicious plant from healthy citrus where practical.',
          'Contact a local horticulture or agricultural authority for confirmation and current management guidance.',
        ],
        prevention: [
          'Use healthy planting material.',
          'Monitor citrus plants regularly for persistent abnormal new growth.',
        ],
      );
    }

    if (key.contains('yellow leaf curl virus') || key.contains('mosaic virus')) {
      return const PlantCareGuidance(
        summary: 'Viral symptoms require confirmation because several stresses can look similar in photographs.',
        actions: [
          'Separate a suspicious plant from healthy plants where practical.',
          'Inspect for insect vectors and other visible stress symptoms.',
          'Seek local agricultural or horticultural confirmation before removing a valuable plant.',
        ],
        prevention: [
          'Use healthy planting material and clean tools.',
          'Control known insect vectors using locally appropriate guidance.',
        ],
      );
    }

    return const PlantCareGuidance(
      summary: 'This is a model classification, not a complete treatment diagnosis. Confirm the symptoms before taking corrective action.',
      actions: [
        'Inspect the whole plant, including new growth, leaf undersides, stems, and soil.',
        'Check watering, drainage, sunlight, temperature, and recent changes in care.',
        'If symptoms are spreading or severe, seek qualified local horticultural advice.',
      ],
      prevention: [
        'Keep plants appropriately spaced and remove dead or infected debris.',
        'Record changes in watering, light, weather, and symptoms in the plant history.',
      ],
    );
  }

  String _normalize(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'[_-]+'), ' ');
}
