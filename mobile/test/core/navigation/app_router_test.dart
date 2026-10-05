import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:plantcare_ai/core/navigation/app_router.dart';

class _RecordingObserver extends NavigatorObserver {
  String? lastRoute;

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    lastRoute = newRoute?.settings.name;
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}

void main() {
  testWidgets('root navigation shows exactly four approved tabs',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const Scaffold(
          body: AppBottomNav(selectedIndex: 0),
        ),
      ),
    );

    expect(find.text('Garden'), findsOneWidget);
    expect(find.text('Scan'), findsOneWidget);
    expect(find.text('Library'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Health'), findsNothing);
    expect(
      find.byType(GestureDetector),
      findsNWidgets(4),
    );
  });

  testWidgets('root tabs map to Garden, Scan, Library and Profile routes',
      (tester) async {
    final observer = _RecordingObserver();

    Widget pageFor(String route) {
      final index = switch (route) {
        AppRouter.dashboard => 0,
        AppRouter.scanner => 1,
        AppRouter.library => 2,
        AppRouter.profile => 3,
        _ => 0,
      };
      return Scaffold(body: AppBottomNav(selectedIndex: index));
    }

    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [observer],
        home: const Scaffold(
          body: AppBottomNav(selectedIndex: 0),
        ),
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => pageFor(settings.name ?? AppRouter.dashboard),
          );
        },
      ),
    );

    await tester.tap(find.text('Scan'));
    await tester.pumpAndSettle();
    expect(observer.lastRoute, AppRouter.scanner);

    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();
    expect(observer.lastRoute, AppRouter.library);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(observer.lastRoute, AppRouter.profile);

    await tester.tap(find.text('Garden'));
    await tester.pumpAndSettle();
    expect(observer.lastRoute, AppRouter.dashboard);
  });
}
