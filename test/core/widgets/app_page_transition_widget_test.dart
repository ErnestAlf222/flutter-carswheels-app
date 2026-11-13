import 'package:animations/animations.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('con disableAnimations cambia de inmediato', (tester) async {
    Widget build(String text) => MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: AppPageTransition(child: Text(text, key: ValueKey(text))),
      ),
    );
    await tester.pumpWidget(build(AppTexts.homePageTitle));
    await tester.pumpWidget(build(AppTexts.searchPageTitle));
    await tester.pump();
    expect(find.text(AppTexts.homePageTitle), findsNothing);
    expect(find.text(AppTexts.searchPageTitle), findsOneWidget);
  });

  group('flowRouteTransition', () {
    Widget host({required bool still, required Animation<double> animation}) =>
        MediaQuery(
          data: MediaQueryData(disableAnimations: still),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) => AppPageTransition.flowRouteTransition(
                context,
                animation,
                kAlwaysDismissedAnimation,
                const Text('flujo'),
              ),
            ),
          ),
        );

    testWidgets('con disableAnimations devuelve el hijo tal cual', (
      tester,
    ) async {
      final controller = AnimationController(
        vsync: tester,
        value: 0,
        duration: AppPageTransition.duration,
      );
      addTearDown(controller.dispose);
      await tester.pumpWidget(host(still: true, animation: controller));
      expect(find.byType(SharedAxisTransition), findsNothing);
      expect(find.text('flujo'), findsOneWidget);
    });

    testWidgets('con animaciones usa un eje compartido horizontal', (
      tester,
    ) async {
      final controller = AnimationController(
        vsync: tester,
        value: 0.5,
        duration: AppPageTransition.duration,
      );
      addTearDown(controller.dispose);
      await tester.pumpWidget(host(still: false, animation: controller));
      final transition = tester.widget<SharedAxisTransition>(
        find.byType(SharedAxisTransition),
      );
      expect(transition.transitionType, SharedAxisTransitionType.horizontal);
      expect(find.text('flujo'), findsOneWidget);
    });
  });
}
