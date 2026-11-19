import 'dart:ui' as ui;

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/navigation/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

const double _cardSize = 100;
const Key _captureKey = Key('shell-capture');
const Key _cardKey = Key('shell-card');

Widget _shell({double keyboard = 0, Widget? page}) => RepaintBoundary(
  key: _captureKey,
  child: MediaQuery(
    data: MediaQueryData(
      disableAnimations: true,
      viewInsets: EdgeInsets.only(bottom: keyboard),
    ),
    child: MaterialApp(
      home: BlocProvider(
        create: (_) => SectionLoaderCubit(),
        child: MainShellPage(
          location: RoutesConfig.home,
          // Página de prueba: fondo transparente y una tarjeta en la zona de la ola.
          child:
              page ??
              Scaffold(
                backgroundColor: Colors.transparent,
                body: Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    key: _cardKey,
                    width: _cardSize,
                    height: _cardSize,
                    color: AppColors.accent,
                  ),
                ),
              ),
        ),
      ),
    ),
  ),
);

Stack _bodyStack(WidgetTester tester) => tester.widget<Stack>(
  find.descendant(
    of: find.byType(MainShellPage),
    matching: find.byWidgetPredicate(
      (widget) =>
          widget is Stack &&
          widget.children.any(
            (child) => child is NotificationListener<ScrollUpdateNotification>,
          ),
    ),
  ),
);

Future<Color> _pixel(WidgetTester tester, Offset at) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(_captureKey),
  );
  final color = await tester.runAsync(() async {
    final image = await boundary.toImage();
    final data = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    final offset = (at.dy.toInt() * image.width + at.dx.toInt()) * 4;
    return Color.fromARGB(
      data.getUint8(offset + 3),
      data.getUint8(offset),
      data.getUint8(offset + 1),
      data.getUint8(offset + 2),
    );
  });
  return color!;
}

void main() {
  testWidgets('orden de capas: ola, contenido, aviso y menú al final', (
    tester,
  ) async {
    await tester.pumpWidget(_shell());
    final children = _bodyStack(tester).children;
    expect(children, hasLength(4));
    final wave = children[0] as Positioned;
    expect(
      find.descendant(
        of: find.byWidget(wave),
        matching: find.byType(WaveFooterWidget),
      ),
      findsOneWidget,
    );
    expect(children[1], isA<NotificationListener<ScrollUpdateNotification>>());
    final nav = children[3] as Positioned;
    expect(
      find.descendant(
        of: find.byWidget(nav),
        matching: find.byType(FloatingNavBar),
      ),
      findsOneWidget,
    );
    // El fondo blanco lo pone el marco; la página no pinta uno propio.
    final shell = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(shell.backgroundColor, AppColors.background);
    final page = tester.widget<Scaffold>(find.byType(Scaffold).at(1));
    expect(page.backgroundColor, Colors.transparent);
  });

  testWidgets('una tarjeta en la zona de la ola se pinta por delante de ella', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_shell());
    final card = tester.getRect(find.byKey(_cardKey));
    final waveTop = 600 - NavConfig.waveFootprint(0);
    // La tarjeta entra de lleno en la zona de la ola.
    expect(card.top, greaterThan(waveTop));
    // Dentro de la tarjeta se ve su color, no el de la ola.
    expect(await _pixel(tester, card.center), AppColors.accent);
    // Junto a la tarjeta, en la parte lisa de la ola, se ve la tinta.
    expect(await _pixel(tester, Offset(card.width + 50, 590)), AppColors.ink);
  });

  testWidgets('el menú flotante queda por encima de la ola', (tester) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_shell());
    final nav = tester.getRect(find.byType(FloatingNavBar));
    final waveTop = 600 - NavConfig.waveFootprint(0);
    expect(nav.top, greaterThan(waveTop));
    expect(nav.bottom, lessThanOrEqualTo(600));
    expect(find.byType(FloatingNavBar).hitTestable(), findsOneWidget);
  });

  testWidgets('con el teclado abierto no hay ola ni menú visible', (
    tester,
  ) async {
    await tester.pumpWidget(_shell(keyboard: 300));
    expect(find.byType(WaveFooterWidget), findsNothing);
    expect(
      tester.widget<FloatingNavBar>(find.byType(FloatingNavBar)).visible,
      isFalse,
    );
    // El contenido conserva su lugar en el árbol.
    expect(find.byKey(_cardKey), findsOneWidget);
  });
}
