class PlantKnowledgeEntry {
  final String title;
  final String category;
  final String summary;
  final List<String> careTips;
  final List<String> warningSigns;

  const PlantKnowledgeEntry(
      {required this.title,
      required this.category,
      required this.summary,
      required this.careTips,
      required this.warningSigns});
}

class PlantKnowledgeService {
  const PlantKnowledgeService();

  List<PlantKnowledgeEntry> get entries => const [
        PlantKnowledgeEntry(
            title: 'Tomato',
            category: 'Vegetable',
            summary:
                'Warm-season crop that benefits from strong light, steady watering and good airflow.',
            careTips: [
              'Give suitable direct sunlight and support the plant as it grows.',
              'Water the soil consistently and avoid repeated leaf wetting.',
              'Check lower leaves and new growth regularly for symptoms or pests.'
            ],
            warningSigns: [
              'Yellowing leaves',
              'Dark leaf spots',
              'Curling leaves',
              'Wilting'
            ]),
        PlantKnowledgeEntry(
            title: 'Potato',
            category: 'Vegetable',
            summary:
                'Cool-season crop that needs well-drained soil and consistent moisture.',
            careTips: [
              'Keep soil evenly moist without leaving it saturated.',
              'Use suitable light and good soil drainage.',
              'Inspect foliage frequently for blight symptoms.'
            ],
            warningSigns: [
              'Brown lesions',
              'Rapid leaf collapse',
              'Yellowing foliage'
            ]),
        PlantKnowledgeEntry(
            title: 'Apple',
            category: 'Fruit',
            summary:
                'Fruit tree that needs suitable sunlight, airflow and seasonal care.',
            careTips: [
              'Maintain airflow around the canopy through appropriate pruning.',
              'Inspect leaves and fruit after wet periods.',
              'Remove fallen diseased debris where practical.'
            ],
            warningSigns: [
              'Olive leaf spots',
              'Black lesions',
              'Rust-like spots'
            ]),
        PlantKnowledgeEntry(
            title: 'Rose',
            category: 'Flower',
            summary:
                'Flowering plant that benefits from sunlight, airflow and careful watering.',
            careTips: [
              'Water the root zone and avoid keeping foliage wet for long periods.',
              'Provide the light level appropriate for the variety.',
              'Remove dead flowers and visibly damaged leaves.'
            ],
            warningSigns: [
              'Powdery coating',
              'Black spots',
              'Wilting',
              'Pest damage'
            ]),
        PlantKnowledgeEntry(
            title: 'Mint',
            category: 'Herb',
            summary:
                'Fast-growing herb that prefers consistent moisture and regular harvesting.',
            careTips: [
              'Keep soil lightly and consistently moist.',
              'Provide good light while avoiding extreme heat stress.',
              'Trim regularly to encourage fresh growth.'
            ],
            warningSigns: [
              'Drooping',
              'Brown leaf edges',
              'Sparse new growth'
            ]),
        PlantKnowledgeEntry(
            title: 'Money Plant',
            category: 'Indoor',
            summary:
                'Adaptable indoor plant that prefers bright indirect light and well-drained soil.',
            careTips: [
              'Let excess water drain and check the soil before watering again.',
              'Use bright indirect light for steady growth.',
              'Rotate the pot periodically for balanced growth.'
            ],
            warningSigns: [
              'Yellow leaves',
              'Soft stems',
              'Root-related decline'
            ]),
      ];

  List<PlantKnowledgeEntry> search(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return entries;
    return entries
        .where((entry) =>
            entry.title.toLowerCase().contains(normalized) ||
            entry.category.toLowerCase().contains(normalized) ||
            entry.summary.toLowerCase().contains(normalized) ||
            entry.warningSigns
                .any((item) => item.toLowerCase().contains(normalized)))
        .toList();
  }
}
