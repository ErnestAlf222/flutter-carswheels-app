import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';

/// Construye las dependencias de la app en un solo lugar.
class AppDependencies {
  AppDependencies._({
    required this.catalogRepository,
    required this.getAvailableYearsUseCase,
    required this.getBrandsUseCase,
    required this.getModelGroupsUseCase,
    required this.brandLogosRepository,
    required this.getModelPhotoUseCase,
    required this.resolveModelPhotoUseCase,
    required this.cancelPendingPhotosUseCase,
    required this.photoKeyBuilder,
    required this.getGroupSummaryUseCase,
    required this.resolveGroupSummaryUseCase,
    required this.cancelPendingSummariesUseCase,
    required this.getGroupOptionsUseCase,
    required this.resolveVehicleDetailUseCase,
    required this.vehicleClassTranslator,
    required this.commonsQueue,
    required this.fuelEconomyQueue,
    required this.closeStorage,
  });

  /// Compone la app con la caché de fotos guardada en la instancia de Isar.
  factory AppDependencies.withIsar(Isar isar) {
    return AppDependencies.create(
      photoCache: IsarPhotoCacheDatasource(isar),
      summaryCache: IsarSummaryCacheDatasource(isar),
      detailCache: IsarVehicleDetailCacheDatasource(isar),
      closeStorage: () => IsarDatabase.close(isar),
    );
  }

  /// Compone la app con clientes reales y la caché de fotos dada.
  factory AppDependencies.create({
    required PhotoCacheDatasource photoCache,
    required SummaryCacheDatasource summaryCache,
    required VehicleDetailCacheDatasource detailCache,
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
      summaryCache,
      detailCache,
      closeStorage: closeStorage,
    );
  }

  /// Compone todo sobre un Dio dado.
  factory AppDependencies.fromDio(
    Dio fuelEconomyDio,
    Dio logosDio,
    Dio commonsDio,
    PhotoCacheDatasource photoCache,
    SummaryCacheDatasource summaryCache,
    VehicleDetailCacheDatasource detailCache, {
    Future<void> Function()? closeStorage,
  }) {
    final repository = CatalogRepositoryImpl(
      FuelEconomyCatalogDatasource(fuelEconomyDio),
    );
    const sortStrategy = AdaptiveSortStrategy<BrandEntity>(
      smallListStrategy: BubbleSortStrategy<BrandEntity>(),
      largeListStrategy: ShellSortStrategy<BrandEntity>(),
    );
    const groupSortStrategy = AdaptiveSortStrategy<ModelGroupEntity>(
      smallListStrategy: BubbleSortStrategy<ModelGroupEntity>(),
      largeListStrategy: ShellSortStrategy<ModelGroupEntity>(),
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
      commonsQueue,
    );
    const photoKeyBuilder = PhotoKeyBuilder(selector: PhotoCandidateSelector());
    final getModelPhoto = GetModelPhotoUseCase(
      repository: photosRepository,
      selector: const PhotoCandidateSelector(),
    );
    final fuelEconomyQueue = ConcurrencyLimitedQueue(
      maxConcurrent: NetworkConfig.maxConcurrentRequests,
    );
    final vehicleSpecsRepository = VehicleSpecsRepositoryImpl(
      datasource: FuelEconomyVehicleSpecsDatasource(
        dio: fuelEconomyDio,
        queue: fuelEconomyQueue,
      ),
      queue: fuelEconomyQueue,
    );
    final getGroupSummary = GetGroupSummaryUseCase(vehicleSpecsRepository);
    return AppDependencies._(
      catalogRepository: repository,
      getAvailableYearsUseCase: getAvailableYears,
      getBrandsUseCase: GetBrandsUseCase(
        repository: repository,
        sortStrategy: sortStrategy,
      ),
      getModelGroupsUseCase: GetModelGroupsUseCase(
        repository: repository,
        grouper: const ModelGrouper(sortStrategy: groupSortStrategy),
      ),
      brandLogosRepository: BrandLogosRepositoryImpl(
        BrandLogosCdnDatasource(logosDio),
      ),
      getModelPhotoUseCase: getModelPhoto,
      resolveModelPhotoUseCase: ResolveModelPhotoUseCase(
        cache: photoCache,
        getModelPhoto: getModelPhoto,
        keyBuilder: photoKeyBuilder,
        clock: DateTime.now,
      ),
      cancelPendingPhotosUseCase: CancelPendingPhotosUseCase(photosRepository),
      photoKeyBuilder: photoKeyBuilder,
      getGroupSummaryUseCase: getGroupSummary,
      resolveGroupSummaryUseCase: ResolveGroupSummaryUseCase(
        cache: summaryCache,
        getGroupSummary: getGroupSummary,
        keyBuilder: const SummaryKeyBuilder(),
        clock: DateTime.now,
      ),
      cancelPendingSummariesUseCase: CancelPendingSummariesUseCase(
        vehicleSpecsRepository,
      ),
      getGroupOptionsUseCase: GetGroupOptionsUseCase(vehicleSpecsRepository),
      resolveVehicleDetailUseCase: ResolveVehicleDetailUseCase(
        cache: detailCache,
        repository: vehicleSpecsRepository,
        keyBuilder: const VehicleDetailKeyBuilder(),
        clock: DateTime.now,
      ),
      vehicleClassTranslator: const VehicleClassTranslator(
        onUntranslated: _logUntranslatedClass,
      ),
      commonsQueue: commonsQueue,
      fuelEconomyQueue: fuelEconomyQueue,
      closeStorage: closeStorage ?? _noStorageToClose,
    );
  }

  final CatalogRepository catalogRepository;
  final GetAvailableYearsUseCase getAvailableYearsUseCase;
  final GetBrandsUseCase getBrandsUseCase;
  final GetModelGroupsUseCase getModelGroupsUseCase;
  final BrandLogosRepository brandLogosRepository;
  final GetModelPhotoUseCase getModelPhotoUseCase;
  final ResolveModelPhotoUseCase resolveModelPhotoUseCase;
  final CancelPendingPhotosUseCase cancelPendingPhotosUseCase;
  final PhotoKeyBuilder photoKeyBuilder;
  final GetGroupSummaryUseCase getGroupSummaryUseCase;
  final ResolveGroupSummaryUseCase resolveGroupSummaryUseCase;
  final CancelPendingSummariesUseCase cancelPendingSummariesUseCase;
  final GetGroupOptionsUseCase getGroupOptionsUseCase;
  final ResolveVehicleDetailUseCase resolveVehicleDetailUseCase;
  final VehicleClassTranslator vehicleClassTranslator;
  final RateLimitedQueue commonsQueue;
  final ConcurrencyLimitedQueue fuelEconomyQueue;
  final Future<void> Function() closeStorage;

  static Future<void> _noStorageToClose() async {}

  // Solo en depuración: avisa de una clase de vehículo sin traducción.
  static void _logUntranslatedClass(String originalClass) {
    if (kDebugMode) {
      debugPrint(
        '${VehicleSpecsConfig.untranslatedClassLogPrefix}$originalClass',
      );
    }
  }

  /// Libera los recursos de la composición.
  Future<void> close() async {
    await commonsQueue.close();
    await fuelEconomyQueue.close();
    await closeStorage();
  }
}
