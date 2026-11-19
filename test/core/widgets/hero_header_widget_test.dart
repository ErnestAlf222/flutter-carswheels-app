import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('el encabezado dibuja la ola tinta de su perfil', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: HeroHeaderWidget(child: Text('hola'))),
      ),
    );
    final painter = tester
        .widgetList<CustomPaint>(
          find.descendant(
            of: find.byType(HeroHeaderWidget),
            matching: find.byType(CustomPaint),
          ),
        )
        .map((paint) => paint.painter)
        .whereType<WavePainter>()
        .single;
    expect(painter.color, AppColors.ink);
    expect(painter.shape, WaveConfig.headerWave);
    expect(find.byType(ClipPath), findsOneWidget);
    expect(find.text('hola'), findsOneWidget);
  });

  testWidgets('el contenido queda por encima de la banda curva', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: HeroHeaderWidget(child: SizedBox(key: Key('c'), height: 10)),
          ),
        ),
      ),
    );
    final header = tester.getRect(find.byType(HeroHeaderWidget));
    final content = tester.getRect(find.byKey(const Key('c')));
    expect(
      content.bottom,
      header.bottom -
          HeaderConfig.contentBottomPadding -
          WaveConfig.headerWave.amplitude,
    );
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
    expect(gradient.colors.first, AppColors.inkSoft);
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
