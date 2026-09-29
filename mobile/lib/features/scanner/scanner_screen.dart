import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/app_services.dart';
import '../../core/models/plant.dart';
import '../../core/navigation/app_router.dart';
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
      _selectedPlantId = plants.first.id;
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

  Future<void> _pick(ImageSource source) async {
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
  }

  Future<void> _analyze() async {
    if (_isAnalyzing) return;

    final imagePath = _selectedImagePath;
    if (imagePath == null || imagePath.isEmpty) {
      setState(() => _error = 'Choose or capture a plant photo first.');
      return;
    }

    final plants = await _plantsFuture;
    final plant = _selectedPlant(plants);
    if (plant == null) {
      setState(
        () =>
            _error = 'Add a plant to your garden before starting a diagnosis.',
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _error = null;
    });

    try {
      final user = await AppServices.auth.currentUser();
      if (user == null) throw StateError('Sign in required.');

      final storedImage = await AppServices.imageStorage.uploadPlantImage(
        filePath: imagePath,
        userId: user.id,
      );

      final result = await AppServices.diagnosis.diagnose(
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
      setState(
        () => _error =
            'We could not analyze this image. Please try another photo.',
      );
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<Plant>>(
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

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Scan a plant',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -.5,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Photo in. Plant health out.',
                            style: TextStyle(color: PlantCareColors.muted),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Diagnosis history',
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRouter.diagnosisHistory,
                      ),
                      icon: const Icon(Icons.history_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (plants.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: PlantCareColors.warm,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: PlantCareColors.warning,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Add a plant first so the diagnosis can be saved to your garden.',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            AppRouter.addPlant,
                          ),
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                  )
                else ...[
                  const Text(
                    'Choose plant',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: selected?.id,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.eco_outlined),
                      hintText: 'Select from your garden',
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
                        : (value) => setState(() {
                              _selectedPlantId = value;
                              _error = null;
                            }),
                  ),
                ],
                const SizedBox(height: 12),
                Container(
                  height: 330,
                  decoration: BoxDecoration(
                    color: PlantCareColors.softGreen,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: PlantCareColors.border),
                  ),
                  child: _isAnalyzing
                      ? const _AnalyzingState()
                      : _selectedImagePath != null
                          ? _ImagePreview(
                              path: _selectedImagePath!,
                              onClear: () => setState(() {
                                _selectedImagePath = null;
                                _error = null;
                              }),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.document_scanner_outlined,
                                  size: 52,
                                  color: PlantCareColors.primary,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Capture a clear leaf photo',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 32),
                                  child: Text(
                                    'Use daylight, keep the leaf in focus and fill most of the frame.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: PlantCareColors.muted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: PlantCareColors.danger),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isAnalyzing
                            ? null
                            : () => _pick(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_outlined),
                        label: Text(
                          _selectedImagePath == null ? 'Upload' : 'Change',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _isAnalyzing
                            ? null
                            : () => _pick(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: Text(
                          _selectedImagePath == null ? 'Camera' : 'Retake',
                        ),
                      ),
                    ),
                  ],
                ),
                if (_selectedImagePath != null && !_isAnalyzing) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: selected == null ? null : _analyze,
                      icon: const Icon(Icons.auto_awesome_rounded),
                      label: const Text('Analyze this photo'),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  selected == null
                      ? 'Select a garden plant before analyzing.'
                      : 'Ready to scan ' + selected.name + '.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: PlantCareColors.muted,
                    fontSize: 11,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: const AppBottomNav(selectedIndex: 1),
    );
  }
}

class _AnalyzingState extends StatefulWidget {
  const _AnalyzingState();

  @override
  State<_AnalyzingState> createState() => _AnalyzingStateState();
}

class _AnalyzingStateState extends State<_AnalyzingState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .8),
                shape: BoxShape.circle,
                border: Border.all(
                  color: PlantCareColors.primary.withValues(alpha: .18),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.eco_rounded,
                size: 54,
                color: PlantCareColors.primary,
              ),
            ),
          ),
          Positioned(
            left: 28,
            right: 28,
            top: 65 + (_controller.value * 180),
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                color: PlantCareColors.primary,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 28,
            child: Column(
              children: [
                Text(
                  'AI is reading your plant',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
                ),
                SizedBox(height: 5),
                Text(
                  'Checking visual patterns and disease signals…',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: PlantCareColors.muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final String path;
  final VoidCallback onClear;

  const _ImagePreview({
    required this.path,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.file(
            File(path),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.broken_image_outlined, size: 48),
            ),
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: IconButton.filledTonal(
            tooltip: 'Remove selected photo',
            onPressed: onClear,
            icon: const Icon(Icons.close),
          ),
        ),
      ],
    );
  }
}
