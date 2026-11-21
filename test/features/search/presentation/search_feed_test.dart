import 'package:cars_wheels_app/app/search_results/search_card_cubits_factory.dart';
import 'package:cars_wheels_app/app/search_results/search_results_grid.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/favorites/favorites.dart';
import 'package:cars_wheels_app/features/market/market.dart';
import 'package:cars_wheels_app/features/search/domain/feed/feed.dart';
import 'package:cars_wheels_app/features/search/search.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/brand_logos_test_support.dart';
import '../../../support/favorites_test_support.dart';
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
  Future<List<ModelEntity>> fetchModels(int year, String brand) async =>
      const [];
}

SearchCardCubitsFactory _cards() => SearchCardCubitsFactory(
  createPhotos: () {
    final cubit = buildMockPhotosCubit();
    when(() => cubit.isClosed).thenReturn(false);
    when(() => cubit.close()).thenAnswer((_) async {});
    return cubit;
  },
  createSummaries: () {
    final cubit = buildMockSummariesCubit();
    when(() => cubit.isClosed).thenReturn(false);
    when(() => cubit.close()).thenAnswer((_) async {});
    return cubit;
  },
);

// 4 marcas de 10 modelos: 40 en total; 6 son sugerencias y 34 son del feed.
Map<String, List<String>> _catalog() => {
  for (final brand in ['Alfa', 'Beta', 'Gama', 'Delta'])
    brand: [for (final i in List.generate(10, (n) => n + 1)) '$brand M$i'],
};

Widget _page(
  SearchHarness harness, {
  bool infiniteFeed = true,
  bool animations = false,
  void Function(BuildContext, SearchResultEntity)? onOpen,
}) => MultiRepositoryProvider(
  providers: [
    RepositoryProvider<ScrollOffsetStore>.value(value: ScrollOffsetStore()),
    RepositoryProvider<SearchCardCubitsFactory>.value(value: _cards()),
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
      BlocProvider<FavoritesCubit>(create: (_) => buildFavoritesCubit()),
    ],
    child: MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: !animations),
        child: child!,
      ),
      home: SearchPage(
        onOpenResult: onOpen ?? (_, _) {},
        resultsGridBuilder: buildSearchResultsGrid,
        selectorBuilder: (_) => const SizedBox(width: 120),
        picksSeed: 7,
        picksBuilder: (context, picks, resetKey, onOpen) => Column(
          children: [for (final pick in picks) Text('pick ${pick.groupName}')],
        ),
        infiniteFeed: infiniteFeed,
      ),
    ),
  ),
);

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
}

// Todas las tarjetas del feed construidas hasta ahora.
List<String> _cardNames(WidgetTester tester) => [
  for (final card in tester.widgetList<ModelGridCardWidget>(
    find.byType(ModelGridCardWidget),
  ))
    '${card.brand} ${card.group.name}',
];

List<String> _pickNames(WidgetTester tester) => [
  for (final text in tester.widgetList<Text>(find.textContaining('pick ')))
    text.data!.substring('pick '.length),
];

