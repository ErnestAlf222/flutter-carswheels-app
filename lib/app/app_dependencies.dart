import 'package:dio/dio.dart';

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
    required this.commonsQueue,
  });

  factory AppDependencies.create() {
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
    return AppDependencies.fromDio(fuelEconomyDio, logosDio, commonsDio);
  }

  /// Compone todo sobre un Dio dado.
  factory AppDependencies.fromDio(
    Dio fuelEconomyDio,
    Dio logosDio,
    Dio commonsDio,
  ) {
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
      getModelPhotoUseCase: GetModelPhotoUseCase(
        repository: photosRepository,
        selector: const PhotoCandidateSelector(),
      ),
      commonsQueue: commonsQueue,
    );
  }

  final CatalogRepository catalogRepository;
  final GetAvailableYearsUseCase getAvailableYearsUseCase;
  final GetBrandsUseCase getBrandsUseCase;
  final GetModelsUseCase getModelsUseCase;
  final BrandLogosRepository brandLogosRepository;
  final GetModelPhotoUseCase getModelPhotoUseCase;
  final RateLimitedQueue commonsQueue;

  /// Libera los recursos de la composición.
  Future<void> close() => commonsQueue.close();
}
