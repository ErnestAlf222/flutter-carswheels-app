import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/market/market.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../support/market_test_support.dart';

Widget _host(
  MarketCubit cubit, {
  required MarketSelectorTone tone,
  bool disableAnimations = false,
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
        child: MarketYearSelectorWidget(
          years: const [2026, 2025],
          year: 2026,
          onYearSelected: (_) {},
          tone: tone,
        ),
      ),
    ),
  ),
);

BoxDecoration _pill(WidgetTester tester) =>
    tester
            .widget<Container>(
              find
                  .descendant(
                    of: find.byType(MarketYearSelectorWidget),
                    matching: find.byType(Container),
                  )
                  .first,
            )
            .decoration!
        as BoxDecoration;

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets(
    'onDark: píldora transparente con borde blanco de baja opacidad',
    (tester) async {
      final cubit = buildMarketCubit();
      addTearDown(cubit.close);
      await tester.pumpWidget(_host(cubit, tone: MarketSelectorTone.onDark));
      await tester.pump();
      final pill = _pill(tester);
      expect(pill.color, AppColors.transparent);
      final border = pill.border! as Border;
      expect(
        border.top.color,
        AppColors.onDark.withValues(
          alpha: MarketConfig.selectorBorderOnDarkOpacity,
        ),
      );
      expect(MarketConfig.selectorBorderOnDarkOpacity, lessThan(0.5));
      expect(border.top.width, MarketConfig.selectorBorderWidth);
      // Año y chevron en blanco; aro blanco fino sin relleno.
      expect(
        tester.widget<Text>(find.text('2026')).style!.color,
        AppColors.onDark,
      );
      expect(
        tester
            .widget<Icon>(
              find.descendant(
                of: find.byType(MarketYearSelectorWidget),
                matching: find.byType(Icon),
              ),
            )
            .color,
        AppColors.onDark,
      );
      final ring =
          tester
                  .widget<Container>(
                    find.descendant(
                      of: find.byKey(const ValueKey('market-switch-ring')),
                      matching: find.byType(Container),
                    ),
                  )
                  .decoration!
              as BoxDecoration;
      expect(ring.color, isNull);
      expect((ring.border! as Border).top.color, AppColors.onDark);
    },
  );

  testWidgets('onLight: píldora blanca con borde outline y tinta', (
    tester,
  ) async {
    final cubit = buildMarketCubit();
    addTearDown(cubit.close);
    await tester.pumpWidget(_host(cubit, tone: MarketSelectorTone.onLight));
    await tester.pump();
    final pill = _pill(tester);
    expect(pill.color, AppColors.surface);
    expect((pill.border! as Border).top.color, AppColors.outline);
    expect(tester.widget<Text>(find.text('2026')).style!.color, AppColors.ink);
    expect(
      tester
          .widget<Icon>(
            find.descendant(
              of: find.byType(MarketYearSelectorWidget),
              matching: find.byType(Icon),
            ),
          )
          .color,
      AppColors.ink,
    );
    final ring =
        tester
                .widget<Container>(
                  find.descendant(
                    of: find.byKey(const ValueKey('market-switch-ring')),
                    matching: find.byType(Container),
                  ),
                )
                .decoration!
            as BoxDecoration;
    expect((ring.border! as Border).top.color, AppColors.ink);
  });

  for (final tone in MarketSelectorTone.values) {
    testWidgets('$tone: dos banderas a color, la inactiva suave (≥ 0.7)', (
      tester,
    ) async {
      final cubit = buildMarketCubit();
      addTearDown(cubit.close);
      await tester.pumpWidget(_host(cubit, tone: tone));
      await tester.pump();
      expect(MarketConfig.inactiveFlagOpacity, greaterThanOrEqualTo(0.7));
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
      // Recortadas en círculo y con el área táctil de 44 intacta.
      for (final market in Market.values) {
        expect(
          find.ancestor(
            of: find.text(market.flag),
            matching: find.byType(ClipOval),
          ),
          findsOneWidget,
        );
      }
      expect(
        tester.getSize(find.byType(MarketSwitchWidget)).height,
        MarketConfig.flagTouchSize,
      );
    });

    testWidgets('$tone: el aro se desliza y con disableAnimations salta', (
      tester,
    ) async {
      final cubit = buildMarketCubit();
      addTearDown(cubit.close);
      await tester.pumpWidget(_host(cubit, tone: tone));
      await tester.pump();
      final ring = find.byKey(const ValueKey('market-switch-ring'));
      final start = tester.getCenter(ring).dx;
      await cubit.select(Market.mexico);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 10));
      // A mitad del recorrido aún no llegó.
      expect(
        tester.getCenter(ring).dx,
        isNot(closeTo(tester.getCenter(find.text(Market.mexico.flag)).dx, 0.5)),
      );
      await tester.pumpAndSettle();
      expect(tester.getCenter(ring).dx, lessThan(start));
      // Sin animaciones: el aro llega en el mismo cuadro.
      await tester.pumpWidget(
        _host(cubit, tone: tone, disableAnimations: true),
      );
      await tester.pump();
      await cubit.select(Market.unitedStates);
      await tester.pump();
      expect(
        tester.getCenter(ring).dx,
        closeTo(tester.getCenter(find.text(Market.unitedStates.flag)).dx, 1),
      );
    });
  }
}
