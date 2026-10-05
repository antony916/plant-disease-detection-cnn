import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'glass_components.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.helperText,
    this.actionLabel,
    this.onAction,
    this.semanticLabel,
  });

  final IconData icon;
  final String title;
  final String helperText;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PlantCareSpacing.xl),
        child: GlassCard(
          semanticLabel: semanticLabel ?? title,
          padding: const EdgeInsets.all(PlantCareSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GlassPill(
                padding: const EdgeInsets.all(14),
                child: Icon(
                  icon,
                  size: 30,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: PlantCareSpacing.md),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: PlantCareSpacing.sm),
              Text(
                helperText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              if (actionLabel != null && onAction != null)
                Padding(
                  padding: const EdgeInsets.only(top: PlantCareSpacing.lg),
                  child: GradientButton(
                    semanticLabel: actionLabel,
                    onPressed: onAction,
                    child: Text(actionLabel!),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
