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
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  String _sunlight = 'Bright indirect light';
  String _soilType = 'General potting mix';
  double _wateringInterval = 2;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final now = DateTime.now();
    final interval = _wateringInterval.round();

    await AppServices.garden.addPlant(
      Plant(
        id: 'plant-${DateTime.now().microsecondsSinceEpoch}',
        name: _nameController.text.trim(),
        species: _speciesController.text.trim().isEmpty
            ? 'Unknown species'
            : _speciesController.text.trim(),
        health: 'Not assessed',
        nextWatering: now.add(Duration(days: interval)),
        wateringIntervalDays: interval,
        sunlight: _sunlight,
        location: _locationController.text.trim().isEmpty
            ? 'Garden'
            : _locationController.text.trim(),
        soilType: _soilType,
        notes: _notesController.text.trim(),
        createdAt: now,
      ),
    );

    if (!mounted) return;
    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_nameController.text.trim()} added to your garden.'),
      ),
    );
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
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(PlantCareSpacing.lg),
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: PlantCareColors.surface,
                borderRadius:
                    BorderRadius.circular(PlantCareRadius.featured),
                border: Border.all(color: PlantCareColors.border),
              ),
              child: const Icon(
                Icons.eco_outlined,
                size: 64,
                color: PlantCareColors.primary,
              ),
            ),
            const SizedBox(height: PlantCareSpacing.lg),
            const Text(
              'Plant basics',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: PlantCareSpacing.sm),
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Plant name',
                hintText: 'e.g. Tomato',
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty
                      ? 'Enter a plant name'
                      : null,
            ),
            const SizedBox(height: PlantCareSpacing.md),
            TextFormField(
              controller: _speciesController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Species (optional)',
                hintText: 'e.g. Solanum lycopersicum',
              ),
            ),
            const SizedBox(height: PlantCareSpacing.lg),
            const Text(
              'Growing conditions',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: PlantCareSpacing.sm),
            DropdownButtonFormField<String>(
              initialValue: _sunlight,
              decoration: const InputDecoration(
                labelText: 'Sunlight',
                prefixIcon: Icon(Icons.wb_sunny_outlined),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Full sun',
                  child: Text('Full sun'),
                ),
                DropdownMenuItem(
                  value: '6–8 hours',
                  child: Text('6–8 hours'),
                ),
                DropdownMenuItem(
                  value: 'Partial sun',
                  child: Text('Partial sun'),
                ),
                DropdownMenuItem(
                  value: 'Bright indirect light',
                  child: Text('Bright indirect light'),
                ),
                DropdownMenuItem(
                  value: 'Low light',
                  child: Text('Low light'),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _sunlight = value);
              },
            ),
            const SizedBox(height: PlantCareSpacing.md),
            TextFormField(
              controller: _locationController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Garden location',
                hintText: 'e.g. Balcony, terrace, kitchen window',
                prefixIcon: Icon(Icons.place_outlined),
              ),
            ),
            const SizedBox(height: PlantCareSpacing.md),
            DropdownButtonFormField<String>(
              initialValue: _soilType,
              decoration: const InputDecoration(
                labelText: 'Soil type',
                prefixIcon: Icon(Icons.grass_outlined),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'General potting mix',
                  child: Text('General potting mix'),
                ),
                DropdownMenuItem(
                  value: 'Loamy potting mix',
                  child: Text('Loamy potting mix'),
                ),
                DropdownMenuItem(
                  value: 'Moist, well-drained mix',
                  child: Text('Moist, well-drained mix'),
                ),
                DropdownMenuItem(
                  value: 'Sandy soil',
                  child: Text('Sandy soil'),
                ),
                DropdownMenuItem(
                  value: 'Clay soil',
                  child: Text('Clay soil'),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _soilType = value);
              },
            ),
            const SizedBox(height: PlantCareSpacing.lg),
            const Text(
              'Watering',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: PlantCareSpacing.sm),
            Text(
              'Every ${_wateringInterval.round()} days',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Slider(
              value: _wateringInterval,
              min: 1,
              max: 14,
              divisions: 13,
              label: '${_wateringInterval.round()} days',
              onChanged: (value) {
                setState(() => _wateringInterval = value);
              },
            ),
            const Text(
              'This is the starting reminder interval. PlantCare can make it smarter later using weather and plant conditions.',
              style: TextStyle(
                color: PlantCareColors.muted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: PlantCareSpacing.lg),
            const Text(
              'Notes',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: PlantCareSpacing.sm),
            TextField(
              controller: _notesController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Optional notes about this plant',
                alignLabelWithHint: true,
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
              'You can update care details later as your plant grows.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: PlantCareColors.muted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
