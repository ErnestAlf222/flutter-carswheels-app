import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/market/market.dart';
import 'package:cars_wheels_app/features/search/presentation/widgets/widgets.dart';
import 'package:cars_wheels_app/features/search/search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../support/brand_logos_test_support.dart';
import '../../../support/market_test_support.dart';
import '../../../support/search_test_support.dart';

// Cuadrícula mínima: una fila de texto por resultado, en el orden recibido.
Widget _grid(
  BuildContext context,
  List<SearchResultEntity> results,
  String resetKey,
  ValueChanged<SearchResultEntity> onOpen,
) => SliverList(
  delegate: SliverChildBuilderDelegate(
    (context, index) => SizedBox(
      height: 40,
      child: Text(
        results[index].groupName!,
        key: ValueKey('row-${results[index].groupName}'),
      ),
    ),
    childCount: results.length,
  ),
);

Widget _noAnimations(BuildContext context, Widget? child) => MediaQuery(
  data: MediaQuery.of(context).copyWith(disableAnimations: true),
  child: child!,
);

Widget _page(SearchHarness harness, {SearchResultsGridBuilder grid = _grid}) =>
    RepositoryProvider<ScrollOffsetStore>.value(
      value: ScrollOffsetStore(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<SearchCubit>.value(value: harness.cubit),
          BlocProvider<BrandLogosCubit>.value(
            value: buildMockBrandLogosCubit(),
          ),
          BlocProvider<MarketCubit>.value(value: buildMarketCubit()),
        ],
        child: MaterialApp(
          builder: _noAnimations,
          home: SearchPage(
            onOpenResult: (_, _) {},
            resultsGridBuilder: grid,
            selectorBuilder: (_) => const SizedBox.shrink(),
          ),
        ),
      ),
    );

SearchHarness _harness() {
  final harness = SearchHarness(
    groupsByBrand: {
      'Toyota': ['Camry Sport', 'Prius Sport'],
      'Honda': ['Civic Sport', 'Accord Sport'],
      'Hyundai': ['Ioniq Sport'],
    },
  );
  harness.traits.byGroup.addAll({
    'Camry Sport': const SearchResultTraitsEntity(
      engines: {SearchEngineOption.combustion},
      maxKmPerLiter: 14,
    ),
    'Prius Sport': const SearchResultTraitsEntity(
      engines: {SearchEngineOption.hybrid, SearchEngineOption.combustion},
      maxKmPerLiter: 25,
    ),
    'Civic Sport': const SearchResultTraitsEntity(
      engines: {SearchEngineOption.combustion},
      maxKmPerLiter: 12,
    ),
    'Ioniq Sport': const SearchResultTraitsEntity(
      engines: {SearchEngineOption.electric},
    ),
  });
  return harness;
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _search(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.pump(const Duration(milliseconds: 350));
  await tester.pump(const Duration(milliseconds: 350));
}

Future<void> _openPage(WidgetTester tester, SearchHarness harness) async {
  await tester.pumpWidget(_page(harness));
  await _settle(tester);
}

Future<void> _openSheet(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('search-filter-button')));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void _test(String description, Future<void> Function(WidgetTester) body) {
  testWidgets(description, (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await body(tester);
    await tester.pumpWidget(const SizedBox());
  });
}

Finder _strip() => find.byKey(const ValueKey('search-active-filters-open'));

