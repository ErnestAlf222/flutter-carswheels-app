import 'dart:io';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/market/market.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../support/market_test_support.dart';

const _years = [2026, 2025, 2024];
final _disc = find.byKey(const ValueKey('market-switch-disc'));

Widget _host(
  MarketCubit cubit, {
  required ValueChanged<int> onYearSelected,
  bool disableAnimations = false,
  List<int> years = _years,
  int? year = 2026,
}) => MaterialApp(
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: disableAnimations),
    child: child!,
  ),
  home: BlocProvider<MarketCubit>.value(
    value: cubit,
    child: Scaffold(
      body: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: MarketYearSelectorWidget(
            years: years,
            year: year,
            onYearSelected: onYearSelected,
          ),
        ),
      ),
    ),
  ),
);

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('se ven las dos banderas en el orden de la configuración', (
    tester,
  ) async {
    final cubit = buildMarketCubit();
    addTearDown(cubit.close);
    await tester.pumpWidget(_host(cubit, onYearSelected: (_) {}));
    await tester.pump();
    final first = tester.getTopLeft(find.text(Market.mexico.flag)).dx;
    final second = tester.getTopLeft(find.text(Market.unitedStates.flag)).dx;
    expect(first, lessThan(second));
    expect(MarketConfig.switchOrderCodes, [
      MarketConfig.mexicoCode,
      MarketConfig.unitedStatesCode,
    ]);
  });

  testWidgets('el disco está tras la bandera activa y la otra se atenúa', (
    tester,
  ) async {
    final cubit = buildMarketCubit();
    addTearDown(cubit.close);
    await tester.pumpWidget(_host(cubit, onYearSelected: (_) {}));
    await tester.pump();
    double opacityOf(Market market) => tester
        .widget<AnimatedOpacity>(
          find.ancestor(
            of: find.text(market.flag),
            matching: find.byType(AnimatedOpacity),
          ),
        )
        .opacity;
    expect(opacityOf(Market.unitedStates), 1.0);
    expect(opacityOf(Market.mexico), MarketConfig.inactiveFlagOpacity);
    expect(
      tester.getCenter(_disc).dx,
      closeTo(tester.getCenter(find.text(Market.unitedStates.flag)).dx, 1),
    );
    await cubit.select(Market.mexico);
    await tester.pumpAndSettle();
    expect(opacityOf(Market.mexico), 1.0);
    expect(
      tester.getCenter(_disc).dx,
      closeTo(tester.getCenter(find.text(Market.mexico.flag)).dx, 1),
    );
  });

  testWidgets('tocar la inactiva alterna el mercado y lo guarda', (
    tester,
  ) async {
    final preference = FakeMarketPreference();
    final cubit = buildMarketCubit(preference: preference);
    addTearDown(cubit.close);
    await tester.pumpWidget(_host(cubit, onYearSelected: (_) {}));
    await tester.pump();
    await tester.tap(find.text(Market.mexico.flag));
    await tester.pumpAndSettle();
    expect(cubit.market, Market.mexico);
    expect(preference.writes, ['mx']);
    await tester.tap(find.text(Market.unitedStates.flag));
    await tester.pumpAndSettle();
    expect(cubit.market, Market.unitedStates);
  });

  testWidgets('tocar la bandera activa no hace nada', (tester) async {
    final preference = FakeMarketPreference();
    final cubit = buildMarketCubit(preference: preference);
    addTearDown(cubit.close);
    await tester.pumpWidget(_host(cubit, onYearSelected: (_) {}));
    await tester.pump();
    await tester.tap(find.text(Market.unitedStates.flag));
    await tester.pumpAndSettle();
    expect(cubit.market, Market.unitedStates);
    expect(preference.writes, isEmpty);
  });

  testWidgets('cada bandera tiene un área táctil mínima', (tester) async {
    final cubit = buildMarketCubit();
    addTearDown(cubit.close);
    await tester.pumpWidget(_host(cubit, onYearSelected: (_) {}));
    await tester.pump();
    for (final market in Market.values) {
      final box = find.ancestor(
        of: find.text(market.flag),
        matching: find.byType(SizedBox),
      );
      final size = tester.getSize(box.first);
      expect(size.width, greaterThanOrEqualTo(MarketConfig.flagTouchSize));
      expect(size.height, greaterThanOrEqualTo(MarketConfig.flagTouchSize));
    }
  });

  testWidgets('con animaciones el disco se desliza; sin ellas salta', (
    tester,
  ) async {
    for (final disable in [false, true]) {
      final cubit = buildMarketCubit();
      addTearDown(cubit.close);
      await tester.pumpWidget(
        _host(cubit, onYearSelected: (_) {}, disableAnimations: disable),
      );
      await tester.pump();
      await cubit.select(Market.mexico);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 30));
      final moved = tester.getCenter(_disc).dx;
      final target = tester.getCenter(find.text(Market.mexico.flag)).dx;
      if (disable) {
        expect(moved, closeTo(target, 1));
      } else {
        expect((moved - target).abs(), greaterThan(1));
      }
      await tester.pumpAndSettle();
    }
  });

  testWidgets('las banderas salen de la configuración de mercados', (
    tester,
  ) async {
    expect(Market.unitedStates.flag, MarketConfig.unitedStatesFlag);
    expect(Market.mexico.flag, MarketConfig.mexicoFlag);
  });

  testWidgets('las etiquetas de accesibilidad nombran el destino', (
    tester,
  ) async {
    final cubit = buildMarketCubit();
    addTearDown(cubit.close);
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_host(cubit, onYearSelected: (_) {}));
    await tester.pump();
    expect(find.bySemanticsLabel(AppTexts.marketMexicoName), findsOneWidget);
    expect(
      find.bySemanticsLabel(AppTexts.marketUnitedStatesName),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel(AppTexts.pickYearLabel), findsOneWidget);
    final mexico = tester.getSemantics(
      find.bySemanticsLabel(AppTexts.marketMexicoName),
    );
    expect(mexico.hint, AppTexts.switchToMexicoLabel);
    await cubit.select(Market.mexico);
    await tester.pumpAndSettle();
    final us = tester.getSemantics(
      find.bySemanticsLabel(AppTexts.marketUnitedStatesName),
    );
    expect(us.hint, AppTexts.switchToUnitedStatesLabel);
    handle.dispose();
  });

  testWidgets('tocar el año abre el panel con los años del mercado', (
    tester,
  ) async {
    final cubit = buildMarketCubit();
    addTearDown(cubit.close);
    await tester.pumpWidget(_host(cubit, onYearSelected: (_) {}));
    await tester.pump();
    expect(find.text('2025'), findsNothing);
    await tester.tap(find.text('2026'));
    await tester.pumpAndSettle();
    expect(find.text('2026'), findsNWidgets(2));
    expect(find.text('2025'), findsOneWidget);
    expect(find.text('2024'), findsOneWidget);
    // Más reciente primero.
    expect(
      tester.getTopLeft(find.text('2025')).dy,
      lessThan(tester.getTopLeft(find.text('2024')).dy),
    );
  });

  testWidgets('el año activo va en amarillo con texto tinta', (tester) async {
    final cubit = buildMarketCubit();
    addTearDown(cubit.close);
    await tester.pumpWidget(_host(cubit, onYearSelected: (_) {}));
    await tester.pump();
    await tester.tap(find.text('2026'));
    await tester.pumpAndSettle();
    final active = tester.widget<Text>(find.text('2026').last);
    final other = tester.widget<Text>(find.text('2025'));
    expect(active.style?.color, AppColors.ink);
    expect(other.style?.color, AppColors.onDark);
    final fill = tester.widget<Material>(
      find
          .ancestor(of: find.text('2026').last, matching: find.byType(Material))
          .first,
    );
    expect(fill.color, AppColors.accent);
  });

  testWidgets('elegir un año cierra el panel y lo notifica', (tester) async {
    final cubit = buildMarketCubit();
    addTearDown(cubit.close);
    final picked = <int>[];
    await tester.pumpWidget(_host(cubit, onYearSelected: picked.add));
    await tester.pump();
    await tester.tap(find.text('2026'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2024'));
    await tester.pumpAndSettle();
    expect(picked, [2024]);
    expect(find.text('2024'), findsNothing);
  });

  testWidgets('tocar fuera cierra el panel sin elegir', (tester) async {
    final cubit = buildMarketCubit();
    addTearDown(cubit.close);
    final picked = <int>[];
    await tester.pumpWidget(_host(cubit, onYearSelected: picked.add));
    await tester.pump();
    await tester.tap(find.text('2026'));
    await tester.pumpAndSettle();
    expect(find.text('2025'), findsOneWidget);
    await tester.tapAt(const Offset(10, 400));
    await tester.pumpAndSettle();
    expect(find.text('2025'), findsNothing);
    expect(picked, isEmpty);
  });

  testWidgets('atrás cierra el panel', (tester) async {
    final cubit = buildMarketCubit();
    addTearDown(cubit.close);
    await tester.pumpWidget(_host(cubit, onYearSelected: (_) {}));
    await tester.pump();
    await tester.tap(find.text('2026'));
    await tester.pumpAndSettle();
    expect(find.text('2025'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('2025'), findsNothing);
  });

  testWidgets('el chevron gira 180 grados al abrir', (tester) async {
    final cubit = buildMarketCubit();
    addTearDown(cubit.close);
    await tester.pumpWidget(_host(cubit, onYearSelected: (_) {}));
    await tester.pump();
    double turns() =>
        tester.widget<AnimatedRotation>(find.byType(AnimatedRotation)).turns;
    expect(turns(), 0);
    await tester.tap(find.text('2026'));
    await tester.pumpAndSettle();
    expect(turns(), 0.5);
  });

  testWidgets('con animaciones el panel se despliega con opacidad', (
    tester,
  ) async {
    final cubit = buildMarketCubit();
    addTearDown(cubit.close);
    await tester.pumpWidget(_host(cubit, onYearSelected: (_) {}));
    await tester.pump();
    await tester.tap(find.text('2026'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));
    final opacity = tester.widget<Opacity>(
      find
          .ancestor(of: find.text('2025'), matching: find.byType(Opacity))
          .first,
    );
    expect(opacity.opacity, lessThan(1));
    await tester.pumpAndSettle();
  });

  testWidgets('con disableAnimations no hay animación', (tester) async {
    final cubit = buildMarketCubit();
    addTearDown(cubit.close);
    await tester.pumpWidget(
      _host(cubit, onYearSelected: (_) {}, disableAnimations: true),
    );
    await tester.pump();
    await tester.tap(find.text('2026'));
    await tester.pump();
    expect(find.byType(TweenAnimationBuilder<double>), findsNothing);
    expect(find.text('2025'), findsOneWidget);
    expect(
      tester.widget<AnimatedRotation>(find.byType(AnimatedRotation)).duration,
      Duration.zero,
    );
  });

  testWidgets('con muchos años el panel respeta el alto máximo y hace scroll', (
    tester,
  ) async {
    final cubit = buildMarketCubit();
    addTearDown(cubit.close);
    final years = [for (int year = 2026; year >= 1990; year--) year];
    await tester.pumpWidget(_host(cubit, onYearSelected: (_) {}, years: years));
    await tester.pump();
    await tester.tap(find.text('2026'));
    await tester.pumpAndSettle();
    final panel = tester.getSize(
      find
          .ancestor(of: find.byType(ListView), matching: find.byType(Material))
          .first,
    );
    expect(panel.height, lessThanOrEqualTo(MarketConfig.yearPanelMaxHeight));
    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets('sin año solo se ve el interruptor', (tester) async {
    final cubit = buildMarketCubit();
    addTearDown(cubit.close);
    await tester.pumpWidget(
      _host(cubit, onYearSelected: (_) {}, years: const [], year: null),
    );
    await tester.pump();
    expect(find.text(Market.unitedStates.flag), findsOneWidget);
    expect(find.text(Market.mexico.flag), findsOneWidget);
    expect(find.byType(AnimatedRotation), findsNothing);
  });

  test('los widgets viejos ya no existen', () {
    for (final path in [
      'lib/features/market/presentation/widgets/market_selector_widget.dart',
      'lib/features/catalog/presentation/widgets/year_selector_widget.dart',
      'lib/features/search/presentation/widgets/search_context_chip_widget.dart',
    ]) {
      expect(File(path).existsSync(), isFalse, reason: path);
    }
  });
  group('disposición', () {
    Future<void> pumpAt360(
      WidgetTester tester,
      MarketCubit cubit,
      MarketSelectorLayout layout,
    ) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.3)),
            child: child!,
          ),
          home: BlocProvider<MarketCubit>.value(
            value: cubit,
            child: Scaffold(
              body: Align(
                alignment: Alignment.topRight,
                child: MarketYearSelectorWidget(
                  years: _years,
                  year: 2026,
                  layout: layout,
                  onYearSelected: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('apilado: banderas arriba, año debajo, sin encimarse', (
      tester,
    ) async {
      final cubit = buildMarketCubit();
      addTearDown(cubit.close);
      await pumpAt360(tester, cubit, MarketSelectorLayout.stacked);
      final flags = tester.getRect(find.byType(MarketSwitchWidget));
      final pill = tester.getRect(find.byType(MarketYearPillWidget));
      expect(flags.overlaps(pill), isFalse);
      expect(pill.top - flags.bottom, MarketConfig.stackedGap);
      expect(flags.right, pill.right);
      expect(tester.takeException(), isNull);
    });

    testWidgets('en fila: separados en horizontal y sin encimarse', (
      tester,
    ) async {
      final cubit = buildMarketCubit();
      addTearDown(cubit.close);
      await pumpAt360(tester, cubit, MarketSelectorLayout.row);
      final flags = tester.getRect(find.byType(MarketSwitchWidget));
      final pill = tester.getRect(find.byType(MarketYearPillWidget));
      expect(flags.overlaps(pill), isFalse);
      expect(pill.left - flags.right, MarketConfig.selectorGap);
      expect(tester.takeException(), isNull);
    });
  });
}
