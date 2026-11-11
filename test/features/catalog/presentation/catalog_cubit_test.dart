import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCatalogRepository implements CatalogRepository {
  _FakeCatalogRepository({
    this.years = const [],
    this.error,
    this.brandsByYear,
    Set<int> failingYears = const {},
  }) : failingYears = {...failingYears};

  final Set<int> failingYears;
  final List<int> years;
  final Map<int, List<BrandEntity>>? brandsByYear;
  final List<int> brandCalls = [];
  Object? error;
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
    brandCalls.add(year);
    if (failingYears.contains(year)) throw const NetworkFailure('sin red');
    if (brandsByYear != null) return brandsByYear![year] ?? const [];
    return const [BrandEntity(name: 'Zeta'), BrandEntity(name: 'Alfa')];
  }

  @override
  Future<List<ModelEntity>> fetchModels(int year, String brand) async =>
      const [];
}

CatalogCubit _cubit(
  _FakeCatalogRepository repository, {
  Duration minimumLoadingTime = Duration.zero,
}) => CatalogCubit(
  minimumLoadingTime: minimumLoadingTime,
  getAvailableYears: GetAvailableYearsUseCase(repository),
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
        availableYears: [2027, 2024, 2020],
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
        availableYears: [2026],
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

  group('años', () {
    const brandsByYear = {
      2026: [
        BrandEntity(name: 'Alfa'),
        BrandEntity(name: 'Éclair'),
        BrandEntity(name: 'Zeta'),
      ],
      2025: [
        BrandEntity(name: 'Alfa'),
        BrandEntity(name: 'ECLAIR'),
        BrandEntity(name: 'Zeta'),
      ],
      2024: [BrandEntity(name: 'Otra'), BrandEntity(name: 'Zeta')],
    };

    CatalogCubit build() => _cubit(
      _FakeCatalogRepository(
        years: [2024, 2026, 2025],
        brandsByYear: brandsByYear,
      ),
    );

    blocTest<CatalogCubit, CatalogState>(
      'loadBrands guarda los años descendentes y elige el más alto',
      build: build,
      act: (cubit) => cubit.loadBrands(),
      verify: (cubit) {
        final loaded = cubit.state as CatalogLoaded;
        expect(loaded.availableYears, [2026, 2025, 2024]);
        expect(loaded.year, 2026);
      },
    );

    blocTest<CatalogCubit, CatalogState>(
      'selectYear recarga las marcas y conserva la marca por nombre',
      build: build,
      act: (cubit) async {
        await cubit.loadBrands();
        cubit.selectBrand(1);
        await cubit.selectYear(2025);
      },
      skip: 3,
      expect: () => [
        const CatalogLoading(),
        isA<CatalogLoaded>()
            .having((s) => s.year, 'year', 2025)
            .having((s) => s.selectedIndex, 'selectedIndex', 1)
            .having((s) => s.windowStart, 'windowStart', 1)
            .having((s) => s.availableYears, 'availableYears', [
              2026,
              2025,
              2024,
            ]),
      ],
    );

    blocTest<CatalogCubit, CatalogState>(
      'selectYear selecciona la primera si la marca no existe en ese año',
      build: build,
      act: (cubit) async {
        await cubit.loadBrands();
        cubit.selectBrand(1);
        await cubit.selectYear(2024);
      },
      skip: 3,
      expect: () => [
        const CatalogLoading(),
        isA<CatalogLoaded>()
            .having((s) => s.year, 'year', 2024)
            .having((s) => s.selectedIndex, 'selectedIndex', 0)
            .having((s) => s.windowStart, 'windowStart', 0),
      ],
    );

    blocTest<CatalogCubit, CatalogState>(
      'selectYear con un año inválido o el actual no hace nada',
      build: build,
      act: (cubit) async {
        await cubit.loadBrands();
        await cubit.selectYear(1999);
        await cubit.selectYear(2026);
      },
      skip: 2,
      expect: () => const <CatalogState>[],
    );

    test('selectYear antes de cargar no hace nada', () async {
      final cubit = build();
      await cubit.selectYear(2025);
      expect(cubit.state, const CatalogInitial());
      await cubit.close();
    });

    blocTest<CatalogCubit, CatalogState>(
      'selectYear emite error si falla la carga de marcas',
      build: () => _cubit(
        _FakeCatalogRepository(
          years: [2026, 2025],
          brandsByYear: {
            2026: [const BrandEntity(name: 'Alfa')],
          },
          failingYears: {2025},
        ),
      ),
      act: (cubit) async {
        await cubit.loadBrands();
        await cubit.selectYear(2025);
      },
      skip: 2,
      expect: () => const [
        CatalogLoading(),
        CatalogError(NetworkFailure('sin red'), failedYear: 2025),
      ],
    );

    test('retry repite el año que falló aunque venga de un error', () async {
      final repository = _FakeCatalogRepository(
        years: [2026, 2025],
        brandsByYear: {
          2026: [const BrandEntity(name: 'Alfa')],
          2025: [const BrandEntity(name: 'Alfa')],
        },
        failingYears: {2025},
      );
      final cubit = _cubit(repository);
      await cubit.loadBrands();
      await cubit.selectYear(2025);
      expect(cubit.state, isA<CatalogError>());
      repository.failingYears.clear();
      await cubit.retry();
      expect(cubit.state, isA<CatalogLoaded>());
      expect((cubit.state as CatalogLoaded).year, 2025);
      await cubit.close();
    });

    test('retry sin año fallido vuelve a llamar a loadBrands', () async {
      final repository = _FakeCatalogRepository(
        years: [2026],
        error: const NetworkFailure('sin red'),
      );
      final cubit = _cubit(repository);
      await cubit.loadBrands();
      expect(cubit.state, const CatalogError(NetworkFailure('sin red')));
      repository.error = null;
      await cubit.retry();
      expect(cubit.state, isA<CatalogLoaded>());
      expect(repository.yearCalls, 2);
      await cubit.close();
    });

    test('retry fuera de un estado de error no hace nada', () async {
      final repository = _FakeCatalogRepository(years: [2026]);
      final cubit = _cubit(repository);
      await cubit.retry();
      expect(cubit.state, const CatalogInitial());
      expect(repository.yearCalls, 0);
      await cubit.close();
    });

    blocTest<CatalogCubit, CatalogState>(
      'showOlderYear va al año anterior y se detiene en el más antiguo',
      build: build,
      act: (cubit) async {
        await cubit.loadBrands();
        await cubit.showOlderYear();
        await cubit.showOlderYear();
        await cubit.showOlderYear();
      },
      skip: 2,
      expect: () => [
        const CatalogLoading(),
        isA<CatalogLoaded>().having((s) => s.year, 'year', 2025),
        const CatalogLoading(),
        isA<CatalogLoaded>().having((s) => s.year, 'year', 2024),
      ],
    );

    blocTest<CatalogCubit, CatalogState>(
      'showNewerYear va al año siguiente y se detiene en el más reciente',
      build: build,
      act: (cubit) async {
        await cubit.loadBrands();
        await cubit.showNewerYear();
        await cubit.selectYear(2024);
        await cubit.showNewerYear();
        await cubit.showNewerYear();
        await cubit.showNewerYear();
      },
      skip: 4,
      expect: () => [
        const CatalogLoading(),
        isA<CatalogLoaded>().having((s) => s.year, 'year', 2025),
        const CatalogLoading(),
        isA<CatalogLoaded>().having((s) => s.year, 'year', 2026),
      ],
    );

    test('los cambios de año no hacen nada antes de cargar', () async {
      final cubit = build();
      await cubit.showNewerYear();
      await cubit.showOlderYear();
      expect(cubit.state, const CatalogInitial());
      await cubit.close();
    });
  });
}
