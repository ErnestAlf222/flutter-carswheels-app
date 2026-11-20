import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

// Color real de un píxel del encabezado ya pintado, sin tintes ni degradados.
Future<Color> _pixelAt(
  WidgetTester tester,
  GlobalKey boundaryKey,
  Offset logical,
) async {
  final boundary =
      boundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await boundary.toImage();
  final data = (await image.toByteData())!;
  final width = image.width;
  final index = (logical.dy.toInt() * width + logical.dx.toInt()) * 4;
  return Color.fromARGB(
    data.getUint8(index + 3),
    data.getUint8(index),
    data.getUint8(index + 1),
    data.getUint8(index + 2),
  );
}

void main() {
  testWidgets('el encabezado es tinta plana, con las esquinas del tema', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: HeroHeaderWidget(child: Text('hola'))),
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
    // Sin brillo radial ni ninguna otra capa con degradado.
    final gradients = tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .where((b) => (b.decoration as BoxDecoration).gradient != null);
    expect(gradients, isEmpty);
  });

  testWidgets(
    'el color renderizado es exactamente la tinta en todo el encabezado',
    (tester) async {
      final key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: RepaintBoundary(
                key: key,
                child: const SizedBox(
                  width: 300,
                  height: 160,
                  child: HeroHeaderWidget(child: SizedBox.expand()),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.runAsync(() async {
        // Esquina superior izquierda, centro y zona derecha donde estaba el brillo.
        for (final point in const [
          Offset(4, 4),
          Offset(150, 60),
          Offset(290, 10),
          Offset(250, 100),
        ]) {
          final color = await _pixelAt(tester, key, point);
          expect(color.toARGB32(), AppColors.ink.toARGB32(), reason: '$point');
        }
      });
    },
  );

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

  testWidgets('con la banda fija el área segura no se suma otra vez', (
    tester,
  ) async {
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
            child: HeroHeaderWidget(
              includeTopInset: false,
              child: Text('hola'),
            ),
          ),
        ),
      ),
    );
    expect(
      tester.getTopLeft(find.text('hola')).dy,
      HeaderConfig.contentTopPadding,
    );
  });

  test('el tema no aplica ningún tinte de superficie', () {
    final theme = AppTheme.light;
    expect(theme.colorScheme.surfaceTint, Colors.transparent);
    expect(theme.cardTheme.surfaceTintColor, Colors.transparent);
    expect(theme.bottomSheetTheme.surfaceTintColor, Colors.transparent);
    expect(theme.dialogTheme.surfaceTintColor, Colors.transparent);
    expect(theme.popupMenuTheme.surfaceTintColor, Colors.transparent);
    expect(theme.appBarTheme.surfaceTintColor, Colors.transparent);
    expect(theme.colorScheme.primary, AppColors.ink);
  });
}
