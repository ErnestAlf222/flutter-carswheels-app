import 'package:bloc_test/bloc_test.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCatalogRepository implements CatalogRepository {
  _FakeCatalogRepository({this.modelCount = 0, this.error, this.delay});

  final int modelCount;
  final Duration? delay;
  Object? error;
  final List<(int, String)> calls = [];

  @override
  Future<List<int>> fetchYears() async => const [];

  @override
  Future<List<BrandEntity>> fetchBrands(int year) async => const [];

  @override
  Future<List<ModelEntity>> fetchModels(int year, String brand) async {
    calls.add((year, brand));
    if (delay != null) await Future<void>.delayed(delay!);
    if (error != null) throw error!;
    return [
      for (int index = 0; index < modelCount; index++)
        ModelEntity(name: 'M${index.toString().padLeft(3, '0')}'),
    ];
  }
}

ModelsCubit _cubit(_FakeCatalogRepository repository) => ModelsCubit(
  getModelGroups: GetModelGroupsUseCase(
    repository: repository,
    grouper: const ModelGrouper(
      sortStrategy: AdaptiveSortStrategy<ModelGroupEntity>(
        smallListStrategy: BubbleSortStrategy<ModelGroupEntity>(),
        largeListStrategy: ShellSortStrategy<ModelGroupEntity>(),
      ),
    ),
  ),
);

Matcher _loaded(int total, int visible) => isA<ModelsLoaded>()
    .having((s) => s.groups.length, 'total', total)
    .having((s) => s.visibleCount, 'visibleCount', visible);

