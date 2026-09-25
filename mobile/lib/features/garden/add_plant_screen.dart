import 'package:flutter/material.dart';

import '../../core/app_services.dart';
import '../../core/models/plant.dart';
import '../../core/navigation/app_router.dart';
import '../../core/theme/app_theme.dart';

class AddPlantScreen extends StatefulWidget {
  const AddPlantScreen({super.key});

  @override
  State<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final species = _speciesController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a plant name first.')),
      );
      return;
    }

    setState(() => _saving = true);

    await AppServices.garden.addPlant(
      Plant(
        id: 'plant-${DateTime.now().microsecondsSinceEpoch}',
        name: name,
        species: species.isEmpty ? 'Unknown species' : species,
        health: 'Not assessed',
      ),
    );

    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pushReplacementNamed(context, AppRouter.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add plant',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(PlantCareSpacing.lg),
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: PlantCareColors.surface,
              borderRadius: BorderRadius.circular(PlantCareRadius.featured),
              border: Border.all(color: PlantCareColors.border),
            ),
            child: const Icon(
              Icons.eco_outlined,
              size: 64,
              color: PlantCareColors.primary,
            ),
          ),
          const SizedBox(height: PlantCareSpacing.lg),
          TextField(
            controller: _nameController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Plant name',
              hintText: 'e.g. Tomato',
            ),
          ),
          const SizedBox(height: PlantCareSpacing.md),
          TextField(
            controller: _speciesController,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Species (optional)',
              hintText: 'e.g. Solanum lycopersicum',
            ),
          ),
          const SizedBox(height: PlantCareSpacing.xl),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Add to my garden'),
          ),
          const SizedBox(height: PlantCareSpacing.sm),
          const Text(
            'More plant details, photos, reminders and location-aware care will be added through the garden profile.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: PlantCareColors.muted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
