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
    expect(find.bySemanticsLabel('card label'), findsOneWidget);
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

    expect(find.bySemanticsLabel('pill label'), findsOneWidget);
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

    expect(find.bySemanticsLabel('chip label'), findsOneWidget);
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

    expect(find.bySemanticsLabel('sheet label'), findsOneWidget);
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

    expect(find.bySemanticsLabel('save label'), findsOneWidget);
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
