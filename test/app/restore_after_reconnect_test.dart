import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockResolvePhoto extends Mock implements ResolveModelPhotoUseCase {}

class _MockCancelPhotos extends Mock implements CancelPendingPhotosUseCase {}

class _MockResolveSummary extends Mock implements ResolveGroupSummaryUseCase {}

class _MockCancelSummaries extends Mock
    implements CancelPendingSummariesUseCase {}

class _MockRepository extends Mock implements VehicleSpecsRepository {}

class _FlakyCatalogRepository implements CatalogRepository {
  bool offline = true;
  int yearCalls = 0;

  @override
  Future<List<int>> fetchYears() async {
    yearCalls++;
    if (offline) throw const NetworkFailure('sin red');
    return [2025];
  }

  @override
  Future<List<BrandEntity>> fetchBrands(int year) async {
    if (offline) throw const NetworkFailure('sin red');
    return const [BrandEntity(name: 'Toyota')];
  }

  @override
  Future<List<ModelEntity>> fetchModels(int year, String brand) async =>
      const [];
}

class _MemoryOptionsCache implements GroupOptionsCacheDatasource {
  final Map<String, List<VehicleOptionEntity>> saved = {};

  @override
  Future<List<VehicleOptionEntity>?> read(String key) async => saved[key];

  @override
  Future<void> write(String key, List<VehicleOptionEntity> options) async =>
      saved[key] = options;
}

PhotoEntity _photo() => const PhotoEntity(
  thumbnailUrl: 'https://ejemplo.test/a.jpg',
  authorName: 'Ana',
  licenseName: 'CC BY',
  sourceUrl: 'https://ejemplo.test/o',
  isReference: false,
);

