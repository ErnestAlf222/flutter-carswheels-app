import 'package:bloc_test/bloc_test.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCatalogRepository implements CatalogRepository {
  _FakeCatalogRepository({this.years = const [], this.error});

  final List<int> years;
  final Object? error;
  int yearCalls = 0;

  @override
  Future<List<int>> fetchYears() async {
    yearCalls++;
    await Future<void>.delayed(Duration.zero);
    if (error != null) throw error!;
    return years;
  }

  @override
  Future<List<BrandEntity>> fetchBrands(int year) async {
    return const [BrandEntity(name: 'Zeta'), BrandEntity(name: 'Alfa')];
  }
}

CatalogCubit _cubit(_FakeCatalogRepository repository) => CatalogCubit(
  getLatestYear: GetLatestYearUseCase(repository),
  getBrands: GetBrandsUseCase(
    repository: repository,
    sortStrategy: const AdaptiveSortStrategy<BrandEntity>(
      smallListStrategy: BubbleSortStrategy<BrandEntity>(),
      largeListStrategy: ShellSortStrategy<BrandEntity>(),
    ),
  ),
);

void main() {
  blocTest<CatalogCubit, CatalogState>(
    'loading -> loaded con el año más alto y marcas ordenadas',
    build: () => _cubit(_FakeCatalogRepository(years: [2020, 2027, 2024])),
    act: (cubit) => cubit.loadBrands(),
    expect: () => const [
      CatalogLoading(),
      CatalogLoaded(
        year: 2027,
        brands: [
          BrandEntity(name: 'Alfa'),
          BrandEntity(name: 'Zeta'),
        ],
      ),
    ],
  );

  blocTest<CatalogCubit, CatalogState>(
    'loading -> error cuando falla el repositorio',
    build: () =>
        _cubit(_FakeCatalogRepository(error: const NetworkFailure('sin red'))),
    act: (cubit) => cubit.loadBrands(),
    expect: () => const [
      CatalogLoading(),
      CatalogError(NetworkFailure('sin red')),
    ],
  );

  blocTest<CatalogCubit, CatalogState>(
    'una excepción no esperada se vuelve UnknownFailure',
    build: () => _cubit(_FakeCatalogRepository(error: StateError('boom'))),
    act: (cubit) => cubit.loadBrands(),
    verify: (cubit) {
      final error = cubit.state as CatalogError;
      expect(error.failure, isA<UnknownFailure>());
    },
  );

  test('no duplica emisiones si ya está cargando', () async {
    final repository = _FakeCatalogRepository(years: [2026]);
    final cubit = _cubit(repository);
    final emitted = <CatalogState>[];
    final subscription = cubit.stream.listen(emitted.add);
    final first = cubit.loadBrands();
    final second = cubit.loadBrands();
    await Future.wait([first, second]);
    await Future<void>.delayed(Duration.zero);
    expect(repository.yearCalls, 1);
    expect(emitted.whereType<CatalogLoading>(), hasLength(1));
    await subscription.cancel();
    await cubit.close();
  });
}
