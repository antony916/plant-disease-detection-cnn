import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/app_services.dart';
import '../../core/models/plant.dart';
import '../../core/navigation/app_router.dart';
import '../../core/services/diagnosis_service.dart';
import '../../core/theme/app_theme.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  late Future<List<Plant>> _plantsFuture;
  String? _selectedPlantId;
  bool _isAnalyzing = false;
  String? _error;
  final ImagePicker _picker = ImagePicker();
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    _plantsFuture = _loadPlants();
  }

  Future<List<Plant>> _loadPlants() async {
    final plants = await AppServices.garden.getPlants();
    if (_selectedPlantId == null && plants.isNotEmpty) {
      final preferred = plants.where(
        (plant) => plant.name.toLowerCase() == 'tomato',
      );
      _selectedPlantId =
          preferred.isNotEmpty ? preferred.first.id : plants.first.id;
    }
    return plants;
  }

  Plant? _selectedPlant(List<Plant> plants) {
    if (_selectedPlantId == null) return null;
    for (final plant in plants) {
      if (plant.id == _selectedPlantId) return plant;
    }
    return null;
  }

  Future<void> _pickAndAnalyze(ImageSource source) async {
    if (_isAnalyzing) return;

    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 90,
      maxWidth: 2048,
      maxHeight: 2048,
    );
    if (picked == null) return;

    setState(() {
      _selectedImagePath = picked.path;
      _error = null;
    });

    await _analyze();
  }

  Future<void> _analyze() async {
    if (_isAnalyzing) return;

    final imagePath = _selectedImagePath;
    if (imagePath == null || imagePath.isEmpty) {
      setState(() {
        _error = 'Choose or capture a plant photo first.';
      });
      return;
    }

    final plants = await _plantsFuture;
    final plant = _selectedPlant(plants);

    if (plant == null) {
      setState(() {
        _error = 'Add a plant to your garden before starting a diagnosis.';
      });
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _error = null;
    });

    try {
      final user = await AppServices.auth.currentUser();
      if (user == null) {
        throw StateError('Sign in required.');
      }

      final storedImage = await AppServices.imageStorage.uploadPlantImage(
        filePath: imagePath,
        userId: user.id,
      );

      final DiagnosisResult result = await AppServices.diagnosis.diagnose(
        imagePath: imagePath,
        imageReference: storedImage,
        plantId: plant.id,
        plantHint: plant.name,
      );

      if (!mounted) return;
      Navigator.pushNamed(
        context,
        AppRouter.diagnosis,
        arguments: result,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'We could not analyze this image. Please try another photo.';
      });
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Plant Scanner',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: FutureBuilder<List<Plant>>(
        future: _plantsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'We could not load your garden. Please try again.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final plants = snapshot.data ?? const <Plant>[];
          final selected = _selectedPlant(plants);

          return Padding(
            padding: const EdgeInsets.all(PlantCareSpacing.lg),
            child: Column(
              children: [
                if (plants.isNotEmpty) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Diagnose a plant',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  const SizedBox(height: PlantCareSpacing.sm),
                  DropdownButtonFormField<String>(
                    initialValue: selected?.id,
                    decoration: const InputDecoration(
                      labelText: 'Garden plant',
                      prefixIcon: Icon(Icons.eco_outlined),
                    ),
                    items: [
                      for (final plant in plants)
                        DropdownMenuItem(
                          value: plant.id,
                          child: Text(plant.name),
                        ),
                    ],
                    onChanged: _isAnalyzing
                        ? null
                        : (value) {
                            setState(() {
                              _selectedPlantId = value;
                              _error = null;
                            });
                          },
                  ),
                  const SizedBox(height: PlantCareSpacing.md),
                ] else
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(PlantCareSpacing.md),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: PlantCareColors.primary,
                          ),
                          const SizedBox(width: PlantCareSpacing.sm),
                          const Expanded(
                            child: Text(
                              'Add a plant to your garden before scanning so the diagnosis can be saved to the correct plant.',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EEE9),
                      borderRadius: BorderRadius.circular(
                        PlantCareRadius.featured,
                      ),
                      border: Border.all(color: PlantCareColors.border),
                    ),
                    child: _isAnalyzing
                        ? const _AnalyzingState()
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add,
                                size: 42,
                                color: PlantCareColors.primary,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Position the affected leaf inside the frame',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 8),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 32),
                                child: Text(
                                  'Use daylight and avoid blur for a clearer diagnosis.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: PlantCareColors.muted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: PlantCareSpacing.sm),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: PlantCareColors.danger),
                  ),
                ],
                const SizedBox(height: PlantCareSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isAnalyzing ? null : () => _pickAndAnalyze(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Upload photo'),
                      ),
                    ),
                    const SizedBox(width: PlantCareSpacing.sm),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _isAnalyzing ? null : () => _pickAndAnalyze(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: const Text('Take photo'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: PlantCareSpacing.sm),
                Text(
                  selected == null
                      ? 'Select a garden plant before starting a diagnosis.'
                      : 'Scanning ${selected.name}. PlantCare will save the result to this plant when the analysis completes.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: PlantCareColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const AppBottomNav(selectedIndex: 1),
    );
  }
}

class _AnalyzingState extends StatelessWidget {
  const _AnalyzingState();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 18),
        Text(
          'Analyzing your plant…',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 6),
        Text(
          'Checking the image for known disease patterns.',
          textAlign: TextAlign.center,
          style: TextStyle(color: PlantCareColors.muted),
        ),
      ],
    );
  }
}