void main() {
  const page = CatalogConfig.defaultPageSize;

  blocTest<ModelsCubit, ModelsState>(
    'loading -> loaded con visibleCount igual al tamaño de página',
    build: () => _cubit(_FakeCatalogRepository(modelCount: page * 3)),
    act: (cubit) => cubit.load(2020, 'Honda'),
    expect: () => [const ModelsLoading(), _loaded(page * 3, page)],
  );

  blocTest<ModelsCubit, ModelsState>(
    'el loaded guarda el año y la marca de la consulta',
    build: () => _cubit(_FakeCatalogRepository(modelCount: 3)),
    act: (cubit) => cubit.load(2020, 'Honda'),
    verify: (cubit) {
      final loaded = cubit.state as ModelsLoaded;
      expect(loaded.year, 2020);
      expect(loaded.brand, 'Honda');
      expect(loaded.isRefreshing, isFalse);
      expect(loaded.refreshFailure, isNull);
    },
  );

  blocTest<ModelsCubit, ModelsState>(
    'con menos modelos que una página visibleCount es el total',
    build: () => _cubit(_FakeCatalogRepository(modelCount: 3)),
    act: (cubit) => cubit.load(2020, 'Honda'),
    expect: () => [const ModelsLoading(), _loaded(3, 3)],
    verify: (cubit) => expect(cubit.hasMore, isFalse),
  );

  blocTest<ModelsCubit, ModelsState>(
    'loadMore suma una página y se detiene en el total',
    build: () => _cubit(_FakeCatalogRepository(modelCount: page * 2 + 3)),
    act: (cubit) async {
      await cubit.load(2020, 'Honda');
      cubit.loadMore();
      cubit.loadMore();
      cubit.loadMore();
    },
    skip: 2,
    expect: () => [
      _loaded(page * 2 + 3, page * 2),
      _loaded(page * 2 + 3, page * 2 + 3),
    ],
    verify: (cubit) => expect(cubit.hasMore, isFalse),
  );

  blocTest<ModelsCubit, ModelsState>(
    'hasMore es verdadero mientras queden modelos',
    build: () => _cubit(_FakeCatalogRepository(modelCount: page + 1)),
    act: (cubit) => cubit.load(2020, 'Honda'),
    verify: (cubit) => expect(cubit.hasMore, isTrue),
  );

  test('hasMore es falso antes de cargar y loadMore no emite', () async {
    final cubit = _cubit(_FakeCatalogRepository());
    expect(cubit.hasMore, isFalse);
    cubit.loadMore();
    expect(cubit.state, const ModelsInitial());
    await cubit.close();
  });

  blocTest<ModelsCubit, ModelsState>(
    'loading -> error cuando falla el repositorio sin datos previos',
    build: () =>
        _cubit(_FakeCatalogRepository(error: const NetworkFailure('sin red'))),
    act: (cubit) => cubit.load(2020, 'Honda'),
    expect: () => const [
      ModelsLoading(),
      ModelsError(NetworkFailure('sin red'), year: 2020, brand: 'Honda'),
    ],
  );

  blocTest<ModelsCubit, ModelsState>(
    'misma marca: refresca en el lugar sin pasar por loading',
    build: () => _cubit(_FakeCatalogRepository(modelCount: 3)),
    act: (cubit) async {
      await cubit.load(2020, 'Honda');
      await cubit.load(2021, 'Honda');
    },
    skip: 2,
    expect: () => [
      isA<ModelsLoaded>()
          .having((s) => s.isRefreshing, 'isRefreshing', true)
          .having((s) => s.year, 'year', 2020),
      isA<ModelsLoaded>()
          .having((s) => s.isRefreshing, 'isRefreshing', false)
          .having((s) => s.year, 'year', 2021)
          .having((s) => s.visibleCount, 'visibleCount', 3),
    ],
  );

  blocTest<ModelsCubit, ModelsState>(
    'marca distinta: pasa por loading',
    build: () => _cubit(_FakeCatalogRepository(modelCount: 3)),
    act: (cubit) async {
      await cubit.load(2020, 'Honda');
      await cubit.load(2020, 'Audi');
    },
    skip: 2,
    expect: () => [const ModelsLoading(), _loaded(3, 3)],
  );

  test('un fallo en el refresco conserva la lista y guarda el fallo', () async {
    final repository = _FakeCatalogRepository(modelCount: 3);
    final cubit = _cubit(repository);
    await cubit.load(2020, 'Honda');
    repository.error = const NetworkFailure('sin red');
    await cubit.load(2021, 'Honda');
    final loaded = cubit.state as ModelsLoaded;
    expect(loaded.groups.length, 3);
    expect(loaded.isRefreshing, isFalse);
    expect(loaded.refreshFailure, const NetworkFailure('sin red'));
    expect(loaded.year, 2020);
    expect(loaded.brand, 'Honda');
    expect(
      loaded.failedRequest,
      const ModelsRequest(year: 2021, brand: 'Honda'),
    );
    await cubit.close();
  });

  test('retry tras un refresco fallido repite el año pedido', () async {
    final repository = _FakeCatalogRepository(modelCount: 3);
    final cubit = _cubit(repository);
    await cubit.load(2020, 'Honda');
    repository.error = const NetworkFailure('sin red');
    await cubit.load(2021, 'Honda');
    repository.error = null;
    await cubit.retry();
    final loaded = cubit.state as ModelsLoaded;
    expect(loaded.refreshFailure, isNull);
    expect(loaded.failedRequest, isNull);
    expect(loaded.year, 2021);
    expect(repository.calls.last, (2021, 'Honda'));
    await cubit.close();
  });

  test('retry desde ModelsError repite la consulta', () async {
    final repository = _FakeCatalogRepository(
      modelCount: 3,
      error: const NetworkFailure('sin red'),
    );
    final cubit = _cubit(repository);
    await cubit.load(2020, 'Honda');
    expect(cubit.state, isA<ModelsError>());
    repository.error = null;
    await cubit.retry();
    expect(cubit.state, _loaded(3, 3));
    expect(repository.calls, [(2020, 'Honda'), (2020, 'Honda')]);
    await cubit.close();
  });

  test('retry sin error no hace nada', () async {
    final repository = _FakeCatalogRepository(modelCount: 3);
    final cubit = _cubit(repository);
    await cubit.retry();
    expect(cubit.state, const ModelsInitial());
    await cubit.load(2020, 'Honda');
    await cubit.retry();
    expect(repository.calls, [(2020, 'Honda')]);
    await cubit.close();
  });

  test('loadMore se ignora mientras se refresca', () async {
    final repository = _FakeCatalogRepository(
      modelCount: page * 2,
      delay: const Duration(milliseconds: 50),
    );
    final cubit = _cubit(repository);
    await cubit.load(2020, 'Honda');
    final refresh = cubit.load(2021, 'Honda');
    cubit.loadMore();
    await refresh;
    expect((cubit.state as ModelsLoaded).visibleCount, page);
    await cubit.close();
  });

  blocTest<ModelsCubit, ModelsState>(
    'una excepción no esperada se vuelve UnknownFailure',
    build: () => _cubit(_FakeCatalogRepository(error: StateError('boom'))),
    act: (cubit) => cubit.load(2020, 'Honda'),
    verify: (cubit) {
      final error = cubit.state as ModelsError;
      expect(error.failure, isA<UnknownFailure>());
    },
  );

  test('no espera ningún tiempo mínimo al cargar', () async {
    final cubit = _cubit(_FakeCatalogRepository(modelCount: 3));
    final timer = Stopwatch()..start();
    await cubit.load(2020, 'Honda');
    expect(timer.elapsedMilliseconds, lessThan(100));
    await cubit.close();
  });
}
