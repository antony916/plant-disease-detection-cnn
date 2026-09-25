import 'package:flutter/material.dart';

import '../../core/app_services.dart';
import '../../core/navigation/app_router.dart';
import '../../core/services/diagnosis_service.dart';
import '../../core/theme/app_theme.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _isAnalyzing = false;
  String? _error;

  Future<void> _analyze() async {
    if (_isAnalyzing) return;

    setState(() {
      _isAnalyzing = true;
      _error = null;
    });

    try {
      final DiagnosisResult result = await AppServices.diagnosis.diagnose(
        imagePath: 'demo://scanner-capture',
        plantHint: 'Tomato',
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
      body: Padding(
        padding: const EdgeInsets.all(PlantCareSpacing.lg),
        child: Column(
          children: [
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
                              style: TextStyle(color: PlantCareColors.muted),
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
                    onPressed: _isAnalyzing ? null : _analyze,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Upload photo'),
                  ),
                ),
                const SizedBox(width: PlantCareSpacing.sm),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isAnalyzing ? null : _analyze,
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Take photo'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: PlantCareSpacing.sm),
            const Text(
              'PlantCare will only show a diagnosis when the model has enough confidence. Uncertain cases can be sent for expert review.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: PlantCareColors.muted,
                fontSize: 12,
              ),
            ),
          ],
        ),
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
