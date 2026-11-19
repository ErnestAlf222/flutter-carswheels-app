import 'package:cars_wheels_app/app/market_catalog/market_get_available_years_usecase.dart';
import 'package:cars_wheels_app/app/market_catalog/market_get_brands_usecase.dart';
import 'package:cars_wheels_app/app/market_catalog/market_get_model_groups_usecase.dart';
import 'package:cars_wheels_app/app/market_catalog/market_resolve_group_summary_usecase.dart';
import 'package:cars_wheels_app/app/market_catalog/market_summary_key_builder.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/market/market.dart';
import 'package:cars_wheels_app/features/mexico_catalog/mexico_catalog.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../support/conuee_test_support.dart';

class _UsCatalogRepository implements CatalogRepository {
  @override
  Future<List<int>> fetchYears() async => [2024, 2025];

  @override
  Future<List<BrandEntity>> fetchBrands(int year) async => [
    const BrandEntity(name: 'Toyota'),
    const BrandEntity(name: 'Audi'),
  ];

  @override
  Future<List<ModelEntity>> fetchModels(int year, String brand) async => [
    const ModelEntity(name: 'Corolla'),
    const ModelEntity(name: 'Camry'),
  ];
}

class _MxRepository implements MexicoCatalogRepository {
  @override
  Future<List<int>> fetchYears() async => [2026, 2025];

  @override
  Future<MxYearCatalogEntity> fetchYear(int year) async => mxCatalog(year, [
    mxVehicle('Chevrolet', 'AVEO'),
    mxVehicle('Chevrolet', 'AVEO LT', id: 1),
    mxVehicle('Audi', 'A3 SEDAN', id: 2),
    mxVehicle('Chevrolet', 'ONIX', id: 3),
  ]);
}

class _MockSpecsRepository extends Mock implements VehicleSpecsRepository {}

class _NullSummaryCache implements SummaryCacheDatasource {
  @override
  Future<CachedSummaryEntity?> read(String key) async => null;

  @override
  Future<void> write(String key, CachedSummaryEntity entry) async {}
}

const _usSummary = GroupSummaryEntity(
  vehicleClass: 'Compact Cars',
  minKmPerLiter: 10,
  maxKmPerLiter: 12,
  hasElectric: false,
  hasPluginHybrid: false,
  variantCount: 1,
);

class _UsSummary extends ResolveGroupSummaryUseCase {
  _UsSummary()
    : super(
        cache: _NullSummaryCache(),
        getGroupSummary: GetGroupSummaryUseCase(_MockSpecsRepository()),
        keyBuilder: const SummaryKeyBuilder(),
        clock: DateTime.now,
      );

  @override
  Future<GroupSummaryEntity?> call({
    required int year,
    required String brand,
    required String groupName,
    required List<String> variantNames,
  }) async => _usSummary;
}

