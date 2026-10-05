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
  final _name = TextEditingController(),
      _species = TextEditingController(),
      _location = TextEditingController(),
      _notes = TextEditingController();
  String _sun = 'Bright indirect light', _soil = 'General potting mix';
  double _interval = 2;
  bool _saving = false;
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
    final now = DateTime.now();
    final days = _interval.round();
    try {
      await AppServices.garden.addPlant(Plant(
          id: 'plant-${now.microsecondsSinceEpoch}',
          name: _name.text.trim(),
          species: _species.text.trim().isEmpty
              ? 'Unknown species'
              : _species.text.trim(),
          health: 'Not assessed',
          nextWatering: now.add(Duration(days: days)),
          wateringIntervalDays: days,
          sunlight: _sun,
          location:
              _location.text.trim().isEmpty ? 'Garden' : _location.text.trim(),
          soilType: _soil,
          notes: _notes.text.trim(),
          createdAt: now));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${_name.text.trim()} added to your garden.')));
      Navigator.pushReplacementNamed(context, AppRouter.dashboard);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Couldn’t add plant: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: const Text('Add plant',
                style: TextStyle(fontWeight: FontWeight.w800))),
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
                          border: Border.all(color: PlantCareColors.border)),
                      child: const Icon(Icons.eco_outlined,
                          size: 64, color: PlantCareColors.primary)),
                  const SizedBox(height: 24),
                  const _Section(
                      'Plant basics', 'Give your plant a simple identity.'),
                  const SizedBox(height: 8),
                  TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(
                          labelText: 'Plant name', hintText: 'e.g. Tomato'),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Enter a plant name'
                          : null),
                  const SizedBox(height: 16),
                  TextFormField(
                      controller: _species,
                      decoration: const InputDecoration(
                          labelText: 'Species (optional)',
                          hintText: 'e.g. Solanum lycopersicum')),
                  const SizedBox(height: 24),
                  const _Section('Growing conditions',
                      'Tell PlantCare where and how it grows.'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                      initialValue: _sun,
                      decoration: const InputDecoration(
                          labelText: 'Sunlight',
                          prefixIcon: Icon(Icons.wb_sunny_outlined)),
                      items: const [
                        DropdownMenuItem(
                            value: 'Full sun', child: Text('Full sun')),
                        DropdownMenuItem(
                            value: '6–8 hours', child: Text('6–8 hours')),
                        DropdownMenuItem(
                            value: 'Partial sun', child: Text('Partial sun')),
                        DropdownMenuItem(
                            value: 'Bright indirect light',
                            child: Text('Bright indirect light')),
                        DropdownMenuItem(
                            value: 'Low light', child: Text('Low light'))
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _sun = v);
                      }),
                  const SizedBox(height: 16),
                  TextFormField(
                      controller: _location,
                      decoration: const InputDecoration(
                          labelText: 'Garden location',
                          hintText: 'Balcony, terrace, kitchen window',
                          prefixIcon: Icon(Icons.place_outlined))),
                  const SizedBox(height: 16),
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
                        DropdownMenuItem(
                            value: 'Clay soil', child: Text('Clay soil'))
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _soil = v);
                      }),
                  const SizedBox(height: 24),
                  const _Section(
                      'Watering', 'Set a starting reminder interval.'),
                  const SizedBox(height: 8),
                  Text('Every ${_interval.round()} days',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  Slider(
                      value: _interval,
                      min: 1,
                      max: 14,
                      divisions: 13,
                      label: '${_interval.round()} days',
                      onChanged: (v) => setState(() => _interval = v)),
                  const Text(
                      'This is the starting reminder interval. PlantCare can make it smarter later using weather and plant conditions.',
                      style: TextStyle(
                          color: PlantCareColors.muted, fontSize: 12)),
                  const SizedBox(height: 24),
                  const _Section(
                      'Notes', 'Optional details you want to remember.'),
                  const SizedBox(height: 8),
                  TextField(
                      controller: _notes,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(
                          hintText: 'Optional notes about this plant',
                          alignLabelWithHint: true)),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.add_rounded),
                      label: Text(_saving ? 'Adding…' : 'Add to my garden')),
                  const SizedBox(height: 8),
                  const Text(
                      'You can update care details later as your plant grows.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: PlantCareColors.muted, fontSize: 12)),
                ])),
      );
}

class _Section extends StatelessWidget {
  final String title, subtitle;
  const _Section(this.title, this.subtitle);
  @override
  Widget build(BuildContext c) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
        const SizedBox(height: 3),
        Text(subtitle,
            style: const TextStyle(color: PlantCareColors.muted, fontSize: 12))
      ]);
}
