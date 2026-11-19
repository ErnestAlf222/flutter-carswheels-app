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

/// Borde del círculo de una marca; nulo si no está seleccionada.
Border? _ringOf(WidgetTester tester, Finder item) {
  final circle = tester.widget<Container>(
    find.descendant(of: item, matching: find.byType(Container)).first,
  );
  return (circle.decoration! as BoxDecoration).border as Border?;
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

  _test('encabezado con título, contexto y campo; estado inicial vacío', (
    tester,
  ) async {
    final harness = SearchHarness();
    await tester.pumpWidget(_page(harness));
    await _settle(tester);
    expect(find.byType(HeroHeaderWidget), findsOneWidget);
    expect(find.text(AppTexts.searchPageTitle), findsOneWidget);
    expect(find.text('EE. UU. · 2025'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    // Sin recientes: solo la lupa grande y el texto amable.
    expect(find.text(AppTexts.searchIdleHint), findsOneWidget);
    expect(find.byType(SearchRecentsWidget), findsNothing);
    expect(find.byType(ModelGridCardWidget), findsNothing);
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

  _test('el selector trae "Todas" y todas las marcas en orden alfabético', (
    tester,
  ) async {
    final harness = SearchHarness();
    await tester.pumpWidget(_page(harness));
    await _settle(tester);
    expect(find.text(AppTexts.searchAllBrandsLabel), findsOneWidget);
    final xs = [
      for (final key in [
        const ValueKey('search-brand-all'),
        const ValueKey('search-brand-Honda'),
        const ValueKey('search-brand-Hyundai'),
        const ValueKey('search-brand-Toyota'),
      ])
        tester.getTopLeft(find.byKey(key)).dx,
    ];
    expect(xs, orderedEquals([...xs]..sort()));
    expect(xs.toSet(), hasLength(4));
    // Una sola fila: todos a la misma altura.
    expect(
      tester.getTopLeft(_brand('Honda')).dy,
      tester.getTopLeft(_brand('Toyota')).dy,
    );
    await tester.pumpWidget(const SizedBox());
  });

  _test('la marca elegida lleva aro tinta y tocarla de nuevo lo quita', (
    tester,
  ) async {
    final harness = SearchHarness();
    await tester.pumpWidget(_page(harness));
    await _settle(tester);
    // Sin marca elegida, "Todas" es la seleccionada.
    expect(
      _ringOf(tester, find.byKey(const ValueKey('search-brand-all'))),
      isNotNull,
    );
    expect(_ringOf(tester, _brand('Toyota')), isNull);
    await _selectBrand(tester, 'Toyota');
    final ring = _ringOf(tester, _brand('Toyota'))!;
    expect(ring.top.width, SearchConfig.brandRingWidth);
    expect(ring.top.color, AppColors.ink);
    expect(_ringOf(tester, _brand('Honda')), isNull);
    expect(harness.cubit.state.brandFilter, 'Toyota');
    await _selectBrand(tester, 'Toyota');
    expect(harness.cubit.state.brandFilter, isNull);
    expect(_ringOf(tester, _brand('Toyota')), isNull);
    await _selectBrand(tester, 'Honda');
    await tester.tap(find.byKey(const ValueKey('search-brand-all')));
    await _settle(tester);
    expect(harness.cubit.state.brandFilter, isNull);
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

  _test('el texto se combina con la marca elegida', (tester) async {
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
    await _selectBrand(tester, 'Toyota');
    expect(find.byType(ModelGridCardWidget), findsOneWidget);
    expect(find.text('Corolla'), findsOneWidget);
    expect(find.text('Corvette X'), findsNothing);
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
    await _selectBrand(tester, 'Toyota');
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
    // Sin marca elegida no hay botón.
    expect(find.text(AppTexts.searchRemoveBrandFilterLabel), findsNothing);
    await _selectBrand(tester, 'Honda');
    expect(find.text(AppTexts.searchRemoveBrandFilterLabel), findsOneWidget);
    await tester.tap(find.text(AppTexts.searchRemoveBrandFilterLabel));
    await _settle(tester);
    expect(harness.cubit.state.brandFilter, isNull);
    expect(find.text(AppTexts.searchRemoveBrandFilterLabel), findsNothing);
    expect(find.text(AppTexts.searchNoResultsTitle('zzzz')), findsOneWidget);
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

  _test('recientes: una fila horizontal con reloj y "x"; sin lista vertical', (
    tester,
  ) async {
    final harness = SearchHarness();
    harness.recents.stored = [_recent('Civic'), _recent('Camry')];
    await tester.pumpWidget(_page(harness));
    await _settle(tester);
    expect(find.text(AppTexts.searchRecentsTitle), findsOneWidget);
    expect(find.text(AppTexts.searchClearAllLabel), findsOneWidget);
    expect(find.byIcon(Symbols.history), findsNWidgets(2));
    expect(find.byIcon(Symbols.close), findsNWidgets(2));
    // Mismo renglón: los dos chips están a la misma altura.
    expect(
      tester.getTopLeft(find.text('Civic')).dy,
      tester.getTopLeft(find.text('Camry')).dy,
    );
    final row = tester.widget<ListView>(
      find.descendant(
        of: find.byType(SearchRecentsWidget),
        matching: find.byType(ListView),
      ),
    );
    expect(row.scrollDirection, Axis.horizontal);
    expect(find.text(AppTexts.searchIdleHint), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

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
    // Sin recientes vuelve el texto amable.
    expect(find.text(AppTexts.searchIdleHint), findsOneWidget);
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
    expect(harness.cubit.state.brandFilter, 'Toyota');
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
}
