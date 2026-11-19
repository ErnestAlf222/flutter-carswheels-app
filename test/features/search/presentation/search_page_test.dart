import 'dart:async';

import 'package:cars_wheels_app/app/app.dart';
import 'package:cars_wheels_app/app/search_results/search_card_cubits_factory.dart';
import 'package:cars_wheels_app/app/search_results/search_results_grid.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/detail/detail.dart';
import 'package:cars_wheels_app/features/market/market.dart';
import 'package:cars_wheels_app/features/search/presentation/widgets/widgets.dart';
import 'package:cars_wheels_app/features/search/search.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/brand_logos_test_support.dart';
import '../../../support/market_test_support.dart';
import '../../../support/photos_test_support.dart';
import '../../../support/search_test_support.dart';
import '../../../support/summaries_test_support.dart';

class _CatalogRepository implements CatalogRepository {
  @override
  Future<List<int>> fetchYears() async => [2025];

  @override
  Future<List<BrandEntity>> fetchBrands(int year) async => const [];

  @override
  Future<List<ModelEntity>> fetchModels(int year, String brand) async => const [
    ModelEntity(name: 'Camry'),
    ModelEntity(name: 'Camry Hybrid'),
  ];
}

/// Cubits de tarjetas falsos que recuerdan cuántos se crearon.
class _CardCubits {
  final List<MockPhotosCubit> photos = [];
  final List<MockSummariesCubit> summaries = [];

  SearchCardCubitsFactory get factory => SearchCardCubitsFactory(
    createPhotos: () {
      final cubit = buildMockPhotosCubit();
      when(() => cubit.isClosed).thenReturn(false);
      when(() => cubit.close()).thenAnswer((_) async {});
      photos.add(cubit);
      return cubit;
    },
    createSummaries: () {
      final cubit = buildMockSummariesCubit();
      when(() => cubit.isClosed).thenReturn(false);
      when(() => cubit.close()).thenAnswer((_) async {});
      summaries.add(cubit);
      return cubit;
    },
  );
}

Widget _wrap(
  SearchHarness harness,
  Widget home, {
  required _CardCubits cards,
}) => MultiRepositoryProvider(
  providers: [
    RepositoryProvider<ScrollOffsetStore>.value(value: ScrollOffsetStore()),
    RepositoryProvider<SearchCardCubitsFactory>.value(value: cards.factory),
    RepositoryProvider<VehicleClassTranslator>.value(
      value: const VehicleClassTranslator(),
    ),
    RepositoryProvider<GetModelGroupsUseCase>.value(
      value: GetModelGroupsUseCase(
        repository: _CatalogRepository(),
        grouper: const ModelGrouper(
          sortStrategy: AdaptiveSortStrategy<ModelGroupEntity>(
            smallListStrategy: BubbleSortStrategy<ModelGroupEntity>(),
            largeListStrategy: ShellSortStrategy<ModelGroupEntity>(),
          ),
        ),
      ),
    ),
  ],
  child: MultiBlocProvider(
    providers: [
      BlocProvider<SearchCubit>.value(value: harness.cubit),
      BlocProvider<BrandLogosCubit>.value(value: buildMockBrandLogosCubit()),
      BlocProvider<MarketCubit>.value(value: buildMarketCubit()),
    ],
    child: home,
  ),
);

// Selector de prueba: un texto reconocible en el encabezado.
Widget _selector(BuildContext context) => const Text('selector-de-prueba');

// Sin animaciones: las pruebas avanzan el reloj a mano.
Widget _noAnimations(BuildContext context, Widget? child) => MediaQuery(
  data: MediaQuery.of(context).copyWith(disableAnimations: true),
  child: child!,
);

Widget _page(
  SearchHarness harness, {
  _CardCubits? cards,
  void Function(BuildContext, SearchResultEntity)? onOpen,
}) => _wrap(
  harness,
  MaterialApp(
    builder: _noAnimations,
    home: SearchPage(
      onOpenResult: onOpen ?? (_, _) {},
      resultsGridBuilder: buildSearchResultsGrid,
      selectorBuilder: _selector,
    ),
  ),
  cards: cards ?? _CardCubits(),
);

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _type(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.pump(const Duration(milliseconds: 350));
  await tester.pump(const Duration(milliseconds: 350));
}

Finder _brand(String name) => find.byKey(ValueKey('search-brand-$name'));

Future<void> _selectBrand(WidgetTester tester, String name) async {
  await tester.tap(_brand(name));
  await _settle(tester);
}

RecentSearchEntity _recent(String text) => RecentSearchEntity(
  key: text.toLowerCase(),
  text: text,
  searchedAt: DateTime(2026),
);

