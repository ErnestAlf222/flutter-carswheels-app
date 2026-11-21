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

Color _pillColor(WidgetTester tester) =>
    (tester
                .widget<DecoratedBox>(
                  find.descendant(
                    of: find.byKey(const ValueKey('market-switch-pill')),
                    matching: find.byType(DecoratedBox),
                  ),
                )
                .decoration
            as BoxDecoration)
        .color!;

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
      expect(_pillColor(tester), AppColors.surface);
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
    expect(_pillColor(tester), AppColors.ink);
  });

  for (final tone in MarketSelectorTone.values) {
    testWidgets(
      '$tone: dos opciones con bandera circular y código, área de 44',
      (tester) async {
        final cubit = buildMarketCubit();
        addTearDown(cubit.close);
        await tester.pumpWidget(_host(cubit, tone: tone));
        await tester.pump();
        expect(find.text(AppTexts.marketUnitedStatesCodeLabel), findsOneWidget);
        expect(find.text(AppTexts.marketMexicoCodeLabel), findsOneWidget);
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
        final colors = MarketSelectorColors.of(tone);
        Color textColor(String text) => tester
            .widget<AnimatedDefaultTextStyle>(
              find
                  .ancestor(
                    of: find.text(text),
                    matching: find.byType(AnimatedDefaultTextStyle),
                  )
                  .first,
            )
            .style
            .color!;
        // Activa y atenuada con los colores del tono.
        expect(
          textColor(AppTexts.marketUnitedStatesCodeLabel),
          colors.activeText,
        );
        expect(textColor(AppTexts.marketMexicoCodeLabel), colors.inactiveText);
      },
    );

    testWidgets('$tone: la pastilla se desliza y con disableAnimations salta', (
      tester,
    ) async {
      final cubit = buildMarketCubit();
      addTearDown(cubit.close);
      await tester.pumpWidget(_host(cubit, tone: tone));
      await tester.pump();
      final pill = find.byKey(const ValueKey('market-switch-pill'));
      final start = tester.getCenter(pill).dx;
      await cubit.select(Market.mexico);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 10));
      final mid = tester.getCenter(pill).dx;
      expect(
        mid,
        isNot(closeTo(tester.getCenter(find.text(Market.mexico.flag)).dx, 0.5)),
      );
      await tester.pumpAndSettle();
      expect(tester.getCenter(pill).dx, lessThan(start));
      await tester.pumpWidget(
        _host(cubit, tone: tone, disableAnimations: true),
      );
      await tester.pump();
      await cubit.select(Market.unitedStates);
      await tester.pump();
      expect(tester.getCenter(pill).dx, closeTo(start, 1));
    });

    testWidgets('$tone: Semantics dice qué mercado está seleccionado', (
      tester,
    ) async {
      final cubit = buildMarketCubit();
      addTearDown(cubit.close);
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(cubit, tone: tone));
      await tester.pump();
      expect(
        find.bySemanticsLabel(
          AppTexts.marketOptionSemanticLabel(
            MarketConfig.unitedStatesCode,
            selected: true,
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(
          AppTexts.marketOptionSemanticLabel(
            MarketConfig.mexicoCode,
            selected: false,
          ),
        ),
        findsOneWidget,
      );
      await tester.tap(find.text(AppTexts.marketMexicoCodeLabel));
      await tester.pumpAndSettle();
      expect(cubit.state.market, Market.mexico);
      handle.dispose();
    });
  }
}
