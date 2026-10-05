import 'package:flutter/material.dart';

import '../../core/app_services.dart';
import '../../core/models/plant.dart';
import '../../core/navigation/app_router.dart';
import '../../core/theme/app_theme.dart';

class EditPlantScreen extends StatefulWidget {
  final Plant plant;
  const EditPlantScreen({super.key, required this.plant});

  @override
  State<EditPlantScreen> createState() => _EditPlantScreenState();
}

class _EditPlantScreenState extends State<EditPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _species;
  late final TextEditingController _location;
  late final TextEditingController _notes;
  late String _sunlight;
  late String _soil;
  late double _watering;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.plant;
    _name = TextEditingController(text: p.name);
    _species = TextEditingController(
        text: p.species == 'Unknown species' ? '' : p.species);
    _location = TextEditingController(text: p.location);
    _notes = TextEditingController(text: p.notes);
    _sunlight = p.sunlight;
    _soil = p.soilType;
    _watering = p.wateringIntervalDays.clamp(1, 14).toDouble();
  }

  @override
  void dispose() {
    _name.dispose();
    _species.dispose();
    _location.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final interval = _watering.round();
    final updated = widget.plant.copyWith(
      name: _name.text.trim(),
      species: _species.text.trim().isEmpty
          ? 'Unknown species'
          : _species.text.trim(),
      location:
          _location.text.trim().isEmpty ? 'Garden' : _location.text.trim(),
      notes: _notes.text.trim(),
      sunlight: _sunlight,
      soilType: _soil,
      wateringIntervalDays: interval,
      nextWatering: DateTime.now().add(Duration(days: interval)),
    );
    try {
      await AppServices.garden.updatePlant(updated);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${updated.name} updated.')),
      );
      Navigator.pushReplacementNamed(context, AppRouter.plant,
          arguments: updated.name);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save changes: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit plant',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(PlantCareSpacing.lg),
          children: [
            const _FormSection(
                title: 'Plant basics',
                subtitle:
                    'Update the details PlantCare uses for care reminders.'),
            const SizedBox(height: PlantCareSpacing.sm),
            TextFormField(
              controller: _name,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Plant name'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter a plant name'
                  : null,
            ),
            const SizedBox(height: PlantCareSpacing.md),
            TextFormField(
              controller: _species,
              textInputAction: TextInputAction.next,
              decoration:
                  const InputDecoration(labelText: 'Species (optional)'),
            ),
            const SizedBox(height: PlantCareSpacing.lg),
            const _FormSection(
                title: 'Growing conditions',
                subtitle: 'Keep light, location and soil information current.'),
            const SizedBox(height: PlantCareSpacing.sm),
            DropdownButtonFormField<String>(
              initialValue: _sunlight,
              decoration: const InputDecoration(
                  labelText: 'Sunlight',
                  prefixIcon: Icon(Icons.wb_sunny_outlined)),
              items: const [
                DropdownMenuItem(value: 'Full sun', child: Text('Full sun')),
                DropdownMenuItem(value: '6–8 hours', child: Text('6–8 hours')),
                DropdownMenuItem(
                    value: 'Partial sun', child: Text('Partial sun')),
                DropdownMenuItem(
                    value: 'Bright indirect light',
                    child: Text('Bright indirect light')),
                DropdownMenuItem(value: 'Low light', child: Text('Low light')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _sunlight = value);
              },
            ),
            const SizedBox(height: PlantCareSpacing.md),
            TextFormField(
              controller: _location,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                  labelText: 'Garden location',
                  prefixIcon: Icon(Icons.place_outlined)),
            ),
            const SizedBox(height: PlantCareSpacing.md),
            DropdownButtonFormField<String>(
              initialValue: _soil,
              decoration: const InputDecoration(
                  labelText: 'Soil type',
                  prefixIcon: Icon(Icons.grass_outlined)),
              items: const [
                DropdownMenuItem(
                    value: 'General potting mix',
                    child: Text('General potting mix')),
                DropdownMenuItem(
                    value: 'Loamy potting mix',
                    child: Text('Loamy potting mix')),
                DropdownMenuItem(
                    value: 'Moist, well-drained mix',
                    child: Text('Moist, well-drained mix')),
                DropdownMenuItem(
                    value: 'Sandy soil', child: Text('Sandy soil')),
                DropdownMenuItem(value: 'Clay soil', child: Text('Clay soil')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _soil = value);
              },
            ),
            const SizedBox(height: PlantCareSpacing.lg),
            const _FormSection(
                title: 'Watering',
                subtitle: 'Adjust the starting reminder interval.'),
            const SizedBox(height: PlantCareSpacing.sm),
            Text('Every ${_watering.round()} days',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            Slider(
              value: _watering,
              min: 1,
              max: 14,
              divisions: 13,
              label: '${_watering.round()} days',
              onChanged: (value) => setState(() => _watering = value),
            ),
            const SizedBox(height: PlantCareSpacing.lg),
            const _FormSection(
                title: 'Notes', subtitle: 'Optional details about this plant.'),
            const SizedBox(height: PlantCareSpacing.sm),
            TextField(
              controller: _notes,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                  hintText: 'Optional notes about this plant',
                  alignLabelWithHint: true),
            ),
            const SizedBox(height: PlantCareSpacing.xl),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Save changes'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  final String title;
  final String subtitle;
  const _FormSection({required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          Text(subtitle,
              style:
                  const TextStyle(color: PlantCareColors.muted, fontSize: 12)),
          const SizedBox(height: PlantCareSpacing.sm),
        ],
      );
}
