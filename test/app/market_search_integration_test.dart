import 'package:cars_wheels_app/app/app.dart';
import 'package:cars_wheels_app/app/market_catalog/market_search_context_source.dart';
import 'package:cars_wheels_app/app/market_catalog/market_search_detail_args_builder.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/market/market.dart';
import 'package:cars_wheels_app/features/search/search.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/market_test_support.dart';

class _Repository implements CatalogRepository {
  _Repository(this.years);

  final List<int> years;

  @override
  Future<List<int>> fetchYears() async => years;

  @override
  Future<List<BrandEntity>> fetchBrands(int year) async => const [
    BrandEntity(name: 'Toyota'),
  ];

  @override
  Future<List<ModelEntity>> fetchModels(int year, String brand) async => const [
    ModelEntity(name: 'Camry LE'),
    ModelEntity(name: 'Camry XSE'),
    ModelEntity(name: 'Corolla'),
  ];
}

CatalogCubit _catalogCubit(CatalogRepository repository, MarketCubit market) =>
    CatalogCubit(
      minimumLoadingTime: Duration.zero,
      preferredYear: () => preferredYearFor(market.market),
      getAvailableYears: GetAvailableYearsUseCase(repository),
      getBrands: GetBrandsUseCase(
        repository: repository,
        sortStrategy: const AdaptiveSortStrategy<BrandEntity>(
          smallListStrategy: BubbleSortStrategy<BrandEntity>(),
          largeListStrategy: ShellSortStrategy<BrandEntity>(),
        ),
      ),
    );

GetModelGroupsUseCase _groups(CatalogRepository repository) =>
    GetModelGroupsUseCase(
      repository: repository,
      grouper: const ModelGrouper(
        sortStrategy: AdaptiveSortStrategy<ModelGroupEntity>(
          smallListStrategy: BubbleSortStrategy<ModelGroupEntity>(),
          largeListStrategy: ShellSortStrategy<ModelGroupEntity>(),
        ),
      ),
    );

Future<void> _pump() => Future<void>.delayed(Duration.zero);

