import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCatalogRepository implements CatalogRepository {
  _FakeCatalogRepository({this.modelCount = 0, this.error});

  final int modelCount;
  final Object? error;

  @override
  Future<List<int>> fetchYears() async => const [];

  @override
  Future<List<BrandEntity>> fetchBrands(int year) async => const [];

  @override
  Future<List<ModelEntity>> fetchModels(int year, String brand) async {
    if (error != null) throw error!;
    return [
      for (int index = 0; index < modelCount; index++)
        ModelEntity(name: 'M${index.toString().padLeft(3, '0')}'),
    ];
  }
}

ModelsCubit _cubit(
  _FakeCatalogRepository repository, {
  Duration minimumLoadingTime = Duration.zero,
}) => ModelsCubit(
  minimumLoadingTime: minimumLoadingTime,
  getModels: GetModelsUseCase(
    repository: repository,
    sortStrategy: const AdaptiveSortStrategy<ModelEntity>(
      smallListStrategy: BubbleSortStrategy<ModelEntity>(),
      largeListStrategy: ShellSortStrategy<ModelEntity>(),
    ),
  ),
);

Matcher _loaded(int total, int visible) => isA<ModelsLoaded>()
    .having((s) => s.models.length, 'total', total)
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
    'loading -> error cuando falla el repositorio',
    build: () =>
        _cubit(_FakeCatalogRepository(error: const NetworkFailure('sin red'))),
    act: (cubit) => cubit.load(2020, 'Honda'),
    expect: () => const [
      ModelsLoading(),
      ModelsError(NetworkFailure('sin red')),
    ],
  );

  blocTest<ModelsCubit, ModelsState>(
    'una excepción no esperada se vuelve UnknownFailure',
    build: () => _cubit(_FakeCatalogRepository(error: StateError('boom'))),
    act: (cubit) => cubit.load(2020, 'Honda'),
    verify: (cubit) {
      final error = cubit.state as ModelsError;
      expect(error.failure, isA<UnknownFailure>());
    },
  );

  blocTest<ModelsCubit, ModelsState>(
    'el tiempo mínimo del loader retrasa el estado loaded',
    build: () => _cubit(
      _FakeCatalogRepository(modelCount: 3),
      minimumLoadingTime: const Duration(milliseconds: 300),
    ),
    act: (cubit) => unawaited(cubit.load(2020, 'Honda')),
    wait: const Duration(milliseconds: 100),
    expect: () => const [ModelsLoading()],
  );

  blocTest<ModelsCubit, ModelsState>(
    'tras el tiempo mínimo emite loaded',
    build: () => _cubit(
      _FakeCatalogRepository(modelCount: 3),
      minimumLoadingTime: const Duration(milliseconds: 200),
    ),
    act: (cubit) => unawaited(cubit.load(2020, 'Honda')),
    wait: const Duration(milliseconds: 400),
    expect: () => [const ModelsLoading(), isA<ModelsLoaded>()],
  );

  blocTest<ModelsCubit, ModelsState>(
    'el error también espera el tiempo mínimo del loader',
    build: () => _cubit(
      _FakeCatalogRepository(error: const NetworkFailure('sin red')),
      minimumLoadingTime: const Duration(milliseconds: 300),
    ),
    act: (cubit) => unawaited(cubit.load(2020, 'Honda')),
    wait: const Duration(milliseconds: 100),
    expect: () => const [ModelsLoading()],
  );
}
