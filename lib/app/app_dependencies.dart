import 'package:dio/dio.dart';
import 'package:isar_community/isar.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';

/// Construye las dependencias de la app en un solo lugar.
class AppDependencies {
  AppDependencies._({
    required this.catalogRepository,
    required this.getAvailableYearsUseCase,
    required this.getBrandsUseCase,
    required this.getModelsUseCase,
    required this.brandLogosRepository,
    required this.getModelPhotoUseCase,
    required this.resolveModelPhotoUseCase,
    required this.commonsQueue,
    required this.closeStorage,
  });

  /// Compone la app con la caché de fotos guardada en la instancia de Isar.
  factory AppDependencies.withIsar(Isar isar) {
    return AppDependencies.create(
      photoCache: IsarPhotoCacheDatasource(isar),
      closeStorage: () => IsarDatabase.close(isar),
    );
  }

  /// Compone la app con clientes reales y la caché de fotos dada.
  factory AppDependencies.create({
    required PhotoCacheDatasource photoCache,
    Future<void> Function()? closeStorage,
  }) {
    final fuelEconomyDio = ApiClientFactory.create(
      baseUrl: ApiConfig.fuelEconomyBaseUrl,
      acceptHeaderValue: NetworkConfig.jsonAcceptHeaderValue,
      userAgent: UserAgentsConfig.fuelEconomyUserAgent,
      sourceLabel: FuelEconomyConfig.fuelEconomySourceLabel,
    );
    final logosDio = ApiClientFactory.create(
      baseUrl: LogosConfig.logosBaseUrl,
      acceptHeaderValue: NetworkConfig.jsonAcceptHeaderValue,
      userAgent: UserAgentsConfig.logosUserAgent,
      sourceLabel: LogosConfig.logosSourceLabel,
    );
    final commonsDio = ApiClientFactory.create(
      baseUrl: ApiConfig.commonsApiUrl,
      acceptHeaderValue: NetworkConfig.jsonAcceptHeaderValue,
      userAgent: UserAgentsConfig.commonsUserAgent,
      sourceLabel: PhotosConfig.commonsSourceLabel,
    );
    return AppDependencies.fromDio(
      fuelEconomyDio,
      logosDio,
      commonsDio,
      photoCache,
      closeStorage: closeStorage,
    );
  }

  /// Compone todo sobre un Dio dado.
  factory AppDependencies.fromDio(
    Dio fuelEconomyDio,
    Dio logosDio,
    Dio commonsDio,
    PhotoCacheDatasource photoCache, {
    Future<void> Function()? closeStorage,
  }) {
    final repository = CatalogRepositoryImpl(
      FuelEconomyCatalogDatasource(fuelEconomyDio),
    );
    const sortStrategy = AdaptiveSortStrategy<BrandEntity>(
      smallListStrategy: BubbleSortStrategy<BrandEntity>(),
      largeListStrategy: ShellSortStrategy<BrandEntity>(),
    );
    const modelSortStrategy = AdaptiveSortStrategy<ModelEntity>(
      smallListStrategy: BubbleSortStrategy<ModelEntity>(),
      largeListStrategy: ShellSortStrategy<ModelEntity>(),
    );
    final getAvailableYears = GetAvailableYearsUseCase(repository);
    final commonsQueue = RateLimitedQueue(
      minInterval: const Duration(
        milliseconds: NetworkConfig.commonsMinIntervalMilliseconds,
      ),
      maxRetries: PhotosConfig.maxRetryAttempts,
    );
    final photosRepository = PhotosRepositoryImpl(
      CommonsPhotosDatasource(dio: commonsDio, queue: commonsQueue),
    );
    final getModelPhoto = GetModelPhotoUseCase(
      repository: photosRepository,
      selector: const PhotoCandidateSelector(),
    );
    return AppDependencies._(
      catalogRepository: repository,
      getAvailableYearsUseCase: getAvailableYears,
      getBrandsUseCase: GetBrandsUseCase(
        repository: repository,
        sortStrategy: sortStrategy,
      ),
      getModelsUseCase: GetModelsUseCase(
        repository: repository,
        sortStrategy: modelSortStrategy,
      ),
      brandLogosRepository: BrandLogosRepositoryImpl(
        BrandLogosCdnDatasource(logosDio),
      ),
      getModelPhotoUseCase: getModelPhoto,
      resolveModelPhotoUseCase: ResolveModelPhotoUseCase(
        cache: photoCache,
        getModelPhoto: getModelPhoto,
        clock: DateTime.now,
      ),
      commonsQueue: commonsQueue,
      closeStorage: closeStorage ?? _noStorageToClose,
    );
  }

  final CatalogRepository catalogRepository;
  final GetAvailableYearsUseCase getAvailableYearsUseCase;
  final GetBrandsUseCase getBrandsUseCase;
  final GetModelsUseCase getModelsUseCase;
  final BrandLogosRepository brandLogosRepository;
  final GetModelPhotoUseCase getModelPhotoUseCase;
  final ResolveModelPhotoUseCase resolveModelPhotoUseCase;
  final RateLimitedQueue commonsQueue;
  final Future<void> Function() closeStorage;

  static Future<void> _noStorageToClose() async {}

  /// Libera los recursos de la composición.
  Future<void> close() async {
    await commonsQueue.close();
    await closeStorage();
  }
}
