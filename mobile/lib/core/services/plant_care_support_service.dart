enum SupportSection { community, experts, shops, resources }

class SupportItem {
  final String title;
  final String subtitle;
  final String detail;
  final SupportSection section;
  const SupportItem({required this.title, required this.subtitle, required this.detail, required this.section});
}

class PlantCareSupportService {
  const PlantCareSupportService();
  List<SupportItem> get items => const [
    SupportItem(title: 'Gardeners Community', subtitle: 'Share a plant question or photo with other gardeners.', detail: 'Community posting is prepared as a moderated product flow. Do not share private contact details or sensitive information in public posts.', section: SupportSection.community),
    SupportItem(title: 'Agricultural Expert', subtitle: 'Escalate uncertain or serious plant problems.', detail: 'Use qualified local horticulture or agricultural support when a diagnosis is low-confidence, rapidly spreading, or high-impact.', section: SupportSection.experts),
    SupportItem(title: 'Nearby Garden Shops', subtitle: 'Find nurseries, garden stores and agricultural suppliers.', detail: 'Location is optional. PlantCare should use a user-selected location before requesting nearby results.', section: SupportSection.shops),
    SupportItem(title: 'Trusted Resources', subtitle: 'Official agriculture and horticulture guidance.', detail: 'Prefer government agriculture/horticulture departments, extension services and other clearly identified authoritative resources.', section: SupportSection.resources),
  ];
}