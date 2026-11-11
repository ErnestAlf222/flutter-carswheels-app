import 'dart:async';

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

CatalogCubit _cubit(
  _FakeCatalogRepository repository, {
  Duration minimumLoadingTime = Duration.zero,
}) => CatalogCubit(
  minimumLoadingTime: minimumLoadingTime,
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

  blocTest<CatalogCubit, CatalogState>(
    'selectBrand cambia la marca seleccionada',
    build: () => _cubit(_FakeCatalogRepository(years: [2026])),
    act: (cubit) async {
      await cubit.loadBrands();
      cubit.selectBrand(1);
    },
    skip: 2,
    expect: () => const [
      CatalogLoaded(
        year: 2026,
        brands: [
          BrandEntity(name: 'Alfa'),
          BrandEntity(name: 'Zeta'),
        ],
        selectedIndex: 1,
      ),
    ],
  );

  blocTest<CatalogCubit, CatalogState>(
    'selectBrand ignora índices fuera de rango',
    build: () => _cubit(_FakeCatalogRepository(years: [2026])),
    act: (cubit) async {
      await cubit.loadBrands();
      cubit.selectBrand(5);
      cubit.selectBrand(-1);
    },
    skip: 2,
    expect: () => const <CatalogState>[],
  );

  blocTest<CatalogCubit, CatalogState>(
    'showPreviousBrands en la primera marca pasa a la última',
    build: () => _cubit(_FakeCatalogRepository(years: [2026])),
    act: (cubit) async {
      await cubit.loadBrands();
      cubit.showPreviousBrands();
      cubit.showNextBrands();
    },
    skip: 2,
    expect: () => [
      isA<CatalogLoaded>().having((s) => s.windowStart, 'windowStart', 1),
      isA<CatalogLoaded>().having((s) => s.windowStart, 'windowStart', 0),
    ],
  );

  blocTest<CatalogCubit, CatalogState>(
    'showNextBrands en la última marca pasa a la primera',
    build: () => _cubit(_FakeCatalogRepository(years: [2026])),
    act: (cubit) async {
      await cubit.loadBrands();
      cubit.showNextBrands();
      cubit.showNextBrands();
    },
    skip: 2,
    expect: () => [
      isA<CatalogLoaded>().having((s) => s.windowStart, 'windowStart', 1),
      isA<CatalogLoaded>().having((s) => s.windowStart, 'windowStart', 0),
    ],
  );

  test('la ventana no se mueve si aún no hay marcas cargadas', () async {
    final cubit = _cubit(_FakeCatalogRepository(years: [2026]));
    cubit.showNextBrands();
    cubit.showPreviousBrands();
    cubit.selectBrand(0);
    expect(cubit.state, const CatalogInitial());
    await cubit.close();
  });

  blocTest<CatalogCubit, CatalogState>(
    'el tiempo mínimo del loader retrasa el estado loaded',
    build: () => _cubit(
      _FakeCatalogRepository(years: [2026]),
      minimumLoadingTime: const Duration(milliseconds: 300),
    ),
    act: (cubit) => unawaited(cubit.loadBrands()),
    wait: const Duration(milliseconds: 100),
    expect: () => const [CatalogLoading()],
  );

  blocTest<CatalogCubit, CatalogState>(
    'tras el tiempo mínimo emite loaded',
    build: () => _cubit(
      _FakeCatalogRepository(years: [2026]),
      minimumLoadingTime: const Duration(milliseconds: 200),
    ),
    act: (cubit) => unawaited(cubit.loadBrands()),
    wait: const Duration(milliseconds: 400),
    expect: () => [const CatalogLoading(), isA<CatalogLoaded>()],
  );

  blocTest<CatalogCubit, CatalogState>(
    'el error también espera el tiempo mínimo del loader',
    build: () => _cubit(
      _FakeCatalogRepository(error: const NetworkFailure('sin red')),
      minimumLoadingTime: const Duration(milliseconds: 300),
    ),
    act: (cubit) => unawaited(cubit.loadBrands()),
    wait: const Duration(milliseconds: 100),
    expect: () => const [CatalogLoading()],
  );
}