void main() {
  const brandSort = AdaptiveSortStrategy<BrandEntity>(
    smallListStrategy: BubbleSortStrategy<BrandEntity>(),
    largeListStrategy: ShellSortStrategy<BrandEntity>(),
  );
  const groupSort = AdaptiveSortStrategy<ModelGroupEntity>(
    smallListStrategy: BubbleSortStrategy<ModelGroupEntity>(),
    largeListStrategy: ShellSortStrategy<ModelGroupEntity>(),
  );
  final usRepository = _UsCatalogRepository();
  final mxRepository = _MxRepository();
  final getMxModelGroups = GetMxModelGroupsUseCase(
    repository: mxRepository,
    grouper: const MxModelGrouper(),
  );
  late Market market;
  Market currentMarket() => market;

  setUp(() => market = Market.unitedStates);

  final years = MarketGetAvailableYearsUseCase(
    repository: usRepository,
    unitedStates: GetAvailableYearsUseCase(usRepository),
    getMxYears: GetMxYearsUseCase(mxRepository),
    currentMarket: currentMarket,
  );
  final brands = MarketGetBrandsUseCase(
    unitedStates: GetBrandsUseCase(
      repository: usRepository,
      sortStrategy: brandSort,
    ),
    getMxBrands: GetMxBrandsUseCase(mxRepository),
    currentMarket: currentMarket,
  );
  final groups = MarketGetModelGroupsUseCase(
    unitedStates: GetModelGroupsUseCase(
      repository: usRepository,
      grouper: const ModelGrouper(sortStrategy: groupSort),
    ),
    getMxModelGroups: getMxModelGroups,
    currentMarket: currentMarket,
  );
  final summary = MarketResolveGroupSummaryUseCase(
    unitedStates: _UsSummary(),
    getMxVersions: GetMxVersionsUseCase(getMxModelGroups),
    summaryBuilder: const MxGroupSummaryBuilder(),
    currentMarket: currentMarket,
  );

  group('delegación por mercado', () {
    test('años: EE. UU. y México', () async {
      expect(await years(), [2025, 2024]);
      market = Market.mexico;
      expect(await years(), [2026, 2025]);
    });

    test('marcas: las de cada catálogo, ordenadas por nombre', () async {
      expect([for (final b in await brands(2025)) b.name], ['Audi', 'Toyota']);
      market = Market.mexico;
      expect(
        [for (final b in await brands(2025)) b.name],
        ['Audi', 'Chevrolet'],
      );
    });

    test('grupos: México usa MxModelGrouper con sus versiones', () async {
      expect([
        for (final g in await groups(2025, 'Toyota')) g.name,
      ], containsAll(['Camry', 'Corolla']));
      market = Market.mexico;
      final result = await groups(2025, 'Chevrolet');
      expect([for (final g in result) g.name], ['AVEO', 'ONIX']);
      expect(
        [for (final v in result.first.variants) v.name],
        ['AVEO', 'AVEO LT'],
      );
    });

    test('resumen: EE. UU. delega; México lo arma con sus versiones', () async {
      expect(
        await summary(
          year: 2025,
          brand: 'Chevrolet',
          groupName: 'AVEO',
          variantNames: const [],
        ),
        _usSummary,
      );
      market = Market.mexico;
      final mx = await summary(
        year: 2025,
        brand: 'Chevrolet',
        groupName: 'AVEO',
        variantNames: const [],
      );
      expect(mx!.vehicleClass, isNull);
      expect(mx.variantCount, 2);
    });

    test('resumen de México de un grupo inexistente es nulo', () async {
      market = Market.mexico;
      expect(
        await summary(
          year: 2025,
          brand: 'Chevrolet',
          groupName: 'NADA',
          variantNames: const [],
        ),
        isNull,
      );
    });

    test('México sin años lanza ParsingFailure', () async {
      market = Market.mexico;
      final empty = MarketGetAvailableYearsUseCase(
        repository: usRepository,
        unitedStates: GetAvailableYearsUseCase(usRepository),
        getMxYears: GetMxYearsUseCase(_EmptyMxRepository()),
        currentMarket: currentMarket,
      );
      expect(empty(), throwsA(isA<ParsingFailure>()));
    });
  });

  group('claves de caché', () {
    test('la clave de resumen incluye el mercado', () {
      const builder = MarketSummaryKeyBuilder(_currentOf);
      final us = builder.build(brand: 'Audi', groupName: 'A3', year: 2025);
      _current = Market.mexico;
      final mx = builder.build(brand: 'Audi', groupName: 'A3', year: 2025);
      _current = Market.unitedStates;
      expect(us, isNot(mx));
      expect(us.startsWith('us|'), isTrue);
      expect(mx.startsWith('mx|'), isTrue);
    });

    test(
      'la clave de foto no depende del mercado y sí de marca/modelo/año',
      () {
        const builder = PhotoKeyBuilder(selector: PhotoCandidateSelector());
        final base = builder.build(
          brand: 'Chevrolet',
          modelName: 'Aveo',
          year: 2025,
        );
        expect(
          builder.build(brand: 'Chevrolet', modelName: 'Aveo', year: 2025),
          base,
        );
        expect(
          builder.build(brand: 'Chevrolet', modelName: 'Aveo', year: 2024),
          isNot(base),
        );
        expect(
          builder.build(brand: 'Chevrolet', modelName: 'Onix', year: 2025),
          isNot(base),
        );
      },
    );
  });
}

class _EmptyMxRepository extends _MxRepository {
  @override
  Future<List<int>> fetchYears() async => const [];
}

Market _current = Market.unitedStates;

Market _currentOf() => _current;
