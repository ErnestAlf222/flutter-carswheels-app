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
  int? Function()? preferredYear,
}) => CatalogCubit(
  minimumLoadingTime: minimumLoadingTime,
  preferredYear: preferredYear,
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
  group('reloadForMarket: recarga en el lugar', () {
    const usBrands = [BrandEntity(name: 'Acura'), BrandEntity(name: 'Buick')];

    Future<CatalogCubit> loadedCubit(
      _FakeCatalogRepository repository, {
      int? Function()? preferredYear,
    }) async {
      final cubit = _cubit(repository, preferredYear: preferredYear);
      await cubit.loadBrands();
      return cubit;
    }

    test('emite Loaded recargando, nunca Loading, y termina cargado', () async {
      final repository = _FakeCatalogRepository(
        years: [2026],
        brandsByYear: {2026: usBrands},
      );
      final cubit = await loadedCubit(repository);
      final states = <CatalogState>[];
      final subscription = cubit.stream.listen(states.add);
      await cubit.reloadForMarket();
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();
      expect(states.first, isA<CatalogLoaded>());
      expect((states.first as CatalogLoaded).isReloading, isTrue);
      expect(states.whereType<CatalogLoading>(), isEmpty);
      expect((states.last as CatalogLoaded).isReloading, isFalse);
      await cubit.close();
    });

    test('conserva la marca elegida si existe en el mercado nuevo', () async {
      final repository = _FakeCatalogRepository(
        years: [2026],
        brandsByYear: {2026: usBrands},
      );
      final cubit = await loadedCubit(repository);
      cubit.selectBrand(1);
      await cubit.reloadForMarket();
      final state = cubit.state as CatalogLoaded;
      expect(state.brands[state.selectedIndex].name, 'Buick');
      await cubit.close();
    });

    test('elige la primera marca si la elegida no existe', () async {
      final brandsByYear = {2026: usBrands};
      final cubit = await loadedCubit(
        _FakeCatalogRepository(years: [2026], brandsByYear: brandsByYear),
      );
      cubit.selectBrand(1);
      brandsByYear[2026] = const [
        BrandEntity(name: 'Chevrolet'),
        BrandEntity(name: 'Dodge'),
      ];
      await cubit.reloadForMarket();
      final state = cubit.state as CatalogLoaded;
      expect(state.selectedIndex, 0);
      expect(state.brands.first.name, 'Chevrolet');
      await cubit.close();
    });

    test('un fallo termina en error y no deja la recarga colgada', () async {
      final repository = _FakeCatalogRepository(
        years: [2026],
        brandsByYear: {2026: usBrands},
      );
      final cubit = await loadedCubit(repository);
      repository.error = const NetworkFailure('sin red');
      await cubit.reloadForMarket();
      expect(cubit.state, isA<CatalogError>());
      await cubit.close();
    });

    test('mientras recarga ignora el cambio de año y de marca', () async {
      final repository = _FakeCatalogRepository(
        years: [2026, 2025],
        brandsByYear: {2026: usBrands, 2025: usBrands},
      );
      final cubit = await loadedCubit(repository);
      final pending = cubit.reloadForMarket();
      cubit.selectBrand(1);
      await cubit.selectYear(2025);
      await pending;
      final state = cubit.state as CatalogLoaded;
      expect(state.year, 2026);
      expect(state.selectedIndex, 0);
      await cubit.close();
    });
  });

  group('año preferido y recarga forzada (cambio de mercado)', () {
    test('arranca en el año preferido si existe', () async {
      final cubit = _cubit(
        _FakeCatalogRepository(years: [2026, 2025]),
        preferredYear: () => 2025,
      );
      await cubit.loadBrands();
      expect((cubit.state as CatalogLoaded).year, 2025);
      await cubit.close();
    });

    test('si el año preferido no existe usa el más reciente', () async {
      final cubit = _cubit(
        _FakeCatalogRepository(years: [2026, 2025]),
        preferredYear: () => 2019,
      );
      await cubit.loadBrands();
      expect((cubit.state as CatalogLoaded).year, 2026);
      await cubit.close();
    });

    test('force reemplaza una carga en curso y gana la última', () async {
      int? preferred;
      final cubit = _cubit(
        _FakeCatalogRepository(years: [2026, 2025]),
        preferredYear: () => preferred,
      );
      final first = cubit.loadBrands();
      preferred = 2025;
      final second = cubit.loadBrands(force: true);
      await Future.wait([first, second]);
      expect((cubit.state as CatalogLoaded).year, 2025);
      await cubit.close();
    });

    test('sin force, una carga en curso ignora la segunda', () async {
      final repository = _FakeCatalogRepository(years: [2026]);
      final cubit = _cubit(repository);
      final first = cubit.loadBrands();
      await cubit.loadBrands();
      await first;
      expect(repository.yearCalls, 1);
      await cubit.close();
    });
  });

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
    'showBrandsFrom mueve el inicio de la ventana y da la vuelta',
    build: () => _cubit(_FakeCatalogRepository(years: [2026])),
    act: (cubit) async {
      await cubit.loadBrands();
      cubit.showBrandsFrom(1);
      // Sin cambio: no emite.
      cubit.showBrandsFrom(1);
      // Pasada la última marca vuelve a la primera.
      cubit.showBrandsFrom(2);
      cubit.showBrandsFrom(-1);
    },
    skip: 2,
    expect: () => [
      isA<CatalogLoaded>().having((s) => s.windowStart, 'windowStart', 1),
      isA<CatalogLoaded>().having((s) => s.windowStart, 'windowStart', 0),
      isA<CatalogLoaded>().having((s) => s.windowStart, 'windowStart', 1),
    ],
  );

  test('la ventana no se mueve si aún no hay marcas cargadas', () async {
    final cubit = _cubit(_FakeCatalogRepository(years: [2026]));
    cubit.showBrandsFrom(1);
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
      'selectYear mantiene marcas y selección mientras refresca y luego '
      'emite el año nuevo conservando la marca por nombre',
      build: build,
      act: (cubit) async {
        await cubit.loadBrands();
        cubit.selectBrand(1);
        await cubit.selectYear(2025);
      },
      skip: 3,
      expect: () => [
        isA<CatalogLoaded>()
            .having((s) => s.isRefreshing, 'isRefreshing', true)
            .having((s) => s.year, 'year', 2026)
            .having((s) => s.brands.length, 'brands', 3)
            .having((s) => s.selectedIndex, 'selectedIndex', 1),
        isA<CatalogLoaded>()
            .having((s) => s.isRefreshing, 'isRefreshing', false)
            .having((s) => s.year, 'year', 2025)
            .having((s) => s.selectedIndex, 'selectedIndex', 1)
            .having((s) => s.windowStart, 'windowStart', 1)
            .having((s) => s.failedYear, 'failedYear', isNull)
            .having((s) => s.refreshFailure, 'refreshFailure', isNull)
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
      skip: 4,
      expect: () => [
        isA<CatalogLoaded>()
            .having((s) => s.year, 'year', 2024)
            .having((s) => s.selectedIndex, 'selectedIndex', 0)
            .having((s) => s.windowStart, 'windowStart', 0)
            .having((s) => s.isRefreshing, 'isRefreshing', false),
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
      'si falla el cambio de año vuelve al estado anterior con el fallo',
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
      expect: () => [
        isA<CatalogLoaded>().having(
          (s) => s.isRefreshing,
          'isRefreshing',
          true,
        ),
        isA<CatalogLoaded>()
            .having((s) => s.isRefreshing, 'isRefreshing', false)
            .having((s) => s.year, 'year', 2026)
            .having((s) => s.brands.length, 'brands', 1)
            .having((s) => s.failedYear, 'failedYear', 2025)
            .having(
              (s) => s.refreshFailure,
              'refreshFailure',
              const NetworkFailure('sin red'),
            ),
      ],
    );

    test('retry repite la petición del año que falló', () async {
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
      expect((cubit.state as CatalogLoaded).failedYear, 2025);
      repository.failingYears.clear();
      await cubit.retry();
      final loaded = cubit.state as CatalogLoaded;
      expect(loaded.year, 2025);
      expect(loaded.failedYear, isNull);
      expect(loaded.refreshFailure, isNull);
      expect(repository.brandCalls, [2026, 2025, 2025]);
      await cubit.close();
    });

    test('retry desde CatalogError llama a loadBrands', () async {
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

    test('el refresco de año no espera el tiempo mínimo del loader', () async {
      final cubit = _cubit(
        _FakeCatalogRepository(years: [2026, 2025], brandsByYear: brandsByYear),
        minimumLoadingTime: const Duration(milliseconds: 300),
      );
      await cubit.loadBrands();
      final timer = Stopwatch()..start();
      await cubit.selectYear(2025);
      expect(timer.elapsedMilliseconds, lessThan(150));
      expect((cubit.state as CatalogLoaded).year, 2025);
      await cubit.close();
    });
  });
}
