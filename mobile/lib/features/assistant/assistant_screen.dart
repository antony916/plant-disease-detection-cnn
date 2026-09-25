import 'package:flutter/material.dart';

import '../../core/navigation/app_router.dart';
import '../../core/theme/app_theme.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PlantCare AI', style: TextStyle(fontWeight: FontWeight.w800))),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(PlantCareSpacing.lg),
              children: [
                Container(
                  padding: const EdgeInsets.all(PlantCareSpacing.md),
                  decoration: BoxDecoration(color: PlantCareColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(16)),
                  child: const Text('Hi! Ask me about watering, plant care, symptoms, pests or your garden. I will use your saved garden context when the production backend is connected.'),
                ),
                const SizedBox(height: PlantCareSpacing.md),
                const Text('Try asking:', style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: PlantCareSpacing.sm),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ActionChip(label: const Text('Why are my tomato leaves yellow?'), onPressed: () {}),
                    ActionChip(label: const Text('What should I water today?'), onPressed: () {}),
                    ActionChip(label: const Text('Help me identify this pest'), onPressed: () => Navigator.pushNamed(context, AppRouter.scanner)),
                  ],
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(PlantCareSpacing.md, 8, PlantCareSpacing.md, 8),
              child: Row(
                children: [
                  Expanded(child: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Ask PlantCare AI...'))),
                  const SizedBox(width: 8),
                  IconButton.filled(onPressed: () => controller.clear(), icon: const Icon(Icons.arrow_upward)),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(selectedIndex: 3),
    );
  }
}
