import 'dart:async';

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

Widget _page(SearchHarness harness) =>
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
            resultsGridBuilder: _grid,
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

Finder _chip(String key) => find.byKey(ValueKey(key));

bool _chipEnabled(WidgetTester tester, String key) =>
    tester.widget<SearchFilterChip>(_chip(key)).enabled;

double _buttonOpacity(WidgetTester tester) => tester
    .widget<AnimatedOpacity>(
      find.byKey(const ValueKey('search-filter-button-fade')),
    )
    .opacity;

List<String> _rows(WidgetTester tester) => [
  for (final text in tester.widgetList<Text>(
    find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.key is ValueKey<String> &&
          (widget.key! as ValueKey<String>).value.startsWith('row-'),
    ),
  ))
    text.data!,
];

void _test(String description, Future<void> Function(WidgetTester) body) {
  testWidgets(description, (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await body(tester);
    await tester.pumpWidget(const SizedBox());
  });
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('botón flotante', () {
    _test('solo aparece con resultados en pantalla o filtros activos', (
      tester,
    ) async {
      final harness = _harness();
      await _openPage(tester, harness);
      expect(_buttonOpacity(tester), 0);
      await _search(tester, 'sport');
      expect(_buttonOpacity(tester), 1);
      // Con filtros activos sigue visible aunque no haya resultados.
      harness.cubit.toggleBrandFilter('Honda');
      await _search(tester, 'zzzz');
      expect(harness.cubit.state.totalResults, 0);
      expect(_buttonOpacity(tester), 1);
      harness.cubit.clearFilters();
      await _settle(tester);
      expect(_buttonOpacity(tester), 0);
    });

    _test('se oculta con el teclado abierto', (tester) async {
      final harness = _harness();
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await _openPage(tester, harness);
      await _search(tester, 'sport');
      expect(harness.cubit.state.totalResults, 5);
      expect(_buttonOpacity(tester), 0);
    });

    _test('reaparece al cerrar el teclado con la pantalla ya construida', (
      tester,
    ) async {
      final harness = _harness();
      await _openPage(tester, harness);
      await _search(tester, 'sport');
      expect(_buttonOpacity(tester), 1);
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(_buttonOpacity(tester), 0);
      tester.view.resetViewInsets();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(_buttonOpacity(tester), 1);
    });

    _test('va apilado encima del botón de subir sin tapar la barra', (
      tester,
    ) async {
      final harness = _harness();
      await _openPage(tester, harness);
      await _search(tester, 'sport');
      final filter = tester.getRect(
        find.byKey(const ValueKey('search-filter-button')),
      );
      final top = tester.getRect(
        find.byKey(const ValueKey('scroll-to-top-button')),
      );
      expect(filter.size, const Size(48, 48));
      expect(filter.bottom, lessThanOrEqualTo(top.top));
      expect(top.top - filter.bottom, ScrollConfig.filterButtonStackGap);
      expect(filter.right, top.right);
      // Por encima de la barra flotante de navegación.
      expect(top.bottom, lessThanOrEqualTo(2400 - NavConfig.footprint));
    });

    _test('la insignia muestra cuántos filtros hay activos', (tester) async {
      final harness = _harness();
      await _openPage(tester, harness);
      await _search(tester, 'sport');
      expect(find.byKey(const ValueKey('search-filter-badge')), findsNothing);
      harness.cubit.toggleEngine(SearchEngineOption.electric);
      harness.cubit.toggleBrandFilter('Hyundai');
      await _settle(tester);
      expect(find.byKey(const ValueKey('search-filter-badge')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('search-filter-badge')),
          matching: find.text('2'),
        ),
        findsOneWidget,
      );
    });
  });

  group('hoja de filtros', () {
    _test('abre con "Analizando" y se completa en vivo', (tester) async {
      final harness = _harness();
      await _openPage(tester, harness);
      await _search(tester, 'sport');
      final gate = harness.traits.gate = Completer<void>();
      await _openSheet(tester);
      expect(find.text(AppTexts.searchFiltersTitle), findsOneWidget);
      expect(
        find.byKey(const ValueKey('search-filters-handle')),
        findsOneWidget,
      );
      expect(
        find.text(AppTexts.searchFiltersAnalyzingLabel(0, 5)),
        findsOneWidget,
      );
      expect(find.byType(AppLoader), findsOneWidget);
      // Aún sin analizar: ninguna opción de motorización.
      expect(
        find.text(AppTexts.searchFiltersEngineTitle.toUpperCase()),
        findsNothing,
      );
      gate.complete();
      await _settle(tester);
      expect(find.byType(AppLoader), findsNothing);
      expect(find.textContaining('Analizando'), findsNothing);
      expect(
        find.text(AppTexts.searchFiltersEngineTitle.toUpperCase()),
        findsOneWidget,
      );
    });

    _test('muestra motorización con conteos, marca y orden', (tester) async {
      final harness = _harness();
      await _openPage(tester, harness);
      await _search(tester, 'sport');
      await _openSheet(tester);
      await _settle(tester);
      // Solo las que existen: sin Enchufable.
      expect(_chip('search-filter-engine-electric'), findsOneWidget);
      expect(_chip('search-filter-engine-hybrid'), findsOneWidget);
      expect(_chip('search-filter-engine-combustion'), findsOneWidget);
      expect(_chip('search-filter-engine-pluginHybrid'), findsNothing);
      final combustion = tester.widget<SearchFilterChip>(
        _chip('search-filter-engine-combustion'),
      );
      // Camry, Prius (mixto) y Civic.
      expect(combustion.count, 3);
      expect(
        tester
            .widget<SearchFilterChip>(_chip('search-filter-engine-hybrid'))
            .count,
        1,
      );
      // Tres marcas: sección de marca con su conteo.
      expect(
        tester
            .widget<SearchFilterChip>(_chip('search-filter-brand-Toyota'))
            .count,
        2,
      );
      expect(_chip('search-filter-sort-alphabetical'), findsOneWidget);
      expect(_chip('search-filter-sort-efficient'), findsOneWidget);
      expect(
        find.text(AppTexts.searchFiltersSortEfficiencyHelp),
        findsOneWidget,
      );
      expect(find.text(AppTexts.searchFiltersApplyLabel(5)), findsOneWidget);
    });

    _test('elegir una opción filtra, cuenta y muestra la insignia', (
      tester,
    ) async {
      final harness = _harness();
      await _openPage(tester, harness);
      await _search(tester, 'sport');
      await _openSheet(tester);
      await _settle(tester);
      await tester.tap(_chip('search-filter-engine-hybrid'));
      await tester.pump();
      expect(find.text(AppTexts.searchFiltersApplyLabel(1)), findsOneWidget);
      expect(
        tester
            .widget<SearchFilterChip>(_chip('search-filter-engine-hybrid'))
            .selected,
        isTrue,
      );
      // Ya hay una motorización elegida: las marcas se recalculan con ella.
      expect(
        tester
            .widget<SearchFilterChip>(_chip('search-filter-brand-Honda'))
            .count,
        0,
      );
      expect(_chipEnabled(tester, 'search-filter-brand-Honda'), isFalse);
      expect(_chipEnabled(tester, 'search-filter-brand-Toyota'), isTrue);
    });

    _test('una opción con conteo 0 se muestra deshabilitada', (tester) async {
      final harness = _harness();
      await _openPage(tester, harness);
      await _search(tester, 'sport');
      harness.cubit.toggleBrandFilter('Honda');
      await _openSheet(tester);
      await _settle(tester);
      // Con solo Honda (Civic: combustión; Accord: sin dato) no hay eléctricos.
      expect(
        tester
            .widget<SearchFilterChip>(_chip('search-filter-engine-electric'))
            .count,
        0,
      );
      expect(_chipEnabled(tester, 'search-filter-engine-electric'), isFalse);
      expect(_chipEnabled(tester, 'search-filter-engine-combustion'), isTrue);
    });

    _test('"Limpiar" quita todo y "Ver N" cierra la hoja', (tester) async {
      final harness = _harness();
      await _openPage(tester, harness);
      await _search(tester, 'sport');
      await _openSheet(tester);
      await _settle(tester);
      await tester.tap(_chip('search-filter-engine-electric'));
      await tester.pump();
      expect(harness.cubit.state.filters.isActive, isTrue);
      await tester.tap(find.byKey(const ValueKey('search-filters-clear')));
      await tester.pump();
      expect(harness.cubit.state.filters, SearchFiltersEntity.none);
      await tester.tap(find.byKey(const ValueKey('search-filters-apply')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text(AppTexts.searchFiltersTitle), findsNothing);
      // Cerrada la hoja sin filtros, el análisis ya no corre.
      expect(harness.cubit.state.isAnalyzing, isFalse);
    });

    _test('con una sola marca no hay sección de marca', (tester) async {
      final harness = _harness();
      await _openPage(tester, harness);
      await _search(tester, 'camry');
      await _openSheet(tester);
      await _settle(tester);
      expect(
        find.text(AppTexts.searchFiltersBrandTitle.toUpperCase()),
        findsNothing,
      );
      expect(find.text(AppTexts.searchFiltersApplyLabel(1)), findsOneWidget);
    });
  });

  group('aplicación en la pantalla', () {
    _test('filtra las secciones y ordena por eficiencia', (tester) async {
      final harness = _harness();
      await _openPage(tester, harness);
      await _search(tester, 'sport');
      harness.cubit.setSortOrder(SearchSortOrder.mostEfficient);
      await _settle(tester);
      // Eléctrico y sin dato al final, en su orden original.
      expect(_rows(tester).take(3), [
        'Prius Sport',
        'Camry Sport',
        'Civic Sport',
      ]);
      expect(_rows(tester).last, anyOf('Ioniq Sport', 'Accord Sport'));
      harness.cubit.toggleEngine(SearchEngineOption.combustion);
      await _settle(tester);
      expect(_rows(tester), ['Prius Sport', 'Camry Sport', 'Civic Sport']);
    });

    _test('sin ninguno muestra el estado vacío y "Limpiar filtros"', (
      tester,
    ) async {
      final harness = _harness();
      await _openPage(tester, harness);
      await _search(tester, 'sport');
      harness.cubit.toggleEngine(SearchEngineOption.pluginHybrid);
      await _settle(tester);
      expect(find.text(AppTexts.searchFiltersEmptyTitle), findsOneWidget);
      expect(_rows(tester), isEmpty);
      await tester.tap(find.byKey(const ValueKey('search-filters-clear-all')));
      await _settle(tester);
      expect(find.text(AppTexts.searchFiltersEmptyTitle), findsNothing);
      expect(_rows(tester), hasLength(5));
    });

    _test('mientras analiza oculta lo pendiente e informa el avance', (
      tester,
    ) async {
      final harness = _harness();
      await _openPage(tester, harness);
      await _search(tester, 'sport');
      final gate = harness.traits.gate = Completer<void>();
      harness.cubit.toggleEngine(SearchEngineOption.electric);
      await _settle(tester);
      expect(_rows(tester), isEmpty);
      expect(
        find.text(AppTexts.searchFiltersAnalyzingLabel(0, 5)),
        findsOneWidget,
      );
      gate.complete();
      await _settle(tester);
      expect(_rows(tester), ['Ioniq Sport']);
    });

    _test('los filtros se conservan al editar el texto', (tester) async {
      final harness = _harness();
      await _openPage(tester, harness);
      await _search(tester, 'sport');
      harness.cubit.toggleBrandFilter('Toyota');
      await _settle(tester);
      expect(_rows(tester), ['Camry Sport', 'Prius Sport']);
      await _search(tester, 'sport c');
      expect(harness.cubit.state.filters.brands, {'Toyota'});
    });
  });
}
