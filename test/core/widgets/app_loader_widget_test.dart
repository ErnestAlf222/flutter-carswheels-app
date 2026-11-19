import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

Widget _host({bool compact = false, bool disableAnimations = false}) =>
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: Scaffold(body: AppLoader(compact: compact)),
      ),
    );

double _carLeft(WidgetTester tester) =>
    tester.getTopLeft(find.byIcon(Symbols.directions_car)).dx;

void main() {
  testWidgets('dibuja el carrito en tinta con el tamaño de overlay', (
    tester,
  ) async {
    await tester.pumpWidget(_host());
    final icon = tester.widget<Icon>(find.byIcon(Symbols.directions_car));
    expect(icon.size, UiConfig.loaderCarSize);
    expect(icon.color, AppColors.ink);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('la variante compacta usa el tamaño compacto', (tester) async {
    await tester.pumpWidget(_host(compact: true));
    final icon = tester.widget<Icon>(find.byIcon(Symbols.directions_car));
    expect(icon.size, UiConfig.loaderCompactCarSize);
  });

  testWidgets('el carrito avanza de izquierda a derecha', (tester) async {
    await tester.pumpWidget(_host());
    final start = _carLeft(tester);
    await tester.pump(
      const Duration(
        milliseconds: AnimationConfig.loaderCycleMilliseconds ~/ 2,
      ),
    );
    expect(_carLeft(tester), greaterThan(start));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('con disableAnimations queda quieto y visible', (tester) async {
    await tester.pumpWidget(_host(disableAnimations: true));
    final before = _carLeft(tester);
    await tester.pump(const Duration(seconds: 2));
    expect(_carLeft(tester), before);
    expect(find.byIcon(Symbols.directions_car), findsOneWidget);
    // Sin bucle, no quedan cuadros pendientes.
    expect(tester.hasRunningAnimations, isFalse);
  });
}
