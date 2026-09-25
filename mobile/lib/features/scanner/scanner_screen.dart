import 'package:flutter/material.dart';

import '../../core/navigation/app_router.dart';
import '../../core/theme/app_theme.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Plant Scanner', style: TextStyle(fontWeight: FontWeight.w800))),
      body: Padding(
        padding: const EdgeInsets.all(PlantCareSpacing.lg),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EEE9),
                  borderRadius: BorderRadius.circular(PlantCareRadius.featured),
                  border: Border.all(color: PlantCareColors.border),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.center_focus_strong, size: 56, color: PlantCareColors.primary),
                    SizedBox(height: 16),
                    Text('Place the affected leaf inside the frame', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                    SizedBox(height: 8),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Text('Use good lighting and capture the affected area clearly.', textAlign: TextAlign.center, style: TextStyle(color: PlantCareColors.muted)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: PlantCareSpacing.md),
            Row(
              children: [
                Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.photo_library_outlined), label: const Text('Upload'))),
                const SizedBox(width: PlantCareSpacing.sm),
                Expanded(child: FilledButton.icon(onPressed: () => Navigator.pushNamed(context, AppRouter.diagnosis, arguments: 'Tomato'), icon: const Icon(Icons.camera_alt_outlined), label: const Text('Camera'))),
              ],
            ),
            const SizedBox(height: PlantCareSpacing.sm),
            const Text('AI checks disease patterns first. Other causes can be added as additional diagnostic models are validated.', textAlign: TextAlign.center, style: TextStyle(color: PlantCareColors.muted, fontSize: 12)),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(selectedIndex: 1),
    );
  }
}
