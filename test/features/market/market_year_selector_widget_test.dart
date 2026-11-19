import 'dart:io';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/market/market.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../support/market_test_support.dart';

const _years = [2026, 2025, 2024];

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

  testWidgets('tocar la bandera alterna el mercado y lo guarda', (
    tester,
  ) async {
    final preference = FakeMarketPreference();
    final cubit = buildMarketCubit(preference: preference);
    addTearDown(cubit.close);
    await tester.pumpWidget(_host(cubit, onYearSelected: (_) {}));
    await tester.pump();
    expect(find.text(Market.unitedStates.flag), findsOneWidget);
    await tester.tap(find.text(Market.unitedStates.flag));
    await tester.pumpAndSettle();
    expect(cubit.market, Market.mexico);
    expect(preference.writes, ['mx']);
    expect(find.text(Market.mexico.flag), findsOneWidget);
    await tester.tap(find.text(Market.mexico.flag));
    await tester.pumpAndSettle();
    expect(cubit.market, Market.unitedStates);
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
    expect(find.bySemanticsLabel(AppTexts.switchToMexicoLabel), findsOneWidget);
    expect(find.bySemanticsLabel(AppTexts.pickYearLabel), findsOneWidget);
    await cubit.select(Market.mexico);
    await tester.pumpAndSettle();
    expect(
      find.bySemanticsLabel(AppTexts.switchToUnitedStatesLabel),
      findsOneWidget,
    );
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

  testWidgets('sin año solo se ve la bandera', (tester) async {
    final cubit = buildMarketCubit();
    addTearDown(cubit.close);
    await tester.pumpWidget(
      _host(cubit, onYearSelected: (_) {}, years: const [], year: null),
    );
    await tester.pump();
    expect(find.text(Market.unitedStates.flag), findsOneWidget);
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
}