Future<void> _pumpShort(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('insignia', () {
    _test('cápsula amarilla con el número en tinta y negrita; oculta con 0', (
      tester,
    ) async {
      final harness = _harness();
      await _openPage(tester, harness);
      await _search(tester, 'sport');
      const badgeKey = ValueKey('search-filter-badge');
      expect(find.byKey(badgeKey), findsNothing);
      harness.cubit.toggleEngine(SearchEngineOption.combustion);
      harness.cubit.toggleBrandFilter('Toyota');
      await _pumpShort(tester);
      final badge = tester.widget<Container>(find.byKey(badgeKey));
      final decoration = badge.decoration! as BoxDecoration;
      expect(decoration.color, AppColors.accent);
      expect(decoration.shape, BoxShape.rectangle);
      expect((decoration.border! as Border).top.color, AppColors.surface);
      final text = tester.widget<Text>(
        find.descendant(of: find.byKey(badgeKey), matching: find.text('2')),
      );
      expect(text.style!.color, AppColors.ink);
      expect(text.style!.fontWeight, FontWeight.w700);
      final size = tester.getSize(find.byKey(badgeKey));
      expect(size.width, greaterThanOrEqualTo(size.height));
      // Arriba a la derecha del botón.
      final button = tester.getRect(
        find.byKey(const ValueKey('search-filter-button')),
      );
      final center = tester.getCenter(find.byKey(badgeKey));
      expect(center.dx, greaterThan(button.center.dx));
      expect(center.dy, lessThan(button.center.dy));
      harness.cubit.clearFilters();
      await _pumpShort(tester);
      expect(find.byKey(badgeKey), findsNothing);
    });
  });

  group('franja de filtros activos', () {
    _test('aparece con filtros, abre la hoja y "Limpiar" los quita', (
      tester,
    ) async {
      final harness = _harness();
      await _openPage(tester, harness);
      await _search(tester, 'sport');
      expect(_strip(), findsNothing);
      harness.cubit.toggleBrandFilter('Toyota');
      await _pumpShort(tester);
      expect(find.text(AppTexts.searchActiveFiltersLabel(1)), findsOneWidget);
      // Justo bajo el encabezado de resultados.
      final header = find.text(
        AppTexts.searchResultsCountLabel(2).toUpperCase(),
      );
      expect(header, findsOneWidget);
      expect(
        tester.getTopLeft(_strip()).dy,
        greaterThanOrEqualTo(tester.getBottomLeft(header).dy),
      );
      await tester.tap(_strip());
      await _pumpShort(tester);
      expect(find.text(AppTexts.searchFiltersTitle), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('search-filters-apply')));
      await _pumpShort(tester);
      const clearKey = ValueKey('search-active-filters-clear');
      await tester.tap(find.byKey(clearKey));
      await _pumpShort(tester);
      expect(harness.cubit.state.filters.isActive, isFalse);
      expect(_strip(), findsNothing);
      expect(find.byKey(clearKey), findsNothing);
    });

    _test('cuenta también el orden distinto del original', (tester) async {
      final harness = _harness();
      await _openPage(tester, harness);
      await _search(tester, 'sport');
      harness.cubit.setSortOrder(SearchSortOrder.alphabetical);
      await _pumpShort(tester);
      expect(find.text(AppTexts.searchActiveFiltersLabel(1)), findsOneWidget);
    });
  });

  group('estado vacío con filtros', () {
    _test(
      'explica los filtros y "Limpiar todo" limpia texto, marca y filtros',
      (tester) async {
        final harness = _harness();
        await _openPage(tester, harness);
        await _search(tester, 'sport');
        harness.cubit.selectBrand('Toyota');
        await _pumpShort(tester);
        harness.cubit.toggleEngine(SearchEngineOption.electric);
        harness.cubit.toggleBrandFilter('Honda');
        await _settle(tester);
        expect(
          find.text(AppTexts.searchFiltersEmptyActive('Eléctrico · Honda')),
          findsOneWidget,
        );
        await tester.tap(find.byKey(const ValueKey('search-clear-everything')));
        await _settle(tester);
        final state = harness.cubit.state;
        expect(state.query, isEmpty);
        expect(state.scopeBrand, isNull);
        expect(state.filters.isActive, isFalse);
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          isEmpty,
        );
      },
    );
  });

  group('filtros en otros años', () {
    _test('se aplican con conteo por año y análisis automático', (
      tester,
    ) async {
      final harness = _harness();
      await _openPage(tester, harness);
      await _search(tester, 'sport');
      harness.cubit.toggleEngine(SearchEngineOption.electric);
      await _settle(tester);
      await tester.tap(find.byKey(const ValueKey('search-other-years-button')));
      await _settle(tester);
      await _settle(tester);
      // Solo el eléctrico (Ioniq) sobrevive en cada uno de los 3 años.
      expect(find.byType(SearchOtherYearRowWidget), findsNWidgets(3));
      for (final year in [2026, 2024, 2023]) {
        expect(
          find.byKey(ValueKey('search-other-year-$year-Hyundai-Ioniq Sport')),
          findsOneWidget,
        );
        expect(
          find.byKey(ValueKey('search-other-year-$year-Toyota-Camry Sport')),
          findsNothing,
        );
      }
      expect(find.text(AppTexts.searchResultsCountLabel(1)), findsWidgets);
      final analyzedYears = {
        for (final key in harness.cubit.state.traits.keys) key.split('|')[1],
      };
      expect(analyzedYears, containsAll(['2026', '2024', '2023']));
    });

    _test('sin coincidencias: aviso y "Limpiar" quita los filtros', (
      tester,
    ) async {
      final harness = _harness();
      await _openPage(tester, harness);
      await _search(tester, 'sport');
      harness.cubit.toggleEngine(SearchEngineOption.electric);
      harness.cubit.toggleBrandFilter('Toyota');
      await _settle(tester);
      await tester.tap(find.byKey(const ValueKey('search-other-years-button')));
      await _settle(tester);
      await _settle(tester);
      expect(
        find.byKey(const ValueKey('search-other-years-no-filter-matches')),
        findsOneWidget,
      );
      expect(find.byType(SearchOtherYearRowWidget), findsNothing);
      await tester.tap(
        find.byKey(const ValueKey('search-other-years-clear-filters')),
      );
      await _settle(tester);
      expect(harness.cubit.state.filters.isActive, isFalse);
      expect(find.byType(SearchOtherYearRowWidget), findsWidgets);
    });

    _test('la hoja avisa que los filtros también valen para otros años', (
      tester,
    ) async {
      final harness = _harness();
      await _openPage(tester, harness);
      await _search(tester, 'sport');
      await _openSheet(tester);
      expect(find.text(AppTexts.searchFiltersAlsoOtherYears), findsOneWidget);
    });
  });
}
