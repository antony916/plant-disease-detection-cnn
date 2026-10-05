import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.semanticLabel,
    this.strong = false,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(PlantCareRadius.card),
    ),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final bool strong;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return _GlassSurface(
      borderRadius: borderRadius,
      padding: padding,
      onTap: onTap,
      semanticLabel: semanticLabel,
      strong: strong,
      child: child,
    );
  }
}

class GlassPill extends StatelessWidget {
  const GlassPill({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
    this.onTap,
    this.semanticLabel,
    this.strong = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return _GlassSurface(
      borderRadius: const BorderRadius.all(
        Radius.circular(PlantCareRadius.pill),
      ),
      padding: padding,
      onTap: onTap,
      semanticLabel: semanticLabel,
      strong: strong,
      child: child,
    );
  }
}

class GlassChip extends StatelessWidget {
  const GlassChip({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.onTap,
    this.semanticLabel,
    this.selected = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return _GlassSurface(
      borderRadius: const BorderRadius.all(
        Radius.circular(PlantCareRadius.pill),
      ),
      padding: padding,
      onTap: onTap,
      semanticLabel: semanticLabel,
      strong: selected,
      child: child,
    );
  }
}

class GlassSheet extends StatelessWidget {
  const GlassSheet({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 18, 20, 24),
    this.onTap,
    this.semanticLabel,
    this.strong = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return _GlassSurface(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(PlantCareRadius.featured),
      ),
      padding: padding,
      onTap: onTap,
      semanticLabel: semanticLabel,
      strong: strong,
      child: child,
    );
  }
}

class GradientButton extends StatefulWidget {
  const GradientButton({
    super.key,
    required this.child,
    this.onPressed,
    this.semanticLabel,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
    this.minimumSize = const Size(0, 44),
  });

  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final EdgeInsetsGeometry padding;
  final Size minimumSize;

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (mounted) {
      setState(() => _pressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduced = PlantCareEffects.reduced(context);
    final enabled = widget.onPressed != null;

    return Semantics(
      button: true,
      enabled: enabled,
      explicitChildNodes: true,
      label: widget.semanticLabel,
      child: GestureDetector(
        onTap: widget.onPressed,
        onTapDown: enabled ? (_) => _setPressed(true) : null,
        onTapUp: enabled ? (_) => _setPressed(false) : null,
        onTapCancel: enabled ? () => _setPressed(false) : null,
        child: AnimatedScale(
          scale: !reduced && _pressed ? 0.97 : 1,
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOut,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: widget.minimumSize.width,
              minHeight: widget.minimumSize.height < 44
                  ? 44
                  : widget.minimumSize.height,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: enabled
                    ? PlantCareGradients.lime
                    : LinearGradient(
                        colors: [
                          PlantCareColors.lime.withValues(alpha: 0.35),
                          PlantCareColors.limeGreen.withValues(alpha: 0.35),
                        ],
                      ),
              ),
              child: Padding(
                padding: widget.padding,
                child: Center(child: widget.child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassSurface extends StatelessWidget {
  const _GlassSurface({
    required this.child,
    required this.borderRadius,
    required this.padding,
    required this.onTap,
    required this.semanticLabel,
    required this.strong,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final reduced = PlantCareEffects.reduced(context);
    final base = Colors.white;
    final fill = PlantCareGlass.fill(base, strong: strong);
    final border = PlantCareGlass.border(base);

    final surface = RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fill,
          borderRadius: borderRadius,
          border: Border.all(color: border),
          boxShadow: reduced
              ? const []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: PlantCareGlass.shadowOpacity,
                    ),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );

    final content = reduced
        ? ClipRRect(
            borderRadius: borderRadius,
            child: surface,
          )
        : ClipRRect(
            borderRadius: borderRadius,
            child: RepaintBoundary(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: PlantCareEffects.blurFor(context),
                  sigmaY: PlantCareEffects.blurFor(context),
                ),
                child: surface,
              ),
            ),
          );

    return Semantics(
      container: true,
      explicitChildNodes: true,
      button: onTap != null,
      label: semanticLabel,
      child: onTap == null
          ? content
          : GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: content,
            ),
    );
  }
}