void main() {
  group('año por defecto de cada mercado', () {
    test('EE. UU. usa el de config y México el de CONUEE', () {
      expect(FuelEconomyConfig.defaultYear, 2026);
      expect(preferredYearFor(Market.unitedStates), 2026);
      expect(preferredYearFor(Market.mexico), ConueeConfig.defaultYear);
    });

    test(
      'con 2027 disponible EE. UU. arranca en 2026 y 2027 sigue en el selector',
      () async {
        final market = buildMarketCubit();
        final catalog = _catalogCubit(_Repository([2027, 2026, 2025]), market);
        await catalog.loadBrands();
        final state = catalog.state as CatalogLoaded;
        expect(state.year, 2026);
        expect(state.availableYears, [2027, 2026, 2025]);
        await catalog.close();
        await market.close();
      },
    );

    test('al cambiar de mercado el año vuelve al de cada mercado', () async {
      final market = buildMarketCubit();
      await _pump();
      // Los años de cada mercado traen 2027, 2026 y 2025 disponibles.
      final catalog = _catalogCubit(_Repository([2027, 2026, 2025]), market);
      await catalog.loadBrands();
      expect((catalog.state as CatalogLoaded).year, 2026);
      // El usuario cambia de año y luego de mercado, como hace la app.
      await catalog.selectYear(2027);
      await market.select(Market.mexico);
      await catalog.loadBrands(force: true);
      expect((catalog.state as CatalogLoaded).year, 2025);
      await catalog.selectYear(2026);
      await market.select(Market.unitedStates);
      await catalog.loadBrands(force: true);
      expect((catalog.state as CatalogLoaded).year, 2026);
      await catalog.close();
      await market.close();
    });

    test('si 2026 no está en la lista cae al primero', () async {
      final market = buildMarketCubit();
      final catalog = _catalogCubit(_Repository([2025, 2024]), market);
      await catalog.loadBrands();
      expect((catalog.state as CatalogLoaded).year, 2025);
      await catalog.close();
      await market.close();
    });
  });

  group('MarketSearchContextSource', () {
    test('da el alcance con mercado y año al cargar el catálogo', () async {
      final market = buildMarketCubit();
      await _pump();
      final catalog = _catalogCubit(_Repository([2027, 2026]), market);
      final source = MarketSearchContextSource(
        market: market,
        catalog: catalog,
      );
      expect(source.scope, isNull);
      final changes = <SearchScopeEntity?>[];
      source.scopeChanges.listen(changes.add);
      await catalog.loadBrands();
      await _pump();
      expect(
        source.scope,
        const SearchScopeEntity(marketCode: 'us', year: 2026),
      );
      expect(changes.last, source.scope);
      await source.close();
      await catalog.close();
      await market.close();
    });

    test('cambiar de año anuncia el nuevo alcance', () async {
      final market = buildMarketCubit();
      await _pump();
      final catalog = _catalogCubit(_Repository([2027, 2026]), market);
      final source = MarketSearchContextSource(
        market: market,
        catalog: catalog,
      );
      await catalog.loadBrands();
      await _pump();
      await catalog.selectYear(2027);
      await _pump();
      expect(
        source.scope,
        const SearchScopeEntity(marketCode: 'us', year: 2027),
      );
      await source.close();
      await catalog.close();
      await market.close();
    });

    test(
      'al cambiar de mercado no hay alcance hasta que el catálogo recarga',
      () async {
        final market = buildMarketCubit();
        await _pump();
        final catalog = _catalogCubit(_Repository([2026]), market);
        final source = MarketSearchContextSource(
          market: market,
          catalog: catalog,
        );
        await catalog.loadBrands();
        await _pump();
        final changes = <SearchScopeEntity?>[];
        source.scopeChanges.listen(changes.add);
        await market.select(Market.mexico);
        await _pump();
        // La app recarga el catálogo al cambiar de mercado.
        await catalog.loadBrands(force: true);
        await _pump();
        expect(
          source.scope,
          const SearchScopeEntity(marketCode: 'mx', year: 2026),
        );
        // Primero queda sin alcance; el mercado nuevo nunca sale con el año viejo.
        expect(changes, [
          null,
          const SearchScopeEntity(marketCode: 'mx', year: 2026),
        ]);
        await source.close();
        await catalog.close();
        await market.close();
      },
    );
  });

  group('MarketSearchContextSource con recarga en el lugar', () {
    test(
      'mientras recarga no hay alcance ni años; luego llega el nuevo',
      () async {
        final market = buildMarketCubit();
        await _pump();
        final catalog = _catalogCubit(_Repository([2026]), market);
        final source = MarketSearchContextSource(
          market: market,
          catalog: catalog,
        );
        await catalog.loadBrands();
        await _pump();
        final changes = <SearchScopeEntity?>[];
        source.scopeChanges.listen(changes.add);
        await market.select(Market.mexico);
        await _pump();
        final duringReload = <(SearchScopeEntity?, List<int>)>[];
        catalog.stream.listen((state) {
          if (state is CatalogLoaded && state.isReloading) {
            duringReload.add((source.scope, source.availableYears));
          }
        });
        final reload = catalog.reloadForMarket();
        await _pump();
        await reload;
        await _pump();
        expect(
          source.scope,
          const SearchScopeEntity(marketCode: 'mx', year: 2026),
        );
        expect(changes, [
          null,
          const SearchScopeEntity(marketCode: 'mx', year: 2026),
        ]);
        await source.close();
        await catalog.close();
        await market.close();
      },
    );
  });

  group('MarketSearchDetailArgsBuilder', () {
    MarketSearchDetailArgsBuilder builder(Market Function() market) =>
        MarketSearchDetailArgsBuilder(
          getModelGroups: _groups(_Repository([2026])),
          currentMarket: market,
        );

    test(
      'arma los argumentos con año, marca, grupo, variantes y mercado',
      () async {
        final group = (await _groups(_Repository([2026]))(
          2026,
          'Toyota',
        )).first;
        final args = await builder(() => Market.unitedStates).build(
          SearchResultEntity(
            brand: 'Toyota',
            groupName: group.name,
            year: 2026,
            marketCode: 'us',
          ),
        );
        expect(args, isNotNull);
        expect(args!.brand, 'Toyota');
        expect(args.groupName, group.name);
        expect(args.year, 2026);
        expect(args.market, Market.unitedStates);
        expect(args.variantNames, [for (final v in group.variants) v.name]);
        expect(args.variantNames, isNotEmpty);
        expect(args.photo, isNull);
      },
    );

    test('lleva el mercado de México en los argumentos', () async {
      final args = await builder(() => Market.mexico).build(
        const SearchResultEntity(
          brand: 'Toyota',
          groupName: 'Corolla',
          year: 2025,
          marketCode: 'mx',
        ),
      );
      expect(args!.market, Market.mexico);
      expect(args.year, 2025);
    });

    test(
      'una marca sola o un resultado de otro mercado no abren Detalle',
      () async {
        final build = builder(() => Market.unitedStates);
        expect(
          await build.build(
            const SearchResultEntity(
              brand: 'Toyota',
              year: 2026,
              marketCode: 'us',
            ),
          ),
          isNull,
        );
        expect(
          await build.build(
            const SearchResultEntity(
              brand: 'Toyota',
              groupName: 'Camry',
              year: 2026,
              marketCode: 'mx',
            ),
          ),
          isNull,
        );
      },
    );
  });
}
