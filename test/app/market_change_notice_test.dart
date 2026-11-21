import 'package:cars_wheels_app/app/market_catalog/market_change_celebration.dart';
import 'package:cars_wheels_app/app/market_catalog/market_change_notice.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/market/market.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../support/market_test_support.dart';

// Pantalla con un botón que lanza el aviso, como lo hace la capa app.
Widget _host({
  required bool onCompare,
  Market market = Market.mexico,
  bool reduced = true,
}) => MediaQuery(
  data: MediaQueryData(disableAnimations: reduced),
  child: MaterialApp(
    home: Scaffold(
      body: Stack(
        children: [
          Builder(
            builder: (context) => TextButton(
              onPressed: () => showMarketChangedNotice(
                ScaffoldMessenger.of(context),
                overlay: Overlay.of(context),
                market: market,
                year: 2025,
                onCompare: onCompare,
              ),
              child: const Text('cambiar'),
            ),
          ),
          const Positioned(bottom: 0, right: 0, child: Text('debajo')),
        ],
      ),
    ),
  ),
);

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('quién cuenta como cambio del usuario', () {
    test('la restauración al arrancar no cuenta', () async {
      final preference = FakeMarketPreference(stored: Market.mexico.code);
      final cubit = MarketCubit(preference: preference);
      addTearDown(cubit.close);
      final states = <MarketState>[cubit.state];
      final subscription = cubit.stream.listen(states.add);
      addTearDown(subscription.cancel);
      await cubit.restore();
      await Future<void>.delayed(Duration.zero);
      // Hubo un cambio de mercado (EE. UU. → México), pero no lo hizo la persona.
      expect(states.last.market, Market.mexico);
      expect(isUserMarketChange(states.first, states.last), isFalse);
    });

    test('elegir otra bandera después de restaurar sí cuenta', () async {
      final cubit = buildMarketCubit();
      addTearDown(cubit.close);
      await Future<void>.delayed(Duration.zero);
      final before = cubit.state;
      await cubit.select(Market.mexico);
      expect(isUserMarketChange(before, cubit.state), isTrue);
    });

    test('elegir la bandera activa no cambia nada', () async {
      final cubit = buildMarketCubit();
      addTearDown(cubit.close);
      await Future<void>.delayed(Duration.zero);
      final before = cubit.state;
      await cubit.select(Market.unitedStates);
      expect(isUserMarketChange(before, cubit.state), isFalse);
    });
  });

  group('aviso de mercado', () {
    testWidgets('lleva bandera, título y línea con mercado y año', (
      tester,
    ) async {
      await tester.pumpWidget(_host(onCompare: false));
      expect(find.byType(SnackBar), findsNothing);
      await tester.tap(find.text('cambiar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text(AppTexts.marketChangedTitle('México')), findsOneWidget);
      expect(
        find.text(AppTexts.marketChangedBody('México', 2025)),
        findsOneWidget,
      );
      expect(find.text(MarketConfig.mexicoFlag), findsOneWidget);
      // Es un SnackBar de Material, flotante y de tinta; no un loader.
      final bar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(bar.behavior, SnackBarBehavior.floating);
      expect(bar.backgroundColor, AppColors.ink);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('queda sobre la barra de navegación flotante', (tester) async {
      await tester.pumpWidget(_host(onCompare: false));
      await tester.tap(find.text('cambiar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
      final bottom = tester
          .getBottomLeft(find.text(AppTexts.marketChangedBody('México', 2025)))
          .dy;
      expect(bottom, lessThanOrEqualTo(screen.height - NavConfig.footprint));
    });

    testWidgets('en Comparar dice que se ve la comparación de ese mercado', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(onCompare: true, market: Market.unitedStates),
      );
      await tester.tap(find.text('cambiar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        find.text(AppTexts.marketChangedCompareBody('EE. UU.')),
        findsOneWidget,
      );
      expect(find.text(MarketConfig.unitedStatesFlag), findsOneWidget);
    });

    testWidgets('se retira solo tras la duración configurada', (tester) async {
      await tester.pumpWidget(_host(onCompare: false));
      await tester.tap(find.text('cambiar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(SnackBar), findsOneWidget);
      await tester.pump(
        const Duration(milliseconds: MarketConfig.noticeDurationMilliseconds),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('un segundo cambio reemplaza al primero', (tester) async {
      await tester.pumpWidget(_host(onCompare: false));
      await tester.tap(find.text('cambiar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.text('cambiar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });

  group('celebración de mercado', () {
    testWidgets('con movimiento dibuja la celebración y no el SnackBar', (
      tester,
    ) async {
      await tester.pumpWidget(_host(onCompare: false, reduced: false));
      await tester.tap(find.text('cambiar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(MarketChangeCelebration), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
      expect(find.text(AppTexts.marketChangedTitle('México')), findsOneWidget);
      expect(
        find.text(AppTexts.marketChangedBody('México', 2025)),
        findsOneWidget,
      );
      await tester.pumpAndSettle();
      // Termina sola dentro de la duración configurada.
      expect(find.byType(MarketChangeCelebration), findsNothing);
    });

    testWidgets('dura hasta lo configurado y no antes', (tester) async {
      await tester.pumpWidget(_host(onCompare: false, reduced: false));
      await tester.tap(find.text('cambiar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));
      expect(find.byType(MarketChangeCelebration), findsOneWidget);
      await tester.pump(AppMotion.celebration);
      await tester.pumpAndSettle();
      expect(find.byType(MarketChangeCelebration), findsNothing);
    });

    testWidgets('un toque en la tarjeta la omite', (tester) async {
      await tester.pumpWidget(_host(onCompare: false, reduced: false));
      await tester.tap(find.text('cambiar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text(AppTexts.marketChangedTitle('México')));
      await tester.pump(AppMotion.fast);
      await tester.pumpAndSettle();
      expect(find.byType(MarketChangeCelebration), findsNothing);
    });

    testWidgets('no intercepta toques fuera de la tarjeta', (tester) async {
      await tester.pumpWidget(_host(onCompare: false, reduced: false));
      await tester.tap(find.text('cambiar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      // El botón de abajo sigue recibiendo el toque mientras corre.
      expect(find.text('debajo').hitTestable(), findsOneWidget);
      expect(find.text('cambiar').hitTestable(), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('en Comparar la segunda línea habla de la comparación', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(onCompare: true, market: Market.unitedStates, reduced: false),
      );
      await tester.tap(find.text('cambiar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        find.text(AppTexts.marketChangedCompareBody('EE. UU.')),
        findsOneWidget,
      );
      await tester.pumpAndSettle();
    });

    testWidgets('un segundo cambio reemplaza a la celebración en curso', (
      tester,
    ) async {
      await tester.pumpWidget(_host(onCompare: false, reduced: false));
      await tester.tap(find.text('cambiar'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('cambiar'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(MarketChangeCelebration), findsOneWidget);
      await tester.pumpAndSettle();
    });

    test('la bandera de México es tricolor sin escudo y la de EE. UU. tiene cantón', () {
      // Solo colores de franjas y campo: ningún otro color de bandera en el tema.
      expect(AppColors.flagMexicoGreen, isNot(AppColors.flagMexicoRed));
      expect(
        MarketConfig.usCantonStripes,
        lessThan(MarketConfig.usStripeCount),
      );
    });
  });
}
