import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import 'package:cars_wheels_app/app/market_catalog/market_get_available_years_usecase.dart';
import 'package:cars_wheels_app/app/market_catalog/market_get_brands_usecase.dart';
import 'package:cars_wheels_app/app/market_catalog/market_get_model_groups_usecase.dart';
import 'package:cars_wheels_app/app/market_catalog/market_load_group_details_usecase.dart';
import 'package:cars_wheels_app/app/market_catalog/market_resolve_group_summary_usecase.dart';
import 'package:cars_wheels_app/app/market_catalog/market_summary_key_builder.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/detail/detail.dart';
import 'package:cars_wheels_app/features/market/market.dart';
import 'package:cars_wheels_app/features/mexico_catalog/mexico_catalog.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:cars_wheels_app/features/safety/safety.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';

/// Construye las dependencias de la app en un solo lugar.
class AppDependencies {
  AppDependencies._({
    required this.marketCubit,
    required this.summaryKeyBuilder,
    required this.catalogRepository,
    required this.getAvailableYearsUseCase,
    required this.getBrandsUseCase,
    required this.getModelGroupsUseCase,
    required this.brandLogosRepository,
    required this.getModelPhotoUseCase,
    required this.resolveModelPhotoUseCase,
    required this.getModelGalleryUseCase,
    required this.resolveModelGalleryUseCase,
    required this.cancelPendingPhotosUseCase,
    required this.photoKeyBuilder,
    required this.getGroupSummaryUseCase,
    required this.resolveGroupSummaryUseCase,
    required this.cancelPendingSummariesUseCase,
    required this.getGroupOptionsUseCase,
    required this.resolveVehicleDetailUseCase,
    required this.vehicleClassTranslator,
    required this.driveLabeler,
    required this.fuelTypeLabeler,
    required this.transmissionLabeler,
    required this.versionDescriptorBuilder,
    required this.defaultVersionSelector,
    required this.loadGroupDetailsUseCase,
    required this.resolveGroupSafetyUseCase,
    required this.getMxYearsUseCase,
    required this.getMxBrandsUseCase,
    required this.getMxModelGroupsUseCase,
    required this.getMxVersionsUseCase,
    required this.commonsQueue,
    required this.fuelEconomyQueue,
    required this.nhtsaQueue,
    required this.conueeQueue,
    required this.closeStorage,
  });

  /// Compone la app con la caché de fotos guardada en la instancia de Isar.
  factory AppDependencies.withIsar(Isar isar) {
    return AppDependencies.create(
      photoCache: IsarPhotoCacheDatasource(isar),
      galleryCache: IsarGalleryCacheDatasource(isar),
      summaryCache: IsarSummaryCacheDatasource(isar),
      detailCache: IsarVehicleDetailCacheDatasource(isar),
      safetyCache: IsarSafetyCacheDatasource(isar),
      mexicoCatalogCache: IsarMexicoCatalogCacheDatasource(isar),
      marketPreference: IsarMarketPreferenceDatasource(isar),
      closeStorage: () => IsarDatabase.close(isar),
    );
  }

