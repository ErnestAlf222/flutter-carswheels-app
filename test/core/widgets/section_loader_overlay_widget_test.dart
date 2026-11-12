import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final taps = <int>[];

  Widget host({required bool visible, bool disableAnimations = false}) =>
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: disableAnimations),
          child: Scaffold(
            body: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => taps.add(1),
                  ),
                ),
                Positioned.fill(child: SectionLoaderOverlay(visible: visible)),
              ],
            ),
          ),
        ),
      );

  setUp(taps.clear);

  testWidgets('oculto no construye el loader', (tester) async {
    await tester.pumpWidget(host(visible: false));
    expect(find.byType(AppLoader), findsNothing);
  });

  testWidgets('visible cubre toda el área con el color de fondo', (
    tester,
  ) async {
    await tester.pumpWidget(host(visible: true));
    await tester.pump(
      const Duration(
        milliseconds: AnimationConfig.sectionLoaderFadeMilliseconds,
      ),
    );
    final layer = find.descendant(
      of: find.byType(SectionLoaderOverlay),
      matching: find.byType(ColoredBox),
    );
    expect(tester.widget<ColoredBox>(layer).color, AppColors.background);
    expect(tester.getSize(layer), tester.getSize(find.byType(Scaffold)));
    expect(find.byType(ClipOval), findsNothing);
    final loaderBox = find.ancestor(
      of: find.byType(AppLoader),
      matching: find.byType(SizedBox),
    );
    expect(
      tester.getSize(loaderBox.first),
      const Size.square(UiConfig.sectionLoaderSize),
    );
    expect(
      tester.getCenter(find.byType(AppLoader)),
      tester.getCenter(find.byType(Scaffold)),
    );
  });

  testWidgets('aparece y desaparece con un fundido', (tester) async {
    await tester.pumpWidget(host(visible: false));
    await tester.pumpWidget(host(visible: true));
    await tester.pump(
      const Duration(
        milliseconds: AnimationConfig.sectionLoaderFadeMilliseconds ~/ 2,
      ),
    );
    final fade = tester.widget<FadeTransition>(
      find
          .descendant(
            of: find.byType(AnimatedSwitcher),
            matching: find.byType(FadeTransition),
          )
          .first,
    );
    expect(fade.opacity.value, inExclusiveRange(0.0, 1.0));
    await tester.pumpAndSettle();
    await tester.pumpWidget(host(visible: false));
    await tester.pumpAndSettle();
    expect(find.byType(AppLoader), findsNothing);
  });

  testWidgets('con disableAnimations aparece y desaparece sin fundido', (
    tester,
  ) async {
    await tester.pumpWidget(host(visible: false, disableAnimations: true));
    await tester.pumpWidget(host(visible: true, disableAnimations: true));
    await tester.pump();
    expect(find.byType(AppLoader), findsOneWidget);
    await tester.pumpWidget(host(visible: false, disableAnimations: true));
    await tester.pump();
    expect(find.byType(AppLoader), findsNothing);
  });

  testWidgets('visible absorbe los toques sobre el contenido', (tester) async {
    await tester.pumpWidget(host(visible: true));
    await tester.pump(
      const Duration(
        milliseconds: AnimationConfig.sectionLoaderFadeMilliseconds,
      ),
    );
    await tester.tapAt(tester.getCenter(find.byType(Scaffold)));
    expect(taps, isEmpty);
  });

  testWidgets('oculto deja pasar los toques al contenido', (tester) async {
    await tester.pumpWidget(host(visible: false));
    await tester.tapAt(tester.getCenter(find.byType(Scaffold)));
    expect(taps, hasLength(1));
  });
}
