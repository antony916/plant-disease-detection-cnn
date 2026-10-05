import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:plantcare_ai/core/ui/glass_components.dart';

Widget _host(Widget child, {bool reduced = false}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(
        disableAnimations: reduced,
        accessibleNavigation: reduced,
      ),
      child: Scaffold(
        body: Center(child: child),
      ),
    ),
  );
}

void main() {
  testWidgets('GlassCard renders with semantics and tap callback',
      (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _host(
        GlassCard(
          semanticLabel: 'card label',
          onTap: () => taps++,
          child: const Text('Card'),
        ),
      ),
    );

    expect(find.text('Card'), findsOneWidget);
    final semantics = SemanticsTester(tester);
    addTearDown(semantics.dispose);
    expect(semantics, includesNodeWith(label: 'card label'));
    await tester.tap(find.text('Card'));
    expect(taps, 1);
  });

  testWidgets('GlassCard reduced-effects path skips BackdropFilter',
      (tester) async {
    await tester.pumpWidget(
      _host(
        const GlassCard(child: Text('Card')),
        reduced: true,
      ),
    );

    expect(find.byType(BackdropFilter), findsNothing);
    expect(find.text('Card'), findsOneWidget);
  });

  testWidgets('GlassPill renders with semantics and tap callback',
      (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _host(
        GlassPill(
          semanticLabel: 'pill label',
          onTap: () => taps++,
          child: const Text('Pill'),
        ),
      ),
    );

    final semantics = SemanticsTester(tester);
    addTearDown(semantics.dispose);
    expect(semantics, includesNodeWith(label: 'pill label'));
    await tester.tap(find.text('Pill'));
    expect(taps, 1);
  });

  testWidgets('GlassPill reduced-effects path skips BackdropFilter',
      (tester) async {
    await tester.pumpWidget(
      _host(
        const GlassPill(child: Text('Pill')),
        reduced: true,
      ),
    );

    expect(find.byType(BackdropFilter), findsNothing);
  });

  testWidgets('GlassChip renders with semantics and tap callback',
      (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _host(
        GlassChip(
          semanticLabel: 'chip label',
          onTap: () => taps++,
          child: const Text('Chip'),
        ),
      ),
    );

    final semantics = SemanticsTester(tester);
    addTearDown(semantics.dispose);
    expect(semantics, includesNodeWith(label: 'chip label'));
    await tester.tap(find.text('Chip'));
    expect(taps, 1);
  });

  testWidgets('GlassChip reduced-effects path skips BackdropFilter',
      (tester) async {
    await tester.pumpWidget(
      _host(
        const GlassChip(child: Text('Chip')),
        reduced: true,
      ),
    );

    expect(find.byType(BackdropFilter), findsNothing);
  });

  testWidgets('GlassSheet renders with semantics and tap callback',
      (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _host(
        GlassSheet(
          semanticLabel: 'sheet label',
          onTap: () => taps++,
          child: const Text('Sheet'),
        ),
      ),
    );

    final semantics = SemanticsTester(tester);
    addTearDown(semantics.dispose);
    expect(semantics, includesNodeWith(label: 'sheet label'));
    await tester.tap(find.text('Sheet'));
    expect(taps, 1);
  });

  testWidgets('GlassSheet reduced-effects path skips BackdropFilter',
      (tester) async {
    await tester.pumpWidget(
      _host(
        const GlassSheet(child: Text('Sheet')),
        reduced: true,
      ),
    );

    expect(find.byType(BackdropFilter), findsNothing);
  });

  testWidgets('GradientButton renders, exposes semantics and taps',
      (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _host(
        GradientButton(
          semanticLabel: 'save label',
          onPressed: () => taps++,
          child: const Text('Save'),
        ),
      ),
    );

    final semantics = SemanticsTester(tester);
    addTearDown(semantics.dispose);
    expect(semantics, includesNodeWith(label: 'save label'));
    expect(
      tester.getSize(find.byType(GradientButton)).height,
      greaterThanOrEqualTo(44),
    );

    await tester.tap(find.text('Save'));
    expect(taps, 1);
  });

  testWidgets('GradientButton reduced-effects path keeps scale at 1',
      (tester) async {
    await tester.pumpWidget(
      _host(
        const GradientButton(child: Text('Save')),
        reduced: true,
      ),
    );

    final scale = tester.widget<AnimatedScale>(
      find.byType(AnimatedScale),
    );
    expect(scale.scale, 1);
  });
}