  /// Compone la app con clientes reales y la caché de fotos dada.
  factory AppDependencies.create({
    required PhotoCacheDatasource photoCache,
    required GalleryCacheDatasource galleryCache,
    required SummaryCacheDatasource summaryCache,
    required VehicleDetailCacheDatasource detailCache,
    required SafetyCacheDatasource safetyCache,
    required MexicoCatalogCacheDatasource mexicoCatalogCache,
    required MarketPreferenceDatasource marketPreference,
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
    final nhtsaApiDio = ApiClientFactory.create(
      baseUrl: ApiConfig.nhtsaApiBaseUrl,
      acceptHeaderValue: NetworkConfig.jsonAcceptHeaderValue,
      userAgent: UserAgentsConfig.nhtsaUserAgent,
      sourceLabel: SafetyConfig.nhtsaSourceLabel,
    );
    final nhtsaVpicDio = ApiClientFactory.create(
      baseUrl: ApiConfig.nhtsaVpicBaseUrl,
      acceptHeaderValue: NetworkConfig.jsonAcceptHeaderValue,
      userAgent: UserAgentsConfig.nhtsaUserAgent,
      sourceLabel: SafetyConfig.nhtsaSourceLabel,
    );
    final conueeDio = ApiClientFactory.create(
      baseUrl: ApiConfig.conueeApiBaseUrl,
      acceptHeaderValue: NetworkConfig.jsonAcceptHeaderValue,
      userAgent: UserAgentsConfig.conueeUserAgent,
      sourceLabel: ConueeConfig.sourceLabel,
    );
    return AppDependencies.fromDio(
      fuelEconomyDio,
      logosDio,
      commonsDio,
      nhtsaApiDio,
      nhtsaVpicDio,
      conueeDio,
      photoCache,
      galleryCache,
      summaryCache,
      detailCache,
      safetyCache,
      mexicoCatalogCache,
      marketPreference,
      closeStorage: closeStorage,
    );
  }

  /// Compone todo sobre un Dio dado.
  factory AppDependencies.fromDio(
    Dio fuelEconomyDio,
    Dio logosDio,
    Dio commonsDio,
    Dio nhtsaApiDio,
    Dio nhtsaVpicDio,
    Dio conueeDio,
    PhotoCacheDatasource photoCache,
    GalleryCacheDatasource galleryCache,
    SummaryCacheDatasource summaryCache,
    VehicleDetailCacheDatasource detailCache,
    SafetyCacheDatasource safetyCache,
    MexicoCatalogCacheDatasource mexicoCatalogCache,
    MarketPreferenceDatasource marketPreference, {
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
    final getModelGallery = GetModelGalleryUseCase(
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
    final getGroupOptions = GetGroupOptionsUseCase(vehicleSpecsRepository);
    final resolveVehicleDetail = ResolveVehicleDetailUseCase(
      cache: detailCache,
      repository: vehicleSpecsRepository,
      keyBuilder: const VehicleDetailKeyBuilder(),
      clock: DateTime.now,
    );
    // Una sola cola para las dos APIs de NHTSA.
    final nhtsaQueue = ConcurrencyLimitedQueue(
      maxConcurrent: SafetyConfig.maxConcurrentRequests,
    );
    final resolveGroupSafety = ResolveGroupSafetyUseCase(
      cache: safetyCache,
      ratingsRepository: SafetyRatingsRepositoryImpl(
        datasource: NhtsaApiSafetyRatingsDatasource(
          dio: nhtsaApiDio,
          queue: nhtsaQueue,
        ),
      ),
      recallsRepository: RecallsRepositoryImpl(
        NhtsaApiRecallsDatasource(
          apiDio: nhtsaApiDio,
          vpicDio: nhtsaVpicDio,
          queue: nhtsaQueue,
        ),
      ),
      keyBuilder: const SafetyKeyBuilder(),
      clock: DateTime.now,
    );
    final conueeQueue = ConcurrencyLimitedQueue(
      maxConcurrent: ConueeConfig.maxConcurrentRequests,
    );
    final mexicoCatalogRepository = MexicoCatalogRepositoryImpl(
      datasource: ConueeApiDatasource(dio: conueeDio, queue: conueeQueue),
      cache: mexicoCatalogCache,
      clock: DateTime.now,
    );
    final getMxModelGroups = GetMxModelGroupsUseCase(
      repository: mexicoCatalogRepository,
      grouper: const MxModelGrouper(),
    );
    final marketCubit = MarketCubit(preference: marketPreference);
    Market currentMarket() => marketCubit.market;
    final getMxVersions = GetMxVersionsUseCase(getMxModelGroups);
    final resolveGroupSummary = ResolveGroupSummaryUseCase(
      cache: summaryCache,
      getGroupSummary: getGroupSummary,
      keyBuilder: const SummaryKeyBuilder(),
      clock: DateTime.now,
    );
    const transmissionLabeler = TransmissionLabeler(
      onUntranslated: _logUntranslatedText,
    );
    const defaultVersionSelector = DefaultVersionSelector();
    return AppDependencies._(
      marketCubit: marketCubit,
      summaryKeyBuilder: MarketSummaryKeyBuilder(currentMarket),
      catalogRepository: repository,
      getAvailableYearsUseCase: MarketGetAvailableYearsUseCase(
        repository: repository,
        unitedStates: getAvailableYears,
        getMxYears: GetMxYearsUseCase(mexicoCatalogRepository),
        currentMarket: currentMarket,
      ),
      getBrandsUseCase: MarketGetBrandsUseCase(
        unitedStates: GetBrandsUseCase(
          repository: repository,
          sortStrategy: sortStrategy,
        ),
        getMxBrands: GetMxBrandsUseCase(mexicoCatalogRepository),
        currentMarket: currentMarket,
      ),
      getModelGroupsUseCase: MarketGetModelGroupsUseCase(
        unitedStates: GetModelGroupsUseCase(
          repository: repository,
          grouper: const ModelGrouper(sortStrategy: groupSortStrategy),
        ),
        getMxModelGroups: getMxModelGroups,
        currentMarket: currentMarket,
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
      getModelGalleryUseCase: getModelGallery,
      resolveModelGalleryUseCase: ResolveModelGalleryUseCase(
        cache: galleryCache,
        getGallery: getModelGallery,
        keyBuilder: photoKeyBuilder,
        clock: DateTime.now,
      ),
      cancelPendingPhotosUseCase: CancelPendingPhotosUseCase(photosRepository),
      photoKeyBuilder: photoKeyBuilder,
      getGroupSummaryUseCase: getGroupSummary,
      resolveGroupSummaryUseCase: MarketResolveGroupSummaryUseCase(
        unitedStates: resolveGroupSummary,
        getMxVersions: getMxVersions,
        summaryBuilder: const MxGroupSummaryBuilder(),
        currentMarket: currentMarket,
      ),
      cancelPendingSummariesUseCase: CancelPendingSummariesUseCase(
        vehicleSpecsRepository,
      ),
      getGroupOptionsUseCase: getGroupOptions,
      resolveVehicleDetailUseCase: resolveVehicleDetail,
      vehicleClassTranslator: const VehicleClassTranslator(
        onUntranslated: _logUntranslatedClass,
      ),
      driveLabeler: const DriveLabeler(onUntranslated: _logUntranslatedText),
      fuelTypeLabeler: const FuelTypeLabeler(
        onUntranslated: _logUntranslatedText,
      ),
      transmissionLabeler: transmissionLabeler,
      versionDescriptorBuilder: const VersionDescriptorBuilder(
        transmissionLabeler: transmissionLabeler,
      ),
      defaultVersionSelector: defaultVersionSelector,
      loadGroupDetailsUseCase: MarketLoadGroupDetailsUseCase(
        unitedStates: LoadGroupDetailsUseCase(
          getGroupOptions: getGroupOptions,
          resolveVehicleDetail: resolveVehicleDetail,
          defaultVersionSelector: defaultVersionSelector,
        ),
        getMxVersions: getMxVersions,
        detailBuilder: const MxVehicleDetailBuilder(),
        labelDisambiguator: const MxVersionLabelDisambiguator(),
      ),
      resolveGroupSafetyUseCase: resolveGroupSafety,
      getMxYearsUseCase: GetMxYearsUseCase(mexicoCatalogRepository),
      getMxBrandsUseCase: GetMxBrandsUseCase(mexicoCatalogRepository),
      getMxModelGroupsUseCase: getMxModelGroups,
      getMxVersionsUseCase: getMxVersions,
      commonsQueue: commonsQueue,
      fuelEconomyQueue: fuelEconomyQueue,
      nhtsaQueue: nhtsaQueue,
      conueeQueue: conueeQueue,
      closeStorage: closeStorage ?? _noStorageToClose,
    );
  }

  final MarketCubit marketCubit;
  final SummaryKeyBuilder summaryKeyBuilder;
  final CatalogRepository catalogRepository;
  final GetAvailableYearsUseCase getAvailableYearsUseCase;
  final GetBrandsUseCase getBrandsUseCase;
  final GetModelGroupsUseCase getModelGroupsUseCase;
  final BrandLogosRepository brandLogosRepository;
  final GetModelPhotoUseCase getModelPhotoUseCase;
  final ResolveModelPhotoUseCase resolveModelPhotoUseCase;
  final GetModelGalleryUseCase getModelGalleryUseCase;
  final ResolveModelGalleryUseCase resolveModelGalleryUseCase;
  final CancelPendingPhotosUseCase cancelPendingPhotosUseCase;
  final PhotoKeyBuilder photoKeyBuilder;
  final GetGroupSummaryUseCase getGroupSummaryUseCase;
  final ResolveGroupSummaryUseCase resolveGroupSummaryUseCase;
  final CancelPendingSummariesUseCase cancelPendingSummariesUseCase;
  final GetGroupOptionsUseCase getGroupOptionsUseCase;
  final ResolveVehicleDetailUseCase resolveVehicleDetailUseCase;
  final VehicleClassTranslator vehicleClassTranslator;
  final DriveLabeler driveLabeler;
  final FuelTypeLabeler fuelTypeLabeler;
  final TransmissionLabeler transmissionLabeler;
  final VersionDescriptorBuilder versionDescriptorBuilder;
  final DefaultVersionSelector defaultVersionSelector;
  final LoadGroupDetailsUseCase loadGroupDetailsUseCase;
  final ResolveGroupSafetyUseCase resolveGroupSafetyUseCase;
  final GetMxYearsUseCase getMxYearsUseCase;
  final GetMxBrandsUseCase getMxBrandsUseCase;
  final GetMxModelGroupsUseCase getMxModelGroupsUseCase;
  final GetMxVersionsUseCase getMxVersionsUseCase;
  final RateLimitedQueue commonsQueue;
  final ConcurrencyLimitedQueue fuelEconomyQueue;
  final ConcurrencyLimitedQueue nhtsaQueue;
  final ConcurrencyLimitedQueue conueeQueue;
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

  // Solo en depuración: avisa de una tracción, combustible o transmisión sin traducción.
  static void _logUntranslatedText(String original) {
    if (kDebugMode) {
      debugPrint('${VehicleSpecsConfig.untranslatedTextLogPrefix}$original');
    }
  }

  /// Libera los recursos de la composición.
  Future<void> close() async {
    await commonsQueue.close();
    await fuelEconomyQueue.close();
    await nhtsaQueue.close();
    await conueeQueue.close();
    await marketCubit.close();
    await closeStorage();
  }
}
