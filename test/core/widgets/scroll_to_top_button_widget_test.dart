import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(ScrollController controller, {bool disableAnimations = false}) =>
    MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(disableAnimations: disableAnimations),
        child: child!,
      ),
      home: Scaffold(
        body: Stack(
          children: [
            ListView.builder(
              controller: controller,
              itemCount: 100,
              itemBuilder: (_, i) =>
                  SizedBox(height: 60, child: Text('fila $i')),
            ),
            ScrollToTopButton(controller: controller),
          ],
        ),
      ),
    );

double _opacity(WidgetTester tester) => tester
    .widget<AnimatedOpacity>(
      find.ancestor(
        of: find.byKey(const ValueKey('scroll-to-top-button')),
        matching: find.byType(AnimatedOpacity),
      ),
    )
    .opacity;

void main() {
  testWidgets('aparece pasado el umbral y se oculta cerca del inicio', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(_host(controller, disableAnimations: true));
    expect(_opacity(tester), 0);
    controller.jumpTo(ScrollConfig.topButtonShowThreshold + 100);
    await tester.pump();
    expect(_opacity(tester), 1);
    controller.jumpTo(10);
    await tester.pump();
    expect(_opacity(tester), 0);
  });

  testWidgets('al tocarlo sube al inicio con animación', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(_host(controller));
    controller.jumpTo(2000);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const ValueKey('scroll-to-top-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(controller.offset, greaterThan(0));
    await tester.pumpAndSettle();
    expect(controller.offset, 0);
  });

  testWidgets('con disableAnimations salta directo', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(_host(controller, disableAnimations: true));
    controller.jumpTo(2000);
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('scroll-to-top-button')));
    await tester.pump();
    expect(controller.offset, 0);
  });

  testWidgets('con el teclado abierto no se ve ni responde', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(_host(controller, disableAnimations: true));
    controller.jumpTo(2000);
    await tester.pump();
    expect(_opacity(tester), 0);
  });

  testWidgets('queda por encima de la barra flotante de navegación', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(_host(controller, disableAnimations: true));
    final bottom =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    final rect = tester.getRect(
      find.byKey(const ValueKey('scroll-to-top-button')),
    );
    expect(
      rect.bottom,
      bottom - NavConfig.footprint - ScrollConfig.topButtonNavGap,
    );
  });
}