void main() {
  setUpAll(() {
    registerFallbackValue(const <String>[]);
  });

  group('CatalogCubit.restoreAfterReconnect', () {
    CatalogCubit build(_FlakyCatalogRepository repository) => CatalogCubit(
      minimumLoadingTime: Duration.zero,
      getAvailableYears: GetAvailableYearsUseCase(repository),
      getBrands: GetBrandsUseCase(
        repository: repository,
        sortStrategy: const AdaptiveSortStrategy<BrandEntity>(
          smallListStrategy: BubbleSortStrategy<BrandEntity>(),
          largeListStrategy: ShellSortStrategy<BrandEntity>(),
        ),
      ),
    );

    test(
      'recarga el error sin pasar por el loader de pantalla completa',
      () async {
        final repository = _FlakyCatalogRepository();
        final cubit = build(repository);
        await cubit.loadBrands();
        expect(cubit.state, isA<CatalogError>());
        final states = <CatalogState>[];
        final subscription = cubit.stream.listen(states.add);
        repository.offline = false;
        await cubit.restoreAfterReconnect();
        await Future<void>.delayed(Duration.zero);
        expect(states.whereType<CatalogLoading>(), isEmpty);
        expect(cubit.state, isA<CatalogLoaded>());
        await subscription.cancel();
        await cubit.close();
      },
    );

    test('si sigue sin red conserva el error y no hace ruido', () async {
      final repository = _FlakyCatalogRepository();
      final cubit = build(repository);
      await cubit.loadBrands();
      final states = <CatalogState>[];
      final subscription = cubit.stream.listen(states.add);
      await cubit.restoreAfterReconnect();
      await Future<void>.delayed(Duration.zero);
      expect(states, isEmpty);
      expect(cubit.state, isA<CatalogError>());
      await subscription.cancel();
      await cubit.close();
    });

    test('con el catálogo cargado no pide nada', () async {
      final repository = _FlakyCatalogRepository()..offline = false;
      final cubit = build(repository);
      await cubit.loadBrands();
      final calls = repository.yearCalls;
      await cubit.restoreAfterReconnect();
      expect(repository.yearCalls, calls);
      await cubit.close();
    });
  });

  group('PhotosCubit.restoreAfterReconnect', () {
    late _MockResolvePhoto resolve;
    late PhotosCubit cubit;

    PhotoRequest request(String model) =>
        PhotoRequest(brand: 'Toyota', model: model, year: 2025);

    setUp(() {
      resolve = _MockResolvePhoto();
      cubit = PhotosCubit(
        resolveModelPhoto: resolve,
        cancelPendingPhotos: _MockCancelPhotos(),
        keyBuilder: const PhotoKeyBuilder(selector: PhotoCandidateSelector()),
      );
    });

    tearDown(() => cubit.close());

    void stub(String model, Future<PhotoEntity?> Function() answer) =>
        when(() => resolve(brand: 'Toyota', modelName: model, year: 2025))
            .thenAnswer((_) => answer());

    test(
      'repone una sola vez las fotos que fallaron por falta de red',
      () async {
        bool online = false;
        stub('Camry', () async {
          if (!online) throw const NetworkFailure('sin red');
          return _photo();
        });
        cubit.requestPhotos([request('Camry')]);
        await Future<void>.delayed(Duration.zero);
        expect(cubit.state.slots.values.single, isA<PhotoFailed>());
        online = true;
        cubit.restoreAfterReconnect();
        await Future<void>.delayed(Duration.zero);
        expect(cubit.state.slots.values.single, isA<PhotoFound>());
        // Ya repuesta: otra restauración no vuelve a pedir nada.
        clearInteractions(resolve);
        cubit.restoreAfterReconnect();
        verifyNever(
          () => resolve(
            brand: any(named: 'brand'),
            modelName: any(named: 'modelName'),
            year: any(named: 'year'),
          ),
        );
      },
    );

    test('las fotos sin resultado ("sin foto") no se reintentan', () async {
      stub('Camry', () async => null);
      cubit.requestPhotos([request('Camry')]);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.slots.values.single, isA<PhotoMissing>());
      clearInteractions(resolve);
      cubit.restoreAfterReconnect();
      verifyNever(
        () => resolve(
          brand: any(named: 'brand'),
          modelName: any(named: 'modelName'),
          year: any(named: 'year'),
        ),
      );
    });

    test('no dispara ráfagas: respeta el tope por restauración', () async {
      final models = [for (final n in List.generate(10, (i) => i)) 'M$n'];
      for (final model in models) {
        stub(model, () async => throw const NetworkFailure('sin red'));
      }
      cubit.requestPhotos([for (final model in models) request(model)]);
      await Future<void>.delayed(Duration.zero);
      clearInteractions(resolve);
      cubit.restoreAfterReconnect(maxItems: 3);
      await Future<void>.delayed(Duration.zero);
      verify(
        () => resolve(
          brand: any(named: 'brand'),
          modelName: any(named: 'modelName'),
          year: any(named: 'year'),
        ),
      ).called(3);
    });
  });

  group('SummariesCubit.restoreAfterReconnect', () {
    test('repone una vez los resúmenes que fallaron', () async {
      final resolve = _MockResolveSummary();
      bool online = false;
      when(
        () => resolve(
          year: any(named: 'year'),
          brand: any(named: 'brand'),
          groupName: any(named: 'groupName'),
          variantNames: any(named: 'variantNames'),
        ),
      ).thenAnswer((_) async {
        if (!online) throw const NetworkFailure('sin red');
        return null;
      });
      final cubit = SummariesCubit(
        resolveGroupSummary: resolve,
        cancelPendingSummaries: _MockCancelSummaries(),
        keyBuilder: const SummaryKeyBuilder(),
      );
      cubit.requestSummaries(const [
        SummaryRequest(
          brand: 'Toyota',
          groupName: 'Camry',
          year: 2025,
          variantNames: ['Camry LE'],
        ),
      ]);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.slots.values.single, isA<SummaryFailed>());
      online = true;
      cubit.restoreAfterReconnect();
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.slots.values.single, isA<SummaryMissing>());
      await cubit.close();
    });
  });

  group('GetGroupOptionsUseCase con caché de versiones', () {
    test('con red guarda las versiones; sin red las usa', () async {
      final repository = _MockRepository();
      final cache = _MemoryOptionsCache();
      final useCase = GetGroupOptionsUseCase(repository, cache: cache);
      const options = [VehicleOptionEntity(id: 7, text: 'Auto 4cyl')];
      when(() => repository.getOptions(2025, 'Toyota', 'Camry'))
          .thenAnswer((_) async => options);
      final online = await useCase(
        year: 2025,
        brand: 'Toyota',
        variantNames: const ['Camry'],
      );
      expect(online.single.option.id, 7);
      expect(cache.saved, hasLength(1));

      when(() => repository.getOptions(2025, 'Toyota', 'Camry'))
          .thenThrow(const NetworkFailure('sin red'));
      final offline = await useCase(
        year: 2025,
        brand: 'Toyota',
        variantNames: const ['Camry'],
      );
      expect(offline.single.option.id, 7);
    });

    test(
      'sin red y sin nada guardado sigue lanzando la falla de red',
      () async {
        final repository = _MockRepository();
        when(() => repository.getOptions(any(), any(), any()))
            .thenThrow(const NetworkFailure('sin red'));
        final useCase = GetGroupOptionsUseCase(
          repository,
          cache: _MemoryOptionsCache(),
        );
        expect(
          useCase(year: 2025, brand: 'Toyota', variantNames: const ['Camry']),
          throwsA(isA<NetworkFailure>()),
        );
      },
    );

    test('un error del servidor no se tapa con lo guardado', () async {
      final repository = _MockRepository();
      final cache = _MemoryOptionsCache()
        ..saved['x'] = const [VehicleOptionEntity(id: 1, text: 't')];
      when(() => repository.getOptions(any(), any(), any()))
          .thenThrow(const ServerFailure('500'));
      final useCase = GetGroupOptionsUseCase(repository, cache: cache);
      expect(
        await useCase(
          year: 2025,
          brand: 'Toyota',
          variantNames: const ['Camry'],
        ),
        isEmpty,
      );
    });
  });
}
