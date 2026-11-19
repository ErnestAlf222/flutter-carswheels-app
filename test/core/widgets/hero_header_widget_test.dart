import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('el encabezado es tinta, con las esquinas del tema', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: HeroHeaderWidget(child: Text('hola'))),
      ),
    );
    final box = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(HeroHeaderWidget),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    final decoration = box.decoration as BoxDecoration;
    expect(decoration.color, AppColors.ink);
    expect(decoration.gradient, isNull);
    expect(
      decoration.borderRadius,
      const BorderRadius.vertical(
        bottom: Radius.circular(HeaderConfig.bottomRadius),
      ),
    );
    expect(find.text('hola'), findsOneWidget);
  });

  testWidgets('trae un único resplandor amarillo radial', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: HeroHeaderWidget(child: Text('hola'))),
      ),
    );
    final glows = tester
        .widgetList<Container>(find.byType(Container))
        .where(
          (c) => (c.decoration as BoxDecoration?)?.gradient is RadialGradient,
        )
        .toList();
    expect(glows, hasLength(1));
    final gradient =
        (glows.single.decoration! as BoxDecoration).gradient! as RadialGradient;
    expect(
      gradient.colors.first,
      AppColors.accent.withValues(alpha: HeaderConfig.glowOpacity),
    );
  });

  testWidgets('el relleno superior respeta el área segura', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(padding: const EdgeInsets.only(top: 40)),
          child: child!,
        ),
        home: const Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: HeroHeaderWidget(child: Text('hola')),
          ),
        ),
      ),
    );
    expect(
      tester.getTopLeft(find.text('hola')).dy,
      40 + HeaderConfig.contentTopPadding,
    );
  });
}