void _view(WidgetTester tester, {double height = 2400}) {
  tester.view.physicalSize = Size(800, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('SearchFeedPlanner', () {
    const planner = SearchFeedPlanner();
    final groups = [
      for (final brand in ['A', 'B'])
        for (final i in List.generate(12, (n) => n))
          SearchEntryEntity(brand: brand, groupName: 'M$i'),
      const SearchEntryEntity(brand: 'A'),
    ];

    List<String> keys(List<SearchEntryEntity> entries) => [
      for (final entry in entries) SearchFeedPlanner.keyOf(entry),
    ];

    test('la misma semilla da la misma página y otra semilla, otra', () {
      final first = planner.plan(groups, seed: 1, exclude: {}, pageSize: 10);
      final again = planner.plan(groups, seed: 1, exclude: {}, pageSize: 10);
      final other = planner.plan(groups, seed: 2, exclude: {}, pageSize: 10);
      expect(keys(first.page), keys(again.page));
      expect(keys(first.page), isNot(keys(other.page)));
      expect(first.page, hasLength(10));
    });

    test('las filas de marca sola no cuentan y lo excluido no se repite', () {
      final first = planner.plan(groups, seed: 1, exclude: {}, pageSize: 10);
      expect(first.remaining, 14);
      final shown = {...keys(first.page)};
      final second = planner.plan(
        groups,
        seed: 1,
        exclude: shown,
        pageSize: 10,
      );
      expect(keys(second.page).toSet().intersection(shown), isEmpty);
      expect(second.page, hasLength(10));
      expect(second.remaining, 4);
    });

    test('de página en página se recorre todo sin repetir y se agota', () {
      final shown = <String>{};
      final order = <String>[];
      for (final _ in List.generate(5, (n) => n)) {
        final slice = planner.plan(
          groups,
          seed: 3,
          exclude: shown,
          pageSize: 10,
        );
        order.addAll(keys(slice.page));
        shown.addAll(keys(slice.page));
      }
      expect(order, hasLength(24));
      expect(order.toSet(), hasLength(24));
    });

    test('si el índice crece, lo ya mostrado no cambia y no hay repetidos', () {
      final partial = groups.take(14).toList();
      final first = planner.plan(partial, seed: 5, exclude: {}, pageSize: 6);
      final shown = keys(first.page).toSet();
      // El índice crece: llega el resto.
      final second = planner.plan(
        groups,
        seed: 5,
        exclude: shown,
        pageSize: 10,
      );
      expect(keys(second.page).toSet().intersection(shown), isEmpty);
      // Y el orden de lo ya mostrado sigue siendo el mismo si se recalcula.
      final recomputed = planner.plan(
        partial,
        seed: 5,
        exclude: {},
        pageSize: 6,
      );
      expect(keys(recomputed.page), keys(first.page));
    });

    test('el feed vacío y sin índice en obra es el final', () {
      const done = SearchFeedPageEntity(
        results: [],
        remaining: 0,
        isBuilding: false,
      );
      const waiting = SearchFeedPageEntity(
        results: [],
        remaining: 0,
        isBuilding: true,
      );
      expect(done.isExhausted, isTrue);
      expect(waiting.isExhausted, isFalse);
    });
  });

  group('feed en Buscar', () {
    testWidgets('con el campo vacío sigue a las sugerencias y no las repite', (
      tester,
    ) async {
      _view(tester, height: 12000);
      final harness = SearchHarness(groupsByBrand: _catalog());
      await tester.pumpWidget(_page(harness));
      await _settle(tester);
      final picks = _pickNames(tester);
      expect(picks, hasLength(SearchConfig.picksCount));
      final names = _cardNames(tester);
      expect(names, isNotEmpty);
      // Nada del feed se repite ni coincide con las sugerencias.
      expect(names.toSet(), hasLength(names.length));
      for (final pick in picks) {
        expect(names.any((name) => name.endsWith(pick)), isFalse);
      }
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets(
      'carga de 10 en 10 al acercarse al final y termina con la nota',
      (tester) async {
        _view(tester, height: 900);
        final harness = SearchHarness(groupsByBrand: _catalog());
        await tester.pumpWidget(_page(harness));
        await _settle(tester);
        final scroll = find.byType(CustomScrollView);
        final first = _cardNames(tester);
        expect(first.length, lessThanOrEqualTo(SearchConfig.feedPageSize + 6));
        expect(find.text(AppTexts.searchFeedEndNote), findsNothing);
        // Se baja varias veces hasta agotar el catálogo.
        for (final _ in List.generate(30, (n) => n)) {
          await tester.drag(scroll, const Offset(0, -3000));
          await _settle(tester);
        }
        expect(find.text(AppTexts.searchFeedEndNote), findsOneWidget);
        await tester.pumpWidget(const SizedBox());
      },
    );

    testWidgets('mientras llega la página se ve solo el cargador compacto', (
      tester,
    ) async {
      _view(tester, height: 900);
      final harness = SearchHarness(groupsByBrand: _catalog());
      await tester.pumpWidget(_page(harness, animations: true));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));
      // Con la pausa de carga a la vista, el pie muestra el cargador compacto.
      expect(find.byType(AppLoader), findsOneWidget);
      expect(tester.widget<AppLoader>(find.byType(AppLoader)).compact, isTrue);
      for (final _ in List.generate(10, (n) => n)) {
        await tester.pump(const Duration(milliseconds: 300));
      }
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets(
      'con texto escrito el feed desaparece y vuelve igual al vaciar',
      (tester) async {
        _view(tester, height: 12000);
        final harness = SearchHarness(groupsByBrand: _catalog());
        await tester.pumpWidget(_page(harness));
        await _settle(tester);
        final before = _cardNames(tester);
        expect(before, isNotEmpty);
        await tester.enterText(find.byType(TextField), 'alfa');
        await tester.pump(const Duration(milliseconds: 350));
        await tester.pump(const Duration(milliseconds: 350));
        expect(find.text(AppTexts.searchFeedEndNote), findsNothing);
        expect(_cardNames(tester), isNot(before));
        await tester.enterText(find.byType(TextField), '');
        await _settle(tester);
        // Lo que ya estaba se conserva tal cual y el feed puede seguir creciendo.
        expect(_cardNames(tester).take(before.length).toList(), before);
        await tester.pumpWidget(const SizedBox());
      },
    );

    testWidgets('en el selector (sin feed) no aparece', (tester) async {
      _view(tester, height: 12000);
      final harness = SearchHarness(groupsByBrand: _catalog());
      await tester.pumpWidget(_page(harness, infiniteFeed: false));
      await _settle(tester);
      expect(find.byType(ModelGridCardWidget), findsNothing);
      expect(find.text(AppTexts.searchFeedEndNote), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('cambiar de año reinicia el feed', (tester) async {
      _view(tester, height: 12000);
      final harness = SearchHarness(groupsByBrand: _catalog());
      await tester.pumpWidget(_page(harness));
      await _settle(tester);
      final before = _cardNames(tester);
      expect(before, isNotEmpty);
      harness.context.change(
        const SearchScopeEntity(marketCode: 'us', year: 2024),
      );
      await _settle(tester);
      // El feed arranca de nuevo con el índice del otro año.
      expect(_cardNames(tester), isNotEmpty);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('sin desbordes a 360 dp con escala de texto 1.3', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final harness = SearchHarness(groupsByBrand: _catalog());
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(360, 900),
            textScaler: TextScaler.linear(1.3),
            disableAnimations: true,
          ),
          child: _page(harness),
        ),
      );
      await _settle(tester);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -2500));
      await _settle(tester);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  });
}