/// Como testWidgets, con una pantalla alta para que quepan varias filas de tarjetas.
void _test(String description, Future<void> Function(WidgetTester) body) {
  testWidgets(description, (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await body(tester);
  });
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  _test('encabezado con título, selector y campo; estado inicial vacío', (
    tester,
  ) async {
    final harness = SearchHarness();
    await tester.pumpWidget(_page(harness));
    await _settle(tester);
    expect(find.byType(HeroHeaderWidget), findsOneWidget);
    expect(find.text(AppTexts.searchPageTitle), findsOneWidget);
    // El selector de mercado y año lo pone la capa app en el encabezado.
    expect(find.text('selector-de-prueba'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    // Sin recientes: explorar por marca (el texto amable es para antes del índice).
    expect(
      find.text(AppTexts.searchExploreByBrandTitle.toUpperCase()),
      findsOneWidget,
    );
    expect(find.byType(SearchRecentsWidget), findsNothing);
    expect(find.byType(ModelGridCardWidget), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  _test('cambio de mercado: texto y foco se conservan, el loader compacto '
      'ocupa solo la zona de resultados y luego llegan los nuevos', (
    tester,
  ) async {
    final harness = SearchHarness();
    await tester.pumpWidget(_page(harness));
    await _settle(tester);
    await tester.tap(find.byType(TextField));
    await _type(tester, 'toy');
    expect(find.byType(ModelGridCardWidget), findsWidgets);
    final field = find.byType(TextField);
    final headerBefore = tester.element(find.text('selector-de-prueba'));
    harness.context.change(null);
    await tester.pump();
    await tester.pump();
    // Encabezado, texto y foco siguen; solo los resultados cedieron el lugar.
    expect(tester.element(find.text('selector-de-prueba')), same(headerBefore));
    expect(tester.widget<TextField>(field).controller!.text, 'toy');
    expect(tester.widget<TextField>(field).focusNode!.hasFocus, isTrue);
    expect(tester.widget<AppLoader>(find.byType(AppLoader)).compact, isTrue);
    expect(find.byType(ModelGridCardWidget), findsNothing);
    harness.context.change(mxScope);
    await _settle(tester);
    expect(find.byType(AppLoader), findsNothing);
    expect(tester.widget<TextField>(field).controller!.text, 'toy');
    expect(find.byType(ModelGridCardWidget), findsWidgets);
    await tester.pumpWidget(const SizedBox());
  });

  _test('sin índice ni recientes también muestra el texto breve', (
    tester,
  ) async {
    final harness = SearchHarness(initialScope: null);
    await tester.pumpWidget(_page(harness));
    await _settle(tester);
    expect(find.text(AppTexts.searchIdleHint), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  _test(
    'explorar por marca: título y todas las marcas en una fila alfabética',
    (tester) async {
      final harness = SearchHarness();
      await tester.pumpWidget(_page(harness));
      await _settle(tester);
      expect(
        find.text(AppTexts.searchExploreByBrandTitle.toUpperCase()),
        findsOneWidget,
      );
      final xs = [
        for (final name in ['Honda', 'Hyundai', 'Toyota'])
          tester.getTopLeft(_brand(name)).dx,
      ];
      expect(xs, orderedEquals([...xs]..sort()));
      expect(xs.toSet(), hasLength(3));
      // Una sola fila: todos a la misma altura y sin elemento "Todas".
      expect(
        tester.getTopLeft(_brand('Honda')).dy,
        tester.getTopLeft(_brand('Toyota')).dy,
      );
      expect(find.byKey(const ValueKey('search-scope-clear')), findsNothing);
      await tester.pumpWidget(const SizedBox());
    },
  );

  _test('la etiqueta "Alfa Romeo" cabe completa en dos líneas', (tester) async {
    final harness = SearchHarness(
      groupsByBrand: {
        'Alfa Romeo': ['Giulia'],
        'Toyota': ['Camry'],
      },
    );
    await tester.pumpWidget(_page(harness));
    await _settle(tester);
    final label = tester.widget<Text>(find.text('Alfa Romeo'));
    expect(label.maxLines, SearchConfig.brandLabelMaxLines);
    expect(label.maxLines, greaterThanOrEqualTo(2));
    expect(find.text('Alfa Romeo'), findsOneWidget);
    final box = tester.getSize(find.text('Alfa Romeo'));
    expect(box.width, lessThanOrEqualTo(SearchConfig.brandItemWidth));
    expect(box.height, lessThanOrEqualTo(SearchConfig.brandLabelHeight));
    await tester.pumpWidget(const SizedBox());
  });

  _test('tocar una marca fija el alcance: fila "Buscando en" y el ✕ lo quita', (
    tester,
  ) async {
    final harness = SearchHarness();
    await tester.pumpWidget(_page(harness));
    await _settle(tester);
    await _selectBrand(tester, 'Toyota');
    expect(harness.cubit.state.scopeBrand, 'Toyota');
    expect(find.text(AppTexts.searchScopePrefix), findsOneWidget);
    // La fila de marcas se reemplaza por la fila compacta.
    expect(
      find.text(AppTexts.searchExploreByBrandTitle.toUpperCase()),
      findsNothing,
    );
    expect(_brand('Honda'), findsNothing);
    expect(find.byType(BrandLogoWidget), findsWidgets);
    await tester.tap(find.byKey(const ValueKey('search-scope-clear')));
    await _settle(tester);
    expect(harness.cubit.state.scopeBrand, isNull);
    expect(find.text(AppTexts.searchScopePrefix), findsNothing);
    expect(
      find.text(AppTexts.searchExploreByBrandTitle.toUpperCase()),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox());
  });

  _test('una marca sin texto muestra todos sus modelos como tarjetas', (
    tester,
  ) async {
    final harness = SearchHarness();
    await tester.pumpWidget(_page(harness));
    await _settle(tester);
    await _selectBrand(tester, 'Honda');
    expect(find.byType(ModelGridCardWidget), findsNWidgets(2));
    expect(find.text('Accord'), findsOneWidget);
    expect(find.text('Civic'), findsOneWidget);
    expect(find.text('Corolla'), findsNothing);
    // Etiqueta de marca en mayúsculas sobre cada nombre.
    expect(find.text('HONDA'), findsNWidgets(2));
    // Encabezado de resultados: cuenta y marca.
    expect(
      find.text(AppTexts.searchResultsCountLabel(2).toUpperCase()),
      findsOneWidget,
    );
    expect(find.text('Honda'), findsWidgets);
    expect(find.text(AppTexts.searchIdleHint), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  _test('con texto los resultados son tarjetas de todas las marcas', (
    tester,
  ) async {
    final harness = SearchHarness();
    await tester.pumpWidget(_page(harness));
    await _settle(tester);
    await _type(tester, 'c');
    expect(find.byType(ModelGridCardWidget), findsNothing);
    await _type(tester, 'ci');
    expect(find.byType(ModelGridCardWidget), findsOneWidget);
    expect(find.text('Civic'), findsOneWidget);
    expect(find.text('HONDA'), findsOneWidget);
    await _type(tester, 'co');
    expect(find.text('Corolla'), findsOneWidget);
    expect(find.text('TOYOTA'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  _test(
    'con alcance y texto: "En {marca}" primero y "En otras marcas" debajo',
    (tester) async {
      final harness = SearchHarness(
        groupsByBrand: {
          'Toyota': ['Corolla', 'Camry'],
          'Honda': ['Civic', 'Corvette X'],
        },
      );
      await tester.pumpWidget(_page(harness));
      await _settle(tester);
      await _type(tester, 'cor');
      expect(find.byType(ModelGridCardWidget), findsNWidgets(2));
      expect(
        find.text(AppTexts.searchResultsCountLabel(2).toUpperCase()),
        findsOneWidget,
      );
      await tester.tap(find.byTooltip(AppTexts.searchClearSemanticLabel));
      await _settle(tester);
      await _selectBrand(tester, 'Toyota');
      await _type(tester, 'cor');
      expect(find.byType(ModelGridCardWidget), findsNWidgets(2));
      final inBrand = find.text(
        AppTexts.searchInBrandTitle('Toyota').toUpperCase(),
      );
      final others = find.text(AppTexts.searchOtherBrandsTitle.toUpperCase());
      expect(inBrand, findsOneWidget);
      expect(others, findsOneWidget);
      double top(Finder finder) => tester.getTopLeft(finder).dy;
      expect(top(inBrand), lessThan(top(find.text('Corolla'))));
      expect(top(find.text('Corolla')), lessThan(top(others)));
      expect(top(others), lessThan(top(find.text('Corvette X'))));
      expect(
        find.text(AppTexts.searchNoResultsInBrand('Toyota')),
        findsNothing,
      );
      await tester.pumpWidget(const SizedBox());
    },
  );

  _test('alcance Audi y "ferrari": nota, los Ferrari debajo y fila Marcas', (
    tester,
  ) async {
    final harness = SearchHarness(
      groupsByBrand: {
        'Audi': ['A3'],
        'Ferrari': ['Roma', 'F8 Tributo'],
      },
    );
    await tester.pumpWidget(_page(harness));
    await _settle(tester);
    await _selectBrand(tester, 'Audi');
    await _type(tester, 'ferrari');
    expect(find.text(AppTexts.searchNoResultsInBrand('Audi')), findsOneWidget);
    expect(
      find.text(AppTexts.searchOtherBrandsTitle.toUpperCase()),
      findsOneWidget,
    );
    expect(find.byType(ModelGridCardWidget), findsNWidgets(2));
    // Fila "Marcas": tocar el logo fija ese alcance y limpia el texto.
    expect(
      find.text(AppTexts.searchBrandMatchesTitle.toUpperCase()),
      findsOneWidget,
    );
    await tester.tap(_brand('Ferrari'));
    await _settle(tester);
    expect(harness.cubit.state.scopeBrand, 'Ferrari');
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '',
    );
    expect(find.byType(ModelGridCardWidget), findsNWidgets(2));
    await tester.pumpWidget(const SizedBox());
  });

  _test('el tope de resultados se avisa con una nota', (tester) async {
    final harness = SearchHarness(
      groupsByBrand: {
        'Toyota': [
          for (int i = 0; i < SearchConfig.maxResults + 5; i++)
            'Modelo ${i.toString().padLeft(3, '0')}',
        ],
      },
    );
    await tester.pumpWidget(_page(harness));
    await _settle(tester);
    await _type(tester, 'modelo');
    expect(
      find.text(AppTexts.searchResultsTruncatedLabel(SearchConfig.maxResults)),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox());
  });

  _test('las tarjetas piden su foto y resumen a cubits propios', (
    tester,
  ) async {
    final harness = SearchHarness();
    final cards = _CardCubits();
    await tester.pumpWidget(_page(harness, cards: cards));
    await _settle(tester);
    await _selectBrand(tester, 'Honda');
    expect(cards.photos, hasLength(1));
    verify(() => cards.photos.single.requestPhotos(any())).called(2);
    verify(() => cards.summaries.single.requestSummaries(any())).called(2);
    // Otra consulta reinicia los cubits y cancela lo pendiente de los viejos.
    await _type(tester, 'ci');
    expect(cards.photos, hasLength(2));
    expect(cards.summaries, hasLength(2));
    verify(() => cards.photos.first.cancelPending()).called(1);
    verify(() => cards.summaries.first.cancelPending()).called(1);
    await tester.pumpWidget(const SizedBox());
  });

  _test('el progreso no reemplaza los resultados ya mostrados', (tester) async {
    final harness = SearchHarness();
    harness.source.failingBrands.add('Honda');
    await tester.pumpWidget(_page(harness));
    await _settle(tester);
    await _type(tester, 'toy');
    expect(find.byType(ModelGridCardWidget), findsNWidgets(3));
    expect(find.byType(LinearProgressIndicator), findsNothing);
    // Al reintentar, el índice vuelve a construirse sin tapar lo mostrado.
    harness.source.failingBrands.clear();
    harness.source.gate = Completer<void>();
    await tester.tap(find.text(AppTexts.retryButtonLabel));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.byType(ModelGridCardWidget), findsNWidgets(3));
    expect(find.text(AppTexts.searchPartialMessage), findsNothing);
    harness.source.gate!.complete();
    await _settle(tester);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.byType(ModelGridCardWidget), findsNWidgets(3));
    await tester.pumpWidget(const SizedBox());
  });

  _test('con el índice en marcha las marcas ya se pueden tocar', (
    tester,
  ) async {
    final harness = SearchHarness();
    harness.source.gate = Completer<void>();
    await tester.pumpWidget(_page(harness));
    await _settle(tester);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    await _selectBrand(tester, 'Honda');
    // Aún sin modelos: ni "sin resultados" ni tarjetas, solo la barra.
    expect(find.byType(ModelGridCardWidget), findsNothing);
    expect(
      find.text(AppTexts.searchNoResultsScope('EE. UU.', 2025)),
      findsNothing,
    );
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    harness.source.gate!.complete();
    await _settle(tester);
    expect(find.byType(ModelGridCardWidget), findsNWidgets(2));
    expect(find.byType(LinearProgressIndicator), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  _test('sin resultados: texto, mercado, año y quitar el filtro de marca', (
    tester,
  ) async {
    final harness = SearchHarness();
    await tester.pumpWidget(_page(harness));
    await _settle(tester);
    await _type(tester, 'zzzz');
    expect(find.text(AppTexts.searchNoResultsTitle('zzzz')), findsOneWidget);
    expect(
      find.text(
        AppTexts.searchNoResultsScope(AppTexts.marketUnitedStatesLabel, 2025),
      ),
      findsOneWidget,
    );
    expect(find.text(AppTexts.searchNoResultsSuggestion), findsOneWidget);
    expect(find.byType(SearchSuggestionsWidget), findsNothing);
    // La única acción principal: relleno amarillo con texto tinta.
    final button = find.byType(AccentButton);
    expect(button, findsOneWidget);
    expect(
      find.descendant(
        of: button,
        matching: find.text(AppTexts.searchOtherYearsAction),
      ),
      findsOneWidget,
    );
    final material = tester.widget<Material>(
      find.descendant(of: button, matching: find.byType(Material)).first,
    );
    expect(material.color, AppColors.accent);
    await tester.pumpWidget(const SizedBox());
  });

  _test('sugerencias en chips: tocar una reemplaza el texto', (tester) async {
    final harness = SearchHarness();
    await tester.pumpWidget(_page(harness));
    await _settle(tester);
    await _type(tester, 'toyta');
    final chip = find.text(AppTexts.searchSuggestionLabel('toyota'));
    expect(chip, findsOneWidget);
    // Nunca se sustituye solo.
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'toyta',
    );
    await tester.tap(chip);
    await _settle(tester);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'toyota',
    );
    expect(find.byType(ModelGridCardWidget), findsNWidgets(3));
    await tester.pumpWidget(const SizedBox());
  });

  _test('otros años: botón, filas compactas y apertura con ese año', (
    tester,
  ) async {
    final harness = SearchHarness();
    final opened = <SearchResultEntity>[];
    await tester.pumpWidget(_page(harness, onOpen: (_, r) => opened.add(r)));
    await _settle(tester);
    await _type(tester, 'zzzz');
    await tester.tap(find.byType(AccentButton));
    await _settle(tester);
    expect(
      find.text(AppTexts.searchOtherYearsTitle.toUpperCase()),
      findsOneWidget,
    );
    expect(find.text(AppTexts.searchOtherYearsNone), findsOneWidget);
    // Con resultados, el enlace discreto al final de la lista.
    await _type(tester, 'camry');
    final link = find.byKey(const ValueKey('search-other-years-button'));
    expect(link, findsOneWidget);
    expect(find.text(AppTexts.searchOtherYearsPrompt), findsOneWidget);
    await tester.tap(link);
    await _settle(tester);
    expect(find.byType(SearchOtherYearRowWidget), findsNWidgets(3));
    // Un encabezado por año (sin pastilla en las filas), del más cercano al activo.
    expect(find.text('2026'), findsOneWidget);
    expect(find.text('2024'), findsOneWidget);
    expect(find.text('2023'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(SearchOtherYearRowWidget),
        matching: find.text('2026'),
      ),
      findsNothing,
    );
    double headerTop(int year) => tester
        .getTopLeft(find.byKey(ValueKey('search-other-year-header-$year')))
        .dy;
    expect(headerTop(2026), lessThan(headerTop(2024)));
    expect(headerTop(2024), lessThan(headerTop(2023)));
    expect(find.text(AppTexts.searchResultsCountLabel(1)), findsWidgets);
    await tester.tap(find.byType(SearchOtherYearRowWidget).first);
    await _settle(tester);
    expect(opened.single.year, 2026);
    expect(opened.single.groupName, 'Camry');
    // El año vigente de la búsqueda no cambió.
    expect(harness.cubit.state.scope, usScope);
    await tester.pumpWidget(const SizedBox());
  });

  _test('otros años en marcha: loader compacto y "Cancelar"', (tester) async {
    final harness = SearchHarness();
    await tester.pumpWidget(_page(harness));
    await _settle(tester);
    await _type(tester, 'camry');
    harness.source.gate = Completer<void>();
    await tester.tap(find.byKey(const ValueKey('search-other-years-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    const loaderKey = ValueKey('search-other-years-loader');
    expect(find.byKey(loaderKey), findsOneWidget);
    expect(tester.widget<AppLoader>(find.byKey(loaderKey)).compact, isTrue);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    await tester.tap(find.byKey(const ValueKey('search-other-years-cancel')));
    harness.source.gate!.complete();
    await _settle(tester);
    expect(find.byKey(loaderKey), findsNothing);
    expect(harness.cubit.state.otherYears, isNull);
    await tester.pumpWidget(const SizedBox());
  });

  _test('índice parcial: aviso discreto con "Reintentar" amarillo', (
    tester,
  ) async {
    final harness = SearchHarness();
    harness.source.failingBrands.add('Honda');
    await tester.pumpWidget(_page(harness));
    await _settle(tester);
    expect(find.text(AppTexts.searchPartialMessage), findsOneWidget);
    final button = tester.widget<Material>(
      find
          .descendant(
            of: find.byType(AccentButton),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(button.color, AppColors.accent);
    harness.source.failingBrands.clear();
    await tester.tap(find.text(AppTexts.retryButtonLabel));
    await _settle(tester);
    expect(find.text(AppTexts.searchPartialMessage), findsNothing);
    expect(harness.cubit.state.indexStatus?.phase, SearchIndexPhase.ready);
    await tester.pumpWidget(const SizedBox());
  });

  _test('sin conexión muestra el error de la app con Reintentar', (
    tester,
  ) async {
    final harness = SearchHarness();
    harness.source.failBrands = true;
    await tester.pumpWidget(_page(harness));
    await _settle(tester);
    expect(find.byType(ErrorStateWidget), findsOneWidget);
    harness.source.failBrands = false;
    await tester.tap(find.text(AppTexts.retryButtonLabel));
    await _settle(tester);
    expect(find.byType(ErrorStateWidget), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  _test(
    'recientes: filas planas con reloj y "x", sin chips ni lista horizontal',
    (tester) async {
      final harness = SearchHarness();
      harness.recents.stored = [_recent('Civic'), _recent('Camry')];
      await tester.pumpWidget(_page(harness));
      await _settle(tester);
      expect(find.text(AppTexts.searchRecentsTitle), findsOneWidget);
      expect(find.text(AppTexts.searchClearAllLabel), findsOneWidget);
      expect(find.byIcon(Symbols.history), findsNWidgets(2));
      expect(find.byIcon(Symbols.close), findsNWidgets(2));
      // Filas planas: una debajo de otra, sin lista horizontal.
      expect(
        tester.getTopLeft(find.text('Camry')).dy,
        greaterThan(tester.getTopLeft(find.text('Civic')).dy),
      );
      expect(
        find.descendant(
          of: find.byType(SearchRecentsWidget),
          matching: find.byType(ListView),
        ),
        findsNothing,
      );
      expect(find.text(AppTexts.searchIdleHint), findsNothing);
      await tester.pumpWidget(const SizedBox());
    },
  );

  _test('borrar una reciente y borrar todo', (tester) async {
    final harness = SearchHarness();
    harness.recents.stored = [_recent('Civic'), _recent('Camry')];
    await tester.pumpWidget(_page(harness));
    await _settle(tester);
    await tester.tap(find.byKey(const ValueKey('search-recent-remove-civic')));
    await _settle(tester);
    expect(find.text('Civic'), findsNothing);
    expect(find.text('Camry'), findsOneWidget);
    await tester.tap(find.text(AppTexts.searchClearAllLabel));
    await _settle(tester);
    expect(find.text('Camry'), findsNothing);
    expect(harness.recents.stored, isEmpty);
    // Sin recientes queda solo explorar por marca.
    expect(find.byType(SearchRecentsWidget), findsNothing);
    expect(
      find.text(AppTexts.searchExploreByBrandTitle.toUpperCase()),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox());
  });

  _test('enviar con el teclado guarda la reciente; tocarla la repite', (
    tester,
  ) async {
    final harness = SearchHarness();
    await tester.pumpWidget(_page(harness));
    await _settle(tester);
    await _type(tester, 'honda');
    expect(harness.recents.stored, isEmpty);
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await _settle(tester);
    expect(harness.recents.stored.single.text, 'honda');
    await tester.tap(find.byTooltip(AppTexts.searchClearSemanticLabel));
    await _settle(tester);
    expect(find.text(AppTexts.searchRecentsTitle), findsOneWidget);
    await tester.tap(find.text('honda'));
    await _settle(tester);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'honda',
    );
    expect(find.text('Accord'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  _test('arrastrar la lista cierra el teclado', (tester) async {
    final harness = SearchHarness();
    await tester.pumpWidget(_page(harness));
    await _settle(tester);
    await _selectBrand(tester, 'Honda');
    final scroll = tester.widget<CustomScrollView>(
      find.byType(CustomScrollView),
    );
    expect(
      scroll.keyboardDismissBehavior,
      ScrollViewKeyboardDismissBehavior.onDrag,
    );
    await tester.pumpWidget(const SizedBox());
  });

  _test('tocar una tarjeta la entrega a la capa app y guarda la reciente', (
    tester,
  ) async {
    final harness = SearchHarness();
    final opened = <SearchResultEntity>[];
    await tester.pumpWidget(_page(harness, onOpen: (_, r) => opened.add(r)));
    await _settle(tester);
    await _type(tester, 'cam');
    await tester.tap(find.byType(ModelGridCardWidget));
    await _settle(tester);
    expect(opened, [
      const SearchResultEntity(
        brand: 'Toyota',
        groupName: 'Camry',
        variantNames: ['Camry'],
        year: 2025,
        marketCode: 'us',
      ),
    ]);
    expect(harness.recents.stored.single.key, 'cam');
    await tester.pumpWidget(const SizedBox());
  });

  _test('la consulta, la marca y los resultados se conservan al volver', (
    tester,
  ) async {
    final harness = SearchHarness();
    await tester.pumpWidget(_page(harness));
    await _settle(tester);
    await _selectBrand(tester, 'Toyota');
    await _type(tester, 'cam');
    expect(find.text('Camry'), findsOneWidget);
    // Se sale de la sección (la pantalla se destruye) y se vuelve.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(_page(harness));
    await _settle(tester);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'cam',
    );
    expect(harness.cubit.state.scopeBrand, 'Toyota');
    expect(find.text('Camry'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  _test('las tarjetas abren Detalle con año, marca, grupo y mercado', (
    tester,
  ) async {
    final harness = SearchHarness();
    DetailArgsEntity? args;
    final router = GoRouter(
      initialLocation: RoutesConfig.search,
      routes: [
        GoRoute(
          path: RoutesConfig.search,
          builder: (_, _) => const SearchPage(
            onOpenResult: openSearchResultInDetail,
            resultsGridBuilder: buildSearchResultsGrid,
            selectorBuilder: _selector,
          ),
        ),
        GoRoute(
          path: RoutesConfig.detail,
          builder: (_, state) {
            args = state.extra! as DetailArgsEntity;
            return const Scaffold(body: Text('detalle'));
          },
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      _wrap(
        harness,
        MaterialApp.router(builder: _noAnimations, routerConfig: router),
        cards: _CardCubits(),
      ),
    );
    await _settle(tester);
    await _type(tester, 'camry');
    await tester.tap(find.byType(ModelGridCardWidget).first);
    await _settle(tester);
    expect(find.text('detalle'), findsOneWidget);
    expect(args?.brand, 'Toyota');
    expect(args?.groupName, 'Camry');
    expect(args?.year, 2025);
    expect(args?.market, Market.unitedStates);
    expect(args?.variantNames, isNotEmpty);
    // Al volver, la búsqueda sigue como estaba.
    router.pop();
    await _settle(tester);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'camry',
    );
    expect(find.text('Camry'), findsWidgets);
    await tester.pumpWidget(const SizedBox());
  });

  _test('la barra de inicio no es editable y lleva a búsqueda con foco', (
    tester,
  ) async {
    final harness = SearchHarness();
    final router = GoRouter(
      routes: [
        GoRoute(
          path: RoutesConfig.home,
          builder: (context, _) => Scaffold(
            body: HomeSearchBarWidget(onTap: () => openSearchFromHome(context)),
          ),
        ),
        GoRoute(
          path: RoutesConfig.search,
          builder: (_, _) => SearchPage(
            onOpenResult: (_, _) {},
            resultsGridBuilder: buildSearchResultsGrid,
            selectorBuilder: _selector,
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      _wrap(
        harness,
        MaterialApp.router(builder: _noAnimations, routerConfig: router),
        cards: _CardCubits(),
      ),
    );
    await tester.pump();
    expect(find.byType(TextField), findsNothing);
    expect(find.text(AppTexts.searchHomeBarLabel), findsOneWidget);
    await tester.tap(find.byType(HomeSearchBarWidget));
    await _settle(tester);
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.focusNode!.hasFocus, isTrue);
    expect(harness.cubit.state.indexStatus?.phase, SearchIndexPhase.ready);
    await tester.pumpWidget(const SizedBox());
  });
  group('buscador fijo', () {
    Future<void> openWithResults(WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 420);
      await tester.pumpWidget(_page(SearchHarness()));
      await _settle(tester);
      await _type(tester, 'toyota');
    }

    // Salto directo: arrastrar a mano cierra el teclado por diseño.
    void scrollTo(WidgetTester tester, double offset) => tester
        .widget<CustomScrollView>(find.byType(CustomScrollView))
        .controller!
        .jumpTo(offset);

    double fieldTop(WidgetTester tester) =>
        tester.getTopLeft(find.byType(SearchFieldWidget)).dy;

    testWidgets('tras bajar el campo sigue arriba y al volver reaparece todo', (
      tester,
    ) async {
      addTearDown(tester.view.reset);
      tester.view.devicePixelRatio = 1;
      await openWithResults(tester);
      expect(find.text(AppTexts.searchPageTitle), findsOneWidget);
      final topBefore = fieldTop(tester);
      scrollTo(tester, 600);
      await tester.pump();
      expect(find.byType(SearchFieldWidget), findsOneWidget);
      // El campo queda dentro de la banda fija, pegado arriba.
      expect(fieldTop(tester), SearchConfig.pinnedBandPadding);
      expect(fieldTop(tester), lessThan(topBefore));
      scrollTo(tester, 0);
      await tester.pump();
      expect(fieldTop(tester), topBefore);
      final title = tester.getRect(find.text(AppTexts.searchPageTitle));
      expect(title.top, greaterThanOrEqualTo(0));
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('el campo conserva foco y texto al colapsar y expandir', (
      tester,
    ) async {
      addTearDown(tester.view.reset);
      tester.view.devicePixelRatio = 1;
      await openWithResults(tester);
      await tester.tap(find.byType(TextField));
      await tester.pump();
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.focusNode!.hasFocus, isTrue);
      scrollTo(tester, 600);
      await tester.pump();
      expect(field.focusNode!.hasFocus, isTrue);
      expect(find.text('toyota'), findsOneWidget);
      scrollTo(tester, 0);
      await tester.pump();
      expect(field.focusNode!.hasFocus, isTrue);
      expect(find.text('toyota'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('estado conservado', () {
    GoRouter buildRouter() => GoRouter(
      initialLocation: '/search',
      routes: [
        GoRoute(
          path: '/search',
          builder: (_, _) => SearchPage(
            onOpenResult: (context, _) => context.push('/detail'),
            resultsGridBuilder: buildSearchResultsGrid,
            selectorBuilder: _selector,
          ),
        ),
        GoRoute(path: '/other', builder: (_, _) => const Text('otra pantalla')),
        GoRoute(path: '/detail', builder: (_, _) => const Text('detalle')),
      ],
    );

    double offset(WidgetTester tester) => tester
        .widget<CustomScrollView>(find.byType(CustomScrollView))
        .controller!
        .offset;

    Future<GoRouter> open(WidgetTester tester, SearchHarness harness) async {
      tester.view.physicalSize = const Size(360, 420);
      final router = buildRouter();
      addTearDown(router.dispose);
      await tester.pumpWidget(
        _wrap(
          harness,
          MaterialApp.router(builder: _noAnimations, routerConfig: router),
          cards: _CardCubits(),
        ),
      );
      await _settle(tester);
      await _type(tester, 'toyota');
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -150));
      await tester.pump();
      return router;
    }

    _test('el botón de subir aparece al bajar en Buscar', (tester) async {
      final harness = SearchHarness();
      await open(tester, harness);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -900));
      await tester.pump(const Duration(milliseconds: 400));
      final opacity = tester
          .widget<AnimatedOpacity>(
            find.ancestor(
              of: find.byKey(const ValueKey('scroll-to-top-button')),
              matching: find.byType(AnimatedOpacity),
            ),
          )
          .opacity;
      expect(offset(tester), greaterThan(ScrollConfig.topButtonShowThreshold));
      expect(opacity, 1);
      await tester.pumpWidget(const SizedBox());
    });

    _test('abrir Detalle y volver conserva el desplazamiento', (tester) async {
      final harness = SearchHarness();
      final router = await open(tester, harness);
      final before = offset(tester);
      expect(before, greaterThan(0));
      unawaited(router.push('/detail'));
      await _settle(tester);
      router.pop();
      await _settle(tester);
      expect(offset(tester), before);
      await tester.pumpWidget(const SizedBox());
    });

    _test('cambiar de pestaña y volver conserva posición y texto', (
      tester,
    ) async {
      final harness = SearchHarness();
      final router = await open(tester, harness);
      final before = offset(tester);
      expect(before, greaterThan(0));
      router.go('/other');
      await _settle(tester);
      router.go('/search');
      await _settle(tester);
      expect(offset(tester), before);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'toyota',
      );
      await tester.pumpWidget(const SizedBox());
    });

    _test('cambiar de mercado o de año reinicia el desplazamiento', (
      tester,
    ) async {
      final harness = SearchHarness();
      final router = await open(tester, harness);
      expect(offset(tester), greaterThan(0));
      router.go('/other');
      await _settle(tester);
      harness.context.change(mxScope);
      await _settle(tester);
      router.go('/search');
      await _settle(tester);
      expect(offset(tester), 0);
      await tester.pumpWidget(const SizedBox());
    });
  });
}
